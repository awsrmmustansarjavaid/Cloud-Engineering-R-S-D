# ☕ Charlie Cafe 1 — Order_Async_Processing_Tracking_System


# ☕ Charlie Café SECTION 1️⃣ Cafe Order Processor 

## PHASE 5️⃣ — Frontend Development Code

##  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

## 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)

### 1️⃣ Create the shared central-auth.js (IMPORTANT)


```
// ===============================
// CENTRAL AUTH FILE (REUSABLE)
// ===============================

// Decode JWT payload
function parseJwt(token) {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    return JSON.parse(atob(base64));
}

// Get logged-in user role
function getUserRole() {
    const token = localStorage.getItem("idToken");
    if (!token) return null;

    const payload = parseJwt(token);
    return payload["cognito:groups"] || [];
}

// Page-level access control
function requireRole(requiredRole) {
    const groups = getUserRole();

    if (!groups || !groups.includes(requiredRole)) {
        alert("Access denied");
        window.location.href = "login.html";
    }
}
```

#### 🧠 This is your future-proof system

You’ll reuse it for every page later.





# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# SECTION 2️⃣ — AWS Cafe Menu + Cache Layer

## PHASE 1️⃣ — AMAZON DYNAMODB (Menu + Cache Layer)

## 🎯 Purpose of This Phase (IMPORTANT)

### In your architecture:

- DynamoDB is NOT replacing RDS

- DynamoDB is used for:

    - Menu data (Coffee, Latte, Tea)

    - Fast reads

    - Cache-like behavior

- Lambda reads menu price from DynamoDB

- RDS is still used for orders & transactions

So the flow is:

```
CloudFront
   ↓
API Gateway
   ↓
Lambda (Menu API)
   ↓
DynamoDB (CafeMenu)
```
> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# SECTION 3️⃣ — AWS CAFE SQS (Async Order Processing)

## PHASE 1️⃣ — SQS/LAMBDA (Producer)

## 🧠 WHY SQS EXISTS (VERY IMPORTANT)

### ➖ Without SQS:

- API waits for DB insert ❌

- API fails if DB is slow ❌

- Users get errors ❌

### ➕ With SQS:

- API responds instantly ✅

- Orders are processed in background ✅

- System scales safely ✅

---

## 🏁 ARCHITECTURE STATE (SUCCESS)

```
Client
  ↓
API Gateway
  ↓
CafeOrderApiLambda
  ↓
SQS (CafeOrdersQueue)
  ↓
CafeOrderWorker Lambda
  ↓
RDS + DynamoDB
```

✔ Fully asynchronous

✔ Decoupled

✔ Scalable

✔ Production-ready

---
## 📢 PRE-CHECK (DO NOT SKIP)

#### Before starting, confirm:

- Region is same for Lambda + SQS + RDS

- You have IAM role for Lambda

- You are using Standard Queue (NOT FIFO)


## 2️⃣ CREATE API Lambda Function (Producer)
> **(ORDER API → SQS)**

### 🎯 PURPOSE 

This Lambda will:

- Receive HTTP request from API Gateway

- Read order JSON

- Send order to SQS

- Respond immediately (202 Accepted)

### 🧱 ARCHITECTURE POSITION

```
Browser / EC2 PHP App
        ↓
    API Gateway
        ↓
CafeOrderApiLambda   ← (YOU ARE CREATING THIS NOW)
        ↓
   CafeOrdersQueue (SQS)
```

### ✅ PRE-CHECK (DO THIS ONCE)

Make sure SQS Queue already exists:

- AWS Console → SQS

- Queue name: CafeOrdersQueue

- Type: Standard

✔ If exists → Continue

❌ If not → STOP and create it first

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 4️⃣ — SQS/Worker LAMBDA (Consumer)

## 1️⃣ Create Worker Lambda (Consumer)

### 📢 Worker Responsibilities:

- Read message
- Insert into RDS
- Update DynamoDB cache

### 🟡 ARCHITECTURE FLOW:

```
Client
 ↓
API Gateway
 ↓
Order API Lambda
 ↓
SQS Queue
 ↓
Worker Lambda
 ↓
RDS + DynamoDB
```

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# SECTION 4️⃣ — ORDER STATUS DASHBOARD

### 🎯 WHAT YOU WANT (CLARIFIED)

#### You want a new frontend page:

```
/order-status
```

#### That shows:

✅ Total orders count

✅ Orders synced through:

- API Gateway

- Lambda

- SQS

- RDS

- DynamoDB

  ✅ Date & time per order

  ✅ Auto-updated (near real-time)

  ✅ Existing order system remains UNTOUCHED

### 🧠 IMPORTANT REALITY CHECK

**You cannot directly “count” orders from SQS because:**

**🔴 SQS is a temporary transport layer**
**Messages are deleted after processing**

#### So in real systems:

- RDS = Source of truth (orders history)

- DynamoDB = Fast counters / dashboard cache

- SQS = Invisible to users (internal)

✔️ This is NORMAL and CORRECT architecture.



### 🏆 RECOMMENDED DESIGN (PRODUCTION)

✅ RDS = Order Records

✅ DynamoDB = Order Counters + Status

✅ Lambda = Aggregator

✅ API Gateway = Dashboard API

✅ Frontend = Order Status Page

### 📐 FINAL ARCHITECTURE (ORDER STATUS DASHBOARD)

```
Browser (order-status.html)
      |
      |--> API Gateway /order-status
              |
              |--> Lambda (OrderStatusLambda)
                      |
                      |--> RDS (orders table)
                      |--> DynamoDB (order_metrics)
```
---
## PHASE 2️⃣ — DYNAMODB METRICS TABLE (FULL)

### 1️⃣ Worker Lambda IAM Role

**AWS IAM Policies:**

```
AmazonDynamoDBFullAccess
AWSSecretsManagerReadOnly
AmazonSQSFullAccess
```

### REQUIRED Additional Policies

#### Your Worker Lambda / API Lambda should have:

| Purpose         | Policy                                 |
| --------------- | -------------------------------------- |
| Secrets Manager | `CafeSecretsManagerReadOnly` (custom)  |
| RDS access      | `AWSLambdaVPCAccessExecutionRole`      |
| CloudWatch logs | `AWSLambdaBasicExecutionRole`          |
| SQS (worker)    | `AmazonSQSFullAccess` or scoped policy |
| DynamoDB        | `AmazonDynamoDBFullAccess` (lab)       |


> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED

