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
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee)
    }