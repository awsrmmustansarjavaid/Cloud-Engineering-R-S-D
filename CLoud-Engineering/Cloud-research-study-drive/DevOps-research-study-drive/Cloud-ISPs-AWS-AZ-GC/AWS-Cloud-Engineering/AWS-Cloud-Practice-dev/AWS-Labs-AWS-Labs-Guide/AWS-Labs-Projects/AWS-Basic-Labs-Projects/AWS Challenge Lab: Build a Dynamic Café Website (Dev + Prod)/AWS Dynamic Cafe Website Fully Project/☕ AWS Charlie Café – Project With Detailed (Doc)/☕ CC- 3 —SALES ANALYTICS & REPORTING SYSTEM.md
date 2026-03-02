# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**

### READ Me About

[☕ CC- 3 —SALES ANALYTICS & REPORTING SYSTEM](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

### ☕ AWS Charlie Café – Test & Verifications

[☕ CC- 3 —SALES ANALYTICS & REPORTING SYSTEM](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

---

# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – RDS 

### ⚠️ IMPORTANT REQUIREMENTS

Your MySQL orders table MUST contain:

```
created_at      DATETIME
payment_status  VARCHAR
order_status    VARCHAR
item_name       VARCHAR
quantity        INT
item_price      DECIMAL
item_cost       DECIMAL
```

If created_at does not exist → add it:

```
ALTER TABLE orders ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
```





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

| Variable          | Example    |                                     |
| ----------------- | ---------- | ----------------------------------- |
| ORDERS_TABLE_NAME | CafeOrders |                                     |
| AWS_REGION        | us-east-1  | *(optional, defaults to us-east-1)* |


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
## PHASE 5️⃣  MODIFY ORDER STATUS PAGE

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

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS

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

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

## PHASE 7️⃣  COST AUTO-CALCULATION USING CafeMenu TABLE

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

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---
## PHASE 8️⃣  PROFIT PER ITEM (ALREADY INCLUDED)

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

### ✅ PHASE 8️⃣ COMPLETION CHECKLIST

✔ DynamoDB has item_cost

✔ Lambda aggregates correctly

✔ profit_per_item returned

✔ Math verified manually

✔ No UI used yet (backend verified first)

**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---

## PHASE 9️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)

### 🔗 1️⃣ – VERIFY GROUP CLAIM IN TOKEN

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

### 🧠 2️⃣ – ENFORCE ROLE IN ANALYTICS LAMBDA

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

### 3️⃣ Lambda Test Event

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


**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**
---
# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