---
# ☕ SECTION 5️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧠 WHY THIS LAB EXISTS

#### In real cafés and food apps:

- Customers expect confirmation

- They want:

    - Order ID

    - Order status

    - Bill details

    - A link they can reopen

    - Print / share receipt

This lab adds all of that
**WITHOUT touching your existing AWS backend.**

### 🏗️ ARCHITECTURE (UPDATED)

```
Customer Browser
   ↓
order.php  (THIS LAB)
   ↓
API Gateway  (EXISTING)
   ↓
CafeOrderApiLambda (EXISTING)
   ↓
SQS (EXISTING)
   ↓
CafeOrderWorker Lambda (EXISTING)
   ↓
RDS + DynamoDB (EXISTING)
```

### 🆕 Frontend Enhancements Only

- Unique Order ID

- Order Status Page URL

- Billing calculation

- Printable receipt

## 🧩 LAB PHASE NAME

### 🎯 LAB OBJECTIVES

### By the end of this phase:

✔ Customers receive a unique order ID

✔ Customers see order status (RECEIVED)

✔ Customers get billing details

✔ Each order has a unique URL

✔ Customers can print their receipt

✔ Backend remains 100% untouched

### 🎯 WHAT EXACTLY WE ARE ADDING

| Feature                 | Where    |
| ----------------------- | -------- |
| Unique Order ID         | Frontend |
| Billing Calculation     | Frontend |
| Order Status (RECEIVED) | Frontend |
| Order Tracking Link     | Frontend |
| Print Receipt           | Frontend |


### 📁 FILES USED IN THIS LAB

| File               | Purpose                       |
| ------------------ | ----------------------------- |
| `order.php`        | Order placement + receipt     |
| `order-status.php` | (Future) Status tracking page |
| Existing API       | **UNCHANGED**                 |

#### 📁 FILES USED

You will work with ONLY ONE FILE in this phase:

```
order.php
```

- No new backend files

- No Lambda changes

- No DB changes

### 🚫 RULES (DO NOT BREAK)

❌ Do NOT modify API Gateway

❌ Do NOT modify Lambda

❌ Do NOT modify SQS

❌ Do NOT modify RDS or DynamoDB

✅ Frontend changes only

### 🧪 DATA FLOW (IMPORTANT)

- Customer fills order form

- Frontend sends JSON to API (already working)

- Backend responds 202 Accepted

#### Frontend immediately:

    - Generates Order ID

    - Calculates bill

    - Displays receipt

    - Shows status link

**👉 Backend continues processing asynchronously via SQS**    

### 🔑 ORDER STATUS MODEL (FRONTEND)

| Status    | Meaning                  |
| --------- | ------------------------ |
| RECEIVED  | Order accepted by system |
| PREPARING | (Future) Kitchen started |
| READY     | (Future) Ready to serve  |
| COMPLETED | (Future) Order closed    |

#### 🔐 ORDER STATUS LOGIC (FOR NOW)

In this phase, order status is:

```
RECEIVED
```

#### Why?

- Order accepted by system

- Async processing is happening

- This matches real systems (Uber Eats, Foodpanda)


### 🧾 BILLING MODEL (FRONTEND)

#### Price list (static for lab):

| Item        | Price |
| ----------- | ----- |
| Coffee      | $3    |
| Tea         | $2    |
| Latte       | $4    |
| Cappuccino  | $4    |
| Fresh Juice | $5    |

#### Total formula:

```
Total = price × quantity
```
---

## 🔔 PHASE 2️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

This phase ONLY reads data

❌ No writes

❌ No SQS

❌ No changes to existing Lambdas

❌ No DB schema changes

### 🧠 WHY THIS PHASE EXISTS (REAL WORLD)

#### Right now:

Customer gets an Order ID ✔

Customer gets receipt ✔

Customer gets a link ✔

But the link is static.

#### In real systems:

Customer opens link later

System shows:

Order details

Current status

Billing

Print button

**👉 This phase makes the order-status link REAL**

### 🏗️ FINAL ARCHITECTURE

```
Customer Browser
   ↓
order-status.php
   ↓
API Gateway (NEW – READ ONLY)
   ↓
OrderStatusLambda (NEW)
   ↓
RDS (SELECT only)
```

### 🎯 WHAT THIS PHASE WILL DO

#### When customer opens:

```
order-status.php?order_id=ORD-123456
```

#### They will see:

✔ Order ID

✔ Table Number

✔ Item

✔ Quantity

✔ Total Bill

✔ Status

✔ Created Time

✔ Print Button

### 🔐 STATUS RULE (IMPORTANT)

#### For this lab:

| Condition       | Status    |
| --------------- | --------- |
| Order exists    | RECEIVED  |
| Order not found | NOT FOUND |

(No worker changes yet — that’s Phase 15)

### 📦 DATA SOURCE DECISION (VERY IMPORTANT)

We DO NOT modify your existing orders table.

#### But your table already has:

- item

- quantity

- customer_name

- created_at

**👉 We will map order_id logically, not physically.**

#### How?

We store order_id as a virtual ID passed from frontend
(Interview-acceptable design for labs)

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

This phase upgrades your cafe from “demo” to “production-grade workflow”

### 🧠 WHAT YOU WILL BUILD (CLEAR FIRST)

#### You already have:

    - Order placement ✅

    - Order tracking (read-only) ✅

#### Now you will add:

- Real order status lifecycle

- Kitchen/Worker updates

- Live status visible to customer

- Billing auto-finalization

### 🏗️ FINAL ARCHITECTURE (COMPLETE VIEW)

```
Customer
  ├── order.php (place order)
  ├── order-status.php (track order)
  ↓
API Gateway
  ├── POST /orders            → CreateOrderLambda
  ├── GET  /order-status      → OrderStatusLambda
  └── POST /order-update      → OrderWorkerLambda
                                   ↓
                                RDS (orders table)
```

### 🧱 ORDER STATE MACHINE (VERY IMPORTANT)

This is MANDATORY and used everywhere.

```
RECEIVED  → PREPARING → READY → COMPLETED
```

#### Rules:

- Status can move only forward

- No skipping

- No rollback

### 📦 DATABASE DESIGN (SAFE CHANGE)

🔴 DO NOT CREATE NEW TABLE

We will ADD COLUMNS ONLY




> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔔 PHASE 4️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### Goal:
> Allow customers to:

- Track their own order status

- View billing details

- Use a unique order URL

- Print receipt

- Auto-refresh status

