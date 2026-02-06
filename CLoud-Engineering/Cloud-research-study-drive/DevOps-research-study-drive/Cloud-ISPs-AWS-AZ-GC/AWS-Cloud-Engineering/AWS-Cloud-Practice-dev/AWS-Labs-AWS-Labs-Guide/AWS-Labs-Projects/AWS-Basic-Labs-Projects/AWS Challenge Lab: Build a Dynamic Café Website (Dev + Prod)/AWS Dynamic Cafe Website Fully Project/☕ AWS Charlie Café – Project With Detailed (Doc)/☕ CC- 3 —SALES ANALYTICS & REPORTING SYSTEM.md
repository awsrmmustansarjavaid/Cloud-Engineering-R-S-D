# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**

### READ Me About

[☕ CC- 3 —SALES ANALYTICS & REPORTING SYSTEM](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

### ☕ AWS Charlie Café – Test & Verifications

[☕ CC- 3 —SALES ANALYTICS & REPORTING SYSTEM](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

---

# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

> **⚠️ This phase is mandatory before Lambda works.**

### 1️⃣ VERIFY EXISTING ORDERS TABLE (REQUIRED STRUCTURE)

#### 1️⃣ Open DynamoDB Console: 

```
AWS Console → DynamoDB → Tables
```

#### 2️⃣ Confirm Table Name: 

```        
CafeOrders
```

**❌ If the name is different, STOP and rename your code, not the table.**

#### 3️⃣ Verify Table Keys (CRITICAL)

- **Go to Table details → General information**

#### Confirm:

| Setting       | Value             |
| ------------- | ----------------- |
| Table name    | CafeOrders        |
| Partition key | order_id (String) |
| Sort key      | ❌ NONE (expected) |


**⚠️ Do NOT add a sort key to the main table**
> **Analytics filtering will be done via GSI.**

### 2️⃣ VERIFY REQUIRED ATTRIBUTES EXIST (DATA CONTRACT)

> **Your analytics depends on these attributes already existing in items.**

#### 1️⃣ Open CafeOrders → Explore Table

> **✅ Required Attributes per Order Item***

#### Every COMPLETED order MUST contain:

| Attribute       | Type   | Why Needed       |
| --------------- | ------ | ---------------- |
| order_id        | String | Primary Key      |
| order_date      | String | GSI partition    |
| order_timestamp | Number | GSI sort         |
| total_amount    | Number | Sales            |
| total_cost      | Number | Cost             |
| order_status    | String | Filter COMPLETED |

**⚠️ If any attribute is missing, analytics will break.**

#### 📌 IMPORTANT

- order_timestamp is required for fast filtering

- Use Unix timestamp

#### 2️⃣ Verify Attributes Exist in Real Data

- **DynamoDB → CafeOrders**

- Click Explore table items

- Open at least 3 COMPLETED orders

- **Manually confirm:**

    - order_date format = 2026-01-17

    - order_timestamp is Number, not String

    - total_amount and total_cost are Numbers

**❌ If any attribute is missing, STOP and fix order-saving logic first.**

### 3️⃣ – ADD ADD GLOBAL SECONDARY INDEX (GSI - VERY IMPORTANT)

> **This step enables date-range queries (today / week / month).**

#### 1️⃣ Go to Indexes Tab

```
AWS Console → DynamoDB → CafeOrders → Indexes → Create index
```

#### 2️⃣ Create Global Secondary Index

#### Configure Index EXACTLY:

| Setting       | Value                    |
| ------------- | ------------------------ |
| Index name    | order_date-index         |
| Partition key | order_date (String)      |
| Sort key      | order_timestamp (Number) |
| Projection    | ALL                      |

- **Create Index**

⏳ Wait until Index status = ACTIVE

⚠️ Do not continue until ACTIVE.

❌ Do not deploy Lambda before this

### 3️⃣ – EXACT DYNAMODB QUERY CODE (REQUIRED)

> **This is the canonical query function used by Analytics Lambda.**

#### ✅ Python Query Function (COPY AS-IS)

> **Daily / Weekly / Monthly Query (Python)**

```
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def query_orders(start_date, end_date):
    response = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': start_date,
            ':e': end_date
        }
    )
    return response['Items']
```

#### ✅ FINAL UPDATED CODE

> **(Same Logic + Comments)**

```
import boto3
from decimal import Decimal

# Initialize DynamoDB resource using default AWS credentials and region
dynamodb = boto3.resource('dynamodb')

# Reference the DynamoDB table that stores cafe orders
# ⚠️ Replace 'CafeOrders' only if your actual table name is different
table = dynamodb.Table('CafeOrders')


def query_orders(start_date, end_date):
    """
    Query orders from DynamoDB between two dates.

    Parameters:
    - start_date (str): Start date in YYYY-MM-DD format
    - end_date (str): End date in YYYY-MM-DD format

    Returns:
    - List of order items from DynamoDB
    """

    # Perform query operation on DynamoDB
    # Uses Global Secondary Index (GSI): order_date-index
    # This index MUST exist on the CafeOrders table
    response = table.query(
        IndexName='order_date-index',

        # Fetch only items where order_date is between start_date and end_date
        KeyConditionExpression='order_date BETWEEN :s AND :e',

        # Expression values used in KeyConditionExpression
        ExpressionAttributeValues={
            ':s': start_date,   # Start date boundary
            ':e': end_date      # End date boundary
        }
    )

    # Return the list of matching order records
    return response['Items']
```

#### 📌 Notes:

- start_date and end_date must be strings

- Format: "YYYY-MM-DD"

- This code assumes GSI already exists

#### 4️⃣ MANUAL TESTING (NO LAMBDA YET)

#### 1️⃣ Insert Test Orders (If Needed)

**⚠️ If you don’t already have test data:**

- DynamoDB → Explore table items

- Click Create item

- Add at least 3 items:

#### Example:

```
order_id: ORD-TEST-001
order_date: 2026-01-17
order_timestamp: 1705488000
total_amount: 30
total_cost: 18
order_status: COMPLETED
```

#### 💠 Create:

- One order for today

- One order for 7 days ago

- One order for earlier this month

#### 2️⃣ TEST QUERY USING AWS LAMBDA (TEMP TEST)

> **This confirms the index + query code works.**

#### 1️⃣ Create TEMP Test Lambda

- **AWS → Lambda → Create function**

- **Name:**

```
CafeDynamoTestLambda
```

- **Runtime:** Python 3.10

- **Permissions:**

```
AmazonDynamoDBReadOnlyAccess

CloudWatchLogsFullAccess
```
#### ✅ FINAL UPDATED CODE 

> **(Same Logic + Comments + Env Variables)**

[CafeDynamoTestLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeDynamoTestLambda.py)

#### 3️⃣ Run Test

- Click Test

- Create test event → {} (empty JSON)

- Run

#### ✅ EXPECTED RESULT (PASS CRITERIA)

✔ StatusCode = 200

✔ count > 0

✔ Items returned are only:

    - From January

    - Have correct order_date

    - Sorted by timestamp

#### ❌ If error:

- Check GSI name

- Check attribute types

- Check index status = ACTIVE


**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**
---
## PHASE 2️⃣  – ANALYTICS LAMBDA (FULL CODE)

### 1️⃣ Create Cafe Analytics Lambda

- **AWS Console → Lambda → Create function**


#### 1️⃣ Lambda configurations

```
Function name: CafeAnalyticsLambda
Runtime: Python 3.10
Execution role: Create new role
```
### 2️⃣ DEPLOY CODE

**FULL CafeAnalyticsLambda PYTHON CODE (COPY-PASTE)**

#### ✅ FINAL ANALYTICS LAMBDA (WITH COMMENTS ONLY)

🔒 Logic unchanged

🧠 Architecture unchanged

📝 Only comments added

🌱 Environment variable usage clarified

[CafeAnalyticsLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)


### 3️⃣ 🔐 Environment Variable Required

- Open Lambda → Your Function

- Go to Configuration → Environment variables

- Click Edit → Add environment variable

| Variable            | Example      |
| ------------------- | ------------ |
| `ORDERS_TABLE_NAME` | `CafeOrders` |

👉 Click Save


**✅ PHASE 2 STATUS**

> **🟢 PHASE 2 COMPLETE & VERIFIED**
---
## PHASE 3️⃣  – API GATEWAY

### 1️⃣ – API GATEWAY CONFIGURATION

####  1️⃣ Create Resource

- **Go to API Gateway → Your Existing API → Resources → Create Resource**

```
Resource Name: analytics
Resource Path: /analytics
```

####  2️⃣ CREATE METHOD

```
Create Method → GET
Integration: Lambda Proxy
Lambda: CafeAnalyticsLambda
```

####  3️⃣ ENABLE CORS

```
Actions → Enable CORS
```

#### Confirm:

```
GET, OPTIONS
```

####  4️⃣ QUERY STRING PARAMETERS

#### 1️⃣ Find URL Query String Parameters

> **You will see sections like:**

- Authorization

- Request Validator

- URL Query String Parameters

- HTTP Request Headers

#### 👉 Find this section:

```
URL Query String Parameters
```

#### 2️⃣ ADD period PARAMETER (EXACT)

- Click Edit (top right)

- Under URL Query String Parameters

- Click Add query string

- **Enter:**

```
Name: period
Required: ❌ NO (leave unchecked)
```
#### Set Allowed Values for period Parameter

- After adding the query string period (Required = ❌ No), click on it.

- Look for “Request Validator / Model” or “Validation” (depends on API Gateway type).

- Under Allowed Values / Enum (if using REST API Request Validator with Model):

```
today
week
month
```

- **Click Save**

#### ⚠️ Important Notes

- ⚠️ If you skip this, API Gateway will accept any value and Lambda must handle invalid ones.

- ⚠️ Do NOT mark it required

- ⚠️ Required = unchecked,  You don’t need to mark as required — Lambda already checks for invalid or missing values.

#### In short:

| Parameter | Required | Allowed Values     |
| --------- | -------- | ------------------ |
| period    | No       | today, week, month |


**That’s it — this is all you need for allowed values configuration.**


#### 3️⃣ VERIFY

> **You must now see:**

```
URL Query String Parameters
--------------------------------
period   false
```

**⚠️ If you don’t see this → it was NOT saved.

#### 4️⃣ DO NOTHING ELSE HERE

✅ Do NOT add mapping templates

✅ Do NOT add models

✅ Do NOT add validators

✅ Do NOT touch headers

**⚠️  Because: ✔ Lambda Proxy Integration already passes query parameters automatically**

####  5️⃣ DEPLOY API

> **If you skip this → nothing works**

- Click Actions

- Click Deploy API

- **Choose:**

```
Stage: prod
```

(or your existing stage)

- **Click Deploy**

#### 6️⃣ FINAL API URL FORMAT (CONFIRM)

Your final URL MUST look like this:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=today
```

#### Examples:

```
?period=today
?period=week
?period=month
```

#### 🧠 HOW THIS CONNECTS TO YOUR LAMBDA

API Gateway sends this to Lambda automatically:

```
{
  "queryStringParameters": {
    "period": "today"
  }
}
```

Which your Lambda reads as:

```
event['queryStringParameters']['period']
```



**✅ PHASE 3 STATUS**

> **🟢 PHASE 3 COMPLETE & VERIFIED**
---

## PHASE 4️⃣  BOOTSTRAP ANALYTICS UI

### 1️⃣ Create analytics.html

```
sudo nano /var/www/html/analytics.html
```

### 2️⃣ analytics.html (FULL CODE)

[analytics.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)

### 3️⃣ File PERMISSIONS (MANDATORY)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```


### 4️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```


**✅ PHASE 4 STATUS**

> **🟢 PHASE 4 COMPLETE & VERIFIED**
---

## PHASE 5️⃣  ☕ MULTI-PAGE SUPPORT PDF GENERATION LAMBDA (REPORTLAB)

### 📄 Printing System 2 — Server PDF (Lambda + ReportLab)

> **(PHASE 5 & 6)**

### 1️⃣ Create Cafe PDF Report Lambda

#### 1️⃣ CREATE LAMBDA

```
Name: CafePDFReportLambda
Runtime: Python 3.10
```

###  2️⃣ ADD REPORTLAB LAYER

- **Lambda → Layers → Create layer**

- **Upload reportlab.zip** (contains reportlab library)

- **Attach layer to:** CafePDFReportLambda

- **Required S3 PERMISSION:**

    - **Attach IAM policy:**

        - **AmazonS3FullAccess**

        - **CloudWatchLogsFullAccess**

        - **AmazonDynamoDBReadOnlyAccess**

** ⚠️ if you want to pull real data from DynamoDB**

###  3️⃣ DEPLOY EXISTING PDF CODE

#### 1️⃣ UPDATED CafePDFReportLambda FULL PYTHON CODE (PDF for BOTH PAGES)

[CafePDFReportLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafePDFReportLambda.py)

#### 2️⃣ 🔐 Environment Variables Required

- Open Lambda → Your Function

- Go to Configuration → Environment variables

- Click Edit → Add environment variable

You will configure these in Lambda (steps below):

| Variable Name         | Value (example) |
| --------------------- | --------------- |
| `ORDERS_TABLE_NAME`   | `CafeOrders`    |
| `REPORTS_BUCKET_NAME` | `charlie-cafe-s3-bucket`  |
| `LOGO_FILE_NAME`      | `Cafelogo.png`  |

👉 Click Save

#### 3️⃣ TESTING THE PDF LAMBDA

- **Go to AWS Console → Lambda → CafePDFReportLambda.**

- Click “Test” button on top-right.

- If you haven’t created a test event yet, it will ask you to configure a new test event.

#### 1️⃣ Create Test Event

- **Event Name:** TestAnalyticsPDF

- **Event JSON:**

#### 1️⃣ To test Analytics PDF:

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 2️⃣ To test Order Status PDF:

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

> **Explanation: queryStringParameters.page is how our Lambda knows which page to generate.**

- **Click “Create”.**

#### 2️⃣ Run Test

- Click “Test” (top-right).

- Lambda will execute.

- **Scroll down to Execution Result → should see:**

```
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/pdf" },
  "body": "...", 
  "isBase64Encoded": false
}
```

> **☢️ Note: body contains the PDF binary in latin1 encoding. You won’t see the PDF in the console, but the Lambda writes the file to your S3 bucket (cafe-reports) if S3 put_object succeeds.**

#### 3️⃣ Verify S3

- **Go to S3 → your bucket.**

You should see:

```
analytics_report_2026-01-17.pdf
order-status_report_2026-01-17.pdf
```

- Click → Download → Open in PDF viewer.

**✅ You now have both PDFs.**


**✅ PHASE 5 STATUS**

> **🟢 PHASE 5 COMPLETE & VERIFIED**
---
## PHASE 6️⃣  CONNECT PDF BUTTON WITH API ( API GATEWAY)

### 1️⃣ CONFIGURE API GATEWAY (FOR MULTI-PAGE PDF)

#### 1️⃣ – OPEN API GATEWAY

- Login to AWS Console

- Go to API Gateway

- Click APIs

- Click your existing API
> **(example name: CafeLabAPI)**

**⚠️ You should now see Resources tree on left side**

#### 2️⃣ – CREATE /report RESOURCE (IF NOT EXISTS)

#### 1️⃣  Check if /report already exists

#### Look in resource tree:

- If you see /report → go to STEP 3

- If NOT → create it

#### 2️⃣ Create /report

- Click root /

- Click Create Resource

- **Resource Name:**

```
report
```

- **Resource Path auto-fills:**

```
/report
```

- Click Create Resource

**✅ /report now exists**

#### 3️⃣ – CREATE /pdf RESOURCE (VERY IMPORTANT)

- Click /report

- Click Create Resource

- **Resource Name:**

```
pdf
```

- **Resource Path auto-fills:**

```
/report/pdf
```

- Click Create Resource

**✅ Final path must be exactly:**

#### 4️⃣ – CREATE POST METHOD (DO NOT SKIP)

- Select /report/pdf

- Click Create Method

- **Choose:**

```
POST
```

- Click ✔️

#### 5️⃣ – CONNECT METHOD TO LAMBDA (CRITICAL)

You are now on POST – Setup page

#### 1️⃣ Integration settings (EXACT VALUES)

| Field                    | Value               |
| ------------------------ | ------------------- |
| Integration type         | Lambda Function     |
| Lambda proxy integration | ✅ CHECKED           |
| Lambda function          | CafePDFReportLambda |
| Use default timeout      | ✅                   |

**⚠️ Region must match Lambda region**

#### 2️⃣ Click Save

If AWS asks permission:

> **“Allow API Gateway to invoke Lambda?”**

- ✔️ Click OK

#### 6️⃣ – ENABLE CORS (DO NOT MISS)

- Select /report/pdf

- Click Enable CORS

- **In popup:**

    - Leave default values

- Click Enable CORS and replace existing CORS headers

- Click Yes, replace existing values

**✅ CORS headers added**

#### 7️⃣ – DEPLOY API (MANDATORY)

If you skip this → NOTHING WILL WORK

- Click Deploy API

- **Deployment stage:**

    - **Choose existing stage (example: prod)**

- Click Deploy

#### 8️⃣ – COPY FINAL PDF API URL

#### After deploy, copy this:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf
```

#### ✏️ Replace:

- API_ID

- REGION

SAVE THIS URL – you will use it in frontend

#### 9️⃣ – UNDERSTAND page QUERY PARAMETER (VERY IMPORTANT)

#### Your Lambda reads:

```
event.queryStringParameters.page
```

#### So API expects:

| Page         | URL                  |
| ------------ | -------------------- |
| Analytics    | `?page=analytics`    |
| Order Status | `?page=order-status` |


#### 🔟 – TEST API WITHOUT FRONTEND (DO THIS FIRST)

#### 1️⃣ Test from Browser (FASTEST)

- **Paste in browser:**

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=analytics
```

#### EXPECTED RESULT:

- Browser downloads OR opens PDF

- Lambda logs show SUCCESS

- S3 bucket contains:

    ```
    analytics_report_YYYY-MM-DD.pdf
    ```

#### 1️⃣ Test Order Status PDF

- **Paste:**

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=order-status
```

#### EXPECTED RESULT:

- PDF opens/downloads

- Order table visible

- S3 object created:

    ```
    order-status_report_YYYY-MM-DD.pdf
    ```

❌ If this fails → STOP

❌ Do NOT touch frontend yet

#### 1️⃣1️⃣ – TEST FROM LAMBDA CONSOLE (MANDATORY)

- Open Lambda → CafePDFReportLambda

- Click Test

- Create test event

- **Name:**

```
AnalyticsPDFTest
```

#### 1️⃣ Test Event JSON (COPY EXACTLY)

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

- Click Test

#### EXPECT:

- StatusCode: 200

- No errors

- PDF saved to S3

#### 2️⃣ Order Status Lambda Test

Create new test:

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

#### 1️⃣2️⃣ – CONNECT ANALYTICS PAGE BUTTON

#### 1️⃣ Open analytics.html

#### 2️⃣ Replace downloadPDF() with:

```
function downloadPDF(){
  window.open(
    "https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=analytics",
    "_blank"
  );
}
```

#### ⚠️ Replace:

- API_ID

- REGION

#### 1️⃣3️⃣ – CONNECT ORDER STATUS PAGE BUTTON

#### 1️⃣ Open order-status.html

#### 2️⃣ Add / Update function:

```
function downloadOrderPDF(){
  window.open(
    "https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=order-status",
    "_blank"
  );
}
```

#### 3️⃣ Attach button:

```
<button class="btn btn-success btn-sm" onclick="downloadOrderPDF()">
  📄 Download Orders PDF
</button>
```

#### 1️⃣4️⃣ – FINAL FULL TEST (DO NOT SKIP)

**✔ Test Matrix**

| Test                         | Result |
| ---------------------------- | ------ |
| Browser direct analytics PDF | ✅      |
| Browser direct order PDF     | ✅      |
| Lambda test analytics        | ✅      |
| Lambda test order-status     | ✅      |
| Analytics page button        | ✅      |
| Order status page button     | ✅      |


#### 1️⃣5️⃣ STATUS: COMPLETE & VERIFIED

✔ API Gateway connected

✔ Lambda receives page parameter

✔ Two pages → one PDF Lambda

✔ Browser downloads PDF

✔ Safe to move to next phase

#### 🔒 IMPORTANT RULE

**❗ DO NOT MOVE TO NEXT PHASE UNTIL ALL TESTS ABOVE PASS**


**✅ PHASE 6 STATUS**

> **🟢 PHASE 6 COMPLETE & VERIFIED**
---
## PHASE 7️⃣  Automation Monthly Auto Report

### 2️⃣ METHOD 1- EventBridge Schedule Using Lambda Trigger  (Recommanded)

#### 1️⃣ TASK 1️⃣: ADD DAILY ORDER STATUS PDF (USING LAMBDA TRIGGER)

#### 1️⃣ OPEN LAMBDA

- AWS Console → Lambda

- Click CafePDFReportLambda

#### 2️⃣ OPEN TRIGGERS TAB

- Scroll to Function overview

- Click ➕ Add trigger

#### 3️⃣ SELECT EVENT SOURCE

- Select source: EventBridge (CloudWatch Events)

**⚠️ This opens EventBridge configuration inside Lambda**

#### 4️⃣ CONFIGURE EVENTBRIDGE RULE

- **Rule settings:**

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Rule             | **Create a new rule**           |
| Rule name        | `DailyOrderPDF`                 |
| Rule description | Generate Order Status PDF daily |
| Rule type        | **Schedule expression**         |

#### 5️⃣ ADD CRON SCHEDULE

**Paste exactly this:**

```
cron(0 0 * * ? *)
```
#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

#### 🔘 Explanation (DO NOT CHANGE):

- Runs every day

- Time: 00:00 UTC

- **AWS requires ? in day-of-month or day-of-week**

#### 6️⃣ CONFIGURE INPUT (VERY IMPORTANT)

Scroll to Configure input

- Select: Constant (JSON text)

- **Paste EXACT JSON:**

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

**❗ This JSON is mandatory**

**❗ Without this, Lambda won’t know which PDF to generate**

#### 7️⃣ ADD TRIGGER

- Click Add

- Trigger appears in Lambda diagram

**✅ Daily automation is now ACTIVE**


#### 2️⃣ TASK 2️⃣: ADD MONTHLY ANALYTICS PDF (USING LAMBDA TRIGGER)

#### 1️⃣ ADD SECOND TRIGGER

- In same Lambda

- Click ➕ Add trigger again

#### 2️⃣ SELECT EVENTBRIDGE

- **Source:** EventBridge (CloudWatch Events)

- **Rule:** Create a new rule

#### 3️⃣ CONFIGURE MONTHLY RULE

| Field       | Value                          |
| ----------- | ------------------------------ |
| Rule name   | `MonthlyAnalyticsPDF`          |
| Description | Generate Analytics PDF monthly |
| Rule type   | Schedule expression            |


#### 4️⃣ MONTHLY CRON EXPRESSION

- **Paste:**

```
cron(0 0 1 * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

#### 🔘 Meaning:

- Runs on 1st day of every month

- At 00:00 UTC

#### 5️⃣ INPUT JSON (VERY IMPORTANT)

- **Select Constant (JSON text) and paste:**

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 6️⃣ ADD TRIGGER

- Click Add

- Now Lambda has TWO triggers

#### TASK 3️⃣ VERIFY TRIGGERS ARE ATTACHED

#### In Lambda Function overview, you should see:

```
EventBridge (DailyOrderPDF)
EventBridge (MonthlyAnalyticsPDF)
```

**If both appear → ✅ SUCCESS**

#### TASK 4️⃣ TEST TRIGGER WITHOUT WAITING

#### TEMPORARY FAST TEST (OPTIONAL BUT RECOMMENDED)

- Click one trigger name (e.g. DailyOrderPDF)

- Click Edit

- Change schedule to:

```
rate(1 minute)
```

- Save

- Wait 1 minute

- Check S3 bucket

**📄 New PDF appears → Automation works**

> **After testing, change back to cron.**

#### TASK 5️⃣ VERIFY OUTPUT

#### Check S3

- **Bucket:** charlie-cafe-s3-bucket

**Files should look like:**

```
order-status_report_2026-01-17.pdf
analytics_report_2026-01-01.pdf
```

#### TASK 6️⃣ CLOUDWATCH LOG VERIFICATION

- Lambda → Monitor

- Click View logs in CloudWatch

- Open latest log stream

**You should see:**

```
PDF generated successfully
Uploaded to S3: cafe-reports
```

#### ✅ FINAL CONFIRMATION CHECKLIST

| Item                           | Status |
| ------------------------------ | ------ |
| Lambda manual test             | ✅      |
| Daily EventBridge trigger      | ✅      |
| Monthly EventBridge trigger    | ✅      |
| Correct JSON input             | ✅      |
| PDF stored in S3               | ✅      |
| No UI EventBridge setup needed | ✅      |


#### 🎯 WHY THIS METHOD IS BETTER

✔ Faster

✔ Less mistakes

✔ IAM auto-permission

✔ Cleaner setup

✔ Same result as EventBridge console

### 3️⃣ METHOD 2- EVENTBRIDGE

**✅ ADD EVENTBRIDGE TRIGGER TO CafePDFReportLambda**

### 1️⃣ CREATE DAILY ORDER STATUS PDF EVENTBRIDGE RULE

#### 1️⃣ Go to EventBridge

- **Go to EventBridge → Rules → Create rule**

#### 2️⃣ Configure Rule

- **Name:** DailyOrderPDF

- **Description:** “Generate Order Status PDF daily”

- **Event bus:** default

- **Rule type:** Schedule

- **Cron expression for daily midnight:**

```
cron(0 0 * * ? *)
```

**➡️ Runs daily at 00:00 UTC**

**⚠️ If you want local time (Pakistan = UTC+5):**

```
cron(0 19 * * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

- **Click Next**


> **Explanation:**

> **0 0 * * ? * → triggers at 00:00 UTC every day**

| Field | Meaning     |
| ----- | ----------- |
| 0     | minute      |
| 0     | hour        |
| *     | every day   |
| *     | every month |
| ?     | day of week |
| *     | every year  |

**⚠️ You can adjust hour/minute for your timezone**

#### 3️⃣ Add Target

- **Target:** Lambda function → CafePDFReportLambda

- **Configure input:**

    - **Select Constant (JSON text)**

    - **Paste JSON for Order Status PDF:**

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

#### 📌 This tells Lambda:

- Generate Order Status PDF

#### 4️⃣ Review & Create Rule

- Review everything

- Click Create rule

**✅ DailyOrderPDF rule is LIVE**

### 2️⃣ CREATE MONTHLY ANALYTICS PDF RULE

> **Repeat steps, but with these changes 👇**

#### 1️⃣ Create Rule

- **EventBridge → Rules → Create rule**

#### 2️⃣ Rule Details

| Field       | Value                          |
| ----------- | ------------------------------ |
| Name        | `MonthlyAnalyticsPDF`          |
| Description | Generate Analytics PDF monthly |
| Rule type   | Schedule                       |

#### 3️⃣ Cron Expression (1st of Month)

```
cron(0 0 1 * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

**➡️ Runs once per month on the 1st day at 00:00 UTC**

#### 4️⃣ Target Configuration

- **Target:** Lambda function

- **Function:** CafePDFReportLambda

#### 5️⃣ Lambda Input JSON (VERY IMPORTANT)

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 📌 This tells Lambda:

- **Generate Analytics PDF**

#### 6️⃣ Create Rule

- Click Create rule

**✅ Monthly automation is complete.**

### 3️⃣ TEST EVENTBRIDGE TRIGGER (MANDATORY)

#### 1️⃣ OPTION A: Test via EventBridge

- EventBridge → Rules

- Click DailyOrderPDF

- Click Run now (or Test rule)

**🕘 Wait 5–10 seconds**

#### 2️⃣ OPTION B: Temporary Fast Test (Recommended)

- Edit rule

- Change schedule to:

```
rate(1 minute)
```

- Save

- Wait 1 minute

- Confirm PDF created

- Change cron back to original

### 4️⃣ VERIFY PDF GENERATION

#### 1️⃣  Go to:

```
AWS Console → S3 → your bucket
```

#### You should see files like:

```
order-status_2026-01-17.pdf
analytics_2026-01-01.pdf
```

#### 2️⃣  Open → PDF contains:

- Tables

- Totals

- Logo

- Correct data

### 5️⃣ Confirm Lambda & EventBridge

- Test in Lambda console → works ✅

- EventBridge trigger → works ✅

- PDFs in S3 → accessible ✅

- Both page types supported (analytics & order-status) ✅

### 💡 Tip:For testing purposes, you can temporarily set EventBridge cron to rate(1 minute) to quickly see PDFs being generated before switching to daily/monthly schedules.

### 🎯 FINAL RESULT

#### You now have:

🕒 Fully automated PDF reports

📄 Daily Order Status

📊 Monthly Analytics

☁️ Serverless

💰 Zero manual work

🧠 Enterprise-grade design

**✅ PHASE 7 STATUS**

> **🟢 PHASE 7 COMPLETE & VERIFIED**
---
## PHASE 8️⃣  MODIFY ORDER STATUS PAGE

#### 1️⃣ – IDENTIFY ORDER STATUS PAGE FILE

**⚠️ All these changes have already been made in all the admin files, so there is no need to follow these steps.**

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```
---

### 🧭 REPLACEMENT GUIDE

> **🔁 Replace ONLY these values**

| What                               | Replace                            |
| ---------------------------------- | ---------------------------------- |
| `REPLACE_WITH_YOUR_COGNITO_DOMAIN` | Cognito → App Integration → Domain |
| `REPLACE_WITH_YOUR_APP_CLIENT_ID`  | Cognito → App clients              |
| `REPLACE_WITH_YOUR_REDIRECT_URL`   | CloudFront / S3 URL                |
| `YOUR_API_ID`                      | API Gateway ID                     |
| `us-east-1`                        | Your region (if different)         |

**✅ PHASE 8 STATUS**

> **🟢 PHASE 8 COMPLETE & VERIFIED**
---
## PHASE 9️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS

### 1️⃣ Required DynamoDB Attributes (Orders Table)

#### 1️⃣ Open DynamoDB Table

- AWS Console → DynamoDB

- Click Tables

- Open table:

```
CafeOrders
```

#### 2️⃣ Verify Table Keys

#### Confirm:

| Setting       | Value               |
| ------------- | ------------------- |
| Partition Key | `order_id` (String) |
| GSI           | `order_date-index`  |


**📢 If GSI does not exist, STOP and create it before continuing.**

#### 3️⃣ Verify Required Attributes (CRITICAL)

Click Explore table items

Open at least ONE COMPLETED order

It MUST contain ALL attributes below:

```
{
  "order_id": "ORD123",
  "order_date": "2026-01-17",
  "order_timestamp": 1705488000,
  "item_name": "Latte",
  "quantity": 2,
  "item_cost": 1.5,
  "item_price": 3.0,
  "order_status": "COMPLETED"
}
```
❌ If ANY field is missing → fix order-creation Lambda first

✔ Do NOT continue until this is correct

### 2️⃣ – VERIFY GSI WORKS (NO CODE YET)

#### Test GSI in Console

- DynamoDB → Explore table items

- Switch Query

- Select index:

```
order_date-index
```

- Query condition:

```
order_date BETWEEN 2026-01-01 AND 2026-01-31
```

- Click Run

✔ If items return → GSI works

❌ If empty → fix dates or index

### 3️⃣ – CREATE ANALYTICS LAMBDA

#### 1️⃣ Create Lambda

- **AWS Console → Lambda → Create function**

| Field          | Value                 |
| -------------- | --------------------- |
| Function name  | `CafeAnalyticsLambda` |
| Runtime        | Python 3.10           |
| Execution role | Create new role       |

- Click Create function

#### 2️⃣ Attach IAM Permissions

= **Lambda → Configuration → Permissions**

- **Click Role → Attach policies**

- **Attach:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

- ✔ Save

### 4️⃣ – PASTE FINAL ANALYTICS CODE (NO CHANGES)

#### 1️⃣ Open Code Editor

- Lambda → Code tab

    - Delete ALL existing code

#### 2️⃣ Paste THIS CODE (COPY EXACTLY)

[CafeAnalyticsLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)

- Click Deploy

### 🧪 5️⃣ – Analytics Lambda Using Environment Variables (Production-Ready)

- **Go to: Lambda → Configuration → Environment variables → Edit**

#### Add EXACTLY these:

| Key                 | Value              |
| ------------------- | ------------------ |
| `ORDERS_TABLE_NAME` | `CafeOrders`       |
| `ORDERS_GSI_NAME`   | `order_date-index` |
| `ALLOWED_ORIGIN`    | `*`                |

✅ Save changes

✅ No code hard-coding remains

### 🧪 5️⃣ – TEST LAMBDA IN CONSOLE (MANDATORY)

- **Lambda → Test → Configure test event**

#### 1️⃣ Create Monthly Analytics Test Event

- **Name:**

```
Analytics_Month
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```

- Click Save

#### 2️⃣ Run Test

- Click Test

#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "month",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [
      {
        "item": "<string>",
        "quantity": <number>,
        "sales": <number>,
        "cost": <number>,
        "profit": <number>
      }
    ],
    "daily_sales": [
      {
        "date": "YYYY-MM-DD",
        "sales": <number>
      }
    ]
  }
}
```

✔ **Status code: 200**

✔ **Response body MUST look like:**

#### 2️⃣ Create Weekly Analytics Test Event

- **Name:**

```
Analytics_Week
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "week"
  }
}
```

- Click Save

#### 2️⃣ Run Test

- Click Test

#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "week",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [],
    "daily_sales": []
  }
}
```

📌 If last 7 days have data → arrays populated

📌 If not → empty arrays (this is correct behavior)

#### 3️⃣ Create Missing Parameter (ERROR CASE) Test Event

- **Name:**

```
Analytics_MissingPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {}
}
```

- Click Save

#### 2️⃣ Run Test

- Click Test

#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Missing period parameter\""
}
```

#### 📌 Note:

- Body is a JSON string

- Quotes are expected because of json.dumps()

#### 3️⃣ Create Invalid Period Value (ERROR CASE) Test Event

- **Name:**

```
Analytics_InvalidPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "year"
  }
}
```

- Click Save

#### 2️⃣ Run Test

- Click Test

#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Invalid period value\""
}
```

#### 📌 This confirms:

- Input validation works

- Lambda fails safely

- No DynamoDB call happens

### 🧪 6️⃣ – TEST THROUGH API GATEWAY

#### 1️⃣  API Gateway Setup (IF NOT DONE)

```
GET /analytics
→ Lambda Proxy → CafeAnalyticsLambda
```

- Deploy API

#### 2️⃣  Browser Test

#### Open browser:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=month
```

