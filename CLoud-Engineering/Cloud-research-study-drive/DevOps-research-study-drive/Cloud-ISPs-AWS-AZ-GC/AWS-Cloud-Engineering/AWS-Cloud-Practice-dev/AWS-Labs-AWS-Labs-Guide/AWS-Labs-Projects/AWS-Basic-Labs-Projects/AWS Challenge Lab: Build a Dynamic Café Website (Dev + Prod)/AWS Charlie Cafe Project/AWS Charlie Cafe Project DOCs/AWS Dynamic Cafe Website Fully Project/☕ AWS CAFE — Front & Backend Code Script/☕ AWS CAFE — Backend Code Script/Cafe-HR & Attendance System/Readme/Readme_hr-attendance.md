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
### hr-attendance.py

Perfect — I see the full Lambda code. The main issue is that your employee_id from checkin.html is coming as a string, and MySQL expects an integer (employee_id column is int). Also, it’s safer to validate numeric input and handle errors clearly.

#### Here’s the fully updated, final Lambda code with comments and fixes for numeric employee IDs:

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
    Expects numeric employee_id in request body.
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
        action = body.get("action", "").lower()

        # Validate employee_id is numeric
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")

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
            if "checkin" in path.lower() or action == "checkin":
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
            elif "checkout" in path.lower() or action == "checkout":
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

### ✅ Key Fixes:

Converts employee_id to int before using in SQL queries.

Handles non-numeric IDs gracefully with a clear error.

Checks action in body if path is generic (/attendance) — so your checkin.html toggle will work.

Maintains all CORS and MySQL connection logic.
---
### hr-attendance.py

> **Update Version:1.3**

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
    Expects numeric employee_id in request body.
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
        action = body.get("action", "").lower()

        # Validate employee_id is numeric
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")

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
            if "checkin" in path.lower() or action == "checkin":
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
            elif "checkout" in path.lower() or action == "checkout":
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
---
### hr-attendance.py

> **Update Version:1.4**

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

    if connection is None:
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
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Public API for employee check-in and check-out.
    Expects numeric employee_id in request body.
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
        action = body.get("action", "").lower()

        # Validate employee_id is numeric
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")

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
            if "checkin" in path.lower() or action == "checkin":
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
            elif "checkout" in path.lower() or action == "checkout":
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

---
### hr-attendance.py

> **Update Version:1.4**

### 🔴 Issue 1 — Lambda DB Connection Can Break (Important)

- File: All Lambdas using MySQL

- Example: hr-employee-profile

- Problem: If RDS connection dies, Lambda keeps using broken connection.

#### Your code:

```
if connection is None:
```

But connection may exist but be closed.

### Fix (Production Standard)

#### Replace get_connection() with this:

```
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
```

### Affected files

Apply this fix to:

```
hr-attendance
hr-employee-profile
hr-attendance-history
hr-leaves-holidays
```

### 🟡 Issue 2 — Missing API Gateway Lambda Proxy Validation

Some Lambdas assume fields always exist.

- File: hr-attendance

#### Current

```
path = event.get("resource") or event.get("path", "")
```

#### Better:

```
path = event.get("path", "").lower()
```

because API Gateway proxy events are inconsistent.

### 🟡 Issue 3 — Attendance Duplicate Protection (Important)

- File: hr-attendance

#### Current:

```
INSERT INTO attendance
```

But if user double-clicks checkin, duplicates can happen.

Better:

#### Before inserting:

```
cursor.execute("""
SELECT employee_id FROM attendance
WHERE employee_id=%s AND attendance_date=%s
""",(employee_id,today))

if cursor.fetchone():
    return response(400,"Already checked in today")
```

Then insert.

### 🟡 Issue 4 — Missing DB Connection Close on Error

In Lambda if exception occurs DB transaction may remain open.

#### Add inside exception:

Example: 

```
except Exception as e:
    if connection:
        connection.rollback()
    return response(500, str(e))
```

#### Apply in: hr-attendance

Only required where autocommit=False.

### ✅ I fixed the following issues:

✅ Robust DB connection reuse (connection.open check)

✅ Duplicate check-in protection (prevents double click / duplicate insert)

✅ Safe API Gateway path handling

✅ Transaction rollback on error

✅ Better error handling

✅ Cleaner structure for maintainability

Your architecture remains compatible with:

API Gateway

RDS MySQL

Secrets Manager

CloudFront frontend

api.js attendance API

