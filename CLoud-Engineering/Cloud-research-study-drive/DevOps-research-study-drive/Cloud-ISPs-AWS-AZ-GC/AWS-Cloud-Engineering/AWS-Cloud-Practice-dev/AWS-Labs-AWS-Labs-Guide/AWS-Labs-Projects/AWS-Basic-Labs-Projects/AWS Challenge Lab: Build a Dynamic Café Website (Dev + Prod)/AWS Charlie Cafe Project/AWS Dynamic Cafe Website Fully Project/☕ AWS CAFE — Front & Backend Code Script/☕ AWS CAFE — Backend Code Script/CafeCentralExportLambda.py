import os
import json
import csv
import io
import datetime
import boto3
import pymysql
from decimal import Decimal
from collections import defaultdict

from reportlab.platypus import (
    SimpleDocTemplate, Table, TableStyle,
    Paragraph, Image, Spacer
)
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# ==================================================
# ENV VARIABLES
# ==================================================
ORDERS_TABLE = os.environ["ORDERS_TABLE_NAME"]
REPORTS_BUCKET = os.environ["REPORTS_BUCKET_NAME"]
LOGO_KEY = os.environ.get("LOGO_S3_KEY")

DB_HOST = os.environ.get("DB_HOST")
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")
AWS_REGION = os.environ.get("AWS_REGION", "ap-south-1")

# ==================================================
# AWS CLIENTS
# ==================================================
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
orders_table = dynamodb.Table(ORDERS_TABLE)
s3 = boto3.client("s3", region_name=AWS_REGION)

# ==================================================
# RDS CONNECTION
# ==================================================
def get_db():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# ==================================================
# AUTH CHECK (ADMIN ONLY)
# ==================================================
def require_admin(event):
    try:
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", "")
        if "Admin" not in groups:
            raise Exception("Forbidden")
    except:
        return False
    return True

# ==================================================
# MAIN HANDLER
# ==================================================
def lambda_handler(event, context):

    params = event.get("queryStringParameters") or {}
    export_type = params.get("type", "pdf")      # pdf | csv
    report = params.get("report", "analytics")   # analytics | orders | daily | attendance

    # Admin-only exports
    if not require_admin(event):
        return {"statusCode": 403, "body": "Admin access required"}

    # ==================================================
    # CSV EXPORT
    # ==================================================
    if export_type == "csv":
        return generate_csv_analytics()

    # ==================================================
    # PDF EXPORT
    # ==================================================
    return generate_pdf_report(report)


# ==================================================
# CSV ANALYTICS
# ==================================================
def generate_csv_analytics():

    response = orders_table.scan()
    orders = response.get("Items", [])

    item_data = defaultdict(lambda: {
        "qty": 0,
        "sales": Decimal("0"),
        "cost": Decimal("0")
    })

    for o in orders:
        if o.get("order_status") != "COMPLETED":
            continue

        qty = int(o["quantity"])
        price = Decimal(str(o["item_price"]))
        cost = Decimal(str(o["item_cost"]))
        name = o["item_name"]

        item_data[name]["qty"] += qty
        item_data[name]["sales"] += price * qty
        item_data[name]["cost"] += cost * qty

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Item", "Quantity", "Sales", "Cost", "Profit"])

    for item, d in item_data.items():
        writer.writerow([
            item, d["qty"],
            float(d["sales"]),
            float(d["cost"]),
            float(d["sales"] - d["cost"])
        ])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": "attachment; filename=cafe-analytics.csv",
            "Access-Control-Allow-Origin": "*"
        },
        "body": output.getvalue()
    }

# ==================================================
# PDF GENERATOR
# ==================================================
def generate_pdf_report(report_type):

    today = datetime.date.today()
    buffer = io.BytesIO()

    doc = SimpleDocTemplate(buffer, pagesize=A4)
    styles = getSampleStyleSheet()
    elements = []

    # Download logo from S3
    if LOGO_KEY:
        logo_path = "/tmp/logo.png"
        try:
            s3.download_file(REPORTS_BUCKET, LOGO_KEY, logo_path)
            elements.append(Image(logo_path, 120, 60))
            elements.append(Spacer(1, 20))
        except:
            pass

    elements.append(Paragraph(f"{report_type.upper()} REPORT", styles["Title"]))
    elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
    elements.append(Spacer(1, 15))

    if report_type in ["analytics", "orders", "daily"]:
        orders = orders_table.scan().get("Items", [])
        table_data = [["Item", "Qty", "Sales", "Cost", "Profit"]]

        for o in orders:
            if o.get("order_status") != "COMPLETED":
                continue

            qty = int(o["quantity"])
            sales = float(o["item_price"]) * qty
            cost = float(o["item_cost"]) * qty

            table_data.append([
                o["item_name"], qty,
                round(sales, 2),
                round(cost, 2),
                round(sales - cost, 2)
            ])

        elements.append(Table(table_data))

    elif report_type == "attendance":
        conn = get_db()
        with conn.cursor() as c:
            c.execute("""
                SELECT e.name, e.job_title, a.attendance_date,
                       a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
            """)
            rows = c.fetchall()

        table_data = [["Name", "Job", "Date", "In", "Out"]]
        for r in rows:
            table_data.append([
                r["name"], r["job_title"],
                str(r["attendance_date"]),
                str(r["checkin_time"] or ""),
                str(r["checkout_time"] or "")
            ])

        elements.append(Table(table_data))

    doc.build(elements)
    buffer.seek(0)

    key = f"exports/{report_type}_{today}.pdf"
    s3.put_object(
        Bucket=REPORTS_BUCKET,
        Key=key,
        Body=buffer.getvalue(),
        ContentType="application/pdf"
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode("latin1"),
        "isBase64Encoded": False
    }