✔ JSON shown

✔ No CORS error

✔ Correct totals


### ✅ PHASE 9 COMPLETION CHECKLIST

| Item                         | Status |
| ---------------------------- | ------ |
| DynamoDB attributes verified | ✅      |
| GSI tested                   | ✅      |
| Lambda created               | ✅      |
| IAM correct                  | ✅      |
| Console test passed          | ✅      |
| API test passed              | ✅      |
| Response format EXACT        | ✅      |

### ⛔ DO NOT MOVE FORWARD UNTIL

✔ You see correct JSON

✔ Numbers match DynamoDB

✔ No CloudWatch errors

**✅ PHASE 9 STATUS**

> **🟢 PHASE 9 COMPLETE & VERIFIED**
---

## PHASE 🔟  COST AUTO-CALCULATION USING CafeMenu TABLE

> **(MANDATORY BEFORE PROFIT / ANALYTICS / PDF)**

### 1️⃣ — CREATE ITEM COST TABLE (CafeMenu)

#### 1️⃣ OPEN DYNAMODB CONSOLE

- Login to AWS Console

- Search DynamoDB

- Click DynamoDB

- Click Tables

- Click Create table

#### 2️⃣ TABLE BASIC CONFIGURATION

- ➡️ **Table name:**

```
CafeMenu
``` 

