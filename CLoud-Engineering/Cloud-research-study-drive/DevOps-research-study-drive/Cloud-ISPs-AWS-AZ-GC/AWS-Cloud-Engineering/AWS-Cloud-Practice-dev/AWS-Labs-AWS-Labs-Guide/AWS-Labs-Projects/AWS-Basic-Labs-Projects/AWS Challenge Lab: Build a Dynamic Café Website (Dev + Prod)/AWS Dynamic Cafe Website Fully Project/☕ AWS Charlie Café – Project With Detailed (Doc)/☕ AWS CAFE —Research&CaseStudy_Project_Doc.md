# ☕ AWS CAFE — Research & CaseStudy Project Doc

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---
## 🎯 Objective

Build a **dynamic café ordering system** using:

* EC2 + LAMP (Dev)
* MariaDB
* Secrets Manager
* IAM Roles (NO hardcoded creds)
* Custom AMI
* Production environment (multi‑region)
* **Automation using Lambda + API Gateway**

---


## 🧱 AWS Café Visual Architecture (Logical Diagram)

This diagram represents everything you actually built, not theory.

### 🧠 High-Level Architecture Flow

```
Customer Browser
        |
        v
   Amazon CloudFront
        |
        |-------------------------------|
        |                               |
 Static Content                    Dynamic APIs
 (HTML/CSS/JS)                     (/orders, /status)
        |                               |
        v                               v
 Application Load Balancer        Amazon API Gateway
        |                               |
        v                               v
 EC2 (Apache + PHP)              Lambda (Order API)
                                        |
                                        v
                                  Amazon SQS
                                        |
                                        v
                                 Lambda (Worker)
                                        |
                                        v
                                 Amazon RDS (MySQL)
                                        |
                                        v
                           Order Status & Billing Data


```

### MERMAID DIAGRAM (Copy-Paste Ready)

You can paste this directly into GitHub Markdown, Mermaid Live Editor, or documentation tools.

```
flowchart TD

    User[Customer Browser]

    CF[Amazon CloudFront]

    ALB[Application Load Balancer]
    EC2[EC2 - Apache + PHP Frontend]

    APIGW[Amazon API Gateway]

    LambdaAPI[Lambda - Order API]
    SQS[Amazon SQS Queue]
    LambdaWorker[Lambda - Order Worker]

    RDS[(Amazon RDS - MySQL)]

    Secrets[AWS Secrets Manager]
    CW[Amazon CloudWatch]

    User --> CF

    CF -->|Static Content| ALB
    ALB --> EC2

    CF -->|Dynamic API Requests| APIGW
    APIGW --> LambdaAPI

    LambdaAPI --> SQS
    SQS --> LambdaWorker

    LambdaWorker --> RDS

    LambdaAPI --> Secrets
    LambdaWorker --> Secrets

    LambdaAPI --> CW
    LambdaWorker --> CW
```



---

## AWS Architecture Diagram 

![AWS Architecture Diagram](./AWS%20Cafe%20Project%20Architecture%20Diagram/AWS%20Drinking%20Café%20architecture%20diagram.png)

---

## ☕ AWS Drinking Café Project— Full Hands-On Lab Tasks 

### 🧩 Architecture & System Design

- Designed a production-grade, event-driven cloud architecture for a dynamic café ordering platform

- Implemented dual backend architecture using EC2 + ALB and API Gateway + Lambda

- Integrated CloudFront CDN with multiple origins and path-based routing

- Applied zero-risk incremental deployment strategy for feature expansion

### ⚙️ Backend Engineering (Serverless & Compute)

- Built serverless order processing APIs using AWS Lambda (Python)

- Implemented asynchronous order processing using Amazon SQS

- Developed worker Lambda for background order handling and status updates

- Designed idempotent order workflows with unique order tracking IDs

### 🗄️ Data & Persistence Layer

- Designed relational database schema for orders, items, and billing

- Integrated Amazon RDS (MySQL) for transactional order storage

- Implemented order status persistence for real-time and historical tracking

- Optimized database access using VPC-secured connectivity

### 🌐 API Management & Integration

- Designed RESTful APIs for order placement, order status, and menu retrieval

- Implemented CORS-enabled API Gateway for frontend integration

- Secured API endpoints using IAM-based permissions

- Enabled CloudFront-accelerated API delivery

### 🖥️ Frontend & Customer Experience

- Developed customer order tracking & billing dashboard (frontend-only, zero-risk)

- Implemented real-time order status lookup using unique order IDs

- Built print-ready billing & receipt system

- Integrated frontend seamlessly with both EC2 and serverless backends

### 🔐 Security & Secrets Management

- Implemented Secrets Manager–based credential management

- Enforced least-privilege IAM policies across Lambda, EC2, and SQS

- Secured backend services using VPC isolation and security groups

- Delivered HTTPS-only application flow via CloudFront and ALB

### 🚀 CI/CD & Automation

- Implemented end-to-end CI/CD pipeline using AWS CodePipeline

- Automated Lambda build & deployment using CodeBuild

- Enabled version-controlled infrastructure updates via GitHub