- Scan QR code to reopen order

- No modification to existing order flow

### 🧱 ARCHITECTURE (IMPORTANT — READ FIRST)

#### ✅ What already exists (UNCHANGED)

- order.php → places order

- API Gateway → /orders

- Lambda → inserts order

- Database → orders table

### 🆕 What this phase adds

- New read-only page: order-status.php

- New read-only API: /order-status

- No breaking changes

- No auth required (public tracking link)


> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED


# ☕ Doc:Cafe Order Processor - COMPLETE & VERIFIED
---
## 6️⃣ ☕ Charlie Café – Cach Payment System 

### 🎯 FINAL BEHAVIOR (CONFIRMED)

#### 1️⃣ Customer side

- Customer places order

- Customer sees two payment choices:

  - 💳 Card Payment (Stripe – existing)

  - ☕ Pay Now (Cash at Counter)

- If customer clicks Pay Now (Cash):

  - Card payment UI is disabled

  - Order status becomes AWAITING_CASH_PAYMENT

  - Customer is redirected to order status page

#### 2️⃣ Admin side

- Admin dashboard shows:

  - Orders waiting for cash

- Admin clicks Mark as Paid

- Order status updates to PAID

✔ This matches real cafés

✔ This teaches state machines

✔ This keeps Stripe intact

✔ This is interview-ready architecture

### 🧠 ORDER STATUS FLOW (IMPORTANT)

```
CREATED
   ↓
AWAITING_CASH_PAYMENT   ← (Pay Now - Cash)
   ↓
PAID                   ← (Admin action)

OR

CREATED
   ↓
PAID                   ← (Stripe Card Payment)
```

### 🧠 WHY THIS DESIGN IS EXCELLENT (IMPORTANT)

✔ Real café workflow

✔ Clean separation of concerns

✔ No Stripe dependency for lab

✔ Demonstrates async payments

✔ Interview-grade system design

✔ Scales to QR ordering easily

☕ CHARLIE CAFÉ – CASH PAYMENT FLOW (LAB GUIDE)

This guide covers ONLY CASH PAYMENT, end-to-end.

🧠 FINAL GOAL (KEEP THIS IN MIND)

When customer clicks “Pay Now (Cash)”:

Frontend sends order_id

API Gateway receives request

Lambda updates order:

payment_method = CASH

payment_status = PENDING

Admin later marks order as PAID

🧱 STEP 0 — PRE-REQUISITES (DO NOT SKIP)

You already have:

✅ Orders table (DynamoDB or RDS)

✅ Order creation API

✅ order_id stored in DB

✅ API Gateway working

✅ Lambda execution role exists

If any one of these is missing, stop and fix it first.

## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 

### 3️⃣ API Gateway – NEW ENDPOINT (CASH)

```
POST /orders/cash-payment
```

#### Purpose

- Called when customer clicks Pay Now (Cash)

- Marks order as:

  - payment_method = CASH

  - payment_status = PENDING


### 3️⃣ Lambda – CashPaymentLambda (Python)

```
# ===========================================
# CashPaymentLambda
# ===========================================

import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    """
    Triggered when customer selects CASH payment.
    This does NOT mark order as PAID.
    Admin will do that later.
    """

    body = json.loads(event['body'])
    order_id = body['order_id']

    # Update order to waiting-for-cash
    table.update_item(
        Key={'order_id': order_id},
        UpdateExpression="""
            SET payment_method = :pm,
                payment_status = :ps
        """,
        ExpressionAttributeValues={
            ':pm': 'CASH',
            ':ps': 'PENDING'
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "success": True,
            "message": "Order marked as cash payment"
        })
    }
```

### 4️⃣ Admin Lambda – Mark Paid (Already Similar to Yours)

```
POST /admin/mark-paid
```

```
# ===========================================
# AdminMarkPaidLambda
# ===========================================

def lambda_handler(event, context):
    body = json.loads(event['body'])
    order_id = body['order_id']

    table.update_item(
        Key={'order_id': order_id},
        UpdateExpression="SET payment_status = :paid",
        ExpressionAttributeValues={':paid': 'PAID'}
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"success": True})
    }
```

### 🎨 FRONTEND – MODIFY YOUR EXISTING order.php

Below are ONLY the additions / changes, so you clearly see what’s new.

#### ✅ 1️⃣ Add CASH button (HTML)

Place this below card payment section:

```
<!-- ===================== CASH PAYMENT ===================== -->
<div class="mt-4">
    <h4>☕ Pay at Counter (Cash)</h4>

    <!-- Cash payment button -->
    <button onclick="payWithCash()"
            class="btn btn-dark w-100 mt-2">
        Pay Now (Cash)
    </button>

    <small class="text-muted d-block mt-2">
        Please pay at the counter. Your order will be prepared after payment.
    </small>
</div>
```

#### ✅ 2️⃣ Disable card payment when cash selected (JS)

Add below your Stripe JS code:

```
<script>
// ===================== CASH PAYMENT =====================

async function payWithCash() {

    // Disable card UI to prevent double payment
    document.getElementById('payment-section').style.display = 'none';

    try {
        const response = await fetch(
            "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    order_id: "<?= $orderId ?>"
                })
            }
        );

        const result = await response.json();

        if (result.success) {
            alert("☕ Please pay at the counter. Order registered.");
            window.location.href = "<?= $statusUrl ?>";
        } else {
            alert("❌ Failed to set cash payment.");
        }

    } catch (err) {
        console.error(err);
        alert("Cash payment error.");
    }
}
</script>
```

#### ✅ 3️⃣ (Optional but Recommended) UI clarity

You can add this above payment section:

```
<p class="alert alert-info mt-4">
Choose <strong>ONE</strong> payment method only.
</p>
```

### 6️⃣ UPDATE payment-status.php FOR CUSTOMER REDIRECT

Add a button to print / track order after payment is confirmed:

```
<?php if ($data['payment_status'] === 'PAID'): ?>
    <a href="print-order.php?order_id=<?= $orderId ?>"
       class="btn btn-primary mt-3">
       🖨 Print Order / View Receipt
    </a>
<?php endif; ?>
```

### 7️⃣ OPTIONAL AUTO-REDIRECT TO PRINT PAGE

Replace button logic with:

```
<?php if ($data['payment_status'] === 'PAID'): ?>
<script>
    setTimeout(() => {
        window.location.href = "print-order.php?order_id=<?= $orderId ?>";
    }, 2000); // Redirect 2 seconds after payment confirmed
</script>
<?php endif; ?>
```
#### 🔹 Step 1.3 — Add Attributes (NO MIGRATION NEEDED)