- ➡️ **Partition key (Primary Key)**

| Field     | Type        |
| --------- | ----------- |
| item_name | String (PK) |
| base_cost | Number      |

✔ Keep as-is

**⚠️ DO NOT add sort key**

#### 3️⃣ TABLE SETTINGS (VERY IMPORTANT)

- Click Customize settings

- Leave Table class → Standard

- Leave Capacity mode → On-demand

- Encryption → Default

- Tags → Optional (skip)

- Click Create table

**✅ Wait until Status = Active**

### 2️⃣ — INSERT ITEM COST DATA (MANUAL TEST DATA)

> **This step is MANDATORY for testing.**

#### 1️⃣ OPEN TABLE ITEMS

- Open CafeMenu

- Click Explore table items

- Click Create item

#### 2️⃣ ADD FIRST ITEM (Latte)

| Attribute name | Type   | Value |
| -------------- | ------ | ----- |
| item_name      | String | Latte |
| base_cost      | Number | 1.5   |

- Click Save

#### 3️⃣ ADD MORE ITEMS (RECOMMENDED)

**♻️ Repeat Create item for:**

2. **Cappuccino:**

```
item_name = Cappuccino
base_cost = 1.8
```

3. **Tea:**

```
item_name = Tea
base_cost = 0.6
```

