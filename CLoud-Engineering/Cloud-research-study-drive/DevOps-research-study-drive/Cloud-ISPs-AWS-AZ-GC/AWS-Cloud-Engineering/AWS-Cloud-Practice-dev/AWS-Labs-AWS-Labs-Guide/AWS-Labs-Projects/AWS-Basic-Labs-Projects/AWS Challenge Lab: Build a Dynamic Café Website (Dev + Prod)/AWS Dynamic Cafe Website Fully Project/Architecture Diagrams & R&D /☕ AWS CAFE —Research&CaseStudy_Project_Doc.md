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


# ☕ Doc:SALES ANALYTICS & REPORTING SYSTEM - COMPLETE & VERIFIED

---