**👉 DynamoDB is schema-less, so you do NOT manually add columns.**

#### Add 2 columns / attributes:

You will simply start writing these attributes:

| Attribute Name | Value          |
| -------------- | -------------- |
| payment_method | CASH / CARD    |
| payment_status | PENDING / PAID |

> **Your existing table is fine — just extend it**

- Click Explore table items (or Items tab) → Create item.

- Use JSON view for ease.

#### You just:

- Added payment_method

- Added payment_status

- WITHOUT changing schema

- WITHOUT migrations

- WITHOUT breaking anything

#### 🧠 WHY THIS WORKS (IMPORTANT)

- DynamoDB stores each item as a JSON object

- Different orders can have:

  - more attributes

  - fewer attributes

  - different shapes

This is by design

#### 🧪 WHAT HAPPENS NEXT (MENTAL MODEL)

When customer places order:

```
{
  "order_id": "ORD-123",
  "payment_method": "CASH",
  "payment_status": "PENDING"
}
```

When customer pays cash:

```
{
  "order_id": "ORD-123",
  "payment_method": "CASH",
  "payment_status": "PAID"
}
```

👉 Same item

👉 Same table

👉 Just updated attributes

### ❌ COMMON WRONG ASSUMPTIONS (YOU DID NOTHING WRONG)

| Thought                    | Reality |
| -------------------------- | ------- |
| “I must add columns”       | ❌ No    |
| “I need migration”         | ❌ No    |
| “I must alter table”       | ❌ No    |
| “This step changes schema” | ❌ No    |



### 5️⃣ 🧪 TEST SCENARIOS (DO THESE)

Scenario 1 – Card

✔ Place order
✔ Pay with card
✔ Status → PAID

Scenario 2 – Cash

✔ Place order
✔ Click Pay Now (Cash)
✔ Card UI disappears
✔ Status → AWAITING PAYMENT
✔ Admin → Mark Paid
✔ Status → PAID

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---



---
## ☕ CHARLIE CAFÉ PHASE 4️⃣ 🔁 REDIRECTING TO payment-status.php

### 🧠 WHY YOU ARE FEELING CONFUSED (VERY NORMAL)

Right now you have two different concepts mixed under the same name:

| Page name                     | Actual responsibility                |
| ----------------------------- | ------------------------------------ |
| `order-status.php` (existing) | Kitchen / preparation / ready status |
| (new page you built)          | Payment result (card or cash)        |


Those are two different stages in the order lifecycle.

So your instinct is 100% right.

### 🧱 CORRECT PAGE RESPONSIBILITY SPLIT (RECOMMENDED)

### ✅ Page 1 — payment-status.php

#### Purpose:
👉 Shown immediately after payment decision

#### Handles:

- Card payment success

- Cash pending

- Cash paid

Nothing else.

### ✅ Page 2 — order-status.php

#### Purpose:
👉 Shown after payment is completed

#### Handles:

- Preparing

- Ready

- Served

Nothing about payment.

#### This separation:

✔ Avoids confusion

✔ Scales well

✔ Matches real apps

✔ Prevents future bugs

### 🔄 FINAL USER FLOW (VERY CLEAR)

```
order.php
   ↓
payment-status.php
   ↓ (after PAID)
order-status.php
   ↓
(print / kitchen / tracking)
```

### 🟦 STEP 1 — REDIRECT FROM order.php (CARD + CASH)

#### 🔴 CURRENT (near the top)

```
// Order status page
$statusUrl = "order-status.php?order_id=$orderId";
```

#### ✅ CHANGE TO

```
// Payment status page (after payment decision)
$statusUrl = "payment-status.php?order_id=$orderId";
```

That’s it.
Nothing else touched here.

- **⚠️ 1️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**

#### 💳 2️⃣ CARD PAYMENT REDIRECT (ADD ONLY)

#### 🔴 CURRENT

```
async function payWithCard() {
    alert("Stripe payment flow continues here (unchanged).");
}
```

#### ✅ UPDATED (redirect added, flow unchanged)

```
async function payWithCard() {

    // ⚠️ Your existing Stripe logic stays here
    alert("Stripe payment successful (LAB simulation).");

    // Redirect to payment status page
    window.location.href = "<?= $statusUrl ?>";
}
```

✔ No Stripe logic removed

✔ Just a redirect after success

- **⚠️ 2️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**

#### ☕ 3️⃣ CASH PAYMENT (ALREADY CORRECT ✅)

You already did this perfectly 👌
This line is already correct:

```
window.location.href = "<?= $statusUrl ?>";
```

Since $statusUrl now points to payment-status.php, cash flow is done.

- **⚠️ 3️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 5️⃣ 🔁 admin-orders.php

### 📊 Admin “Mark as Paid” button

👉 You do NOT add the “Admin – Mark as Paid” button in order.php or payment-status.php. That button belongs to a separate Admin page, not a customer page.

### Why it should NOT be on order.php or payment-status.php
order.php

- Customer-facing

- Used to place order + choose payment

- Customers must never see admin controls

  ❌ Security risk

  ❌ Logic mixing

#### payment-status.php

- Still customer-facing

- Read-only status page

- Shows:

  - “Pay at counter”

  - “Paid”

  - “Waiting”

    ❌ Customers must NOT mark themselves as paid

So we keep these pages clean and safe.

### ✅ Correct & professional placement

#### 📊 Admin “Mark as Paid” button goes here:

👉 admin-orders.php (NEW or existing admin page)

This page is:

- Admin-only (protected later with Cognito / auth)

- Shows all orders

- Used by cashier or staff

#### Recommended Admin Flow (LAB-Perfect)

```
Customer
 └─ order.php
     └─ payment-status.php (cash pending)

Admin / Cashier
 └─ admin-orders.php
     └─ [Mark as Paid] button
         └─ Lambda → update payment_status = PAID
```

### Result

- Customer refreshes payment-status.php → sees PAID

- Admin sees Print button

- Printing uses print-order.php

### ✅ You now have a REAL café workflow

- Customer ≠ Cashier

- Cash verified manually

- Status syncs across pages

- No hacks, no shortcuts

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 4️⃣ Redirect

### 🧠 PART 1 — HOW REDIRECT ACTUALLY WORKS (VERY SIMPLE)

There are only two valid ways to redirect a user in your case:

