# Charlie Cafe -- hr-attendance-history


### hr-attendance-history.py

> **Update Version:1.0**


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
            SELECT attendance_date, checkin_time, checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
            ORDER BY attendance_date DESC
        """, (cognito_user_id,))
        records = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(records, default=json_serializer)
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

---
### hr-attendance-history.py

> **Update Version:1.1**

❌ Remove environment DB variables

✅ Use secret CafeDevDBSM

✅ Reuse DB connection across invocations

✅ Keep RBAC (Employee only)

✅ Add proper error handling

✅ Keep clean production-ready structure

### ✅ FINAL: hr-attendance-history (With Secrets Manager)

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

### 🔐 IAM Permission Reminder

Make sure Lambda execution role allows:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:YOUR-REGION:YOUR-ACCOUNT-ID:secret:CafeDevDBSM*"
}
```

### ✅ Now Your HR Module Is Fully Secure

You now have:

hr-employee-profile → Secrets Manager ✅

hr-attendance-history → Secrets Manager ✅

Attendance Check-in/out → Secrets Manager ✅

All using centralized credential management.

---
### hr-attendance-history.py

> **Update Version:1.2**

### ✅ What Was Removed

❌ check_role() function

❌ Cognito group validation

❌ claims extraction

❌ cognito_user_id usage

❌ forbidden() function

❌ JOIN using cognito_user_id

### ✅ What Changed

API now expects employee_id in request body

Attendance is fetched directly using employee_id

Keeps Secrets Manager

Keeps connection reuse

Keeps Decimal/date serializer

Adds proper CORS handling

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
    Public API that returns attendance history.
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

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()

        return response(200, records)

    except Exception as e:
        return response(500, {"error": str(e)})
```

### ✅ Frontend Example Request

```
POST /attendance/history
{
  "employee_id": 5
}
```

### ⚠️ Production Warning

Because this API is now fully public:

Anyone can view any employee’s attendance history

No identity validation

No access control

If this is development → you're fine.
If production → strongly recommend adding at least:

API key

JWT auth

Private VPC access

Or IP restriction

---
### hr-attendance-history.py

> **Update Version:1.3**

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
    Public API that returns attendance history.
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

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()

        return response(200, records)

    except Exception as e:
        return response(500, {"error": str(e)})
```

---
### hr-attendance-history.py

> **Update Version:1.4**

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

    if connection is None:
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
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Public API that returns attendance history.
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

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()

        return response(200, records)

    except Exception as e:
        return response(500, {"error": str(e)})
```
### ISSUE 6 — CORS header improvement

#### File All Lambda functions:

- hr-attendance

- hr-employee-profile

- hr-attendance-history

- hr-leaves-holidays

- hr-cognito-token-exchange

#### Find header block

#### Example:

```
"Access-Control-Allow-Methods": "POST,OPTIONS"
```

#### Replace with

```
"Access-Control-Allow-Methods": "GET,POST,OPTIONS"
```

#### Example full header:

```
"headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
}
```

### ISSUE 7 — Lambda connection reuse stability

- File: All HR Lambdas:

```
hr-attendance
hr-employee-profile
hr-attendance-history
hr-leaves-holidays
```

#### Find

```
if connection is None or not connection.open:
```

#### Replace with

```
if connection is None:
```

Why?

Lambda containers freeze connections sometimes.

Simpler logic is safer.

### ⚠️ Issue 1 — Missing Numeric Validation (2 Lambdas)

You fixed this in employee-profile, but not in:

hr-attendance-history

hr-leaves-holidays

#### Currently both have:

```
employee_id = body.get("employee_id")

if not employee_id:
    return response(400, {"message": "employee_id is required"})
```

This allows:

```
employee_id = "abc"
```

which can break queries.

### Fix

#### Replace with:

```
try:
    employee_id = int(body.get("employee_id"))
except:
    return response(400, {"message": "employee_id must be numeric"})
```

### File Location: hr-attendance-history & hr-leaves-holidays

#### Replace this section:

```
employee_id = body.get("employee_id")

if not employee_id:
    return response(400, {"message": "employee_id is required"})
```

### ✅ Fully Final hr-attendance-history.py

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
# AWS Secrets Manager stores RDS credentials securely.
# Replace SECRET_NAME with your actual secret name.
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================
def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager.
    Returns a dictionary with host, username, password, and dbname.
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================
connection = None

def get_connection():
    """
    Reuse a persistent DB connection across Lambda invocations
    to improve performance and reduce cold start latency.
    """
    global connection

    if connection is None:
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
# JSON SERIALIZER
# ==========================================================
def json_serializer(obj):
    """
    Converts non-JSON-serializable types to JSON-friendly types:
    - Decimal -> float
    - datetime.date/datetime -> ISO format string
    """
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status, body):
    """
    Standard API Gateway response with CORS headers.
    """
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Returns attendance history for a given employee.
    Expects JSON body:
    { "employee_id": 1001 }
    """

    try:
        # Handle CORS preflight request
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})

        # Validate request body
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
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()

        # Return attendance records
        return response(200, records)

    except Exception as e:
        # Catch-all error handler
        return response(500, {"error": str(e)})
