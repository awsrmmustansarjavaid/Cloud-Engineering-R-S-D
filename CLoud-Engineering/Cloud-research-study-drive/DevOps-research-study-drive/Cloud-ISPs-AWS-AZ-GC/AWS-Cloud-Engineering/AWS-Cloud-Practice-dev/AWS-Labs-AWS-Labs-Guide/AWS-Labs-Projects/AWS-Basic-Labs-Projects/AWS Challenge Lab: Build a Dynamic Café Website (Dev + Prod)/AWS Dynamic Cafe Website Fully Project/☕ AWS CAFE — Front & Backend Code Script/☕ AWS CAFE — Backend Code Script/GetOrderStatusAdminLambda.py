import json
import pymysql
import boto3
import csv
import io
from datetime import datetime

# =========================================================
# GET DATABASE CREDENTIALS FROM SECRETS MANAGER
# =========================================================
def get_db_secret():
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId="CafeDevDBSM")
    return json.loads(response["SecretString"])


# =========================================================
# MAIN LAMBDA HANDLER
# =========================================================
def lambda_handler(event, context):

    # -----------------------------------------------------
    # 1️⃣ READ QUERY PARAMETERS
    # -----------------------------------------------------
    params = event.get("queryStringParameters") or {}

    # If export=true → CSV mode
    export_csv = params.get("export") == "true"

    # Optional date filter (YYYY-MM-DD)
    filter_date = params.get("date")

    # -----------------------------------------------------
    # 2️⃣ CONNECT TO DATABASE
    # -----------------------------------------------------
    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        cursorclass=pymysql.cursors.DictCursor
    )

    try:
        with connection.cursor() as cursor:

            # -------------------------------------------------
            # 3️⃣ BUILD SQL QUERY
            # -------------------------------------------------
            sql = """
                SELECT
                    customer_name,
                    item,
                    quantity,
                    table_number,
                    created_at
                FROM orders
            """

            values = []

            # Optional date filter
            if filter_date:
                sql += " WHERE DATE(created_at) = %s"
                values.append(filter_date)

            sql += " ORDER BY created_at DESC"

            cursor.execute(sql, values)
            orders = cursor.fetchall()

        # -----------------------------------------------------
        # 4️⃣ CSV EXPORT RESPONSE
        # -----------------------------------------------------
        if export_csv:

            output = io.StringIO()
            writer = csv.writer(output)

            # CSV Header
            writer.writerow([
                "Customer",
                "Item",
                "Quantity",
                "Table",
                "Date"
            ])

            # CSV Rows
            for o in orders:
                writer.writerow([
                    o["customer_name"] or "Anonymous",
                    o["item"],
                    o["quantity"],
                    o["table_number"] or "",
                    o["created_at"].strftime("%Y-%m-%d %H:%M:%S")
                ])

            return {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "text/csv",
                    "Content-Disposition": "attachment; filename=orders.csv",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": output.getvalue()
            }

        # -----------------------------------------------------
        # 5️⃣ NORMAL JSON RESPONSE (DASHBOARD)
        # -----------------------------------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "metrics": [
                    {
                        "metric": "Total Orders",
                        "count": len(orders)
                    }
                ],
                "recent_orders": orders
            }, default=str)
        }

    finally:
        connection.close()