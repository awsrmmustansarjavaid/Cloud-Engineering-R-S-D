import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("📩 Worker Lambda triggered by SQS")
    print("Event:", json.dumps(event))

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10,
        autocommit=False
    )

    menu_table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:
                order = json.loads(record["body"])

                table_number = int(order["table_number"])
                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    """
                    INSERT INTO orders
                    (table_number, customer_name, item, quantity)
                    VALUES (%s, %s, %s, %s)
                    """,
                    (table_number, customer_name, item, quantity)
                )

                # ---------- UPDATE DYNAMODB ----------
                menu_table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={
                        ":inc": Decimal(quantity)
                    }
                )

                print("✅ Order processed:", order)

        connection.commit()
        return {"statusCode": 200}

    except Exception as e:
        connection.rollback()
        print("❌ WORKER FAILED:", str(e))
        raise e  # REQUIRED for SQS retry

    finally:
        connection.close()