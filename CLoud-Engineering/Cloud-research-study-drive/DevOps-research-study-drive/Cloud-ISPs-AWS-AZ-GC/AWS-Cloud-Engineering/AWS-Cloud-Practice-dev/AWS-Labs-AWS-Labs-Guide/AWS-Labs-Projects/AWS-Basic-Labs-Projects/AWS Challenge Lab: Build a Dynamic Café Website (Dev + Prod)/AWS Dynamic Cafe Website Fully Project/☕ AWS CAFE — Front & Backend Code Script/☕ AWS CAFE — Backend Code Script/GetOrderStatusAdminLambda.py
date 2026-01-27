import csv
import io

if export_csv:
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Customer", "Item", "Quantity", "Table", "Date"])
    for o in orders:
        writer.writerow([o["customer_name"], o["item"], o["quantity"], o["table_number"], o["created_at"]])
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": "attachment; filename=orders.csv",
            "Access-Control-Allow-Origin": "*"
        },
        "body": output.getvalue()
    }