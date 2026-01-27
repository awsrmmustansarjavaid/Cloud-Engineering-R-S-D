# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**


# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

> **⚠️ This phase is mandatory before Lambda works.**

**Goal of this phase:**

Ensure your existing DynamoDB table structure, index, and query logic are 100% correct and testable before analytics logic is added.

### 1️⃣ VERIFY EXISTING ORDERS TABLE (REQUIRED STRUCTURE)

#### 2️⃣ Confirm Table Name: 

```        
CafeOrders
```

#### ❌ If table name is:

- cafeorders

- cafe_orders

- Orders

👉 STOP

👉 Either rename Lambda code OR recreate table

👉 Do NOT rename the table randomly

### 2️⃣ VERIFY REQUIRED ATTRIBUTES EXIST (DATA CONTRACT)

#### Why this matters

Analytics requires GSI, not main keys.

#### ⚠️ DO NOT ADD A SORT KEY TO MAIN TABLE

Adding one breaks:

- Existing writes

- Existing Lambdas

- API Gateway

👉 Analytics filtering happens via GSI, not main table.

#### UNDERSTAND THE “DATA CONTRACT”

This is the MOST IMPORTANT CONCEPT you were missing.

❓ What is a Data Contract?

It means:

“Analytics Lambda EXPECTS these attributes to already exist in every COMPLETED order”

- Lambda does not create them

- Lambda does not fix them

- Lambda only reads

#### REQUIRED ATTRIBUTES (NO EXCEPTIONS)

For every COMPLETED order, DynamoDB item must contain:

| Attribute       | Type   | Why                   |
| --------------- | ------ | --------------------- |
| order_id        | String | Primary key           |
| order_date      | String | Used by GSI partition |
| order_timestamp | Number | Used by GSI sort      |
| total_amount    | Number | Sales calculation     |
| total_cost      | Number | Profit calculation    |
| order_status    | String | Filter COMPLETED      |

**⚠️ Missing even ONE → analytics fails silently or returns empty data.**

#### 2️⃣ Verify Attributes Exist in Real Data

Why this step exists

Most bugs come from:

- order_timestamp saved as string

- total_amount saved as "30" instead of 30

Do this EXACTLY:

- DynamoDB → CafeOrders

- Click Explore table items

- Open at least 3 COMPLETED orders

Manually confirm:

✅ order_date = "2026-01-17"

✅ order_timestamp = Number

✅ total_amount = Number

✅ total_cost = Number

❌ If wrong:

👉 STOP

👉 Fix order creation Lambda first

### 3️⃣ – ADD ADD GLOBAL SECONDARY INDEX (GSI - VERY IMPORTANT)

WHY GSI IS REQUIRED (VERY IMPORTANT)

**❓ Why can’t we just scan the table?**

- Scan is slow

- Scan is expensive

- Scan is forbidden in production analytics

**❓ What problem GSI solves?**

We want:

```
All orders between date A and date B
```

DynamoDB cannot query by non-key attributes

➡️ So we CREATE a key → GSI

### 3️⃣ – EXACT DYNAMODB QUERY CODE (REQUIRED)

HOW QUERY ACTUALLY WORKS (MENTAL MODEL)

Let’s say you query:

```
start_date = 2026-01-01
end_date   = 2026-01-31
```

DynamoDB does:

- Go to GSI order_date-index

- Find partitions between dates

- Sort by order_timestamp

- Return matching items FAST ⚡

Without GSI → impossible.

#### ANALYTICS QUERY CODE (EXPLAINED LINE-BY-LINE)

```
import boto3
from decimal import Decimal
```

👉 boto3 = AWS SDK

👉 Decimal = DynamoDB number safety

```
dynamodb = boto3.resource('dynamodb')
```

👉 Creates DynamoDB connection using Lambda IAM role

```
table = dynamodb.Table('CafeOrders')
```

👉 Points to EXACT table name

```
def query_orders(start_date, end_date):
```

👉 Function accepts:

- "2026-01-01"

- "2026-01-31"

```
response = table.query(
```

👉 QUERY, not SCAN (critical)

```
IndexName='order_date-index',
```

👉 Uses GSI