```
### ✅ Key Improvements & Features

- Connection Reuse: Reuses DB connection across Lambda invocations for faster performance.

- CORS Support: Handles preflight OPTIONS requests for browser-based calls.

- JSON Serialization: Converts Decimal and datetime objects automatically.

- Detailed Comments: Each section has clear explanations.

- Error Handling: Returns proper HTTP status codes and error messages.
---
### hr-attendance-history.py

> **Update Version:1.5**

### hr-attendance-history — with numeric validation

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
    Returns a dictionary with host, username, password, and dbname.
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================
connection = None

def get_connection():
    """
    Reuse a persistent DB connection across Lambda invocations
    to improve performance and reduce cold start latency.
    """
    global connection
    if connection is None:
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
# JSON SERIALIZER
# ==========================================================
def json_serializer(obj):
    """Converts non-JSON-serializable types to JSON-friendly types"""
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status, body):
    """Standard API Gateway response with CORS headers"""
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Returns attendance history for a given employee.
    Expects JSON body:
    { "employee_id": 1001 }
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

        # Validate employee_id exists
        if employee_id is None:
            return response(400, {"message": "employee_id is required"})

        # ✅ Numeric validation
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, {"message": "employee_id must be a number"})

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))
            records = cursor.fetchall()

        return response(200, records)

    except Exception as e:
        return response(500, {"error": str(e)})
```

### ✅ Key Updates & Fixes:

#### Added explicit numeric validation for employee_id in both Lambdas:

```
try:
    employee_id = int(employee_id)
except (ValueError, TypeError):
    return response(400, {"message": "employee_id must be a number"})
```
- Ensures empty or missing employee_id returns a proper 400 response.

- CORS preflight handling remains unchanged.

- Code is fully production-ready and aligned with your existing HR portal APIs.
---
### hr-attendance-history.py

> **Update Version:1.6**

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
    Returns a dictionary with host, username, password, and dbname.
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================
connection = None