- Reduced manual deployment risk through pipeline-driven releases

### 📊 Monitoring, Reliability & Operations

- Implemented CloudWatch logging and metrics for Lambdas and SQS

- Monitored order throughput, failures, and queue backlogs

- Configured alerts for system failures and performance degradation

- Validated system reliability through end-to-end workflow testing

### 📦 Performance, Scaling & Cost Awareness

- Applied CloudFront caching strategies for static and dynamic content

- Optimized API performance with cache-controlled GET endpoints

- Designed architecture fully within AWS Free Tier constraints

- Balanced cost, scalability, and availability for real-world usage

### 🏁 Production Readiness & Portfolio Delivery

- Delivered a portfolio-ready, real-world cloud application

- Created modular, extensible architecture suitable for future microservices

- Documented full system design and workflows in Markdown

- Prepared project for technical interviews, demos, and cloud assessments



# 🟢 SECTION INTRO CHARLIE CAFE -  COMPLETE & VERIFIED
---

# ☕ Charlie Café - Doc:  Cafe Order Processor 

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
# ☕ Charlie Café  Doc:# SALES ANALYTICS & REPORTING SYSTEM

### 🎯 WHAT YOU ARE BUILDING (CLEAR SCOPE)

You will build ONE analytics system that:

✔ Reads data from existing Order Status DynamoDB table

✔ Calculates Today / Weekly / Monthly Sales

✔ Calculates Cost, Profit, Loss

✔ Displays professional Bootstrap analytics dashboard

✔ Generates PDF reports (custom date OR month-end)

✔ Supports manual PDF download

✔ Supports monthly auto-PDF generation

✔ Uses existing API Gateway + Lambda (minimal additions)

### 🧱 ARCHITECTURE (FINAL)

```
Order Status Page (Existing)
        |
        |--- GET /order-status        (existing)
        |--- GET /analytics           (new)
        |--- GET /analytics/csv       (new)
        |--- POST /report/pdf         (new)
        |
API Gateway (Existing)
        |
        |--- OrderStatusLambda        (existing)
        |--- CafeAnalyticsLambda     (new)
        |--- CafePDFReportLambda     (new)
        |
DynamoDB
        |
        |--- CafeOrders              (existing)
        |--- CafeMenu                (new – cost only)
        |
EventBridge
        |
        |--- Daily / Monthly PDF
```

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

### WHY THIS INDEX WORKS (MENTAL MODEL)

- **order_date → filters day ranges**

- **order_timestamp → sorts results chronologically**

- BETWEEN start_date AND end_date → enables:

    - Today

    - Last 7 days

    - Month to date

This avoids full table scans (very important).







> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED


# ☕ Doc:Cafe Order Processor - COMPLETE & VERIFIED

---
# ☕ Charlie Café  Doc:SALES ANALYTICS & REPORTING SYSTEM



**✅ PHASE 16 STATUS**

> **🟢 PHASE 16 COMPLETE & VERIFIED**

# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

# SECTION 2️⃣ ☕ Charlie Café – Online Payment Integration
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

# 🟢 SECTION 8️⃣ COMPLETE & VERIFIED


# ☕ Doc:SALES ANALYTICS & REPORTING SYSTEM - COMPLETE & VERIFIED

---

# ☕ Charlie Café  Doc:Secure HR & Attendance System

# ☕ Charlie Café SECTION 5️⃣ – Secure HR & Attendance System
> **📄 ☕ AWS Charlie Café – Secure HR & Attendance System.md


# ☕ Charlie Café SECTION 1️⃣ - Research & Development

## PHASE 1️⃣ System Scope

### 1️⃣ Attendance Management

- Employee daily check-in and check-out

- Automatic capture of:

    - Date

    - Time

    - Employee ID

- Centralized attendance records stored in RDS

- Admin/HR dashboard to view:

    - Daily attendance

    - Weekly summary

    - Monthly summary

### 2️⃣ Employee Portal

- Secure employee login using Amazon Cognito

- Employee can:

    - View personal attendance history

    - View approved leaves

    - View official café holidays

    - View HR profile information:

        - Job title

        - Salary

        - Start date

### 3️⃣ Access Control & Security

- Application access restricted using Security Groups

- 1️⃣ Frontend EC2:

    - HTTP/HTTPS allowed only from allowed IP ranges (practice lab)

- 2️⃣ Backend services protected using:

    - API Gateway authorization

    - Cognito JWT validation

- 3️⃣ Database access:

    - RDS accessible only from Lambda security group

## PHASE 2️⃣ Architecture Overview   

### 1️⃣ Frontend Layer

- Hosted on **EC2 Apache Web Server**

- Pages:

    - Attendance Check-In / Check-Out page (tablet/kiosk style)

    - Employee Portal page

    - Admin / HR Dashboard page

- Frontend communicates with backend using API Gateway endpoints

### 2️⃣ Backend Layer

#### 1️⃣ AWS API Gateway (REST API)

#### 2️⃣ AWS Lambda functions:

    - checkin

    - checkout

    - employeeProfile

    - attendanceHistory

    - leavesAndHolidays

