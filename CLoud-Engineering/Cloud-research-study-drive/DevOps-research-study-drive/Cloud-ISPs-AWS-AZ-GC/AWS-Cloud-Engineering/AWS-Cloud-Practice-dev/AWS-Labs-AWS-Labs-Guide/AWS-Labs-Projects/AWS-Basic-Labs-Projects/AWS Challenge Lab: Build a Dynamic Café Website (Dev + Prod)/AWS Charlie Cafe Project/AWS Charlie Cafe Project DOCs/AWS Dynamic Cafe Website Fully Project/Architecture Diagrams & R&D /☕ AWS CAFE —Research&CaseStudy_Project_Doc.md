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