4. **Coffee:**

```
item_name = Juice
base_cost = 1.2
```

5. **Juice**

```
item_name = Juice
base_cost = 1.2
```

**✅ At least 2–3 items must exist for testing**

### 3️⃣ — VERIFY CafeMenu TABLE (VERY IMPORTANT)

#### Before touching Lambda:

- Click Explore table items

#### Confirm:

    - item_name exists

    - base_cost exists

    - base_cost is Number, not String

**❌ If base_cost is String → DELETE ITEM → RECREATE**

### 4️⃣ — UPDATE CafeOrderProcessor RDS orders TABLE (MANDATORY)

#### 1️⃣ YOUR CURRENT TABLE (CONFIRMED)

> **You currently have this table:**

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
);
```

✅ This is valid

❌ It is missing cost columns

> **🔴 You MUST add cost columns in MySQL**

#### 2️⃣ CONNECT TO RDS

> **You must connect to your MySQL database using ONE of these:**

```
mysql -h <RDS-ENDPOINT> -u <USERNAME> -p
```

#### After login:

```
USE <your_database_name>;
```

#### 3️⃣ RUN THE ALTER COMMAND (COPY–PASTE)

#### ⚠️ Run this EXACTLY once

```
ALTER TABLE orders
ADD COLUMN item_cost DECIMAL(6,2) AFTER quantity,
ADD COLUMN total_cost DECIMAL(6,2) AFTER item_cost;
```
#### Why this is safe

✔ Does NOT delete data

✔ Does NOT change existing rows

✔ Just adds two new columns

#### 4️⃣ VERIFY COLUMNS EXIST (MANDATORY)

Immediately run:

```
DESCRIBE orders;
```
#### You MUST see:

```
item_cost   decimal(6,2)
total_cost  decimal(6,2)
```

**⚠️ If you do NOT see them → STOP and tell me.**

#### 5️⃣ TEST MANUAL INSERT (OPTIONAL BUT SAFE)

Run this test insert:

```
INSERT INTO orders
(table_number, customer_name, item, quantity, item_cost, total_cost)
VALUES
(1, 'Test User', 'Latte', 2, 1.50, 3.00);
```

#### Then verify:

```
SELECT * FROM orders ORDER BY id DESC LIMIT 1;
```

✔ If row inserted → DB is READY

✔ If error → do NOT continue

#### 🧾 FINAL UPDATED TABLE STRUCTURE (REFERENCE ONLY)

> **❗ You do NOT re-create the table**
> **This is only to show how it now looks**

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,

    -- ✅ NEW COLUMNS
    item_cost       DECIMAL(6,2),
    total_cost      DECIMAL(6,2),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
);
```