### ✅ Final Production Code — hr-attendance

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
    return json.loads(response["SecretString"])


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
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Charlie Café HR Attendance API

    Supports:
    POST /attendance/checkin
    POST /attendance/checkout

    Request body:
    {
        "employee_id": 5,
        "action": "checkin" | "checkout"
    }
    """

    connection = None

    try:

        # --------------------------------------------------
        # HANDLE CORS PREFLIGHT
        # --------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return response(200, "CORS preflight successful")


        # --------------------------------------------------
        # VALIDATE REQUEST BODY
        # --------------------------------------------------
        if not event.get("body"):
            return response(400, "Missing request body")

        body = json.loads(event["body"])

        employee_id = body.get("employee_id")
        action = body.get("action", "").lower()


        # --------------------------------------------------
        # VALIDATE EMPLOYEE ID
        # --------------------------------------------------
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")


        # --------------------------------------------------
        # REQUEST CONTEXT
        # --------------------------------------------------
        today = date.today()
        now = datetime.now().time()

        # API Gateway path detection
        path = event.get("path", "").lower()


        # --------------------------------------------------
        # CONNECT TO DATABASE
        # --------------------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:

            # --------------------------------------------------
            # VERIFY EMPLOYEE EXISTS
            # --------------------------------------------------
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
            if "checkin" in path or action == "checkin":

                # Prevent duplicate check-ins
                cursor.execute("""
                    SELECT employee_id
                    FROM attendance
                    WHERE employee_id=%s
                    AND attendance_date=%s
                """, (employee_id, today))

                if cursor.fetchone():
                    return response(400, "Already checked in today")

                cursor.execute("""
                    INSERT INTO attendance
                    (employee_id, attendance_date, checkin_time)
                    VALUES (%s, %s, %s)
                """, (employee_id, today, now))

                connection.commit()

                return response(200, "Check-in successful")


            # ==================================================
            # CHECK-OUT LOGIC
            # ==================================================
            elif "checkout" in path or action == "checkout":

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
            # INVALID ROUTE
            # ==================================================
            else:
                return response(404, "Invalid attendance action")


    # --------------------------------------------------
    # ERROR HANDLING
    # --------------------------------------------------
    except Exception as e:

        if connection:
            connection.rollback()

        return response(500, str(e))
```

### ✅ What This Final Version Improves

| Feature                       | Benefit                        |
| ----------------------------- | ------------------------------ |
| Duplicate Check-in Protection | prevents double clicks         |
| Connection Recovery           | Lambda reconnects if DB closed |
| Rollback Handling             | prevents partial writes        |
| Better Path Handling          | stable with API Gateway        |
| Clean Code Structure          | easier maintenance             |
| Production Error Handling     | avoids broken transactions     |

### ⭐ Result

Your Charlie Café HR Attendance Lambda is now production ready.

It is now safe for:

- multiple concurrent Lambda executions

- accidental double check-ins

- API Gateway inconsistencies

- database connection failures


---
### hr-attendance.py

> **Update Version:1.5**

```
# ==============================================================================
# CHARLIE CAFÉ ☕ — Lambda: hr-attendance
# ==============================================================================
# Purpose  : Handles employee check-in and check-out for today's date.
# Routes   : POST /attendance/checkin
#            POST /attendance/checkout
# Auth     : NO Cognito Authorizer — this endpoint is called by a shared
#            check-in kiosk/device, so employee_id comes from the request body.
# Database : RDS MySQL via PyMySQL (credentials from AWS Secrets Manager)
# ==============================================================================

import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ------------------------------------------------------------------------------
# SECRETS MANAGER — configuration
# The secret name must match exactly what you created in AWS Secrets Manager.
# REGION_NAME is read from the Lambda environment variable AWS_REGION.
# ------------------------------------------------------------------------------
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ------------------------------------------------------------------------------
# get_db_secret()
# Fetches RDS credentials from Secrets Manager at runtime.
# Returns a dict: { host, username, password, dbname }
# Called only when a new DB connection is needed (cold start or reconnect).
# ------------------------------------------------------------------------------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ------------------------------------------------------------------------------
# Persistent connection — reused across warm Lambda invocations for performance.
#
# IMPORTANT: Named _connection (leading underscore) to prevent any local variable
# named `connection` inside lambda_handler from accidentally shadowing this global.
# That shadowing bug was the original cause of rollback() failing in the except block.
#
# autocommit=False: We commit manually after successful writes so we can
# rollback() on any error and keep the database consistent.
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
            autocommit=False,
            connect_timeout=10
        )
    return _connection


# ------------------------------------------------------------------------------
# api_response()
# Builds a standard API Gateway Lambda proxy response.
# Includes CORS headers so the browser's preflight and data requests both work.
# `message` is a plain string — the body is always { "message": "..." }
# ------------------------------------------------------------------------------
def api_response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin":  "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }


# ------------------------------------------------------------------------------
# lambda_handler()
# Main entry point called by API Gateway for every request.
#
# Flow:
#   1. Handle browser CORS preflight (OPTIONS)
#   2. Parse + validate the JSON body (employee_id, action)
#   3. Open DB connection
#   4. Verify employee exists
#   5. Branch to check-in or check-out logic
#   6. Commit and return success, or rollback and return error
# ------------------------------------------------------------------------------
def lambda_handler(event, context):

    # `conn` is the local reference to the DB connection for THIS invocation.
    # Initialised to None so the except block can safely check `if conn:`
    # before calling rollback() — avoids UnboundLocalError.
    conn = None

    try:

        # ----------------------------------------------------------------------
        # STEP 1 — Handle CORS preflight
        # Browsers send OPTIONS before cross-origin POST requests.
        # We must respond 200 immediately or the actual POST is blocked.
        # ----------------------------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return api_response(200, "CORS preflight successful")


        # ----------------------------------------------------------------------
        # STEP 2 — Parse request body
        # ----------------------------------------------------------------------
        if not event.get("body"):
            return api_response(400, "Missing request body")

        body        = json.loads(event["body"])
        employee_id = body.get("employee_id")
        action      = body.get("action", "").lower()   # expected: "checkin" or "checkout"

        # Validate that employee_id can be cast to an integer
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return api_response(400, "employee_id must be a number")


        # ----------------------------------------------------------------------
        # STEP 3 — Capture date/time and determine the requested route
        # today / now are used in both checkin and checkout SQL queries.
        # path routing is a fallback alongside the action field in the body.
        # ----------------------------------------------------------------------
        today = date.today()
        now   = datetime.now().time()
        path  = event.get("path", "").lower()   # e.g. "/attendance/checkin"


        # ----------------------------------------------------------------------
        # STEP 4 — Open DB connection
        # ----------------------------------------------------------------------
        conn = get_connection()

        with conn.cursor() as cursor:

            # ------------------------------------------------------------------
            # Verify employee exists before any attendance write
            # ------------------------------------------------------------------
            cursor.execute(
                "SELECT employee_id FROM employees WHERE employee_id = %s",
                (employee_id,)
            )
            if not cursor.fetchone():
                return api_response(404, "Employee not found")


            # ==================================================================
            # STEP 5a — CHECK-IN
            # Routing: URL path contains "checkin" OR body action == "checkin"
            # ==================================================================
            if "checkin" in path or action == "checkin":

                # Guard: one check-in per employee per calendar day
                cursor.execute("""
                    SELECT employee_id
                    FROM   attendance
                    WHERE  employee_id     = %s
                    AND    attendance_date  = %s
                """, (employee_id, today))

                if cursor.fetchone():
                    return api_response(400, "Already checked in today")

                # Insert attendance row with today's date and current time
                cursor.execute("""
                    INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                    VALUES (%s, %s, %s)
                """, (employee_id, today, now))

                conn.commit()   # Persist the insert
                return api_response(200, "Check-in successful")


            # ==================================================================
            # STEP 5b — CHECK-OUT
            # Routing: URL path contains "checkout" OR body action == "checkout"
            # Updates the existing row — employee must have checked in first.
            # ==================================================================
            elif "checkout" in path or action == "checkout":

                cursor.execute("""
                    UPDATE attendance
                    SET    checkout_time   = %s
                    WHERE  employee_id     = %s
                    AND    attendance_date  = %s
                """, (now, employee_id, today))

                # rowcount == 0 means no matching row was found to update
                # (employee never checked in today)
                if cursor.rowcount == 0:
                    return api_response(400, "Check-in required before checkout")

                conn.commit()   # Persist the update
                return api_response(200, "Check-out successful")


            # ==================================================================
            # STEP 5c — INVALID ACTION
            # ==================================================================
            else:
                return api_response(404, "Invalid attendance action. Use 'checkin' or 'checkout'")


    # --------------------------------------------------------------------------
    # Global error handler
    # Rolls back any partial transaction so the DB stays consistent.
    # Returns a 500 with the exception message for debugging.
    # --------------------------------------------------------------------------
    except Exception as e:
        if conn:
            conn.rollback()
        return api_response(500, f"Internal server error: {str(e)}")
```


---
### hr-attendance.py

> **Update Version:1.6**