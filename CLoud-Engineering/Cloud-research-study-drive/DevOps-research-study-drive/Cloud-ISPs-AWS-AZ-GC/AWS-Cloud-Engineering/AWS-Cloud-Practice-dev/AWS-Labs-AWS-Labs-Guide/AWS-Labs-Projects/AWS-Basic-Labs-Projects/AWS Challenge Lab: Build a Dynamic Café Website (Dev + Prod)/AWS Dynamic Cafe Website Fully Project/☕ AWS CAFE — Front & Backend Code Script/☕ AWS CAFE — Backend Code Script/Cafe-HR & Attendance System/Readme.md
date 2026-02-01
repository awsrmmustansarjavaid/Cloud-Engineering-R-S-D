# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System


## SECTION 1️⃣ - Previous Working Code

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

### 1️⃣ hr-checkout.py
> **Update Version 1.0**

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
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                SET a.checkout_time=%s
                WHERE e.cognito_user_id=%s
                AND a.attendance_date=%s
            """, (now, cognito_user_id, today))

            if cursor.rowcount == 0:
                return response(400, "Check-in required before checkout")

            connection.commit()

        return response(200, "Check-out successful")

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