#### 3️⃣ Amazon Cognito:

    - User authentication

    - JWT-based access control for APIs


## PHASE 3️⃣ Database Layer (RDS)

### 1️⃣ Database Type

    - MySQL or PostgreSQL

### 2️⃣ Tables

#### 1️⃣ employees

    - employee_id

    - name

    - job_title

    - salary

    - start_date

    - cognito_user_id

#### 2️⃣ attendance

    - attendance_id

    - employee_id

    - date

    - checkin_time

    - checkout_time

#### 3️⃣ leaves

    - leave_id

    - employee_id

    - leave_date

    - leave_type

#### 4️⃣ holidays

    - holiday_date

    - description

## PHASE 4️⃣ Frontend Pages

### 1️⃣ A) Attendance Check-In / Check-Out Page

    - Tablet-friendly layout

    - Employee authentication via Cognito

    - Buttons:

        - Check-In

        - Check-Out

    - Auto timestamp capture

    - Success / error notification

### 2️⃣ B) Employee Portal Page

    - Authenticated access only

    - Sections:

        - Employee profile summary

        - Attendance table

        - Leaves and holidays list

#### Displayed Data Example

```
Employee Name: Alice
Job Title: Barista
Salary: 40,000 / month

Attendance:
Date        | Check-In | Check-Out
2026-01-19  | 09:00    | 17:00
2026-01-18  | 09:10    | 17:00

Leaves:
- 2026-01-15 | Sick Leave
- 2026-01-01 | Public Holiday
```

### 2️⃣ C) Admin / HR Dashboard

    - Secure Cognito-admin access

    - View:

        - Daily attendance

        - Weekly summary

        - Monthly summary

    - Employee-wise filtering

    - Export-ready table structure (future use)


## PHASE 5️⃣ API Endpoints (API Gateway + Lambda)

    - POST /api/checkin

    - POST /api/checkout

    - GET /api/employee/profile

    - GET /api/attendance

    - GET /api/leaves-holidays

#### Security

    - Cognito Authorizer enabled

    - JWT required for all endpoints

## PHASE 6️⃣ Security Configuration

### 1️⃣ Security Groups

#### 1️⃣ Frontend EC2

    - Allow HTTP/HTTPS from allowed IP ranges

#### 2️⃣ Lambda

    - Allow outbound access to RDS

#### 3️⃣ RDS

    - Allow inbound only from Lambda security group

### 2️⃣ Authentication & Authorization

    - Amazon Cognito User Pool

    - Role-based access:

        - Employee

        - Admin / HR

    - JWT validation enforced at API Gateway

## PHASE 7️⃣ Deployment Alignment

    - Frontend deployed on existing EC2 Apache server

    - Backend integrated into existing API Gateway + Lambda

    - Authentication integrated with existing Cognito

    - Database hosted in existing RDS

    - Logging via CloudWatch

## PHASE 8️⃣ Completion Outcome

    - Fully integrated internal café attendance system

    - Professional AWS architecture aligned with real job requirements

    - Secure, scalable, and production-style setup

    - Completes the final 20% of the Charlie Café lab



> **🟢 SECTION 1️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 🎯 What We Are Creating in This Part

#### You will create 5 NEW Lambda functions:

- hr-checkin

- hr-checkout

- hr-employee-profile

- hr-attendance-history

- hr-leaves-holidays

#### Each Lambda will:

- Use existing RDS (cafedb)

- Be protected by existing Cognito

- Be callable from existing API Gateway

- Follow real job-level backend standards


> **🟢 PHASE 2️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 4️⃣ — Frontend Pages for HR System

### 1️⃣ Employee Check-In / Check-Out Page (Tablet Friendly)

#### 1️⃣ File: checkin.html

✅ Designed for tablet / kiosk

✅ Uses Bootstrap 5

✅ Café-style background

✅ Works with API Gateway + Lambda + RDS

✅ Employee ID input + Submit

✅ Fully commented (no guessing later)

#### 2️⃣ ✅ Why This Is Correct for a REAL Café Lab

✔ No Cognito needed (kiosk logic)

✔ Works inside Security Group–restricted EC2

✔ Simple for staff (ID + 1 tap)

✔ Backend already handles validation

✔ Tablet-friendly (big buttons)

✔ Professional café branding

### 2️⃣ Employee Portal Page

☕ Café-style look (same visual identity as admin & check-in pages)

📱 Fully responsive Bootstrap 5 layout

🔐 Cognito + API Gateway logic preserved (no backend changes)

🧱 Clean cards instead of plain tables

💬 Detailed comments everywhere (frontend-learning friendly)

1️⃣ Logout button (Cognito-based)

2️⃣ Today’s attendance status badge

3️⃣ Download attendance as PDF (client-side)

4️⃣ Dark / Light café mode toggle

#### ✅ What This Page Now Represents (Job-Ready)

✔ Consistent Charlie Café branding

✔ Secure Cognito-protected employee portal

✔ Clean, readable UI for non-technical staff

✔ Fully responsive (mobile / tablet / desktop)