👉 Without this → crash

```
KeyConditionExpression='order_date BETWEEN :s AND :e',
```

👉 DynamoDB syntax:

- Find all orders where date is between two values

```
ExpressionAttributeValues={
    ':s': start_date,
    ':e': end_date
}
```

👉 Injects values safely

```
return response['Items']
```

👉 Returns list of orders → Lambda will calculate totals later

**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**
---
## PHASE 5️⃣  ☕ MULTI-PAGE SUPPORT PDF GENERATION LAMBDA (REPORTLAB)

### 📄 Printing System 2 — Server PDF (Lambda + ReportLab)

> **(PHASE 5 & 6)**

#### How it works

✔️ Button → API Gateway

✔️ API → Lambda

✔️ Lambda → ReportLab

✔️ PDF saved in S3

✔️ Browser downloads PDF

#### Best for

✔️ Admin

✔️ Monthly reports

✔️ Accounting

✔️ Audit

#### Automation (EventBridge)

✅ Professional

✅ Consistent layout

✅ Can be automated

❌ Slight delay

❌ AWS cost (small)

| Printing Type    | Where it runs | Technology         | Purpose                           |
| ---------------- | ------------- | ------------------ | --------------------------------- |
| 🖨 Browser Print | Frontend only | `window.print()`   | Quick, instant print / save PDF   |
| 📄 Lambda PDF    | Backend       | ReportLab + Lambda | Official, stored, branded reports |

#### 🧠 SIMPLE MENTAL MODEL

```
STAFF USES → Browser Print
ADMIN USES → Lambda PDF
```

#### ⚠️Why?

#### Browser print:
> **PHASE 7️⃣ **AWS  Charlie Cafe — Secure Admin Order Dashboard**

✔️ Fast

✔️ No backend cost

✔️ No S3

✔️ No permissions

✔️ Good for receipts, daily summaries

#### Lambda PDF:

> **PHASE 5️⃣ & 6️⃣ **☕ AWS CAFE — SALES ANALYTICS & REPORTING SYSTEM**

✔️ Professional layout

✔️ Stored in S3

✔️ Monthly / daily automation

✔️ Logo, tables, profit

✔️ Admin-only (RBAC)

**✅ You are building a REAL PRODUCTION SYSTEM**

**✅ PHASE 5 STATUS**

> **🟢 PHASE 5 COMPLETE & VERIFIED**
---
## PHASE 6️⃣  CONNECT PDF BUTTON WITH API ( API GATEWAY)

### Goal :

> **When you click PDF button from**

    - analytics.html 
    
            OR

    - order-status.html

➡️ API Gateway must call CafePDFReportLambda

➡️ Lambda must know which page requested the PDF

➡️ Browser must download/open the PDF

### 🧠 BEFORE YOU START – VERIFY THESE EXIST

#### STOP and verify ALL of these are already done:

| Item            | Must Exist                 |
| --------------- | -------------------------- |
| Lambda          | `CafePDFReportLambda`      |
| Runtime         | Python 3.10                |
| ReportLab layer | Attached                   |
| API Gateway     | Same API used by analytics |
| Region          | Known (ex: `us-east-1`)    |

**❗ If any item is missing → DO NOT continue**

**✅ PHASE 6 STATUS**

> **🟢 PHASE 6 COMPLETE & VERIFIED**
---
## PHASE 7️⃣  Automation Monthly Auto Report

### 1️⃣ PREREQUISITE CHECK (DO THIS FIRST)

**📢 Before starting, make sure:**

- **Lambda exists:** CafePDFReportLambda & CafeAnalyticsLambda

- Lambda already works in Test Event (manual test passed)

- **Lambda IAM Role includes:**

    - AmazonS3FullAccess OR

    - Custom policy with s3:PutObject

- S3 bucket exists (example):

```
Your S3 Bucket
```
    - CloudWatchLogsFullAccess

- Lambda code is already working when tested manually

**✅ If all above are true → continue.**

**❗ If Lambda test does not work, STOP and fix Lambda first.**

**This will automatically generate PDFs:**

- Daily → Order Status PDF

- Monthly → Analytics PDF



