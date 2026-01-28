# ☕ Charlie Cafe 1 — Order_Async_Processing_Tracking_System


# ☕ Charlie Café SECTION 1️⃣ Cafe Order Processor 



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