#### 🟢 FINAL CONFIRMATION CHECKLIST (VERY IMPORTANT)

> **❌ Do NOT move forward until ALL are true:**

✔ DESCRIBE orders; shows item_cost

✔ DESCRIBE orders; shows total_cost

✔ Manual INSERT works

✔ No SQL errors

#### ✅ STEP 4️⃣ STATUS

🟢 RDS TABLE UPDATED

🟢 SAFE

🟢 VERIFIED

🟢 READY FOR LAMBDA TEST

### 5️⃣ — OPEN ORDER PROCESSING LAMBDA

#### 1️⃣ OPEN LAMBDA

- Go to AWS Lambda

- Click Functions

- Click your Order Processing Lambda

- Example name:

```
CafeOrderProcessingLambda
```

#### 2️⃣ VERIFY IAM PERMISSIONS (NO SKIP)

- Click Configuration

- Click Permissions

- Click Execution role

- Ensure this policy exists:

```
AmazonDynamoDBReadOnlyAccess
AWSSecretsManagerReadWrite
```

#### ❌ If missing:

- Click Add permissions

- Attach policy

- Save

### 5️⃣ — CONNECT CafeMenu TABLE IN LAMBDA

[CafeOrderProcessingLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderProcessor/CafeOrderProcessingLambda.py)