### ✅ WAY 1 — JavaScript Redirect (BEST FOR PAYMENT)

Used after Stripe or Cash API success

```
window.location.href = "order-status.php?order_id=ORD-123";
```

### 📌 This is what you must use after payment approval, because:

- Payment happens in JavaScript

- PHP has already finished executing

- Headers can’t be changed anymore

**👉 This is the correct method for your case**

### ❌ WAY 2 — PHP header() (NOT usable here)

```
header("Location: order-status.php");
```

❌ This will NOT work after Stripe/cash click

❌ PHP already rendered the page

### 🧠 PART 2 — YOUR EXACT REQUIREMENT

“After payment approved I want:

- order-status page open

- printing page also open”

This is 100% doable, and this is how cafés do it.

### ✅ CORRECT UX PATTERN (IMPORTANT)

You DO NOT redirect to two pages.

Instead:

👉 order-status.php opens

👉 order-status.php triggers print automatically

This avoids popup blockers and chaos.

### 🧩 FINAL FLOW (VERY CLEAR)

```
Payment Success
     ↓
Redirect to order-status.php
     ↓
order-status.php auto-opens print page
```

### 🧾 WHAT WILL PRINT?

By default:

- Order ID

- Payment message

- Status

You can style print-only receipt later.

### 🧪 HOW THIS BEHAVES (IMPORTANT)

#### Case 1 — Card Payment

✔ Pay → Redirect

✔ Order status page opens

✔ Print dialog opens automatically

#### Case 2 — Cash Payment

✔ Click Cash

✔ Redirect

✔ Status page shows “Pay at counter”

✔ Print dialog opens

#### Case 3 — Admin marks paid later

✔ Customer refreshes

✔ No auto-print (unless print=1)

### ⚠️ WHY THIS IS THE RIGHT WAY

❌ Redirecting to 2 pages = browser blocks

❌ Opening new tabs = popup issues

✅ Single redirect

✅ Controlled printing

✅ Clean UX

✅ Mobile-safe

### 🧠 FINAL RULE (REMEMBER THIS)

> **Redirect ONCE → Print INSIDE destination page**

## 2️⃣ ☕ Charlie Café – Online Payment Integration + STRIPE


## 🟦 PHASE 1️⃣ — STRIPE ACCOUNT (ABSOLUTELY BEGINNER SAFE)
> **(Using Existing Place Order Flow)**

### Tech Stack (Your Existing Lab):

- Frontend: EC2 + Apache (HTML / JS)

- Auth: Amazon Cognito (JWT)

- API: API Gateway

- Backend: AWS Lambda (Node.js)

- DB: Amazon RDS (MySQL / PostgreSQL)

- Payment: Stripe (Test Mode)

- Security: HTTPS + JWT + Secrets Manager

### 🧠 FINAL PAYMENT FLOW (REAL WORLD)

```
Customer clicks "Place Order"
↓
Order saved as PAYMENT_PENDING
↓
Stripe payment starts
↓
Payment succeeds
↓
Order updated to PAID
↓
Order visible in dashboard
```

### 🧠 FIRST – WHAT WE ARE ACTUALLY BUILDING (VERY IMPORTANT)

Before touching AWS or code, understand the final behavior:

#### Current (Your Existing System)

```
Customer clicks Place Order
→ Order saved
→ Done
```
#### New (Professional Payment Flow)

```
Customer clicks Place Order
→ Order saved as PAYMENT_PENDING
→ Payment page opens
→ Customer pays
→ Stripe confirms payment
→ Order updated to PAID
```

#### 💡 Rule:
👉 Order is NEVER PAID by frontend

👉 Only Stripe → Backend → DB can mark PAID

### 🟦 PHASE 0 — PREREQUISITES (DO THIS FIRST)

#### STEP 0.1 — Confirm What You Already Have

You MUST already have:

✔ Place Order frontend (HTML/JS)

✔ Place Order backend Lambda

✔ API Gateway endpoint for Place Order

✔ Orders table in RDS

✔ Cognito authentication working

#### ⚠️ If any of these are missing → STOP and fix first

🟦 PHASE 8️⃣ — FRONTEND PAYMENT (FULLY EXPANDED)

🔹 STEP 8.1 — Add Stripe JS SDK (MANDATORY)

📍 Where:
Inside <head> or before </body> of your order page HTML

🔍 Why:
Without this file, Stripe does not exist in browser.

🔹 STEP 8.2 — Create Payment HTML UI (NO JS YET)

📍 Add this inside <body>

🔍 Why this exists:

#card-element → Stripe mounts secure card UI here

#card-errors → Shows validation/payment errors

Button → Triggers your existing order flow

🔹 STEP 8.3 — Initialize Stripe (GLOBAL STEP)

📍 In your JS file or <script> block

❗ Rule

ONLY pk_test_ allowed in frontend

NEVER sk_test_

🔹 STEP 8.4 — Create Stripe Elements Object

🔍 Why:
elements is a Stripe UI factory that creates secure inputs.

🔹 STEP 8.5 — Create Card Input Element (THIS WAS MISSING BEFORE)

✅ NOW cardElement EXISTS
This is what we use later in confirmCardPayment.

🔹 STEP 8.6 — Mount Card Element into HTML

📌 Important

This connects Stripe → HTML

Without this, nothing appears on screen

🔹 STEP 8.7 — Handle Card Input Errors (VERY IMPORTANT)

🔍 Why recruiters like this

Real-time validation

Professional UX

No blind failures

🔹 STEP 8.8 — FINAL placeOrder() FUNCTION (NOW FULLY CORRECT)

This is the COMPLETE FUNCTION, now that cardElement exists.

### 1️⃣ — Add Stripe JS SDK (MANDATORY)

#### 📍 Where:

Inside <head> or before </body> of your order page HTML

```
<!-- Stripe official JavaScript SDK -->
<script src="https://js.stripe.com/v3/"></script>
```

### 2️⃣ — Create Payment HTML UI (NO JS YET)

#### 📍 Add this inside <body>

```
<!-- Payment section -->
<div id="payment-section">

    <h3>Pay with Card</h3>

    <!-- Stripe will inject secure card input here -->
    <div id="card-element"></div>

    <!-- Show card errors here -->
    <div id="card-errors" style="color:red; margin-top:10px;"></div>

    <!-- Submit order + payment -->
    <button onclick="placeOrder()">Place Order & Pay</button>

</div>
```

### 3️⃣ — Initialize Stripe (GLOBAL STEP)