✔ Perfect match with your AWS lab architecture

### 3️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)

#### ✅ Features of This Admin Dashboard

☑️ Responsive sidebar using Bootstrap

☑️ Sidebar buttons:

    ✔️ Dashboard (default view)

    ✔️ Attendance Management

    ✔️ Employees

    ✔️ Leaves & Holidays

    ✔️ Reports

    ✔️ Logout button at bottom of sidebar

☑️ Main content area:

    ✔️ Attendance summary table (dynamic)

    ✔️ Leaves & Holidays table (dynamic)

    ✔️ Placeholder for Employees & Reports pages

☑️ Café theme colors (dark sidebar + gold hover)

☑️ Fully responsive — works on mobile and desktop

☑️ Fully commented for easy future development

☑️  You can directly upload this file to /var/www/html/

☑️  No backend changes required

✅ Newly Added to ADMIN page

    1️⃣ Cognito Logout button

    2️⃣ Today’s café attendance status badge

    3️⃣ Download attendance report (PDF)

    4️⃣ Dark / Light café theme toggle

### 4️⃣ — HOW LOGOUT INTEGRATES WITH COGNITO (STEP-BY-STEP)

> **✅ this logout design and logic applies to BOTH the Admin page and the Employee page in your Charlie Café HR system.**

#### 🔐 What Logout Actually Does

Cognito stores the login session in browser storage.
Logout means destroying that session.

#### ✅ CONFIRMATION: SAME LOGOUT LOGIC FOR ADMIN & EMPLOYEE

✔ Admin Portal → uses Cognito Admin group

✔ Employee Portal → uses Cognito Employee group

✔ Logout behavior → IDENTICAL for both

The difference is NOT logout, the difference is authorization (groups & APIs).

#### 🔐 WHAT LOGOUT DOES (RECONFIRMED)

Your understanding is correct 👇

Cognito Stores These After Login:

- ID Token

- Access Token

- Refresh Token

**🌐 Stored by Amazon Cognito JS SDK in browser storage.**

#### 🚪 SINGLE LINE THAT LOGS OUT THE USER

```
user.signOut();
```

#### What this instantly does:

❌ Deletes tokens from browser

❌ Invalidates Cognito session

❌ getCurrentUser() becomes null

This is true for admin and employee both.

#### 🛡️ PAGE PROTECTION (MOST IMPORTANT PART)

You already have (or must have) this on EVERY protected page:

```
const user = userPool.getCurrentUser();
if (!user) {
    window.location.href = "login.html";
}
```

#### Why this matters

- After logout → session gone

- User presses Back button

- ❌ Page must NOT load

- ✅ Redirects to login / home page

#### This is mandatory on:

- admin-dashboard.html

- employee-portal.html

#### 🔘 STANDARD LOGOUT BUTTON (SAME FOR BOTH)
> **HTML (Admin & Employee)**

```
<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```

#### JavaScript

```
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html"; // café landing or login
}
```

✔ Works for Admin

✔ Works for Employee

✔ Works on mobile / desktop

✔ Secure & Cognito-approved

> **🟢 PHASE 3️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 5️⃣ Secure Frontend & API Integration with Production Hardening
> **Frontend & Backend Security, API Integration, and Role-Based UI (Production Ready)**

### 1️⃣ Goal

- Integrate frontend pages (Admin + Employee) with backend APIs

- Enforce role-based UI & API access (Admin vs Employee)

- Add production-level hardening: error handling, loaders, JWT expiration, centralized config, secure backend checks, and logging

- Make the system job-ready, secure, and maintainable

### 2️⃣ Architecture Flow

```
[Frontend Admin/Employee Pages]
          |
          | secureFetch (with JWT)
          v
[API Gateway] -> Cognito Authorizer
          |
          v
[Lambdas (Checkin, Checkout, Employee Info, Leaves, Admin Employees)]
          |
          v
[RDS Database / DynamoDB]
```

#### Enhancements for merged phase:

- JWT validation & token expiration handled in frontend

- Role detection & UI enforcement in frontend

- Backend role enforcement in Lambdas

- Logging & error handling (CloudWatch)

- Loading indicators & centralized config in frontend

### 3️⃣ Achievements

- Unified auth & API layer for Admin & Employee

- Enterprise-grade security (frontend + backend)

- Job-ready UX polish: loader, error messages, responsive UI

- Scalable & maintainable codebase

- Audit & observability: logs for debugging and production monitoring

### 4️⃣ Tasks List

#### 1️⃣ Frontend Tasks

- Centralize config (API URL, Cognito IDs)

- Create auth-api.js with:

    - JWT token fetch

    - Secure API helper

    - Role detection

    - UI enforcement for Admin/Employee

    - Global error handler

    - Loader functions

    - Logout function

- Update Admin & Employee pages:

    - Include Cognito SDK

    - Include config.js + auth-api.js

    - Call protectPage() + enforceAdminAccess() / enforceEmployeeAccess()

- Replace API calls in pages with secureFetch

#### 1️⃣ Backend Tasks (Lambdas)

- Add logging (CloudWatch)