#### 2️⃣ — DEPLOY LAMBDA (DO NOT SKIP)

- Click Deploy

- Wait for success message

#### 3️⃣ — ADD ENVIRONMENT VARIABLES (MANDATORY)

- **Go to: Configuration → Environment variables → Edit**

#### Add:

| Key             | Value      |
| --------------- | ---------- |
| MENU_TABLE_NAME | CafeMenu   |
| AWS_REGION      | ap-south-1 |

- Save

### 9️⃣ — TEST THIS PHASE (MANDATORY)

#### ❌ DO NOT CONTINUE WITHOUT TESTING

#### 1️⃣ CREATE TEST EVENT

- Click Test → Configure test event

- Test JSON

```
{
  "body": "{\"item_name\":\"Latte\",\"quantity\":2,\"price\":3.0}"
}
```

#### 2️⃣ RUN TEST

- Click Test

#### Confirm:

    - StatusCode = 200

    - No exception

#### 3️⃣ VERIFY DYNAMODB OUTPUT

- Open CafeOrders

- Open latest item

- Confirm these fields exist:

```
item_cost
total_cost
```

#### Example:

```
item_cost = 1.5
total_cost = 3.0
```

**❌ If missing → STOP and fix Lambda**

**✅ PHASE 10 STATUS**

> **🟢 PHASE 10 COMPLETE & VERIFIED**
---
## PHASE 1️⃣1️⃣  PROFIT PER ITEM (ALREADY INCLUDED)

### 1️⃣ PREREQUISITE CHECK (DO NOT SKIP)

#### 1️⃣ – Verify DynamoDB Order Item Structure

- Open DynamoDB → Tables → CafeOrders → Explore table

- Confirm EACH ORDER ITEM contains ALL of these attributes:

```
order_id        (String)
order_date      (String)   e.g. "2026-01-17"
order_timestamp (Number)
item_name       (String)
quantity        (Number)
item_price      (Number)   ← selling price
item_cost       (Number)   ← base cost
order_status    (String)   ← COMPLETED
```

❌ If item_cost does NOT exist → STOP

✔ Fix order-processing Lambda FIRST

#### 2️⃣ – Verify Only COMPLETED Orders Are Counted

- **Profit must NOT include:**

```
PENDING
CANCELLED
FAILED
```

#### Confirm in DynamoDB that:

```
order_status = "COMPLETED"
```

### 2️⃣ – PROFIT CALCULATION LOGIC (CLEAR MATH)

#### For each order item:

```
item_sales = item_price × quantity
item_cost  = item_cost × quantity
item_profit = item_sales - item_cost
```

**📢 For same item_name, values must be aggregated.**

### 3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)

### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

- **Go to:**

```
AWS Console → Lambda → Your Analytics Lambda
→ Configuration → Environment variables → Edit
```

#### 1️⃣ Add EXACTLY these variables

| Key                   | Value        | Notes                      |
| --------------------- | ------------ | -------------------------- |
| `DYNAMODB_TABLE_NAME` | `CafeOrders` | ✅ Your DynamoDB table name |
| `AWS_REGION`          | `ap-south-1` | ✅ Same region as DynamoDB  |

👉 Click Save

❗ DO NOT add quotes

❗ Key names must match exactly

#### 2️⃣ DEPLOY LAMBDA

- **Click Deploy**

- **🕐 Wait for: Successfully deployed**

### 5️⃣ Lambda Test Event

> ** (DO NOT CONTINUE WITHOUT THIS)**

#### 1️⃣ TEST PHASE 11 + 12 (REQUIRED - Recommanded)

#### 1️⃣ ✅ Test as ADMIN (SUCCESS)

#### Lambda Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "month"
  }
}
```

✔ StatusCode: 200

✔ Returns:

- total_sales

- total_cost

- profit

- profit_per_item[]

#### 2️⃣ ❌ Test as STAFF (BLOCKED)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Staff"
      }
    }
  }
}
```

✔ StatusCode: 403

✔ Message: "Access denied"

#### 2️⃣ TEST PHASE 11 (PROFIT PER ITEM)

#### 1️⃣ – Lambda Test Event

In Lambda → Test, use:

- **Lambda Test Event - 1: (Recommanded)**

```
{
  "queryStringParameters": {
    "period": "month"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```


### ✅ EXPECTED OUTPUT:

```
{
  "total_sales": 120,
  "total_cost": 70,
  "profit": 50,
  "profit_per_item": [
    {
      "item": "Latte",
      "quantity": 10,
      "sales": 50,
      "cost": 30,
      "profit": 20
    }
  ]
}
```


- **Lambda Test Event - 2:**

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```

#### 2️⃣ – VERIFY RESPONSE (STRICT)

Response MUST include:

```
"profit_per_item": [
  {
    "item": "Latte",
    "quantity": 12,
    "sales": 36,
    "cost": 18,
    "profit": 18
  }
]
```

✔ Profit math correct

✔ Aggregated per item

❌ Missing field = STOP

❌ Wrong math = STOP

### ✅ PHASE 11 COMPLETION CHECKLIST

✔ DynamoDB has item_cost

✔ Lambda aggregates correctly

✔ profit_per_item returned

✔ Math verified manually

✔ No UI used yet (backend verified first)

**✅ PHASE 11 STATUS**

> **🟢 PHASE 11 COMPLETE & VERIFIED**
---

## PHASE 1️⃣2️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)

### 👥 1️⃣ – CREATE COGNITO GROUPS (DETAILED)

- **Go to: AWS Console → Cognito → User Pools → YOUR_POOL**

#### 1️⃣ Create Admin Group

- Click Groups

- Click Create group

- **Group name:**

```
Admin
```

- Precedence: 1

- Click Create group

#### 2️⃣ Create Staff Group

- Repeat:

```
Group name: Staff
Precedence: 2
```

### 👤 2️⃣ – ASSIGN USERS TO GROUPS

- **Cognito → Users → Select User**

#### 1️⃣ Add to Group

- Click Add to group

- **Select:**

```
Admin   OR   Staff
```

**❗ A user MUST belong to one group**


### 🔗 3️⃣ – VERIFY GROUP CLAIM IN TOKEN

#### 1️⃣ – Login as Admin

- Login via Hosted UI

- Open browser DevTools

- Copy access_token

#### 2️⃣ – Decode JWT (jwt.io)

Confirm this exists:

```
"cognito:groups": ["Admin"]
```

**❌ If missing → group assignment failed**

### 🧠 4️⃣ – ENFORCE ROLE IN ANALYTICS LAMBDA

#### 1️⃣ – Extract Claims (EXACT CODE)

Add TOP of lambda_handler:

```
claims = event['requestContext']['authorizer']['claims']
groups = claims.get('cognito:groups', '')
```

#### 2️⃣ – Enforce Admin-Only Access

Add IMMEDIATELY AFTER:

```
if 'Admin' not in groups:
    return response(403, "Access denied")
