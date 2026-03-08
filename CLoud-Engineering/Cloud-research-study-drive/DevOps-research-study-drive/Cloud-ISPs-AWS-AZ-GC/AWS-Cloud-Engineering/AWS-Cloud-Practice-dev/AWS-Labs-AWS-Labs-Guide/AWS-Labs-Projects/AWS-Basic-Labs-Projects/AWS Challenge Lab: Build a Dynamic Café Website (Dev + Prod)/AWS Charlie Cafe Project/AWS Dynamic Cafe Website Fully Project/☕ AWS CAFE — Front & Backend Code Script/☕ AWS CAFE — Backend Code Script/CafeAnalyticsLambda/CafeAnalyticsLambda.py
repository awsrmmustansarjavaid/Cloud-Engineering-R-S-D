# ===========================================
# CafeAnalyticsLambda (RDS - FINAL VERSION)
# ===========================================
# Purpose:
#   ✅ Calculate total sales, total cost, and profit per item
#   ✅ Uses RDS MySQL only (no DynamoDB)
#   ✅ Filters only PAID orders (matches your real data)
#   ✅ Supports period: today / week / month
# ===========================================

import json
import boto3
import pymysql
import os
from datetime import datetime, timedelta

# -----------------------------
# Secrets Manager Setup
# -----------------------------
# The Lambda fetches database credentials securely from AWS Secrets Manager
SECRETS_NAME = os.environ.get('SECRET_NAME', 'CafeDevDBSM')
secrets_client = boto3.client('secretsmanager')

def get_db_secret():
    """
    Fetch RDS database credentials from Secrets Manager
    Returns a dictionary with host, username, password, dbname
    """
    secret = secrets_client.get_secret_value(SecretId=SECRETS_NAME)
    return json.loads(secret['SecretString'])

# -----------------------------
# Standard JSON Response
# -----------------------------
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"  # CORS for frontend
        },
        "body": json.dumps(body)
    }

# -----------------------------
# Lambda Handler
# -----------------------------
def lambda_handler(event, context):
    try:
        # -----------------------------
        # 1️⃣ Determine the period filter
        # -----------------------------
        period = "today"
        if event.get("queryStringParameters"):
            period = event["queryStringParameters"].get("period", "today")

        now = datetime.utcnow()

        # Determine start date based on period
        if period == "today":
            start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
        elif period == "week":
            start_date = now - timedelta(days=7)
        elif period == "month":
            start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        else:
            start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)

        # -----------------------------
        # 2️⃣ Connect to RDS
        # -----------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )

        try:
            with connection.cursor() as cursor:

                # -----------------------------
                # 3️⃣ Fetch all PAID orders since start_date
                # Note: removed 'status = COMPLETED' filter
                # -----------------------------
                sql = """
                    SELECT item,
                           quantity,
                           total_amount,
                           total_cost
                    FROM orders
                    WHERE payment_status = 'PAID'
                    AND created_at >= %s
                """

                cursor.execute(sql, (start_date,))
                rows = cursor.fetchall()

        finally:
            connection.close()

        # -----------------------------
        # 4️⃣ Aggregate totals
        # -----------------------------
        total_sales = 0
        total_cost = 0
        item_stats = {}

        for row in rows:
            item = row["item"]
            qty = int(row["quantity"])
            sales_value = float(row["total_amount"] or 0)
            cost_value = float(row["total_cost"] or 0)

            total_sales += sales_value
            total_cost += cost_value

            if item not in item_stats:
                item_stats[item] = {"quantity": 0, "sales": 0, "cost": 0}

            item_stats[item]["quantity"] += qty
            item_stats[item]["sales"] += sales_value
            item_stats[item]["cost"] += cost_value

        # Prepare per-item profit
        profit_per_item = []
        for item, data in item_stats.items():
            profit_per_item.append({
                "item": item,
                "quantity": data["quantity"],
                "sales": round(data["sales"], 2),
                "cost": round(data["cost"], 2),
                "profit": round(data["sales"] - data["cost"], 2)
            })

        # -----------------------------
        # 5️⃣ Return final JSON
        # -----------------------------
        return response(200, {
            "period": period,
            "total_sales": round(total_sales, 2),
            "total_cost": round(total_cost, 2),
            "profit": round(total_sales - total_cost, 2),
            "orders_count": len(rows),
            "profit_per_item": profit_per_item
        })

    except Exception as e:
        # -----------------------------
        # 6️⃣ Error handling
        # -----------------------------
        return response(500, {"error": str(e)})