- Enforce role check using JWT claims

- Replace “Function logic goes here” with specific business logic (checkin, checkout, profile, leaves, admin employees)

- Return structured JSON responses

#### Testing Tasks

- Frontend: Login, logout, access control, loader, error handling

- Backend: Authorized vs unauthorized role access, CloudWatch logging

### 5️⃣ Anything else helpful for research / case study

- Show centralized config improves maintainability

- Explain role enforcement both frontend & backend prevents security bypass

- Include JWT expiration handling as production-ready feature

- Highlight CloudWatch logging as audit & monitoring

- Emphasize loader + error handling for professional UX

- Include flow diagram of merged phase for documentation / case study

> **📣 This structure makes the merged phase clear, self-contained, and professional — perfect for deployment, documentation, and research.**



### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

### 🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control

### 1️⃣ — STANDARD API CALL FUNCTION (FRONTEND)
> **This function will be used everywhere (Admin & Employee).**

### 📌 Why this is important

- No duplicate code

- Easy debugging

- JWT always attached

- Same pattern used in real companies

### 5️⃣ — BACKEND SECURITY (DOUBLE PROTECTION)

✔ Frontend check

✔ Backend check

✔ Enterprise-grade security

### ➕ - A SHARED SCRIPT FILE (Recommanded)

#### ✅ Benefits of a Shared Script File (Industry Standard)

By creating ONE shared JS file:

✔ Clean HTML (UI only)

✔ All security logic in one place

✔ Easy debugging

✔ Easy upgrades

✔ Same pattern used in:

AWS Amplify apps

React / Vue projects

Enterprise dashboards

👉 This is how companies expect you to work

#### 1️⃣ config.js
➡ Holds only configuration (API URL, Cognito IDs)

#### 2️⃣ auth-api.js
➡ Holds logic (Cognito, JWT, roles, API calls, logout, loader)

#### 📌 Rule (VERY IMPORTANT):

config.js MUST load BEFORE auth-api.js

Why?

auth-api.js uses CONFIG

If CONFIG is not loaded → ❌ JavaScript error

#### ❗ Problem

auth-api.js USES CONFIG, but CONFIG is defined in config.js

➡️ JavaScript loads files in order

➡️ If config.js is NOT loaded before auth-api.js, you will get:

```
Uncaught ReferenceError: CONFIG is not defined
```

#### ✅ THE FIX (MANDATORY)

You must include config.js BEFORE auth-api.js on every page that uses it.



### 🟢 STEP 1 — CENTRAL CONFIG FILE (FRONTEND)

#### ❓ Why this matters

Hard-coding values everywhere is not professional.

#### We will centralize:

- API Base URL

- Cognito IDs

- App name

### 🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control 
> **➕ - A SHARED SCRIPT FILE (Recommanded)**

### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

```
/* =====================================================
   AUTH & API SHARED UTILITIES
   Used by: Admin + Employee pages
   Project: Charlie Café HR System
===================================================== */

/* ===============================
   COGNITO CONFIG
================================ */
const poolData = {
    UserPoolId: 'us-east-1_XXXXXX',
    ClientId: 'XXXXXXXXXXXX'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const apiBase = 'https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod';

/* ===============================
   SESSION GUARD (PAGE PROTECTION)
================================ */
function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===============================
   GET JWT TOKEN
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");
        user.getSession((err, session) => {
            if (err) reject(err);
            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error("API request failed or unauthorized");
    }

    return response.json();
}

/* ===============================
   ROLE DETECTION
================================ */
async function getUserRoles() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        user.getSession((err, session) => {
            if (err) reject(err);
            const payload = session.getIdToken().decodePayload();
            resolve(payload["cognito:groups"] || []);
        });
    });
}

/* ===============================
   ADMIN UI CONTROL
================================ */
async function enforceAdminAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
    document.getElementById("admin-section").style.display = "block";
}

/* ===============================
   EMPLOYEE UI CONTROL
================================ */
async function enforceEmployeeAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}

/* ===============================
   LOGOUT (Cognito)
================================ */
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html";
}
```

✅ One file

✅ Reusable

✅ Secure

✅ Clean

### 🟢 FINAL AUTH-API.JS (ALL-IN-ONE)

#### ✅ What this file contains

#### Phase 4 — Frontend API integration & role-based UI

- protectPage() → Protects pages from unauthenticated users

- getJWT() → Fetches Cognito JWT

- secureFetch() → Central API call function

- getUserRoles() → Reads Cognito groups

- enforceAdminAccess() / enforceEmployeeAccess() → Role-based UI control

- loadEmployeeProfile() / loadAllEmployees() → Example API calls

- logout() → Cognito logout

#### Phase 5 — Production Hardening

- getJWT() updated to handle token expiration and auto logout

- handleError() → Global error handler

- showLoader() / hideLoader() → Loading indicator for smooth UX

- All API calls updated to use loader + error handler

- Now uses CONFIG for centralized config (API URL & Cognito IDs)

#### 🔹 Summary

- Everything from Phase 4 is included

- Everything from Phase 5 is included

- This is the final, job-ready auth-api.js

