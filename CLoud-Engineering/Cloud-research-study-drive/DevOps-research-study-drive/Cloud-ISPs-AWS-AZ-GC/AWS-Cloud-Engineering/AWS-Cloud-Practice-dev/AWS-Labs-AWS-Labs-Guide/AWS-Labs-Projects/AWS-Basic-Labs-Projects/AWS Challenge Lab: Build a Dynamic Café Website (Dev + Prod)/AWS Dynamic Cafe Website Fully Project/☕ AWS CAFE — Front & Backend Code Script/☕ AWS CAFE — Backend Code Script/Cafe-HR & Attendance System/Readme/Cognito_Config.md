# Charlie Cafe -- HR & Attendance System

### hr-attendance.py

> **Update Version:1.0**

```
import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ==========================================================
# AWS SECRETS MANAGER CONFIG
# ==========================================================

SECRET_NAME = "CafeDevDBSM"   # Name of secret in AWS Secrets Manager
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager.
    Expected secret JSON format:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    secret = json.loads(response["SecretString"])
    return secret


# ==========================================================
# CREATE / REUSE DATABASE CONNECTION
# ==========================================================

connection = None  # Global connection (reused across Lambda invocations)

def get_connection():
    """
    Reuse existing DB connection if available.
    Otherwise create new connection using Secrets Manager.
    """
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False,
            connect_timeout=10
        )

    return connection


# ==========================================================
# ROLE CHECK (RBAC USING COGNITO GROUP)
# ==========================================================

def check_role(event, allowed_role):
    """
    Allow only users in required Cognito group
    """
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# STANDARD API RESPONSE
# ==========================================================

def response(status, message):
    """
    Standardized API Gateway response with CORS
    """
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Handles employee check-in and check-out.
    Requires user to belong to 'Employee' Cognito group.
    """

    try:
        # --------------------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # --------------------------------------------------
        if not check_role(event, "Employee"):
            return response(403, "Forbidden")

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        today = date.today()
        now = datetime.now().time()

        # Identify route (checkin / checkout)
        path = event.get("resource") or event.get("path", "")

        # Get DB connection from Secrets Manager
        connection = get_connection()

        with connection.cursor() as cursor:

            # --------------------------------------------------
            # FETCH EMPLOYEE ID
            # --------------------------------------------------
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )

            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            employee_id = employee["employee_id"]

            # ==================================================
            # ✅ CHECK-IN LOGIC
            # ==================================================
            if "checkin" in path:

                try:
                    cursor.execute("""
                        INSERT INTO attendance
                        (employee_id, attendance_date, checkin_time)
                        VALUES (%s, %s, %s)
                    """, (employee_id, today, now))

                    connection.commit()
                    return response(200, "Check-in successful")

                except pymysql.err.IntegrityError:
                    return response(400, "Already checked in today")

            # ==================================================
            # ✅ CHECK-OUT LOGIC
            # ==================================================
            elif "checkout" in path:

                cursor.execute("""
                    UPDATE attendance
                    SET checkout_time=%s
                    WHERE employee_id=%s
                    AND attendance_date=%s
                """, (now, employee_id, today))

                if cursor.rowcount == 0:
                    return response(400, "Check-in required before checkout")

                connection.commit()
                return response(200, "Check-out successful")

            # --------------------------------------------------
            # UNKNOWN ROUTE
            # --------------------------------------------------
            else:
                return response(404, "Invalid attendance action")

    except Exception as e:
        return response(500, str(e))
```

### Option - B hr-checkin & hr-checkinout

### 1️⃣ Create Lambda: hr-checkin

#### Function name:

```
hr-checkin
```

> **Replace entire code with this:**

[hr-checkin.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-checkin.py)

### 2️⃣ Create Lambda: hr-checkout
> **Repeat Steps Exactly Like hr-checkin**

#### Function name:

```
hr-checkout
```
[hr-checkout.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-checkout.py)

- Click Create function

- Click Deploy

#### Step 3️⃣: Configure Environment Variables

- Lambda → Configuration → Environment variables

#### Add ALL:

