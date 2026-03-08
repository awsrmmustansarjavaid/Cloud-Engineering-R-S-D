import json
import boto3
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("CafeAttendance")

def lambda_handler(event, context):

    # Admin-only endpoint (Cognito authorizer handles role)
    params = event.get("queryStringParameters") or {}
    employee_id = params.get("employee_id")
    date = params.get("date")

    if not employee_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "employee_id required"})
        }

    key_expr = "#eid = :eid"
    expr_attr = {
        ":eid": employee_id
    }

    if date:
        key_expr += " AND #d = :d"
        expr_attr[":d"] = date

    response = table.query(
        KeyConditionExpression=key_expr,
        ExpressionAttributeNames={
            "#eid": "employee_id",
            "#d": "date"
        },
        ExpressionAttributeValues=expr_attr
    )

    return {
        "statusCode": 200,
        "body": json.dumps(response["Items"])
    }