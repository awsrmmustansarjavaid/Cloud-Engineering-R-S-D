# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

## hr-checkout.py 


### hr-leaves-holidays.py
> **Update Version 1.0**

```
import json
import os
import pymysql
import datetime
from decimal import Decimal

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
        return obj.isoformat()  # convert to string "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS"
    return str(obj)  # fallback for any other type

# ------------------------
# LAMBDA HANDLER
# ------------------------
def lambda_handler(event, context):
    # Get logged-in Cognito user ID
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        # Fetch employee leaves
        cursor.execute("""
            SELECT l.leave_date, l.leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        # Fetch company holidays
        cursor.execute("""
            SELECT holiday_date, description
            FROM holidays
        """)
        holidays = cursor.fetchall()

    # Return JSON safely
    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "leaves": leaves,
            "holidays": holidays
        }, default=json_serializer)
    }
```


---

### hr-leaves-holidays.py
> **Update Version 1.1**

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

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    if "Employee" not in groups:
        return forbidden()

    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT l.leave_date, l.leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        cursor.execute("""
            SELECT holiday_date, description
            FROM holidays
        """)
        holidays = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(
            {"leaves": leaves, "holidays": holidays},
            default=json_serializer
        )
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-leaves-holidays.py
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
            SELECT leave_date, leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        cursor.execute("""
            SELECT holiday_date, description
            FROM holidays
        """)
        holidays = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(
            {"leaves": leaves, "holidays": holidays},
            default=json_serializer
        )
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-leaves-holidays.py
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
            SELECT leave_date, leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        cursor.execute("""
            SELECT holiday_date, description
            FROM holidays
        """)
        holidays = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(
            {"leaves": leaves, "holidays": holidays},
            default=json_serializer
        )
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-leaves-holidays.py
> **Update Version 1.4**



This keeps your entire HR module:

🔐 Secure (no DB credentials in environment variables)

♻️ Reusing DB connection

🏗 Production-ready structure

🔄 Ready for secret rotation

### ✅ FINAL: hr-leaves-holidays (With Secrets Manager)

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

### 🔐 IAM Reminder

Your Lambda role must allow:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:YOUR-REGION:YOUR-ACCOUNT-ID:secret:CafeDevDBSM*"
}
```

### ✅ Your HR System Architecture Is Now Consistent

All HR Lambdas:

hr-employee-profile

hr-attendance-history

hr-leaves-holidays

attendance check-in/out

Now use:

✔ Centralized secret
✔ Secure credential management
✔ Reusable DB connection
✔ Clean RBAC pattern

---
### hr-leaves-holidays.py
> **Update Version 1.5**

### ✅ What Was Removed

❌ check_role() function

❌ Cognito group validation

❌ claims usage

❌ cognito_user_id lookup

❌ forbidden() function

❌ JOIN using cognito_user_id

### ✅ What Changed

Now expects employee_id in request body

Fetches leave history using employee_id

Holidays remain public (no filtering needed)

Proper CORS handling added

Keeps Secrets Manager + DB reuse

Keeps Decimal/date serializer

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
# JSON SERIALIZER (DECIMAL & DATE SUPPORT)
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
    Public API that returns:
    - Employee leave history
    - Company holiday list

    Expects employee_id in request body.
    """

    try:
        # Handle CORS preflight
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})

        # Validate request body
        if not event.get("body"):
            return response(400, {"message": "Missing request body"})

        body = json.loads(event["body"])
        employee_id = body.get("employee_id")

        if not employee_id:
            return response(400, {"message": "employee_id is required"})

        connection = get_connection()

        with connection.cursor() as cursor:

            # ----------------------------------------
            # FETCH EMPLOYEE LEAVES
            # ----------------------------------------
            cursor.execute("""
                SELECT leave_date, leave_type
                FROM leaves
                WHERE employee_id=%s
                ORDER BY leave_date DESC
            """, (employee_id,))

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

        return response(200, {
            "leaves": leaves,
            "holidays": holidays
        })

    except Exception as e:
        return response(500, {"error": str(e)})
```

### ✅ Example Frontend Request

```
POST /employee/leaves
{
  "employee_id": 5
}
```

### ⚠️ Production Warning

This API is now fully public:

Anyone can view any employee’s leave history

No authentication

No authorization

Sensitive HR data exposed

If this is production, at minimum add:

API key

JWT

Private network restriction

Or IAM authorizer

---


