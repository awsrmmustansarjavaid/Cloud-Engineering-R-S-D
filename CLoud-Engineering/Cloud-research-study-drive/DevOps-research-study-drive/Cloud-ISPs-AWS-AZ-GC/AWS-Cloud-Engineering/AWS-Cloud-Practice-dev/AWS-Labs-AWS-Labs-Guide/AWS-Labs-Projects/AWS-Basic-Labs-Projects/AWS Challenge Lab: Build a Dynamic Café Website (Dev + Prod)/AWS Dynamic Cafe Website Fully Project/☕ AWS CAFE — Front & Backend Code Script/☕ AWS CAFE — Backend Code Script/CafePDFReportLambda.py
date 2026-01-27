import os
import boto3
import io
import datetime
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# =======================
# ENVIRONMENT VARIABLES
# =======================
# REPLACE VALUES IN LAMBDA ENV VARIABLES (NOT HERE)
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")
REPORTS_BUCKET_NAME = os.environ.get("REPORTS_BUCKET_NAME")
LOGO_FILE_NAME = os.environ.get("LOGO_FILE_NAME", "")

# =======================
# AWS CLIENTS
# =======================
dynamodb = boto3.resource("dynamodb")
orders_table = dynamodb.Table(ORDERS_TABLE_NAME)

s3 = boto3.client("s3")

def lambda_handler(event, context):

    page_type = event.get("queryStringParameters", {}).get("page", "analytics")
    today = datetime.date.today()

    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()
    elements = []

    # =======================
    # LOGO (OPTIONAL)
    # =======================
    if LOGO_FILE_NAME:
        try:
            elements.append(Image(LOGO_FILE_NAME, width=120, height=60))
            elements.append(Spacer(1, 20))
        except:
            pass

    # =======================
    # ANALYTICS PDF
    # =======================
    if page_type == "analytics":

        elements.append(Paragraph("📊 Cafe Sales Analytics Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        # Placeholder analytics (can be replaced later)
        total_sales = 12000
        total_cost = 8000
        profit = total_sales - total_cost

        data = [
            ["Metric", "Amount"],
            ["Total Sales", total_sales],
            ["Total Cost", total_cost],
            ["Profit", profit]
        ]

        table = Table(data, colWidths=[200, 150])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.brown),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 1, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.beige)
        ]))

        elements.append(table)

    # =======================
    # ORDER STATUS PDF
    # =======================
    elif page_type == "order-status":

        elements.append(Paragraph("📝 Cafe Order Status Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        orders = orders_table.scan().get("Items", [])

        table_data = [["Order ID", "Item", "Qty", "Cost", "Price", "Profit"]]

        for o in orders:
            qty = int(o.get("quantity", 1))
            cost = float(o.get("item_cost", 0)) * qty
            price = float(o.get("item_price", 0)) * qty
            profit = price - cost

            table_data.append([
                o.get("order_id"),
                o.get("item_name"),
                qty,
                cost,
                price,
                profit
            ])

        table = Table(table_data, colWidths=[80, 110, 50, 60, 60, 60])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.darkblue),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 0.5, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
        ]))

        elements.append(table)

    # =======================
    # BUILD PDF
    # =======================
    doc.build(elements)

    buffer.seek(0)

    s3_key = f"{page_type}_report_{today}.pdf"

    s3.put_object(
        Bucket=REPORTS_BUCKET_NAME,
        Key=s3_key,
        Body=buffer.getvalue(),
        ContentType="application/pdf"
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode("latin1"),
        "isBase64Encoded": False
    }