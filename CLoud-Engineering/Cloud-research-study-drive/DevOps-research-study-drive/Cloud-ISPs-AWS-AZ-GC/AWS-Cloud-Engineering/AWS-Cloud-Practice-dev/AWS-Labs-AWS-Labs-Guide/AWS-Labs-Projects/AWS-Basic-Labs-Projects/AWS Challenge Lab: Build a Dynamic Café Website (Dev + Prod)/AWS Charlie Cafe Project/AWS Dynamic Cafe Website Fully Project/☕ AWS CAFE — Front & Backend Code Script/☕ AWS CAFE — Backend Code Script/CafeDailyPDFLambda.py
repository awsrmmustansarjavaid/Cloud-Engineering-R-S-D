import boto3
import datetime
import os
from reportlab.platypus import SimpleDocTemplate, Table, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet

# =========================
# 🔹 ENVIRONMENT VARIABLES
# Set these in Lambda console under Configuration → Environment Variables
# KEY                 VALUE
# BUCKET_NAME          charlie-cafe-s3-bucket
# LOGO_KEY             Cafelogo.png
# DYNAMODB_TABLE       CafeOrders
# AWS_REGION           ap-south-1
# =========================

BUCKET_NAME = os.environ.get("BUCKET_NAME", "charlie-cafe-s3-bucket")
LOGO_KEY = os.environ.get("LOGO_KEY", "Cafelogo.png")
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE", "CafeOrders")
AWS_REGION = os.environ.get("AWS_REGION", "ap-south-1")

# =========================
# 🔹 Initialize AWS clients
# =========================
s3 = boto3.client("s3", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

def lambda_handler(event, context):
    """
    Lambda handler to generate daily PDF report for Cafe
    Includes: Logo, Table of Sales, Cost, Profit per Item
    Uploads PDF to S3 at: s3://<BUCKET_NAME>/daily_reports/daily_<YYYY-MM-DD>.pdf
    """

    # -------------------------
    # 🔹 Prepare PDF filename
    # Using /tmp folder in Lambda
    # -------------------------
    today = datetime.date.today().isoformat()  # YYYY-MM-DD
    pdf_path = f"/tmp/daily_report_{today}.pdf"

    # -------------------------
    # 🔹 Fetch orders from DynamoDB
    # Only include COMPLETED orders
    # -------------------------
    response = table.scan()  # Full scan (for small datasets)
    items = response.get("Items", [])

    profit_items = []

    for i in items:
        if i.get("order_status") != "COMPLETED":
            continue  # Skip cancelled or pending orders

        qty = int(i["quantity"])  # Order quantity
        sales = float(i["item_price"]) * qty  # Total sales
        cost = float(i["item_cost"]) * qty    # Total cost

        # Append item-level profit details
        profit_items.append({
            "item": i["item_name"],
            "quantity": qty,
            "sales": round(sales, 2),
            "cost": round(cost, 2),
            "profit": round(sales - cost, 2)
        })

    # -------------------------
    # 🔹 Create PDF document
    # -------------------------
    doc = SimpleDocTemplate(pdf_path, pagesize=A4)
    styles = getSampleStyleSheet()  # default styles
    elements = []

    # -------------------------
    # 🔹 Download logo from S3 to /tmp
    # -------------------------
    logo_path = "/tmp/logo.png"
    s3.download_file(BUCKET_NAME, LOGO_KEY, logo_path)

    # Add logo to PDF
    elements.append(Image(logo_path, width=120, height=60))
    elements.append(Spacer(1, 20))  # Space after logo

    # -------------------------
    # 🔹 Prepare table data
    # -------------------------
    table_data = [["Item", "Qty", "Sales", "Cost", "Profit"]]

    for p in profit_items:
        table_data.append([
            p["item"],
            p["quantity"],
            p["sales"],
            p["cost"],
            p["profit"]
        ])

    # Add table to PDF
    elements.append(Table(table_data))

    # Build PDF
    doc.build(elements)

    # -------------------------
    # 🔹 Upload PDF to S3
    # -------------------------
    s3.upload_file(
        pdf_path,
        BUCKET_NAME,
        f"daily_reports/daily_{today}.pdf"
    )

    # -------------------------
    # 🔹 Return success response
    # -------------------------
    return {
        "statusCode": 200,
        "body": f"PDF generated and uploaded: daily_{today}.pdf"
    }