import json
import os
import pymysql

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT a.attendance_date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
            ORDER BY a.attendance_date DESC
        """, (cognito_user_id,))
        records = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(records)
    }