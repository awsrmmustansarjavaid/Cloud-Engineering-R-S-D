# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

##  hr-checkin.py 


### 1️⃣ hr-checkin.py 
> **Update Version 1.0**

```
import json
import os
import pymysql
from datetime import date, datetime

# Database connection
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    try:
        # Extract Cognito user ID from JWT
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            # Get employee ID
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )
            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            employee_id = employee['employee_id']

            # Insert attendance
            cursor.execute("""
                INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                VALUES (%s, %s, %s)
            """, (employee_id, today, now))

            connection.commit()

        return response(200, "Check-in successful")

    except pymysql.err.IntegrityError:
        return response(400, "Already checked in today")

    except Exception as e:
        return response(500, str(e))

def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": message})
    }
```


---

### 1️⃣ hr-checkin.py 
> **Update Version 1.1**

```
import json
import os
import pymysql
from datetime import date, datetime

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    try:
        # -------------------------------
        # AUTHORIZATION — ROLE CHECK
        # -------------------------------
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", [])

        if isinstance(groups, str):
            groups = [groups]

        if "Employee" not in groups:
            return response(403, "Forbidden")

        # -------------------------------
        # BUSINESS LOGIC (UNCHANGED)
        # -------------------------------
        cognito_user_id = claims["sub"]
        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )
            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            cursor.execute("""
                INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                VALUES (%s, %s, %s)
            """, (employee["employee_id"], today, now))

            connection.commit()

        return response(200, "Check-in successful")

    except pymysql.err.IntegrityError:
        return response(400, "Already checked in today")

    except Exception as e:
        return response(500, str(e))

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
```

---
### 1️⃣ hr-checkin.py 
> **Update Version 1.2**



```
import json
import os
import pymysql
from datetime import date, datetime

# ----------------------------------------
# DATABASE CONNECTION
# ----------------------------------------
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

# ----------------------------------------
# COMMON ROLE CHECK (RBAC)
# ----------------------------------------
def check_role(event, allowed_role):
    """
    Validates if user belongs to required Cognito group
    """
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

# ----------------------------------------
# LAMBDA HANDLER
# ----------------------------------------
def lambda_handler(event, context):
    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return response(403, "Forbidden")

        # ----------------------------------------
        # BUSINESS LOGIC — CHECK-IN
        # ----------------------------------------
        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )
            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            cursor.execute("""
                INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                VALUES (%s, %s, %s)
            """, (employee["employee_id"], today, now))

            connection.commit()

        return response(200, "Check-in successful")

    except pymysql.err.IntegrityError:
        return response(400, "Already checked in today")

    except Exception as e:
        return response(500, str(e))

# ----------------------------------------
# STANDARD RESPONSE
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
```