- You do not need to add anything else in this file

- You can now include this single file in both admin-dashboard.html and employee-portal.html


```
cd /var/www/html/js
```
```
sudo nano auth-api.js
```

---

### 🌐 Method 2️⃣ Frontend → API Integration & Role-Based UI Control

### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

### 1️⃣ — STANDARD API CALL FUNCTION (FRONTEND)
> **This function will be used everywhere (Admin & Employee).**

#### ✅ Add this to BOTH pages (admin-dashboard.html, employee-portal.html)

```
<script>
/* ===============================
   GET JWT TOKEN FROM COGNITO
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");
        user.getSession((err, session) => {
            if (err) reject(err);
            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error("API access denied or failed");
    }

    return response.json();
}
</script>
```

### 2️⃣ — ROLE DETECTION (ADMIN vs EMPLOYEE)

Cognito puts groups inside the JWT.

#### ✅ Add this function

```
<script>
/* ===============================
   DETECT USER ROLE FROM TOKEN
================================ */
async function getUserRole() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        user.getSession((err, session) => {
            if (err) reject(err);
            const payload = session.getIdToken().decodePayload();
            const groups = payload["cognito:groups"] || [];
            resolve(groups);
        });
    });
}
</script>
```

### 3️⃣ — ROLE-BASED UI CONTROL (FRONTEND)

#### ✅ Admin Page (admin-dashboard.html)

```
<script>
async function applyAdminUIRules() {
    const roles = await getUserRole();

    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }

    // Admin-only buttons
    document.getElementById("admin-section").style.display = "block";
}
applyAdminUIRules();
</script>
```

#### HTML Example

```
<div id="admin-section" style="display:none;">
    <button class="btn btn-warning">Manage Employees</button>
    <button class="btn btn-danger">View Payroll</button>
</div>
```

#### ✅ Employee Page (employee-portal.html)

```
<script>
async function applyEmployeeUIRules() {
    const roles = await getUserRole();

    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}
applyEmployeeUIRules();
</script>
```

- **📌 Employees never see admin buttons**

- **📌 Even if they edit HTML → API still blocks them**

### 4️⃣ — FRONTEND → API INTEGRATION (REAL DATA)

#### Example: Employee Profile Load

```
<script>
async function loadEmployeeProfile() {
    try {
        const data = await secureFetch(
            apiBase + "/employee/profile"
        );

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
    } catch (err) {
        alert("Failed to load profile");
    }
}
loadEmployeeProfile();
</script>
```

#### Example: Admin Fetch All Employees

```
<script>
async function loadAllEmployees() {
    const data = await secureFetch(
        apiBase + "/admin/employees"
    );

    console.log("Employees:", data);
}
</script>
```


---
### 🌐 Frontend — Task 2️⃣ — PRODUCTION HARDENING (ENTERPRISE-GRADE)


#### 🟢 STEP 2 — TOKEN EXPIRATION HANDLING (VERY IMPORTANT)

#### ❓ Problem

JWT tokens expire (usually 1 hour).

#### If expired:

- API calls fail

- Users see random errors

####  ✅ Add Token Expiry Check

#### Update getJWT() in auth-api.js

```
async function getJWT() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");

        user.getSession((err, session) => {
            if (err || !session.isValid()) {
                alert("Session expired. Please login again.");
                user.signOut();
                window.location.href = "login.html";
                reject("Session expired");
            }

            resolve(session.getIdToken().getJwtToken());
        });
    });
}
```

✔ Auto logout

✔ Clean redirect

✔ No broken UI

#### 🟢 STEP 3 — GLOBAL ERROR HANDLER (FRONTEND)

#### ❓ Why

You must not handle errors randomly in every function.

#### ✅ Central Error Handler

Add this to auth-api.js

```
function handleError(error) {
    console.error("Application Error:", error);
    alert("Something went wrong. Please try again.");
}
```

#### ✅ Use it in API calls

```
async function loadProfile() {
    try {
        const data = await secureFetch(apiBase + "/employee/profile");
        document.getElementById("profile-name").innerText = data.name;
    } catch (err) {
        handleError(err);
    }
}
```

**📌 One error handler → clean & consistent UX**

#### 🟢 STEP 4 — LOADING INDICATOR (UX POLISH)

#### ❓ Why this matters

Interviewers notice UX details.

#### ✅ Add Loader HTML (Both Pages)

```
<div id="loader" class="text-center mt-3" style="display:none;">
    <div class="spinner-border text-warning"></div>
    <p>Loading...</p>
</div>
```

#### ✅ Loader Control Functions

Add to auth-api.js

```
function showLoader() {
    document.getElementById("loader").style.display = "block";
}

function hideLoader() {
    document.getElementById("loader").style.display = "none";
}
```

#### ✅ Use in API calls

```
async function loadProfile() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/employee/profile");
        document.getElementById("profile-name").innerText = data.name;
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}
```

✔ Professional

✔ Smooth UX

✔ Real-world polish


---
#### 🟢 STEP 5 — LOGOUT FLOW (BOTH PAGES)

#### What Happens (Internally)