```

✔ This blocks Staff

✔ This secures Analytics & PDF

#### 3️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)

#### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

- **Go to:**

```
AWS Console → Lambda → Your Analytics Lambda
→ Configuration → Environment variables → Edit
```

#### 1️⃣ Add EXACTLY these variables

| Key                   | Value        | Notes                      |
| --------------------- | ------------ | -------------------------- |
| `DYNAMODB_TABLE_NAME` | `CafeOrders` | ✅ Your DynamoDB table name |
| `AWS_REGION`          | `ap-south-1` | ✅ Same region as DynamoDB  |

👉 Click Save

❗ DO NOT add quotes

❗ Key names must match exactly

#### 2️⃣ DEPLOY LAMBDA

- **Click Deploy**

- **🕐 Wait for: Successfully deployed**

### 5️⃣ Lambda Test Event

> ** (DO NOT CONTINUE WITHOUT THIS)**

#### 1️⃣ TEST PHASE 11 + 12 (REQUIRED - Recommanded)

#### 1️⃣ ✅ Test as ADMIN (SUCCESS)

#### Lambda Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "month"
  }
}
```

✔ StatusCode: 200

✔ Returns:

- total_sales

- total_cost

- profit

- profit_per_item[]

#### 2️⃣ ❌ Test as STAFF (BLOCKED)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Staff"
      }
    }
  }
}
```

✔ StatusCode: 403

✔ Message: "Access denied"

#### 2️⃣ TEST PHASE 12 (ROLE SECURITY)

#### 1️⃣ ❌ STAFF TEST

Change test event to:

```
"cognito:groups": "Staff"
```

#### EXPECTED:

```
403 Access denied
```

✔ Security works

#### 3️⃣ – TEST ROLE ACCESS (MANDATORY)

#### 1️⃣ – STAFF USER

- Login as Staff

- Open Analytics

- Expected result:

```
403 Access denied
```

**✔ PASS**

#### 2️⃣ – ADMIN USER

- Login as Admin

- Open Analytics

- Expected result:

✔ Data loads

✔ PDF downloads

### ✅ PHASE 12 COMPLETION CHECKLIST

✔ Cognito groups created

✔ Users assigned correctly

✔ Token contains cognito:groups

✔ Lambda enforces role

✔ Staff blocked

✔ Admin allowed


**✅ PHASE 12 STATUS**

> **🟢 PHASE 12 COMPLETE & VERIFIED**
---
## PHASE 1️⃣3️⃣  CSV EXPORT (PROFESSIONAL)

### 1️⃣ — Cafe Analytics CSV Lambda

- **Go to: AWS Console → Lambda → Create function**

#### 1️⃣ Create new Lambda function

| Field         | Value                  |
| ------------- | ---------------------- |
| Function name | CafeAnalyticsCSVLambda |
| Runtime       | Python 3.10            |
| Architecture  | x86_64                 |

- **Create function**

**✅ Lambda is created**

### 2️⃣ SET LAMBDA PERMISSIONS (VERY IMPORTANT)

- **Go to Configuration → Permissions**
- **Click IAM Role name (blue link)**
- **IAM → Add permissions → Attach policies**

#### Attach ALL:

✔ AmazonDynamoDBReadOnlyAccess

✔ AWSLambdaBasicExecutionRole

- **Click Add permissions**

**✅ Lambda can now read DynamoDB**

### 3️⃣ CafeAnalyticsCSVLambda CODE

[CafeAnalyticsCSVLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsCSVLambda.py)

#### DEPLOY LAMBDA

- **Click Deploy**
- **Wait for Success message**

**Code is live**

### 4️⃣ CREATE API GATEWAY ENDPOINT

- **Go to: API Gateway → Your API**

- **Select existing /analytics resource**

#### 1️⃣ New API Resource

```
GET /analytics/csv
```

#### Fill:

| Field         | Value |
| ------------- | ----- |
| Resource Name | csv   |
| Resource Path | csv   |

**✔ Click Create Resource**

#### 2️⃣ CREATE GET METHOD

- **Select /analytics/csv**
- **Click Create Method → GET**

#### Method Setup:

| Setting          | Value                  |
| ---------------- | ---------------------- |
| Integration type | Lambda                 |
| Lambda function  | CafeAnalyticsCSVLambda |
| Use Lambda proxy | ✔ Enabled              |

- **Click Save**

#### 3️⃣ ENABLE COGNITO AUTHORIZER

- **Open GET /analytics/csv**
- **Click Method Request**
- **Set:**

```
Authorization → Cognito Authorizer
```

- **Choose same authorizer used for analytics**

- **✔ Save**

#### 4️⃣ — DEPLOY API

- **Click Deploy API**
- **Choose stage:**

```
prod
```

- **Click Deploy**

### 5️⃣ TEST CSV EXPORT (MANDATORY)

#### 1️⃣ TEST AS ADMIN (SUCCESS)

#### Use browser or curl:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics/csv
```

✔ Logged in as Admin

#### ✅ EXPECTED RESULT:

#### ⬇️ File downloads automatically:

```
cafe-analytics.csv
```

#### 2️⃣ Open file → Should show:

```
Item,Quantity,Sales,Cost,Profit
Latte,10,50,30,20
Espresso,5,25,15,10
```

#### 2️⃣ ❌ TEST AS STAFF (BLOCKED)

- Login as Staff

- Open same URL

#### ✅ EXPECTED RESULT:

```
403 Access denied
```

✔ Security verified

### ✅ PHASE 13 FINAL STATUS

🟢 PHASE 13 COMPLETE

🟢 TESTED

🟢 ADMIN-ONLY CSV DOWNLOAD

🟢 NO EXISTING SYSTEM BROKEN

**✅ PHASE 13 STATUS**

> **🟢 PHASE 13 COMPLETE & VERIFIED**
---
## PHASE 1️⃣4️⃣  DAILY AUTO PDF WITH TABLES & LOGO

### 1️⃣ CREATE Or Open existing S3 BUCKET

```
charlie-cafe-s3-bucket
```

### 2️⃣ Region:

✔ Same region as Lambda

### 3️⃣ Settings:

✔ Block all public access → ON

✔ Bucket versioning → Optional (OFF is fine)

- **Create bucket**

#### ✅ Bucket created

### 4️⃣ UPLOAD LOGO FILE (VERY IMPORTANT)

```
Cafelogo.png
```

#### ⚠️ Exact name is REQUIRED
> **(Case-sensitive)**

#### ✅ Logo stored in S3

### 5️⃣ CREATE PDF LAMBDA

#### Basic Configuration

| Parameter            | Value                  |
|----------------------|------------------------|
| Creation method      | Author from scratch    |
| Function name        | CafeDailyPDFLambda     |
| Runtime              | Python 3.10            |
| Architecture         | x86_64                 |

- **✔️ Create function**

### 6️⃣ ADD REPORTLAB LAYER (REQUIRED)

#### 1️⃣ Prepare reportlab.zip

Your zip must contain:

```
python/
 └── reportlab/
```

#### 2️⃣ Go to:

```
Lambda → Layers → Create layer
```

#### 3️⃣ Layer name:

```
reportlab-layer
```

#### 4️⃣ Upload ZIP:

```
reportlab.zip
```

#### 5️⃣ Compatible runtime:

```
Python 3.10
```

- **✔️ Create layer**

#### 6️⃣ Attach Layer to Lambda

```
Lambda → CafeDailyPDFLambda → Layers → Add layer
```

✔ Select existing layer

✔ Choose reportlab-layer

✔ Click Add

### 7️⃣ IAM PERMISSIONS (NO MISS)

#### 1️⃣ Open Lambda:

```
Configuration → Permissions
```

#### 2️⃣ Click Role name:

```
CafeDailyPDFLambda-role-xxxx
```

#### 3️⃣ Attach policies:

```
AmazonS3FullAccess
AmazonDynamoDBReadOnlyAccess
```

✔ Save

### 8️⃣ REPLACE LAMBDA CODE (FULL FINAL CODE)

> **⚠️ DELETE ALL EXISTING CODE FIRST**

Then PASTE EVERYTHING BELOW

#### 1️⃣ FINAL PDF GENERATION LAMBDA (COPY-PASTE SAFE)

[CafeDailyPDFLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeDailyPDFLambda.py)

✔ Click Deploy

✔ Wait for success

