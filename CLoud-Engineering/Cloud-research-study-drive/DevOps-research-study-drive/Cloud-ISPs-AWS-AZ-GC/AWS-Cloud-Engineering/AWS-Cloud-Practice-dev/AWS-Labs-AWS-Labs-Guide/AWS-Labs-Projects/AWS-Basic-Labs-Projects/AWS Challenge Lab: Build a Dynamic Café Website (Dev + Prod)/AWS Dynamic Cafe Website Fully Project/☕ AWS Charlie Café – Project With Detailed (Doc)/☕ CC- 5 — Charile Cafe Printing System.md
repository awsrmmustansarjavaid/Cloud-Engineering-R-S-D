# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

### READ Me About

[Charile Cafe Printing System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕%20CC-%201%20—%20Order_Async_Processing_Tracking_System.md)

### ☕ AWS Charlie Café – Test & Verifications

[Charile Cafe Printing System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—%20Order_Async_Processing_Tracking_System%20.md)


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

# SECTION 1️⃣  COMPLETE ✅
