# Charlie Cafe -- CafeOrderProcessor


### CafeOrderProcessor.py

> **Update Version:1.0**

```
# ==============================
# IMPORT REQUIRED LIBRARIES
# ==============================

import json                    # For parsing JSON request/response
import pymysql                 # For connecting to RDS MySQL
import boto3                   # AWS SDK (DynamoDB, Secrets Manager)
import os                      # Read environment variables
from decimal import Decimal    # Accurate currency calculations


# ==============================
# ENVIRONMENT VARIABLES
# ==============================

# DynamoDB table name where item cost is stored
# (Configured in Lambda → Environment variables)
MENU_TABLE = os.environ['MENU_TABLE_NAME']

# AWS region where DynamoDB table exists
AWS_REGION = os.environ['AWS_REGION']


# ==============================
# AWS CLIENT INITIALIZATION
# ==============================

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)

# Reference CafeMenu DynamoDB table
menu_table = dynamodb.Table(MENU_TABLE)

# Initialize Secrets Manager client
secrets_client = boto3.client('secretsmanager')


# ==============================
# FETCH DATABASE CREDENTIALS
# ==============================

def get_db_secret():
    """
    Fetch RDS database credentials securely
    from AWS Secrets Manager
    """
    response = secrets_client.get_secret_value(
        SecretId='CafeDevDBSM'  # Secret name (DO NOT hardcode credentials)
    )

    # Convert secret JSON string to Python dictionary
    return json.loads(response['SecretString'])


# ==============================
# FETCH ITEM COST FROM DYNAMODB
# ==============================

def get_item_cost(item_name):
    """
    Fetch base cost of an item from CafeMenu table
    """

    # Query DynamoDB using item_name as partition key
    response = menu_table.get_item(
        Key={'item_name': item_name}
    )

    # If item does not exist, raise error (prevents silent bugs)
    if 'Item' not in response:
        raise Exception(f"Cost not found for item: {item_name}")

    # Return cost as Decimal for accurate calculations
    return Decimal(str(response['Item']['base_cost']))


# ==============================
# MAIN LAMBDA HANDLER
# ==============================

def lambda_handler(event, context):
    try:
        # ------------------------------
        # PARSE API GATEWAY REQUEST BODY
        # ------------------------------
        body = json.loads(event['body'])

        # Extract order details from request
        table_number = int(body['table_number'])
        customer_name = body.get('customer_name')  # Optional field
        item_name = body['item']
        quantity = int(body['quantity'])

        # ------------------------------
        # FETCH ITEM COST & CALCULATE TOTAL COST
        # ------------------------------
        item_cost = get_item_cost(item_name)
        total_cost = item_cost * quantity

        # ------------------------------
        # FETCH RDS DATABASE CREDENTIALS
        # ------------------------------
        secret = get_db_secret()

        # ------------------------------
        # CONNECT TO RDS MYSQL DATABASE
        # ------------------------------
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        # ------------------------------
        # INSERT ORDER INTO DATABASE
        # ------------------------------
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders
                (table_number, customer_name, item, quantity, item_cost, total_cost)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(
                sql,
                (
                    table_number,
                    customer_name,
                    item_name,
                    quantity,
                    float(item_cost),    # Convert Decimal → float for MySQL
                    float(total_cost)
                )
            )
            connection.commit()

        # Close DB connection
        connection.close()

        # ------------------------------
        # SUCCESS RESPONSE TO FRONTEND
        # ------------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order saved successfully",
                "item": item_name,
                "item_cost": float(item_cost),
                "total_cost": float(total_cost)
            })
        }

    except Exception as e:
        # ------------------------------
        # ERROR HANDLING
        # ------------------------------
        print("❌ ERROR:", str(e))

        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": str(e)
            })
        }
```

