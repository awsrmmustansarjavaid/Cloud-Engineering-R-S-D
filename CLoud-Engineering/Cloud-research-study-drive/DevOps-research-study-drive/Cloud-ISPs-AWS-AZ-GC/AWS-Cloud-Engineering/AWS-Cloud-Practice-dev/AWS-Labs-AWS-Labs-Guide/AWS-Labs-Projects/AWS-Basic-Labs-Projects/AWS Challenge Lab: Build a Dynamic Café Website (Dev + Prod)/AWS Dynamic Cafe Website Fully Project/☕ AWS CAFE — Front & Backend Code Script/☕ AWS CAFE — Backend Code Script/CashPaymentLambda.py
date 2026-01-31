# ===========================================
# CashPaymentLambda
# Purpose:
# - Called when customer selects CASH payment
# - Does NOT mark payment as PAID
# - Admin will mark PAID later
# ===========================================

import json
import boto3

# Create DynamoDB resource
dynamodb = boto3.resource('dynamodb')

# Reference your orders table
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    """
    Expected Input (from API Gateway):
    {
        "order_id": "ORD-123456"
    }
    """

    try:
        # -------------------------------
        # Parse request body
        # -------------------------------
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -------------------------------
        # Update order to CASH + PENDING
        # -------------------------------
        table.update_item(
            Key={
                'order_id': order_id
            },
            UpdateExpression="""
                SET payment_method = :pm,
                    payment_status = :ps
            """,
            ExpressionAttributeValues={
                ':pm': 'CASH',
                ':ps': 'PENDING'
            }
        )

        # -------------------------------
        # Success response
        # -------------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": True,
                "message": "Order marked for cash payment"
            })
        }

    except Exception as e:
        # -------------------------------
        # Error handling
        # -------------------------------
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