📍 In your JS file or <script> block

```
// Initialize Stripe using TEST publishable key
// This key is SAFE to expose in frontend
const stripe = Stripe("pk_test_xxxxxxxxx");
```
### 4️⃣ — Create Stripe Elements Object

```
// Create Stripe Elements instance
const elements = stripe.elements();
```

### 5️⃣ — Create Card Input Element (THIS WAS MISSING BEFORE)

```
// Create a card input field
const cardElement = elements.create('card', {
    style: {
        base: {
            fontSize: '16px',
            color: '#ffffff',
            '::placeholder': {
                color: '#cccccc'
            }
        },
        invalid: {
            color: '#ff0000'
        }
    }
});
```

### 6️⃣ — Mount Card Element into HTML

```
// Attach Stripe card UI to <div id="card-element">
cardElement.mount('#card-element');
```

### 7️⃣ — Mount Card Element into HTML

```
// Listen for validation errors in real-time
cardElement.on('change', function(event) {

    const displayError = document.getElementById('card-errors');

    if (event.error) {
        displayError.textContent = event.error.message;
    } else {
        displayError.textContent = '';
    }
});
```

### 8️⃣ — FINAL placeOrder() FUNCTION (NOW FULLY CORRECT)

This is the COMPLETE FUNCTION, now that cardElement exists.

```
async function placeOrder() {

    try {

        // 1️⃣ Call EXISTING Place Order backend
        const orderResponse = await fetch('/place-order', {
            method: 'POST',
            headers: {
                'Authorization': localStorage.getItem('token'),
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(cartData)
        });

        const orderResult = await orderResponse.json();
        const orderId = orderResult.orderId;

        // 2️⃣ Calculate total amount (Stripe requires cents)
        const amount = calculateTotalAmount() * 100;

        // 3️⃣ Create Payment Intent (backend)
        const paymentResponse = await fetch('/payment/create-intent', {
            method: 'POST',
            headers: {
                'Authorization': localStorage.getItem('token'),
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                orderId: orderId,
                amount: amount
            })
        });

        const paymentData = await paymentResponse.json();

        // 4️⃣ Confirm card payment using Stripe
        const result = await stripe.confirmCardPayment(
            paymentData.clientSecret,
            {
                payment_method: {
                    card: cardElement
                }
            }
        );

        // 5️⃣ Handle result
        if (result.error) {

            // Payment failed
            alert("Payment failed: " + result.error.message);

        } else {

            // Payment succeeded
            alert("Payment successful! Order confirmed.");

        }

    } catch (error) {
        console.error(error);
        alert("Something went wrong during payment.");
    }
}
```

✅ PHASE 8️⃣ — FINAL STATUS (NOW ACTUALLY COMPLETE)

✔ Stripe SDK loaded
✔ HTML payment UI created
✔ Stripe Elements initialized
✔ cardElement created
✔ cardElement mounted
✔ Errors handled
✔ Payment confirmed securely

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**

🟦 PHASE 9️⃣ — STRIPE WEBHOOK
(BACKEND TRUST • FINAL PAYMENT CONFIRMATION)
🧠 WHY THIS PHASE EXISTS (READ FIRST)

Up to now:

Frontend requests payment

Stripe processes payment

Frontend shows success

⚠️ THIS IS NOT TRUSTED

👉 In real systems:

Frontend can be closed

Browser can be hacked

Network can fail

✅ ONLY STRIPE → BACKEND is trusted

That is why webhooks exist.

🔹 STEP 9.1 — What Is a Stripe Webhook?

A webhook is:

Stripe calling YOUR backend URL
and saying:
“Payment really succeeded”

Only after this do we mark order as PAID.

🔹 STEP 9.3 — Why Python Here?

Stripe webhooks are simple JSON

Python is clean and readable

Good for interview explanation

(You can use Node.js too — logic is same)

✅ PHASE 9️⃣ STATUS

🟢 Stripe → Backend confirmation
🟢 No frontend trust
🟢 Real production behavior


> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**

🟦 PHASE 🔟 — UPDATE ORDER STATUS (DB LOGIC)
🔹 STEP 10.1 — Why Update in Webhook Only?

❌ Frontend success ≠ real payment
✅ Webhook success = real payment

So ONLY webhook updates DB.


> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**

🧠 FIRST: WHAT IS “DASHBOARD” IN YOUR PROJECT?

In Charlie Café, a Dashboard means:

A page for Admin / Owner / HR
that shows business numbers, not customer orders.

Examples:

How much money did we earn today?

How much this week?

Which orders are actually paid?

👉 This is NOT the customer order page
👉 This is Admin-only view

🧠 WHY YOU ARE CONFUSED (IMPORTANT)

You are thinking:

“I already have orders in DB… why new queries?”

Because:

Orders table contains ALL orders

Business cares ONLY about money

Money comes ONLY from PAID orders

So dashboard = filtered view of orders

🧠 Explained Like You’re Building It for the First Time
🔴 FIRST: WHAT PHASE 13 IS NOT

❌ It is NOT Stripe
❌ It is NOT payment processing
❌ It is NOT customer order page

👉 PHASE 13 = BUSINESS REPORTING

🟢 WHAT PHASE 13 ACTUALLY IS

Think of Charlie Café owner asking:

“How much money did my café make today and this week?”

That is PHASE 13.

🧠 VERY IMPORTANT MENTAL MODEL (READ TWICE)

```
Stripe → confirms payment
↓
Order marked PAID in database
↓
Dashboard reads database
↓
Dashboard shows numbers
```

⚠️ Dashboard does NOT talk to Stripe
⚠️ Dashboard does NOT care about PENDING orders

🟦 STEP 13.0 — WHY YOU FEEL CONFUSED

Because you are mixing these 3 layers:

| Layer                     | Job                |
| ------------------------- | ------------------ |
| Database                  | Stores orders      |
| Backend (Lambda)          | Calculates numbers |
| Frontend (Dashboard page) | Shows numbers      |

We will now separate them one by one.


🔹 STEP 13.2 — Where These SQL Queries Are Used

This is VERY important 👇
You do NOT run these queries in browser.

Correct place:

```
Dashboard Page (HTML)
   ↓ calls
Dashboard API (API Gateway)
   ↓ triggers
Dashboard Lambda
   ↓ runs
SQL Queries on RDS
```

So SQL = backend only

🧠 SIMPLE MENTAL MODEL (REMEMBER THIS)