def get_connection():
    """
    Reuse a persistent DB connection across Lambda invocations
    to improve performance and reduce cold start latency.
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
# JSON SERIALIZER
# ==========================================================
def json_serializer(obj):
    """Converts non-JSON-serializable types to JSON-friendly types"""
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status, body):
    """Standard API Gateway response with CORS headers"""
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Returns attendance history for a given employee.
    Expects JSON body:
    { "employee_id": 1001 }
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

        # Validate employee_id exists
        if employee_id is None:
            return response(400, {"message": "employee_id is required"})

        # ✅ Numeric validation
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, {"message": "employee_id must be a number"})

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))
            records = cursor.fetchall()

        return response(200, records)

    except Exception as e:
        return response(500, {"error": str(e)})
```

---
### hr-attendance-history.py

> **Update Version:1.7**

```
# ==============================================================================
# CHARLIE CAFÉ ☕ — Lambda: hr-attendance-history
# ==============================================================================
# Purpose  : Returns the full attendance history for the authenticated employee.
# Route    : POST /attendance-history
# Auth     : Cognito Authorizer — employee_id is extracted from the JWT claims.
#            The frontend sends NO body — the token alone identifies the employee.
#
# FIX (vs original): The original code read employee_id from the POST body,
# but api.js sends no body for this endpoint. Fixed to use JWT claims instead,
# matching the same pattern as hr-employee-profile.
#
# Database : RDS MySQL via PyMySQL (credentials from AWS Secrets Manager)
# ==============================================================================

import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ------------------------------------------------------------------------------
# SECRETS MANAGER — configuration
# ------------------------------------------------------------------------------
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ------------------------------------------------------------------------------
# get_db_secret()
# Fetches RDS credentials from Secrets Manager.
# Returns a dict: { host, username, password, dbname }
# ------------------------------------------------------------------------------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ------------------------------------------------------------------------------
# Persistent connection — reused across warm Lambda invocations.
# autocommit=True: this Lambda is read-only, no manual commit/rollback needed.
# ------------------------------------------------------------------------------
_connection = None

def get_connection():
    global _connection
    if _connection is None or not _connection.open:
        secret = get_db_secret()
        _connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )
    return _connection


# ------------------------------------------------------------------------------
# json_serializer()
# Converts MySQL types that json.dumps cannot handle natively:
#   Decimal       → float   (not present here but included for consistency)
#   date/datetime → ISO 8601 string  (attendance_date, checkin_time, checkout_time)
# ------------------------------------------------------------------------------
def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ------------------------------------------------------------------------------
# api_response()
# Standard API Gateway Lambda proxy response with CORS headers.
# Authorization is in Allow-Headers because Cognito sends a Bearer token.
# ------------------------------------------------------------------------------
def api_response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin":  "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }


# ------------------------------------------------------------------------------
# lambda_handler()
# Main entry point called by API Gateway for every request.
#
# Flow:
#   1. Handle browser CORS preflight (OPTIONS)
#   2. Extract employee_id from Cognito JWT claims (no body parsing needed)
#   3. Query attendance table ordered by most recent date first
#   4. Return the records array (empty array [] if no history exists)
# ------------------------------------------------------------------------------
def lambda_handler(event, context):

    try:

        # ----------------------------------------------------------------------
        # STEP 1 — Handle CORS preflight
        # ----------------------------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return api_response(200, {"message": "CORS preflight successful"})


        # ----------------------------------------------------------------------
        # STEP 2 — Extract employee_id from Cognito JWT claims
        #
        # The Cognito Authorizer on API Gateway decodes the Bearer token and
        # injects the claims here. No body is sent by the frontend.
        #
        # Requires: custom attribute "custom:employee_id" set on each Cognito user.
        # ----------------------------------------------------------------------
        claims = (
            event
            .get("requestContext", {})
            .get("authorizer", {})
            .get("claims", {})
        )

        if not claims:
            return api_response(401, {"message": "Unauthorized — missing JWT claims"})

        # Cognito custom attributes are strings — cast to int for the SQL query
        try:
            employee_id = int(claims.get("custom:employee_id"))
        except (TypeError, ValueError):
            return api_response(400, {"message": "Invalid employee_id in token"})


        # ----------------------------------------------------------------------
        # STEP 3 — Query attendance history
        # Returns all rows for this employee, newest date first.
        # checkin_time and checkout_time may be NULL if employee only checked in.
        # ----------------------------------------------------------------------
        conn = get_connection()

        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date,
                       checkin_time,
                       checkout_time
                FROM   attendance
                WHERE  employee_id = %s
                ORDER  BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()


        # ----------------------------------------------------------------------
        # STEP 4 — Return results
        # Returns an empty array [] if the employee has no attendance history.
        # The frontend handles both empty and populated arrays gracefully.
        # ----------------------------------------------------------------------
        return api_response(200, records)


    # --------------------------------------------------------------------------
    # Global error handler
    # --------------------------------------------------------------------------
    except Exception as e:
        return api_response(500, {"error": str(e)})
```

---
### hr-attendance-history.py

> **Update Version:1.8**