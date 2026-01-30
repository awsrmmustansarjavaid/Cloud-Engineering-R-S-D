# ===========================================
# AdminMarkPaidLambda
# Purpose:
# - Used by ADMIN only
# - Marks CASH orders as PAID
# ===========================================

import json
import boto3

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    """
    Expected request body:
    {
        "order_id": "ORD-123456"
    }
    """

    try:
        # -----------------------------
        # Parse incoming request
        # -----------------------------
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -----------------------------
        # Update payment status to PAID
        # -----------------------------
        table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={
                ':ps': 'PAID'
            }
        )

        # -----------------------------
        # Success response
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": True,
                "message": "Order marked as PAID"
            })
        }

    except Exception as e:
        # -----------------------------
        # Error handling
        # -----------------------------
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": False,
                "error": str(e)
            })
        }