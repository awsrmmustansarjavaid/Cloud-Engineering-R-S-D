# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System


## SECTION 1️⃣ - Previous Working Code

### 6️⃣ admin_dashboard_data.py
> **Update Version 1.0**

```
import json
import pymysql
import os
from datetime import date

# RDS connection details from Lambda environment variables
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    """
    Returns:
    - Filtered attendance records (optionally by employee_id)
    - Summary counts: total present, absent, leaves
    """

    # Optional query parameter for employee filtering
    employee_id = event.get('queryStringParameters', {}).get('employee_id')

    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)

        # 1️⃣ Attendance Records
        if employee_id:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE e.employee_id = %s
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance, (employee_id,))
        else:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance)

        attendance_records = cursor.fetchall()

        # 2️⃣ Summary Cards
        sql_summary = """
            SELECT 
                COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN a.employee_id END) AS total_present,
                COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN a.employee_id END) AS total_absent,
                (SELECT COUNT(*) FROM leaves) AS total_leaves
            FROM employees e
            LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
        """
        cursor.execute(sql_summary)
        summary = cursor.fetchone()

        return {
            'statusCode': 200,
            'body': json.dumps({'attendance': attendance_records, 'summary': summary})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()
```        

### ✅ admin_dashboard_data.py
> **Update Version 1.1**

Phase 6 you merged the 3 attendance Lambdas into a single Lambda with query param type=daily|weekly|monthly, it’s best to update admin_dashboard_data.py to be consistent with that logic and make it more robust for Phase 7 dashboard needs.

Here’s a fully commented, updated version for your dashboard Lambda:

```
import json
import pymysql
import os
from datetime import date, datetime

# =========================================================
# CHARLIE CAFE — ADMIN DASHBOARD DATA (PHASE 7)
# ---------------------------------------------------------
# Lambda for:
#  - Admin dashboard summary cards (present / absent / leaves)
#  - Attendance table (optionally filtered by employee)
#  - Compatible with Phase 6 merged attendance Lambda logic
# =========================================================

# RDS connection details from Lambda environment variables
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    """
    Handles GET requests from /admin/dashboard API Gateway resource

    Query Parameters:
    - employee_id (optional) : filter by specific employee

    Returns:
    - attendance: list of attendance records
    - summary: total_present, total_absent, total_leaves
    """

    # Optional employee filter
    employee_id = event.get('queryStringParameters', {}).get('employee_id')

    try:
        # Connect to RDS
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        cursor = connection.cursor()

        # =====================================================
        # 1️⃣ Fetch attendance records (latest first)
        # =====================================================
        if employee_id:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE e.employee_id = %s
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance, (employee_id,))
        else:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance)

        attendance_records = cursor.fetchall()

        # =====================================================
        # 2️⃣ Fetch summary cards (present / absent / leaves)
        # =====================================================
        # Present: employees with checkin_time today
        # Absent: total employees - present
        # Leaves: count from leaves table for today
        sql_summary = """
            SELECT
                COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_present,
                COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_absent,
                (SELECT COUNT(*) FROM leaves WHERE leave_date = CURDATE()) AS total_leaves
            FROM employees e
            LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
        """
        cursor.execute(sql_summary)
        summary = cursor.fetchone()

        # =====================================================
        # 3️⃣ Return structured response for frontend
        # =====================================================
        return {
            'statusCode': 200,
            'headers': {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"  # Required for CORS
            },
            'body': json.dumps({
                'attendance': attendance_records,
                'summary': summary
            })
        }

    except Exception as e:
        # =====================================================
        # Error handling
        # =====================================================
        return {
            'statusCode': 500,
            'headers': {"Content-Type": "application/json"},
            'body': json.dumps({'error': str(e)})
        }

    finally:
        # Close connections safely
        if cursor:
            cursor.close()
        if connection:
            connection.close()
```

### ✅ Key Modifications After Phase 6 Merge:

- Single Lambda now matches the Phase 6 merged attendance approach.

- Optional employee filter maintained.

- Summary query updated:

    - Uses CURDATE() for “today” summary.

    - Counts present / absent correctly.

    - Leaves filtered for today only.

    - CORS headers added for frontend requests.

    - Fully commented for easy maintenance.

- Compatible with your updated central-auth-api.js Phase 7 integration (CHARLIE.api.adminDashboard.fetchData()).

---