```
Orders table
 ├── PENDING (ignored)
 ├── FAILED  (ignored)
 └── PAID    → Dashboard numbers
```
Dashboard = filtered math on PAID orders


> **🟢 PHASE 1️⃣3️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION R & D COMPLETE & VERIFIED

---

## 2️⃣ ☕ Charlie Café – Online Payment Integration + STRIPE


## ☕ CHARLIE CAFÉ PHASE 1️⃣ — STRIPE ACCOUNT (ABSOLUTELY BEGINNER SAFE)

### 1️⃣ — Create Stripe Account

- Go to stripe.com

- Click Sign Up

- Use email + password

- Verify email

**👉 No company info needed for Test Mode**

### 2️⃣ — Enable Test Mode

- Login to Stripe Dashboard

- Top-right toggle → Test Mode ON

**👉 You should see “TEST MODE” label**

### 3️⃣ — Get API Keys

- Go to Developers → API Keys

#### Copy:

  - Publishable key → starts with pk_test_

  - Secret key → starts with sk_test_

#### ⚠️ VERY IMPORTANT

  - pk_test_ → frontend only

  - sk_test_ → backend only (NEVER frontend)

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

## 🟦 PHASE 2️⃣ — DATABASE (NO PAYMENT WORKS WITHOUT THIS)

### 1️⃣ — Open Your RDS Database

- Login to RDS

- Open Query Editor / MySQL client

- Select your charlie_cafe database

### 2️⃣ — Understand Why We Add Columns

#### 1️⃣ Stripe returns:

- payment ID

- payment status

- payment time

#### We MUST store these for:

✔ audit

✔ dashboard

✔ real-world credibility

### 2️⃣ — ALTER TABLE (RUN THIS EXACTLY)

```
ALTER TABLE orders
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING',
ADD COLUMN payment_intent_id VARCHAR(100) NULL,
ADD COLUMN payment_amount DECIMAL(10,2) NULL,
ADD COLUMN payment_method VARCHAR(50) NULL,
ADD COLUMN payment_time TIMESTAMP NULL;
```

### 4️⃣ — Allowed Payment Status Values

#### Use ONLY these values (case-sensitive):

```
PENDING   → order created, not paid
PAID      → payment successful
FAILED    → payment failed
```

**⚠️ Do NOT invent new values**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 3️⃣ — AWS SECRETS MANAGER (NO HARD-CODED KEYS)

### 3️⃣ — Open Secrets Manager

- AWS Console → Secrets Manager

- Click Store a new secret

### 2️⃣ — Choose Secret Type

- Select: Other type of secret

- Key: STRIPE_SECRET_KEY

- Value: sk_test_xxxxxxxxx

- Click Next

### 3️⃣ — Name the Secret

#### Secret name:

```
stripe/charlie-cafe
```

- Click Next → Next → Store

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 4️⃣ — IAM ROLE (THIS IS WHERE MOST PEOPLE FAIL)

### 1️⃣ — Open IAM

- AWS Console → IAM

- Click Roles

- Open role used by Payment Lambda
(or your common Lambda role)

### 2️⃣— Attach Secrets Manager Policy

- Click Add permissions → Inline policy

#### Paste this:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
```

Click Review → Save

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 5️⃣ — CREATE PAYMENT LAMBDA (NO ASSUMPTIONS)

### 1️⃣ — Create Lambda

- AWS Lambda → Create function

- Name:

```
CreatePaymentIntent
```

- Runtime:

```
Node.js 18.x
```

- Execution role:

```
Use existing role (same as Place Order)
```

- Click Create

### 2️⃣ — Add Dependencies

- Stripe SDK is REQUIRED.

- If using Lambda Layers:

- Add Stripe library

(For lab: inline example is acceptable)

### 3️⃣ — FULLY COMMENTED LAMBDA CODE

[CreatePaymentIntent.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CreatePaymentIntent.py)

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 6️⃣ — API GATEWAY (NO SKIPPED CLICKS)

### 1️⃣ — Open API Gateway

- API Gateway → your existing API

- Click Create Resource

- Resource name:

```
payment
```

### 2️⃣— Create Method

- Resource: /payment

- Create Method → POST

- Method name:

```
/payment/create-intent
```

### 3️⃣ — Integration Settings

- Integration type: Lambda

- Lambda function: CreatePaymentIntent

- Enable Lambda proxy integration

### 4️⃣ — Authorization

- Authorization: Cognito Authorizer

- Same authorizer as Place Order

- Deploy API.

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 7️⃣ — MODIFY EXISTING PLACE ORDER (SAFE CHANGE)

### 1️⃣ — What Changes?

#### ONLY this:

- Set payment_status = 'PENDING'

- Return orderId

### 2️⃣ — Example Update (COMMENTED)

```
// After inserting order into DB
const orderId = result.insertId;

// Return order ID for payment
return {
    statusCode: 200,
    body: JSON.stringify({
        orderId: orderId,
        message: "Order created. Payment pending."
    })
};
```

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 8️⃣ — FRONTEND PAYMENT (VERY DETAILED)

[orders.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)


**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 9️⃣ — STRIPE WEBHOOK (BACKEND TRUST ONLY)

### 1️⃣ — Create Webhook Lambda

- Function name:

```
StripeWebhookHandler
```

- Runtime:

```
Python 3.11
```

- Execution role:

```
Use existing Lambda role
```

- Click Create

### 2️⃣ — Webhook Code (COMMENTED)

[StripeWebhookHandler.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/StripeWebhookHandler.py)

### 3️⃣ — Environment Variables (CRITICAL)

- In StripeWebhookHandler Lambda → Configuration → Environment variables

- Add:

```
DB_HOST = your-rds-endpoint
DB_USER = db-username
DB_PASSWORD = db-password
DB_NAME = charlie_cafe
```

### 4️⃣ — API Gateway for Webhook

- Open API Gateway

- Create new resource:

```
/stripe-webhook
```

- Add method:

```
POST
```

- Integration:

  - Lambda

  - Function: StripeWebhookHandler

- Authorization:

```
NONE
```

**⚠️ Stripe cannot use Cognito**

### 5️⃣ — Configure Webhook in Stripe Dashboard

- Stripe Dashboard → Developers → Webhooks

- Click Add endpoint

- Endpoint URL:

```
https://your-api-id.execute-api.region.amazonaws.com/prod/stripe-webhook
```

- Events to listen:

```
payment_intent.succeeded
```

- Save


**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 🔟 — UPDATE ORDER STATUS IN DB

### 1️⃣ SQL Used (FINAL)

```
UPDATE orders
SET payment_status = 'PAID',
    payment_intent_id = ?,
    payment_time = NOW()
