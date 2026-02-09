# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

### READ Me About

[Charile Cafe Printing System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%205%20—%20Charile%20Cafe%20Printing%20System.md)

### ☕ AWS Charlie Café – Test & Verifications

[Charile Cafe Printing System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%205%20—%20Charile%20Cafe%20Printing%20System.md)


---
# SECTION 1️⃣ Charlie Cafe - PRINTING System

## 🔐 PHASE 1️⃣ Charlie Cafe - PRINTING (FRONTEND ONLY)

### 1️⃣ Create a Dedicated Printing HTML (central-print.html)

Path: /var/www/html/central-print.html

This will be the universal printing & export hub.

This file will:

- Include central-cafe-style.css for all print styles

- Include central-auth-api.js for browser printing functions

- Include optional export functionality (CSV/PDF)

- Be reusable for any page: order.php, order-status.html, HR reports, etc.

- Allow printing or exporting without duplicating code

### 1️⃣ Create File

```
sudo nano /var/www/html/central-print.html
```

### 2️⃣ Add Full HTML Template

Paste this code into central-print.html. It is fully commented, contains thermal print, daily summary, CSV export, PDF export, and UX/UI features.

[central-print.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Printing%20System/central-print.html)

#### Save File

```
CTRL + O → ENTER
CTRL + X
```

#### Permissions

```
sudo chown apache:apache /var/www/html/central-print.html
```
```
sudo chmod 644 /var/www/html/central-print.html
```

### 3️⃣ Using this Central Print File in Other Pages

- Include a print button on any page, e.g., order-status.html:

```
<button class="btn btn-outline-dark" onclick="openCentralPrint('#ordersTable')">
  🖨️ Print / Export
</button>

<script>
function openCentralPrint(selector) {
  const content = document.querySelector(selector).outerHTML;
  const printWindow = window.open('/central-print.html', '_blank');
  printWindow.onload = function() {
    printWindow.centralPrint.loadContent(content);
  }
}
</script>
```

#### ✅ Works for any table or section.

### 4️⃣ UX / UI Features Added

✔️ Fixed-bottom action buttons for testing (Print, Thermal, CSV, PDF)

✔️ Keyboard shortcuts:

✔️ Ctrl+P → Print A4

✔️ Ctrl+T → Thermal print

✔️ Ctrl+C → CSV export

✔️ Ctrl+D → PDF export

✔️ Alerts if no table found

✔️ Fully responsive using Bootstrap

✔️ Thermal print layout uses central-cafe-style.css


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ Cafe Central Export 

### 1️⃣ Create Cafe Export Lambda

#### 1️⃣ CREATE LAMBDA

```
Name: CafeCentralExportLambda
Runtime: Python 3.10
```

[CafeCentralExportLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeCentralExportLambda.py)


#### 2️⃣ Environment Variables

Set these in Lambda Configuration → Environment variables:

```
ORDERS_TABLE_NAME = CafeOrders
REPORTS_BUCKET_NAME = charlie-cafe-s3-bucket
LOGO_S3_KEY = Cafelogo.png

DB_HOST = your-rds-endpoint.amazonaws.com
DB_NAME = cafe_hr
DB_USER = admin
DB_PASS = password
AWS_REGION = ap-south-1
```

###  2️⃣ ADD REPORTLAB LAYER

- **Lambda → Layers → Create layer**

- **Upload reportlab.zip** (contains reportlab library)

- **Attach layer to:** CafeCentralExportLambda

- **Required S3 PERMISSION:**

    - **Attach IAM policy:**

        - **AmazonS3FullAccess**

        - **CloudWatchLogsFullAccess**

        - **AmazonDynamoDBReadOnlyAccess**

** ⚠️ if you want to pull real data from DynamoDB**



### 3️⃣ — Attach Lambda to API Gateway (MOST IMPORTANT)

You already have the Lambda.
Now we create ONE API Gateway resource and connect it.

#### STEP 1️⃣ Create / Open REST API

In AWS Console:

```
API Gateway → APIs → (Create API OR open existing Cafe API)
→ REST API
```