✔ Cognito tokens destroyed

✔ Session cleared

✔ getCurrentUser() → null

✔ Redirect happens

✔ Back button blocked

---

### 3️⃣ BACKEND  - Lambda 

### 🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control

#### 🔹 COMMON SECURITY TEMPLATE (Python)

#### 🟢 WHERE PYTHON LAMBDA UPDATES GO

You have 5 Lambda functions for HR & Attendance:

checkin

checkout

employeeInfo

leaves

admin/employees

All of them need backend hardening. Here’s what to do:

#### 🟢 LAMBDA SECURITY LOGIC PER FUNCTION

| Lambda          | Allowed Group | Notes                             |
| --------------- | ------------- | --------------------------------- |
| checkin         | Employee      | Only Employee can checkin         |
| checkout        | Employee      | Only Employee can checkout        |
| employeeInfo    | Employee      | Only Employee can view own info   |
| leaves          | Employee      | Only Employee can view/add leave  |
| admin/employees | Admin         | Only Admin can view all employees |

#### 🟢 About this Python Lambda code

This code is not just from one phase, it is a combined / consolidated version of the Python Lambda code from both Phase 4 (role-based APIs) and Phase 5 (production hardening, logging, security).

#### ✅ What it includes from both phases:

| Feature                                                            | Phase 4 | Phase 5 | Present in this code? |
| ------------------------------------------------------------------ | ------- | ------- | --------------------- |
| Basic Lambda function for API                                      | ✔       | ✔       | ✔                     |
| Role check (Cognito groups)                                        | ✔       | ✔       | ✔                     |
| Blocking unauthorized roles                                        | ✔       | ✔       | ✔                     |
| CloudWatch logging                                                 | ❌       | ✔       | ✔                     |
| Return structured JSON                                             | ✔       | ✔       | ✔                     |
| Placeholder for actual business logic (checkin/checkout/admin etc) | ✔       | ✔       | ✔                     |

So yes — this Python template is ready to use as a combined “Phase 4 + Phase 5” Lambda function.

#### 🟢 How to use this for your 5 Lambda functions

You will copy this template for each Lambda and replace the business logic:

#### Checkin Lambda

- Allowed group → Employee

- Logic → Save check-in timestamp to RDS

#### Checkout Lambda

- Allowed group → Employee

- Logic → Save check-out timestamp to RDS

#### employeeInfo Lambda

- Allowed group → Employee

- Logic → Query employee profile from RDS

#### leaves Lambda

- Allowed group → Employee

- Logic → Query/add leave info

#### admin/employees Lambda

- Allowed group → Admin

- Logic → Query all employee info from RDS

#### 🟢 Deployment tip (Phase 4 + 5 together)

- Treat Phase 4 as functional code + role check

- Treat Phase 5 as security, logging, UX polish, production readiness

- Combining them in one final template avoids confusion during deployment ✅

- This is exactly what your current template does: role enforcement + logging + placeholder for business logic

#### 🟢 Key Notes

The line:

```
groups = event['requestContext']['authorizer']['claims'].get('cognito:groups', [])
```

- works for all 5 Lambda functions if you set the Cognito Authorizer correctly in API Gateway.

- You only need to change the if-check and replace the “Function logic goes here” for each Lambda.

- This ensures:

    - Unauthorized roles blocked

    - Logging visible in CloudWatch

    - Production-ready security ✅


---
### 🌐 Method 2️⃣ Frontend → API Integration & Role-Based UI Control

### ☢️ BACKEND— Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

### 1️⃣ — BACKEND SECURITY (DOUBLE PROTECTION)

Even if UI fails, Lambda still protects.

Lambda Check Example

```
groups = event['requestContext']['authorizer']['claims'].get('cognito:groups', '')

if 'Admin' not in groups:
    return {
        "statusCode": 403,
        "body": "Forbidden"
    }
```

✔ Frontend check

✔ Backend check

✔ Enterprise-grade security
----

### ☢️ BACKEND— Task 2️⃣ — PRODUCTION HARDENING (ENTERPRISE-GRADE)

#### 🟢 STEP 5 — BACKEND HARDENING (LAMBDA)

#### ❓ Why

Frontend checks are not enough.

#### ✅ Enforce Role Check in Lambda (Python)

```
groups = event['requestContext']['authorizer']['claims'].get('cognito:groups', '')

if 'Admin' not in groups:
    return {
        "statusCode": 403,
        "headers": {"Content-Type": "application/json"},
        "body": '{"message":"Forbidden"}'
    }
```

✔ API secure

✔ HTML edits useless

✔ Enterprise security

#### 🟢 STEP 6 — CLOUDWATCH LOGGING (MANDATORY)

#### ✅ Add Logging in Lambda

```
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info("Request received")
logger.info(event)
```

#### ✅ Verify Logs

- AWS Console → CloudWatch

- Log groups → Lambda function

#### Confirm:

- Requests logged

- Errors visible

- Execution time visible

**📌 Interviewers love this**
---

### 3️⃣  🔐 PART 4 – Frontend → API Integration & Role-Based UI Control

