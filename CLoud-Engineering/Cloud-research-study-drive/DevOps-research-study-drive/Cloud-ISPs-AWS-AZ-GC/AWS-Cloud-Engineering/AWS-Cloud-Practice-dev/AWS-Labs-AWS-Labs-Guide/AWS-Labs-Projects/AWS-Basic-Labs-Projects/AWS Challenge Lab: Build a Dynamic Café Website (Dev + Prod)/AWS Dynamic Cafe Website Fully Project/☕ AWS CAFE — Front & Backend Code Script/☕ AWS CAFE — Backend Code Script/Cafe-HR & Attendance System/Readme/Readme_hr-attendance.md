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


Below is your fully updated, production-ready Lambda code that:

✅ Uses AWS Secrets Manager

✅ Fetches secret CafeDevDBSM

✅ Connects to Amazon RDS

✅ Reuses DB connection properly

✅ Includes comments for every section

✅ Keeps your Cognito role validation

### ✅ FINAL VERSION — Attendance Check-Out Lambda (Using Secrets Manager)

```
import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
# Client for AWS Secrets Manager
secrets_client = boto3.client("secretsmanager")

# ==========================================================
# CONFIGURATION
# ==========================================================
# Name of the secret stored in AWS Secrets Manager
SECRET_NAME = "CafeDevDBSM"

# Global connection variable (reused across Lambda invocations)
connection = None


# ==========================================================
# FETCH DATABASE SECRET FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    """
    Retrieves RDS credentials from AWS Secrets Manager.
    Expected secret JSON format:
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
# CREATE DATABASE CONNECTION (REUSED)
# ==========================================================
def get_db_connection():
    """
    Creates and returns a MySQL connection using credentials
    from AWS Secrets Manager.
    Reuses existing connection if still valid.
    """
    global connection

    if connection and connection.open:
        return connection

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=5,
        autocommit=False
    )

    return connection


# ==========================================================
# ROLE VALIDATION FUNCTION
# ==========================================================
def check_role(event, allowed_role):
    """
    Checks if authenticated Cognito user belongs to required group.
    """
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# STANDARDIZED HTTP RESPONSE
# ==========================================================
def response(status, message):
    """
    Returns API Gateway compatible response with CORS.
    """
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST"
        },
        "body": json.dumps({"message": message})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Employee Check-Out Lambda Function

    - Validates user role (Employee only)
    - Updates checkout time in attendance table
    - Uses RDS credentials from AWS Secrets Manager
    """

    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return response(403, "Forbidden - Employee access required")

        # ----------------------------------------
        # GET USER INFO FROM COGNITO TOKEN
        # ----------------------------------------
        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        today = date.today()
        now = datetime.now().time()

        # ----------------------------------------
        # CONNECT TO DATABASE
        # ----------------------------------------
        connection = get_db_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                SET a.checkout_time = %s
                WHERE e.cognito_user_id = %s
                AND a.attendance_date = %s
            """, (now, cognito_user_id, today))

            # If no rows updated → user didn't check in
            if cursor.rowcount == 0:
                return response(400, "Check-in required before checkout")

            connection.commit()

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return response(200, "Check-out successful")

    except Exception as e:
        return response(500, f"Internal Server Error: {str(e)}")
```

### 🔐 IMPORTANT — IAM Permission Required

Your Lambda execution role MUST have permission:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:YOUR-REGION:YOUR-ACCOUNT-ID:secret:CafeDevDBSM*"
}
```

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
---