If you already have a cafe backend API → use the same one.

#### STEP 2️⃣ Create Resource

Create this path:

```
/reports
    └── /export
```

#### Steps:

- Click Resources

- Select /

- Create Resource → name: reports

- Select /reports

- Create Resource → name: export

- Final path:

```
/reports/export
```

#### STEP 3️⃣ Create GET Method

- On /reports/export:

- Click Create Method

- Select GET

- Integration type: Lambda Function

- Lambda function: CafeCentralExportLambda

#### ✅ Enable Lambda Proxy Integration

- Save

#### STEP 4️⃣ — Attach Cognito Authorizer

You already use Cognito, so reuse it.

#### 🔐 Attach Authorizer

- Click GET /reports/export

- Method Request

- Authorization:

  - Select your Cognito User Pool Authorizer

- Save

Now:

  - Only logged-in users reach Lambda

  - Lambda itself checks Admin group

#### STEP 5️⃣ — Enable CORS (VERY IMPORTANT)

On /reports/export:

- Actions → Enable CORS

- Allow:

  - GET

  - Headers: Authorization,Content-Type

- Save

- Deploy API

Without this, browser downloads will FAIL.

#### STEP 6️⃣ — Deploy API

- Actions → Deploy API

- Stage: prod (or your stage)

- Note the URL:

```
https://xxxxx.execute-api.ap-south-1.amazonaws.com/prod
```

This becomes:

```
API_BASE = "https://xxxxx.execute-api.ap-south-1.amazonaws.com/prod"
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣ Automation Report 

### EventBridge Schedule Using Lambda Trigger (Recommanded)

- Go to AWS Console → Lambda → CafeCentralExportLambda

#### Step 1️⃣ — Add EventBridge Trigger

Click "Add trigger" in the Function overview.

Select EventBridge (CloudWatch Events) as the trigger.

Choose “Create a new rule”.

#### Step 2️⃣ — Configure EventBridge Rule

| Field            | Value                                   |
| ---------------- | --------------------------------------- |
| Rule name        | e.g., `DailyOrderPDF`                   |
| Rule description | Generate PDF / CSV report automatically |
| Rule type        | **Schedule expression**                 |


#### Step 3️⃣ — Define Schedule (Pakistan Time)

> **📢 AWS cron uses UTC, Pakistan Standard Time (PST) = UTC+5.**

> **Example: you want midnight PKT, that is 19:00 UTC previous day.**

Daily Report (Midnight Pakistan Time)

```
cron(0 19 * * ? *)
```

🔔 0 → minute 0

🔔 19 → hour in UTC (midnight PKT)

🔔 * * ? * → every day, every month, every year

#### 🕑 Hourly Report

```
cron(0 0/1 * * ? *)
```

🔔 Every hour at minute 0

#### 🕑 Every 10 Minutes (For Testing)

```
cron(0/10 * * * ? *)
```

🔔 Every 10 minutes starting at minute 0

#### ✅ Notes

🔔 ? → required placeholder for day-of-week

🔔 AWS uses cron(Minute Hour Day-of-Month Month Day-of-Week Year)

#### Step 4️⃣ — Configure Input for Lambda

- Scroll to Configure input in EventBridge trigger.

- Select “Constant (JSON text)”.

- Paste mandatory JSON (example for order status PDF):

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

> **This tells your Lambda which report to generate. You can modify "page" to "analytics" for other reports.**

#### Step 5️⃣ — Add Trigger & Deploy

Click Add to attach the EventBridge rule.

Trigger will appear in Lambda diagram.

Test your schedule by setting a short interval (10 min) first.

#### Step 6️⃣ — Optional: Multiple Schedules

You can add multiple EventBridge rules to the same Lambda:

Daily: cron(0 19 * * ? *) → PKT midnight

Hourly: cron(0 0/1 * * ? *) → every hour

10-Min Test: cron(0/10 * * * ? *) → every 10 min

Each schedule can pass different input JSON for different report types.


# SECTION 1️⃣ Charlie Cafe - PRINTING System
---