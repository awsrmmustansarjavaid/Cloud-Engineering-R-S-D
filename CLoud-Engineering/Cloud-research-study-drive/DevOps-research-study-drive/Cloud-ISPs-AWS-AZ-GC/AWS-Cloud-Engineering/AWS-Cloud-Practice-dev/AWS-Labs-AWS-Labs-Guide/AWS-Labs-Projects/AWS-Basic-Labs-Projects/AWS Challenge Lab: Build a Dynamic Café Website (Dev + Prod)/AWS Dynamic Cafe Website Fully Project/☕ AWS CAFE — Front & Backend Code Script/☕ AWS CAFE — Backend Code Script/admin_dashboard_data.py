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