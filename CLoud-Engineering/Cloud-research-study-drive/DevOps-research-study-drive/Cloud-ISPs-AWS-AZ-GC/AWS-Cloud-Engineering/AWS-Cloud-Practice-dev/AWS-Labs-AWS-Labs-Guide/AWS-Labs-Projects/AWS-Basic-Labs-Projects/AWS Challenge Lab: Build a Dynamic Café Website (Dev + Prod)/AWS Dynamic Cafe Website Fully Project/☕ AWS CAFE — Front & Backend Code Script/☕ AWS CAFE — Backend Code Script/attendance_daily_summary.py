import json
import pymysql
import os
from datetime import date

# Database configuration (set in Lambda environment variables)
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # Get today's date
        today = date.today().strftime('%Y-%m-%d')
        
        # SQL query: daily attendance
        sql = """
            SELECT e.employee_id, e.name, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE a.date = %s
        """
        cursor.execute(sql, (today,))
        result = cursor.fetchall()
        
        return {
            'statusCode': 200,
            'body': json.dumps({'date': today, 'attendance': result})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()