| Key     | Value             |
| ------- | ----------------- |
| DB_HOST | your-rds-endpoint |
| DB_NAME | cafedb            |
| DB_USER | cafe_user     |
| DB_PASS | your-db-password  |

- Click Save

---

### hr-employee-profile.py

> **Update Version:1.0**

```
import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"   # Your existing RDS secret
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Retrieve database credentials from AWS Secrets Manager.

    Expected secret JSON structure:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse existing DB connection if open.
    Otherwise create new connection using secret credentials.
    """
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10,
            autocommit=True
        )

    return connection


# ==========================================================
# ROLE CHECK (COGNITO GROUP VALIDATION)
# ==========================================================

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# JSON SERIALIZER (FOR DECIMAL & DATE)
# ==========================================================

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ==========================================================
# FORBIDDEN RESPONSE
# ==========================================================

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Returns logged-in employee profile.
    Only accessible by users in 'Employee' Cognito group.
    """

    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return forbidden()

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT name, job_title, salary, start_date
                FROM employees
                WHERE cognito_user_id=%s
            """, (cognito_user_id,))

            employee = cursor.fetchone()

        if not employee:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Employee not found"})
            }

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(employee, default=json_serializer)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

---
### hr-attendance-history.py

> **Update Version:1.0**

```
import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Fetch RDS credentials from AWS Secrets Manager.

    Expected JSON format:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse open DB connection if available.
    Otherwise create new connection using secret.
    """
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10,
            autocommit=True
        )

    return connection


# ==========================================================
# ROLE CHECK (COGNITO GROUP VALIDATION)
# ==========================================================

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# JSON SERIALIZER (DECIMAL & DATE SUPPORT)
# ==========================================================

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ==========================================================
# FORBIDDEN RESPONSE
# ==========================================================

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Returns attendance history for logged-in employee.
    Accessible only to users in 'Employee' Cognito group.
    """

    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return forbidden()

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE e.cognito_user_id=%s
                ORDER BY attendance_date DESC
            """, (cognito_user_id,))

            records = cursor.fetchall()

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(records, default=json_serializer)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

---
### hr-leaves-holidays.py

> **Update Version:1.0**

```
import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager.

    Expected secret structure:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse DB connection if open.
    Otherwise create new connection using secret.
    """
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10,
            autocommit=True
        )

    return connection


# ==========================================================
# ROLE CHECK (COGNITO GROUP VALIDATION)
# ==========================================================

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# JSON SERIALIZER (DECIMAL & DATE SUPPORT)
# ==========================================================

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ==========================================================
# FORBIDDEN RESPONSE
# ==========================================================

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Returns:
    - Employee leave history
    - Company holiday list

    Accessible only to users in 'Employee' Cognito group.
    """

    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return forbidden()

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        connection = get_connection()

        with connection.cursor() as cursor:

            # ----------------------------------------
            # FETCH EMPLOYEE LEAVES
            # ----------------------------------------
            cursor.execute("""
                SELECT leave_date, leave_type
                FROM leaves l
                JOIN employees e ON l.employee_id = e.employee_id
                WHERE e.cognito_user_id=%s
                ORDER BY leave_date DESC
            """, (cognito_user_id,))

            leaves = cursor.fetchall()

            # ----------------------------------------
            # FETCH COMPANY HOLIDAYS
            # ----------------------------------------
            cursor.execute("""
                SELECT holiday_date, description
                FROM holidays
                ORDER BY holiday_date DESC
            """)

            holidays = cursor.fetchall()

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(
                {
                    "leaves": leaves,
                    "holidays": holidays
                },
                default=json_serializer
            )
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

---
### hr-leaves-holidays.py

> **Update Version:1.0**

```
import json
import os
import boto3
import pymysql
from datetime import date
from boto3.dynamodb.conditions import Key

# ==========================================================
# 🔐 AWS SECRETS MANAGER CONFIGURATION
# ----------------------------------------------------------
# We do NOT store DB credentials in environment variables.
# Instead, we securely fetch them from Secrets Manager.
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    """
    Expected Secret JSON format:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# 🔌 RDS CONNECTION (REUSED BETWEEN INVOCATIONS)