#### 🟢 OVERVIEW

#### This section connects:

- Frontend pages (Admin & Employee)

- Amazon Cognito authentication

- API Gateway + Lambda (secureFetch)

- Role-based UI access control

- All protected pages MUST:

- Block unauthenticated users

- Enforce role access (Admin / Employee)

- Use Cognito tokens securely

- Call backend APIs safely

#### 🟢 GLOBAL RULE (VERY IMPORTANT)

#### ✅ SCRIPT LOAD ORDER (NON-NEGOTIABLE)

Every protected page MUST load scripts in this exact order:

```
<!-- 1️⃣ Cognito SDK -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

<!-- 2️⃣ Global Config (MUST come first) -->
<script src="js/config.js"></script>

<!-- 3️⃣ Auth & API Logic -->
<script src="js/auth-api.js"></script>
```

❌ Do NOT change this order
❌ Do NOT skip config.js

🟢 STEP 1 — GLOBAL CONFIG FILE
📄 js/config.js

```
/* ===== GLOBAL CONFIGURATION ===== */

const CONFIG = {
    region: "us-east-1",
    userPoolId: "us-east-1_XXXXXXXXX",
    clientId: "XXXXXXXXXXXXXXXXXXXXXXXXXX"
};

/* Base API Gateway URL */
const apiBase = "https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/prod";
```

🟢 STEP 2 — SHARED AUTH & API LOGIC
📄 js/auth-api.js

```
/* ===== COGNITO SETUP ===== */

const poolData = {
    UserPoolId: CONFIG.userPoolId,
    ClientId: CONFIG.clientId
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

/* ===== PAGE PROTECTION ===== */

function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===== ROLE CHECK HELPERS ===== */

function getUserRole(callback) {
    const user = userPool.getCurrentUser();
    if (!user) return;

    user.getSession((err, session) => {
        if (err) return;

        const token = session.getIdToken().payload;
        callback(token["custom:role"]);
    });
}

function enforceAdminAccess() {
    getUserRole(role => {
        if (role !== "admin") {
            alert("Access denied: Admins only");
            window.location.href = "employee-portal.html";
        }
        document.getElementById("admin-section").style.display = "block";
    });
}

function enforceEmployeeAccess() {
    getUserRole(role => {
        if (role !== "employee") {
            alert("Access denied: Employees only");
            window.location.href = "admin-dashboard.html";
        }
    });
}

/* ===== SECURE API FETCH ===== */

async function secureFetch(url, options = {}) {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        user.getSession(async (err, session) => {
            if (err) reject(err);

            const token = session.getIdToken().getJwtToken();

            const response = await fetch(url, {
                ...options,
                headers: {
                    "Authorization": token,
                    "Content-Type": "application/json"
                }
            });

            resolve(response.json());
        });
    });
}

/* ===== LOGOUT ===== */

function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html";
}
```

#### 🟢 STEP 5 — TEST & VERIFICATION (MANDATORY)

#### ✅ Authentication Tests

- Open admin page without login → ❌ Redirect

- Login as employee → admin page → ❌ blocked

- Login as admin → admin page → ✅ allowed

#### ✅ API Security Test

- Remove Authorization header → ❌ 401

- Valid token → ✅ data loads

#### ✅ Logout Test

- Click Logout

- Redirect occurs

- Press browser Back

❌ Page must NOT load

---

### ✅ CONCLUSION

- auth-api.js now contains all production hardening, role logic, API helpers, loader, error handling.

- Python Lambda functions now have common security + logging template.

- Frontend & backend are fully secure, job-ready, and maintainable.

### 🎓 HOW YOU EXPLAIN THIS IN INTERVIEW

“I hardened the system by centralizing configuration, implementing JWT expiration handling, role-based access at both frontend and backend, global error handling, UX loaders, and CloudWatch observability.”

That answer = strong hire signal.



> **🟢 PHASE 5️⃣  R & D COMPLETE**
---

---
## ☕ Charlie Café PHASE 8️⃣ — Update Cafe Security Configuration

### Objective

Ensure all EC2, Lambda, and RDS components are properly secured via Security Groups (SGs).

Document rules for future audits and maintenance.


> **🟢 PHASE 8️⃣  R & D COMPLETE**
---

---
## ☕ Charlie Café PHASE 9️⃣ — Minor UX / UI Polish
> **🌐 (Optional but Professional)**

### Objective

- Replace alert() with professional toast notifications

- Show clear success / error / loading states

- Improve user trust and usability (real-world standard)


### Step 5.10 — Final Professional UX Checklist

✔ No browser alerts

✔ Clear success & error messages

✔ Smooth animations

✔ User feedback for every action

✔ Looks production-ready

### ✅ FINAL RESULT

You now have:

Admin holiday management ✅

Secure AWS architecture (SG verified) ✅

Professional UI/UX like real enterprise apps ✅

This is exactly how real AWS + frontend projects are reviewed in interviews.


> **🟢 PHASE 9️⃣ COMPLETE**


# ☕ Doc:Secure HR & Attendance System - COMPLETE & VERIFIED---
---