WHERE order_id = ?;
```

### 2️⃣ Payment Failure Case

If Stripe sends:

```
payment_intent.payment_failed
```

#### You update:

```
UPDATE orders
SET payment_status = 'FAILED'
WHERE order_id = ?;
```

**✅(You can add later)**

### ✅ PHASE 🔟 STATUS

🟢 DB reflects real payment

🟢 No fake PAID orders

**✅ PHASE 🔟 STATUS**

> **🟢 PHASE 🔟 COMPLETE & VERIFIED**
---

## 🟦 PHASE 1️⃣1️⃣ — SECURITY (MANDATORY)

### 1️⃣ — Card Data Handling

✔ Stripe handles card UI

✔ Your system NEVER sees card number

✔ PCI compliance achieved

### 2️⃣ — Secrets

✔ Stripe secret key in Secrets Manager

✔ DB credentials in Lambda env vars

✔ No hard-coded secrets

### 3️⃣ — Network Security

✔ HTTPS enforced

✔ API Gateway throttling enabled

✔ Lambda security group → RDS only

### 4️⃣ — Authorization Summary

| API                    | Auth               |
| ---------------------- | ------------------ |
| /place-order           | Cognito            |
| /payment/create-intent | Cognito            |
| /stripe-webhook        | NONE (Stripe only) |

### ✅ PHASE 1️⃣1️⃣ STATUS

🟢 Production-grade security

🟢 Interview-ready explanation

**✅ PHASE 1️⃣1️⃣ STATUS**

> **🟢 PHASE 1️⃣1️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 1️⃣2️⃣ — TESTING

### 1️⃣ Stripe Test Card

#### Use ONLY this:

```
4242 4242 4242 4242
Any future date
Any CVC
```

### 2️⃣ Full Test Flow

- Open frontend

- Add items to cart

- Click Place Order & Pay

- Enter test card

- Confirm payment

- Check:

  - Stripe Dashboard → Payments

  - RDS → orders table

- Verify:

```
payment_status = PAID
```

### 3️⃣ Failure Test

- Use:

```
4000 0000 0000 9995
```

- Result:

```
payment_status = FAILED
```

###  ✅ PHASE 1️⃣2️⃣ STATUS

🟢 Payment success verified

🟢 Payment failure verified

**✅ PHASE 1️⃣2️⃣ STATUS**

> **🟢 PHASE 1️⃣2️⃣ COMPLETE & VERIFIED**
---

## 🟦 PHASE 1️⃣3️⃣ — DASHBOARD

### 🟦 PRE-CHECK (VERY IMPORTANT)

Before dashboard works, confirm this in DB:

#### Run:

```
SELECT order_id, payment_status, payment_amount, payment_time
FROM orders;
```

#### You MUST see rows like:

| order_id | payment_status | payment_amount | payment_time     |
| -------- | -------------- | -------------- | ---------------- |
| 101      | PAID           | 25.00          | 2026-01-22 18:30 |
| 102      | PENDING        | NULL           | NULL             |

**⚠️ If payment_amount or payment_time is NULL for PAID, dashboard will not work ❌**

### 1️⃣ — Why Dashboard Uses PAID Only

#### Think like café owner:

| Status  | Meaning              | Count as money? |
| ------- | -------------------- | --------------- |
| PENDING | Customer hasn’t paid | ❌ NO            |
| FAILED  | Payment failed       | ❌ NO            |
| PAID    | Money received       | ✅ YES           |

#### So rule is:

```
Dashboard = SUM of PAID orders only
```

**⚠️ This is business logic, not AWS logic.**

### 2️⃣ Create Dashboard Backend (Lambda)

#### 1️⃣ — Create Lambda

- Name:

```
GetDashboardStats
```

- Runtime:

```
Node.js 18
```

- Role:

```
Same role as other Lambdas
```

#### 2️⃣ — Dashboard Lambda Code (COMMENTED)

[GetDashboardStats.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/GetDashboardStats.py)

### 3️⃣ — API Gateway for Dashboard

#### 1️⃣ Create API:

```
GET /dashboard
``` 

#### 2️⃣ Integration:

- Lambda: GetDashboardStats

- Authorization: Cognito (Admin users only)

### 4️⃣ — Frontend Dashboard Page (SIMPLE)

#### 1️⃣ — HTML

```
<h2>Charlie Café Dashboard</h2>

<h3>Daily Revenue</h3>
<div id="daily-revenue"></div>

<h3>Weekly Revenue</h3>
<div id="weekly-revenue"></div>
```

#### 2️⃣ Dashboard JS (COMMENTED)

```
async function loadDashboard() {

    // Call dashboard API
    const response = await fetch('/dashboard', {
        headers: {
            'Authorization': localStorage.getItem('token')
        }
    });

    const data = await response.json();

    // Show daily revenue
    let dailyHtml = '';
    data.dailyRevenue.forEach(row => {
        dailyHtml += `<p>${row.day}: $${row.total}</p>`;
    });
    document.getElementById('daily-revenue').innerHTML = dailyHtml;

    // Show weekly revenue
    let weeklyHtml = '';
    data.weeklyRevenue.forEach(row => {
        weeklyHtml += `<p>Week ${row.week}: $${row.total}</p>`;
    });
    document.getElementById('weekly-revenue').innerHTML = weeklyHtml;
}
```

#### Call this on page load:

```
loadDashboard();
```

### 2️⃣ Orders Query (Correct)

```
SELECT *
FROM orders
WHERE payment_status = 'PAID';
```

### 3️⃣ Daily Revenue

```
SELECT DATE(payment_time) AS day,
       SUM(payment_amount) AS total
FROM orders
WHERE payment_status = 'PAID'
GROUP BY day;
```

### 4️⃣ Weekly Revenue

```
SELECT WEEK(payment_time) AS week,
       SUM(payment_amount) AS total
FROM orders
WHERE payment_status = 'PAID'
GROUP BY week;
```

### ✅ PHASE 1️⃣3️⃣ STATUS

🟢 Accurate revenue

🟢 Real café metrics

🟢 Professional reporting

**✅ PHASE 1️⃣3️⃣ STATUS**

> **🟢 PHASE 1️⃣3️⃣ COMPLETE & VERIFIED**

---





