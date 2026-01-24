import json
import pymysql
import boto3
import os  # Added for environment variables

# ---------- GET DB SECRET ----------
def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

# ---------- SQS CLIENT (outside handler for reuse) ----------
sqs = boto3.client('sqs')
# Load SQS queue URL from Lambda environment variables (already set to https://sqs.us-east-1.amazonaws.com/910599465397/CafeOrdersQueue)
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):
    try:
        # Parse API Gateway body
        body = json.loads(event['body'])
        
        # NEW: Table Number
        table_number = int(body['table_number'])
        customer_name = body.get('customer_name', None)
        item = body['item']
        quantity = int(body['quantity'])

        # Fetch DB credentials
        secret = get_db_secret()

        # Connect to RDS
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        # Insert order into RDS
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (table_number, customer_name, item, quantity)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(
                sql,
                (table_number, customer_name, item, quantity)
            )
            connection.commit()

        connection.close()

        # ────────────────────────────────────────────────
        # NEW: Send message to SQS → triggers Worker Lambda → updates DynamoDB
        # ────────────────────────────────────────────────
        order_data = {
            "source": "web",                    # helps Worker know it's from website
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            # Optional: add timestamp, order_id (if you fetch it), etc.
            # "timestamp": str(datetime.now().isoformat())
        }

        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(order_data),
            # Optional: DelaySeconds=2, MessageGroupId="cafe-orders" (if FIFO queue)
        )

        # Return success to API Gateway / frontend
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order saved successfully",
                "table_number": table_number
            })
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }