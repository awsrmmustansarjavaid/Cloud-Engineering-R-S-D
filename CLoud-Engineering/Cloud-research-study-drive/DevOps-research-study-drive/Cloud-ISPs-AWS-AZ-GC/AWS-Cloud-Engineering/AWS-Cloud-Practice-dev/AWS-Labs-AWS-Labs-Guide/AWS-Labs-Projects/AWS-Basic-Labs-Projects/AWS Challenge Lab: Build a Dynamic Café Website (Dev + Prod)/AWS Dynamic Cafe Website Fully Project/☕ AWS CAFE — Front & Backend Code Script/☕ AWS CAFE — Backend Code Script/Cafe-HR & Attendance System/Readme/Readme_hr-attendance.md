# Charlie Cafe --- hr-attendance


### hr-attendance.py

> **Update Version:1.0**


```
import json
import os
import pymysql
from datetime import date, datetime

# ----------------------------------------
# DATABASE CONNECTION (Reuse across invocations)
# ----------------------------------------
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor,
    autocommit=False
)

# ----------------------------------------
# ROLE CHECK (RBAC)
# ----------------------------------------
def check_role(event, allowed_role):
    """
    Allow only users in required Cognito group
    """
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

# ----------------------------------------
# STANDARD API RESPONSE
# ----------------------------------------
def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }

# ----------------------------------------
# LAMBDA HANDLER
# ----------------------------------------
def lambda_handler(event, context):
    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        if not check_role(event, "Employee"):
            return response(403, "Forbidden")

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        today = date.today()
        now = datetime.now().time()

        # ----------------------------------------
        # IDENTIFY ACTION (checkin / checkout)
        # ----------------------------------------
        path = event.get("resource") or event.get("path", "")

        with connection.cursor() as cursor:

            # ----------------------------------------
            # FETCH EMPLOYEE ID
            # ----------------------------------------
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )
            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            employee_id = employee["employee_id"]

            # ============================================================
            # ✅ CHECK-IN LOGIC
            # ============================================================
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

            # ============================================================
            # ✅ CHECK-OUT LOGIC
            # ============================================================
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

            # ----------------------------------------
            # UNKNOWN ROUTE
            # ----------------------------------------
            else:
                return response(404, "Invalid attendance action")

    except Exception as e:
        return response(500, str(e))
```

---
### hr-attendance.py

> **Update Version:1.1**

❌ Remove DB_HOST, DB_USER, DB_PASS, DB_NAME from environment variables

✅ Fetch credentials from Secrets Manager (CafeDevDBSM)

✅ Reuse DB connection across invocations (best practice for Lambda)

✅ Keep clean structure + comments

### ✅ FINAL Attendance Lambda (Using Secrets Manager)

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

### 🔐 Important: IAM Permission Required

Your Lambda role must have permission to access:
```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "*"
}
```
(Preferably restrict to the specific secret ARN.)

### ✅ What You Can Now Remove

From Lambda Environment Variables, you can DELETE:

```
DB_HOST
DB_NAME
DB_USER
DB_PASS
```

Now everything is securely pulled from:

👉 AWS Secrets Manager → CafeDevDBSM

### ✅ What You Achieved

- No more hardcoded DB credentials

- No environment variables for DB

- Centralized credential management

- Secure rotation support

- Production-ready architecture
---
### hr-attendance.py

> **Update Version:1.2**


Below is your fully cleaned Lambda code with ALL Cognito logic removed.

Changes made:

❌ Removed check_role

❌ Removed Cognito claims

❌ Removed RBAC logic

❌ Removed cognito_user_id lookup

✅ Now accepts employee_id directly from request body

✅ Works with fully public API Gateway endpoints

✅ Keeps Secrets Manager + DB reuse logic

✅ Keeps CORS headers

### ✅ FINAL LAMBDA CODE (NO COGNITO, NO AUTHORIZATION)

```
import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ==========================================================
# AWS SECRETS MANAGER CONFIG
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    secret = json.loads(response["SecretString"])
    return secret


# ==========================================================
# CREATE / REUSE DATABASE CONNECTION
# ==========================================================

connection = None

def get_connection():
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
# STANDARD API RESPONSE
# ==========================================================

def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Public API for employee check-in and check-out.
    Expects employee_id in request body.
    """

    try:
        # Handle OPTIONS (CORS preflight)
        if event.get("httpMethod") == "OPTIONS":
            return response(200, "CORS preflight successful")

        # Parse request body
        if not event.get("body"):
            return response(400, "Missing request body")

        body = json.loads(event["body"])
        employee_id = body.get("employee_id")

        if not employee_id:
            return response(400, "employee_id is required")

        today = date.today()
        now = datetime.now().time()

        path = event.get("resource") or event.get("path", "")

        connection = get_connection()

        with connection.cursor() as cursor:

            # Validate employee exists
            cursor.execute(
                "SELECT employee_id FROM employees WHERE employee_id=%s",
                (employee_id,)
            )

            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            # ==================================================
            # CHECK-IN LOGIC
            # ==================================================
            if "checkin" in path.lower():

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
            # CHECK-OUT LOGIC
            # ==================================================
            elif "checkout" in path.lower():

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

            # ==================================================
            # UNKNOWN ROUTE
            # ==================================================
            else:
                return response(404, "Invalid attendance action")

    except Exception as e:
        return response(500, str(e))
```

### ✅ What Your Frontend Must Now Send

#### Check-In Request

```
POST /checkin
{
  "employee_id": 5
}
```

#### Check-Out Request

```
POST /checkout
{
  "employee_id": 5
}
```

### 🔒 Important Security Note

Since your APIs are now fully public:

Anyone can submit any employee_id

There is no identity verification

This is NOT secure for production

If this is for development or internal usage, you're fine.

----


