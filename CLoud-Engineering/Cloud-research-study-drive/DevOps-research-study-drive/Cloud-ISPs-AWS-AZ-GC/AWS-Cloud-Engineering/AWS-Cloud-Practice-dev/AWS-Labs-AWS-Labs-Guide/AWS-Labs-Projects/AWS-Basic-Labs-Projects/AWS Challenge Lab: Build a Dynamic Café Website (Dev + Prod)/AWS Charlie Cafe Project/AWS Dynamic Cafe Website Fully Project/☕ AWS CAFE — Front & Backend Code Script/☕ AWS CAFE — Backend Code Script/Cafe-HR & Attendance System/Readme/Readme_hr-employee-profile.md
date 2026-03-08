# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

## hr-checkout.py 

### hr-employee-profile.py
> **Update Version 1.0**

```
import json
import os
import pymysql
from decimal import Decimal
import datetime

# ------------------------
# DATABASE CONNECTION
# ------------------------
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

# ------------------------
# JSON SERIALIZER
# ------------------------
def json_serializer(obj):
    """
    Handles Decimal, date, datetime for JSON serialization
    """
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)  # fallback for other types

# ------------------------
# LAMBDA HANDLER
# ------------------------
def lambda_handler(event, context):
    # Get logged-in Cognito user ID
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    # Return JSON response safely
    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee, default=json_serializer)
    }
```

---

### hr-employee-profile.py
> **Update Version 1.1**

```
import json
import os
import pymysql
from decimal import Decimal
import datetime

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    # -------------------------------
    # AUTHORIZATION — ROLE CHECK
    # -------------------------------
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    if "Employee" not in groups:
        return forbidden()

    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type"
        },
        "body": json.dumps(employee, default=json_serializer)
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-employee-profile.py
> **Update Version 1.2**


```
import json
import os
import pymysql
import datetime
from decimal import Decimal

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    # ----------------------------------------
    # AUTHORIZATION — EMPLOYEE ONLY
    # ----------------------------------------
    ALLOWED_ROLE = "Employee"

    if not check_role(event, ALLOWED_ROLE):
        return forbidden()

    claims = event["requestContext"]["authorizer"]["claims"]
    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee, default=json_serializer)
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```
### hr-employee-profile.py
> **Update Version 1.3**

```
import json
import os
import pymysql
import datetime
from decimal import Decimal

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    # ----------------------------------------
    # AUTHORIZATION — EMPLOYEE ONLY
    # ----------------------------------------
    ALLOWED_ROLE = "Employee"

    if not check_role(event, ALLOWED_ROLE):
        return forbidden()

    claims = event["requestContext"]["authorizer"]["claims"]
    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee, default=json_serializer)
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-employee-profile.py
> **Update Version 1.4**

❌ Remove DB_HOST, DB_USER, DB_PASS, DB_NAME

✅ Use secret: CafeDevDBSM

✅ Reuse DB connection (Lambda best practice)

✅ Keep your role-based authorization

✅ Add proper error handling

✅ Add comments for production clarity

### ✅ FINAL: hr-employee-profile (With Secrets Manager)

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

### 🔐 IMPORTANT – IAM Permission Required

Your Lambda execution role must include:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:YOUR-REGION:YOUR-ACCOUNT-ID:secret:CafeDevDBSM*"
}
```

---
### hr-employee-profile.py
> **Update Version 1.5**

Below is your fully cleaned Lambda function with ALL Cognito and authorization logic removed.

### ✅ What Was Removed

❌ check_role() function

❌ Cognito claims usage

❌ Group validation (Employee)

❌ cognito_user_id lookup

❌ forbidden() function

### ✅ What Changed

API is now fully public

Expects employee_id in request body

Returns employee profile based on employee_id

Keeps Secrets Manager + connection reuse

Keeps Decimal/date JSON serialization

### ✅ FINAL LAMBDA CODE (NO COGNITO)

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
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
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
            connect_timeout=10,
            autocommit=True
        )

    return connection


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
# STANDARD RESPONSE
# ==========================================================

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Public API that returns employee profile.
    Expects employee_id in request body.
    """

    try:
        # Handle CORS preflight
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})

        # Validate body
        if not event.get("body"):
            return response(400, {"message": "Missing request body"})

        body = json.loads(event["body"])
        employee_id = body.get("employee_id")

        if not employee_id:
            return response(400, {"message": "employee_id is required"})

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT employee_id, name, job_title, salary, start_date
                FROM employees
                WHERE employee_id=%s
            """, (employee_id,))

            employee = cursor.fetchone()

        if not employee:
            return response(404, {"message": "Employee not found"})

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return response(200, employee)

    except Exception as e:
        return response(500, {"error": str(e)})
```

### ✅ Frontend Request Example

```
POST /employee/profile
{
  "employee_id": 5
}
```

### ⚠️ Important (Production Warning)

Since this API is fully public:

Anyone can fetch any employee profile

Salaries are exposed

No identity verification exists

If this is for development/testing → fine.
If production → you should at least add:

API key

JWT auth

Or internal network restriction
---