#### 2️⃣ USE ENVIRONMENT VARIABLES

- Open your CafeDailyPDFLambda → Configuration → Environment variables

- Add the following keys & values exactly:

| Key            | Value                  |
| -------------- | ---------------------- |
| BUCKET_NAME    | charlie-cafe-s3-bucket |
| LOGO_KEY       | Cafelogo.png           |
| DYNAMODB_TABLE | CafeOrders             |
| AWS_REGION     | ap-south-1             |

- Save changes.

- In the code, the Lambda reads these using os.environ.get(...).

**⚡ Benefit: You no longer need to edit code when bucket/table changes.**

#### 3️⃣ MANUAL TEST (MANDATORY BEFORE NEXT PHASE)

- **Lambda → Test → Create test event**
- **Event name:**

```
manual-test
```

- **Event JSON:**

```
{}
```

- **Test**

#### ✅ EXPECTED RESULT

✔ StatusCode: 200

✔ Message:

```
PDF generated and uploaded
```

#### 4️⃣ VERIFY PDF OUTPUT

- **S3 → charlie-cafe-s3-bucket → daily_reports/**

- **File exists:** daily_YYYY-MM-DD.pdf

- **Download & open PDF**

✔ Logo visible

✔ Table visible

✔ Correct profit values


### 9️⃣ EventBridge Rule (AUTOMATION)

- **Amazon EventBridge → Rules → Create rule**

#### 1️⃣ Rule Details

- **Rule name: (optional, but recommended)**

```
DailyCafePDFRule
```

- **Description: (optional, but recommended)**

```
Triggers CafeDailyPDFLambda every day at midnight UTC
```

- **Define pattern:**

- **➡️ Choose Schedule**

#### 2️⃣ Schedule Pattern (CRON)

- Select Cron expression

- Enter exact UTC cron expression:

> **(midnight UTC)**

```
cron(0 0 * * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

✔ Daily midnight PDF

✔ Stored in S3

#### 💡 Explanation:

| Field        | Value | Meaning                  |
| ------------ | ----- | ------------------------ |
| Minute       | 0     | At 0 minutes             |
| Hour         | 0     | At 0 hour (midnight UTC) |
| Day-of-month | *     | Every day                |
| Month        | *     | Every month              |
| Day-of-week  | ?     | No specific day of week  |
| Year         | *     | Every year               |

> **This will run every day at midnight UTC**

#### 3️⃣ Add Target

- Scroll down to Select targets → Lambda function

- In the dropdown, select:

```
CafeDailyPDFLambda
```

- Click Create a new role for this specific resource (if not using existing)

`- Or choose existing IAM role that allows EventBridge → Lambda invoke

**✔ This IAM role must have permission to invoke your Lambda**

#### 4️⃣ Configure Dead Letter Queue (Optional but recommended)

- Keep default None (for now)

- Or add SQS if you want retries

#### 5️⃣ Tags (Optional)

Add tags like:

```
Environment: Production
Project: CharlieCafeLab
```

#### 6️⃣ Review + Create

- Review all settings carefully

- Click Create rule**

✅ Rule created

✅ You now have EventBridge → Lambda

#### 7️⃣ Verify Lambda Trigger

- **Go to Lambda → CafeDailyPDFLambda → Configuration → Triggers**

- You should see:

```
EventBridge (DailyCafePDFRule)
```

#### 8️⃣ Manual Test (Before waiting for midnight)

- **Go to Lambda → CafeDailyPDFLambda → Test**

- **Event JSON:**

```
{}
```

- **Click Test**

- Verify S3 bucket:

```
charlie-cafe-s3-bucket/daily_reports/
```

- File exists: daily_YYYY-MM-DD.pdf

- Logo + table visible

> **This ensures EventBridge will run correctly at schedule**


**✅ PHASE 14 STATUS**

> **🟢 PHASE 14 COMPLETE & VERIFIED**
---
## 🖨 PHASE 1️⃣5️⃣ PDF BUTTON INTEGRATION

> **FRONTEND → EXISTING LAMBDA**

**🏷 You already did backend correctly ✅ Now we only connect buttons.**

### ✅ Method 1️⃣ -  FINAL UPDATED order-status.html

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 5️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 6️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```

```
sudo chmod 644 /var/www/html/order-status.html
```

#### 7️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 8️⃣ Open page in browser

```
http://EC2 Public IP/order-status.html
```

### 6️⃣ Test (DO NOT SKIP)

#### 1️⃣ Open page

```
https://YOUR_EC2 Public IP/order-status.html
```

#### 2️⃣ You should be redirected to Cognito login

#### 3️⃣ TEST 1️⃣ — STAFF USER (RBAC + ORDER STATUS)

#### 🎯 Purpose

#### Verify:

- Login works

- Order dashboard loads

- Analytics & PDF are hidden

#### Steps

1️⃣ Open order-status.html in browser

2️⃣ You are redirected to Cognito Login

3️⃣ Login using a Staff user (belongs to Staff group)

4️⃣ After login, confirm:

✔ Orders table loads

✔ Metrics cards show

✔ Chart shows

❌ Analytics button NOT visible

❌ PDF button NOT visible

**✅ PASS RESULT**

> **Staff can see orders only**

#### 4️⃣ Logout as STAFF USER

#### 5️⃣ TEST 2️⃣ — ADMIN USER (Analytics + PDF)

#### 🎯 Purpose

#### Verify:

- Admin privileges

- Analytics + PDF access

####  Steps

1️⃣ Logout

2️⃣ Open order-status.html again

3️⃣ Login using an Admin user (belongs to Admin group)

4️⃣ After login, confirm:

✔ Orders dashboard loads

✔ Analytics button visible

✔ PDF button visible

5️⃣ Click 📊 Analytics

  - Metrics load

  - No errors

6️⃣ Click 📄 PDF

  - New tab opens

  - PDF downloads or opens

**✅ PASS RESULT**

> **Admin sees everything**

#### 6️⃣ Logout as Admin USER

#### 7️⃣ 🔴 IF ANYTHING FAILS (Quick Fix)

#### 1️⃣ ❌ Analytics/PDF not showing for Admin?

#### Check:

```
parseJwt(token)["cognito:groups"]
```

**👉 Admin must be in Cognito group Admin**

#### 2️⃣ ❌ Redirect loop?

#### Check:

- Redirect URI exactly matches Cognito App Client

- No trailing slash mismatch

### 🧪 FINAL TEST CHECKLIST (DO NOT SKIP)

✔ Staff cannot see PDF

✔ Admin sees PDF

✔ Admin PDF opens

✔ Staff print works

✔ Mobile view OK

✔ Dark/light toggle works

✔ Analytics link opens

✔ Lambda still works

### ✅ CURRENT STATUS

🟢 Frontend printing — COMPLETE

🟢 Backend PDF — COMPLETE

🟢 RBAC — COMPLETE

🟢 UI professional — COMPLETE


**✅ PHASE 15 STATUS**

> **🟢 PHASE 15 COMPLETE & VERIFIED**
---

## PHASE 1️⃣6️⃣  Test

### 1️⃣  - 📄 PDF – HOW IT WORKS FROM ORDER STATUS PAGE

✔ Click 📊 Analytics

✔ Click 📄 PDF Report

✔ Calls /report/pdf

✔ Lambda generates PDF

✔ Browser downloads it

❌ No duplication

❌ No extra UI

❌ No confusion

### 2️⃣ - ⏰ MONTH-END AUTO PDF (NO UI)

#### Already handled by:

```
EventBridge → CafePDFReportLambda
cron(0/10 * * * ? *)
```

**No Order Status page change needed.**

### ✅ FINAL SYSTEM CHECKLIST CONFIRMATION

✔ You used existing Order Status system

✔ You did not create new page

✔ You did not modify backend logic

✔ You added professional analytics

✔ You added PDF reports

✔ You kept everything secure & clean

✔ CSV Export

✔ Role-based analytics

✔ Auto cost calculation

✔ Profit per item

✔ Daily PDF with logo & table

✔ Exact API response format

✔ No duplicate systems

✔ Production ready

**✅ PHASE 16 STATUS**

> **🟢 PHASE 16 COMPLETE & VERIFIED**

# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