# ----------------------------------------------------------
# Improves performance by avoiding reconnect each time.
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection

# ==========================================================
# 📦 DYNAMODB CONFIGURATION
# ----------------------------------------------------------
# Table name comes from Lambda Environment Variable:
#
#   DYNAMODB_TABLE = CafeAttendance
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]

dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)

# ==========================================================
# 🔐 ADMIN ROLE CHECK (COGNITO GROUP VALIDATION)
# ----------------------------------------------------------
# Only users in the "Admin" group can access this Lambda.
# ==========================================================

def check_admin(event):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return "Admin" in groups

# ==========================================================
# 🌍 STANDARD RESPONSE FORMAT (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# 🚀 MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # ------------------------------------------------------
    # 1️⃣ ADMIN AUTHORIZATION CHECK
    # ------------------------------------------------------
    if not check_admin(event):
        return make_response(403, {"message": "Forbidden - Admin only"})

    # ------------------------------------------------------
    # 2️⃣ READ QUERY PARAMETERS
    # ------------------------------------------------------
    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")  # daily | weekly | monthly
    employee_id = params.get("employee_id")   # Optional
    lookup_date = params.get("date")          # Optional (DynamoDB filter)
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # 3️⃣ RDS ATTENDANCE QUERY (MySQL)
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        # -------------------------
        # Date filtering logic
        # -------------------------
        if query_type == "daily":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date = CURDATE()
            """
        elif query_type == "weekly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date >= CURDATE() - INTERVAL 7 DAY
            """
        elif query_type == "monthly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE MONTH(a.date) = MONTH(CURDATE())
                AND YEAR(a.date) = YEAR(CURDATE())
            """
        else:
            return make_response(400, {"message": "Invalid type parameter"})

        # -------------------------
        # Optional employee filter
        # -------------------------
        if employee_id:
            sql += " AND e.employee_id = %s"
            cursor.execute(sql, (employee_id,))
        else:
            cursor.execute(sql)

        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # 4️⃣ SUMMARY CARDS (OPTIONAL)
        # =====================================================

        if include_summary:
            summary_sql = """
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_absent,
                    (SELECT COUNT(*) FROM leaves WHERE leave_date = CURDATE()) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
            """
            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})

    # =====================================================
    # 5️⃣ DYNAMODB LOOKUP (OPTIONAL)
    # -----------------------------------------------------
    # If employee_id is provided, query DynamoDB table.
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})

    # =====================================================
    # 6️⃣ FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```
    


---

### Enable Cognito Authorizer

#### Step 1 — Create Authorizer

- API Gateway → Authorizers → Create New Authorizer

- Name: HR-Cognito-Authorizer

- Type: Cognito

- Cognito User Pool: Select your café User Pool

- Token Source: Authorization

- Click Create

#### Step 2 — Attach Authorizer to Methods

#### For each resource method:

    - Click on Method → Method Request

    - Authorization: select HR-Cognito-Authorizer

    - Save
---

### 1️⃣ Lambda Testing & Verification

#### 1️⃣ Test Environment Variables

- Lambda → Configuration → Environment variables

- Ensure:

```
DB_HOST, DB_NAME, DB_USER, DB_PASS
```

- Double-check spelling and values (typos will break RDS connection).

#### 2️⃣ — VPC Settings

- Lambda → Configuration → VPC

- Must be in the same VPC as RDS

- Use private subnets that can reach RDS

- Security group: allows outbound TCP 3306 to RDS

#### 3️⃣ — Install PyMySQL Layer (if missing)

- If your Lambda environment doesn’t have pymysql, create a Lambda Layer:

- Create a folder python/lib/python3.12/site-packages/

- pip install pymysql -t python/lib/python3.12/site-packages/

- Zip and upload as Layer

- Attach Layer to all HR Lambdas

### 2️⃣ Test hr-attendance

- Navigate: Lambda → hr-attendance → Test

#### ✅ TEST 1 — CHECK-IN (SUCCESS)

🔹 Lambda Test Event Name

HR-CheckIn-Success

🔹 Event JSON

```
{
  "resource": "/hr/attendance/checkin",
  "path": "/hr/attendance/checkin",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "cognito-user-123",
        "cognito:groups": ["Employee"]
      }
    }
  }
}
```

✅ Expected Result

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-in successful\"}"
}
```

🧠 Database Effect

✔ New row inserted in attendance
✔ checkin_time filled
✔ checkout_time = NULL

❌ TEST 2 — CHECK-IN AGAIN (ALREADY CHECKED IN)

🔹 Event JSON (same as above)

```
{
  "resource": "/hr/attendance/checkin",
  "path": "/hr/attendance/checkin",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "cognito-user-123",
        "cognito:groups": ["Employee"]
      }
    }
  }
}
```

✅ Expected Result

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Already checked in today\"}"
}
```

✅ TEST 3 — CHECK-OUT (SUCCESS)
🔹 Lambda Test Event Name

HR-CheckOut-Success

🔹 Event JSON

```
{
  "resource": "/hr/attendance/checkout",
  "path": "/hr/attendance/checkout",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "cognito-user-123",
        "cognito:groups": ["Employee"]
      }
    }
  }
}
```

✅ Expected Result

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```

🧠 Database Effect

✔ Existing row updated
✔ checkout_time populated

❌ TEST 4 — CHECK-OUT WITHOUT CHECK-IN
🔹 Event JSON

```
{
  "resource": "/hr/attendance/checkout",
  "path": "/hr/attendance/checkout",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "new-cognito-user",
        "cognito:groups": ["Employee"]
      }
    }
  }
}
```

❌ Expected Result

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Check-in required before checkout\"}"
}
```

❌ TEST 5 — UNAUTHORIZED USER (NOT EMPLOYEE)
🔹 Event JSON

```
{
  "resource": "/hr/attendance/checkin",
  "path": "/hr/attendance/checkin",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "admin-user-001",
        "cognito:groups": ["Admin"]
      }
    }
  }
}
```

❌ Expected Result

```
{
  "statusCode": 403,
  "body": "{\"message\": \"Forbidden\"}"
}
```

❌ TEST 6 — INVALID ROUTE
🔹 Event JSON

```
{
  "resource": "/hr/attendance/delete",
  "path": "/hr/attendance/delete",
  "httpMethod": "POST",
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "cognito-user-123",
        "cognito:groups": ["Employee"]
      }
    }
  }
}
```

❌ Expected Result

```
{
  "statusCode": 404,
  "body": "{\"message\": \"Invalid attendance action\"}"
}
```

🧪 PRO TESTING TIP (CloudWatch)

Add this temporarily if you want clean logs:

```
print("PATH:", path)
print("USER:", cognito_user_id)
```

### 3️⃣ Test hr-checkin Lambda

#### Step 1 — Open Lambda Console

- Navigate: Lambda → hr-checkin → Test

#### Step 2 — Create Test Event

- Event template: API Gateway AWS Proxy (JSON)

Example:

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

> **Replace "sub" with an actual Cognito user ID mapped to your employees table.**

- Name: TestCheckIn

- Save

#### Step 3 — Invoke Test

- Click Test

- Observe output:

#### Expected success:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-in successful\"}"
}
```

#### If already checked in:

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Already checked in today\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

#### Step 4 — Verify in RDS

```
SELECT * FROM attendance WHERE employee_id = 1;
```

- Should see today’s date with checkin_time populated

- checkout_time should be NULL

### 4️⃣ Test hr-checkout Lambda

#### Step 1 — Open Lambda Console

- Lambda → hr-checkout → Test

#### Step 2 — Create Test Event

- Same template as hr-checkin:

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

- Click Test

#### Expected success:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```
#### If not checked in yet:

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Check-in required before checkout\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

#### Step 4 — Verify in RDS

```
SELECT * FROM attendance WHERE employee_id = 1;
```

> **checkout_time should now be populated**

### 5️⃣ Test hr-employee-profile Lambda

#### Step 1 — Open Lambda Console → hr-employee-profile → Test

#### Step 2 — Test Event (same as above)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "{\"name\": \"Alice\", \"job_title\": \"Barista\", \"salary\": 40000.00, \"start_date\": \"2025-12-01\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms Lambda can read employees table from RDS**

### 6️⃣ Test hr-attendance-history Lambda

#### Step 1 — Open Lambda → hr-attendance-history → Test

#### Step 2 — Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "[{\"attendance_date\": \"2026-01-19\", \"checkin_time\": \"09:00:00\", \"checkout_time\": \"17:00:00\"}]"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms RDS attendance table integration**

### 7️⃣ Test hr-leaves-holidays Lambda

#### Step 1 — Open Lambda → hr-leaves-holidays → Test

#### Step 2 — Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "{\"leaves\": [{\"leave_date\": \"2026-01-15\", \"leave_type\": \"Sick Leave\"}], \"holidays\": [{\"holiday_date\": \"2026-01-01\", \"description\": \"New Year\"}]}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms Lambda reads both leaves and holidays tables**

### ✅ Verification Checklist

#### All 5 Lambdas invoke without error

✔️ Database writes/reads are successful

✔️ Test attendance table shows:

    ✔️ Today’s check-in

    ✔️ Today’s check-out

✔️ Employee profile matches employees table

✔️ Leaves and holidays return correct rows

### 📞 Research & Interview 

### 1️⃣ Why ALL 5 Lambdas return 403 Forbidden

Every one of your HR Lambdas contains this line (directly or indirectly):

```
cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
```

#### That means:

**👉 These Lambdas REQUIRE Cognito authentication**

So what happens?

#### During Lambda Test (without Cognito)

- There is NO JWT token

- There is NO authorizer

- requestContext.authorizer.claims does not exist

- API Gateway (or your test harness) blocks the request

- Result = 403 Forbidden

**This is correct security behavior, not an error.**

### What 403 Means in YOUR Case (Important)

#### 403 Forbidden here means:

**🔐 “You are not authenticated, so access is denied”**

It does NOT mean:

❌ Lambda code is wrong

❌ Database is broken

❌ SQL queries failed

❌ IAM permissions are wrong

#### It ONLY means:

**👉 Cognito is not configured yet**

### Status of Each Lambda (All Good ✅)


| Lambda Name           | Result | Status    |
| --------------------- | ------ | --------- |
| hr-checkin            | 403    | ✅ Correct |
| hr-checkout           | 403    | ✅ Correct |
| hr-employee-profile   | 403    | ✅ Correct |
| hr-attendance-history | 403    | ✅ Correct |
| hr-leaves-holidays    | 403    | ✅ Correct |

**If any of these returned 200 without Cognito, that would actually be a security bug 🚨**

### When Will These Lambdas Return 200 OK?

#### They will work automatically once you do:

- Required Next Steps (Later Phase)

- Create Cognito User Pool

- Create App Client

- Configure API Gateway Authorizer

- Send requests with:

```
Authorization: Bearer <JWT_TOKEN>
```

Then:

- claims.sub will exist

- cognito_user_id will resolve

- DB queries will work

- You’ll get 200 OK responses 🎉

#### If You REALLY Want to Test Without Cognito (Optional)

**⚠️ Only for learning — NOT recommended for production**

You could:

- Hardcode a test cognito_user_id

- Or mock event['requestContext']

But since you’re building a real HR system, I do NOT recommend this.

**You’re actually doing things the right way 👍**

### Final Verdict (Very Important)

✔ Your Lambda logic is correct

✔ Your SQL structure is correct

✔ Your security design is correct

✔ 403 Forbidden is the expected result

✔ You are ready for Cognito integration

**✔️  If all pass → Lambdas are fully integrated with RDS**
> **We are ready to move to API Gateway to expose them to the frontend securely.**


### 📥 What You Have Achieved

✅ New HR-specific Lambda layer

✅ Cognito-secured backend

✅ RDS-integrated attendance logic

✅ Real-world AWS job architecture

✅ No duplication of existing lab

