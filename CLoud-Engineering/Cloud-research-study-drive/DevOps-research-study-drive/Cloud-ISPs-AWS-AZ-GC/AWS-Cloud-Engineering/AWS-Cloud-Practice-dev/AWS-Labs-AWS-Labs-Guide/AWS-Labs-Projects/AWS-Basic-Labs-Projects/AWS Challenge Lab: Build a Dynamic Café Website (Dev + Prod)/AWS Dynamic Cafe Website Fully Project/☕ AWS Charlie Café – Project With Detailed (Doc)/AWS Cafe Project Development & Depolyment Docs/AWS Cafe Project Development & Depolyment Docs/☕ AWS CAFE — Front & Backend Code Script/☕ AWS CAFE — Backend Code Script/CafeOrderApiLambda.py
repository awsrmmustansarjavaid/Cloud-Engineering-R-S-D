import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        # ---------- Parse request body ----------
        body = json.loads(event.get("body", "{}"))

        # ---------- Validate required fields ----------
        required_fields = ["table_number", "item", "quantity"]
        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {"Access-Control-Allow-Origin": "*"},
                    "body": json.dumps({
                        "error": f"Missing required field: {field}"
                    })
                }

        # ---------- Validate data ----------
        table_number = int(body["table_number"])
        quantity = int(body["quantity"])

        if table_number <= 0:
            raise ValueError("Invalid table number")

        if quantity <= 0:
            raise ValueError("Quantity must be greater than zero")

        # ---------- Build order payload ----------
        order = {
            "table_number": table_number,
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": quantity
        }

        # ---------- Send message to SQS ----------
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order accepted",
                "order": order
            })
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }