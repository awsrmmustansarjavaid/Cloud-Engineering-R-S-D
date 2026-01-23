# ☕ AWS CAFE — CloudFront-EC2-API GATEWAY- ALB-DUAL ARchitecture


### 🎯 SECTION GOAL (READ FIRST)

You will run TWO architectures in parallel, both valid in real companies:

### 🔹 Architecture A (Traditional Web / Lift & Shift)

```
User
 ↓
CloudFront
 ↓
Application Load Balancer
 ↓
EC2 (Apache + PHP)
 ↓
API Gateway → Lambda → SQS → Worker → DB
```

### 🔹 Architecture B (Serverless API-First)

```
User
 ↓
CloudFront
 ↓
API Gateway
 ↓
Lambda → SQS → Worker → DB
```

✔ Same backend

✔ Same APIs

✔ Same order flow

✔ Different entry points

This teaches REAL AWS decision-making, not tutorials.


## 🌍 PHASE 1 — PART A — CloudFront + ALB + EC2

#### (Primary Website Architecture)

### 🔐 PREREQUISITES (DO NOT SKIP)

#### Confirm ALL of these exist:

| Resource              | Status         |
| --------------------- | -------------- |
| EC2 instance          | Running        |
| Apache installed      | ✅              |
| PHP installed         | ✅              |
| ALB created           | ✅              |
| Target group attached | ✅              |
| Domain optional       | ❌ not required |

### 🟩 STEP 1 — PREPARE EC2 APACHE APP

#### 1️⃣ SSH into EC2

```
ssh ec2-user@<EC2-PUBLIC-IP>
```

#### 2️⃣ Confirm Apache is running

```
sudo systemctl status httpd
```

#### If stopped:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### 3️⃣ Web root location

```
cd /var/www/html
```

#### Your files:

```
index.php
order.php
order-status.php
```

### 🟩 STEP 2 — CREATE APPLICATION LOAD BALANCER (ALB)

#### 1️⃣ Go to AWS Console → EC2 → Load Balancers

Click Create load balancer

#### 2️⃣ Select

```
Application Load Balancer
```

#### 3️⃣ Basic configuration

| Field           | Value           |
| --------------- | --------------- |
| Name            | cafe-alb        |
| Scheme          | Internet-facing |
| IP address type | IPv4            |

#### 4️⃣ Network mapping

- VPC → same as EC2

- Subnets → at least 2 public subnets

#### 5️⃣ Security Group

#### Inbound rules:

| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |


#### 6️⃣ Target Group

#### Create new target group:

| Field             | Value        |
| ----------------- | ------------ |
| Target type       | Instance     |
| Protocol          | HTTP         |
| Port              | 80           |
| Health check path | `/index.php` |

Register EC2 instance ✔

#### 7️⃣ Create ALB

#### Wait until:

```
State: Active
Health: Healthy
```

#### 📌 Copy:

```
ALB DNS name
```

### 🟩 STEP 3 — TEST ALB DIRECTLY

#### Open browser:

```
http://<ALB-DNS-NAME>
```

✔ Your café website must load

❌ If not → stop here and fix Apache/SG

---

## 🌍 PHASE 2 — PART B — CLOUDFRONT + ALB (EC2 WEBSITE)

### 🟦 STEP 4 — CREATE CLOUDFRONT DISTRIBUTION (FOR EC2)

### 1️⃣ AWS Console → CloudFront → Create distribution

### 2️⃣ ORIGIN SETTINGS

| Field         | Value            |
| ------------- | ---------------- |
| Origin domain | **ALB DNS NAME** |
| Origin type   | Custom           |
| Protocol      | HTTP only        |

### 3️⃣ DEFAULT CACHE BEHAVIOR

| Field                 | Value                    |
| --------------------- | ------------------------ |
| Viewer protocol       | Redirect HTTP to HTTPS   |
| Allowed methods       | GET, HEAD                |
| Cache policy          | Managed-CachingOptimized |
| Origin request policy | Managed-AllViewer        |


### 4️⃣ Create Distribution

⏳ Wait 10–15 minutes

#### Copy:

```
CloudFront Domain Name
```

### 🟦 STEP 5 — TEST EC2 VIA CLOUDFRONT

#### Open:

```
https://<cloudfront-domain>
```

✔ Page loads

✔ HTTPS enabled

✔ Cached globally

---

## 🌍 PHASE 3 — CLOUDFRONT + API GATEWAY (SERVERLESS API)

### 🟨 STEP 6 — CREATE SECOND CLOUDFRONT ORIGIN (API)

#### Edit existing CloudFront distribution

OR create new one (recommended for learning)

#### Origin configuration

| Field         | Value                                      |
| ------------- | ------------------------------------------ |
| Origin domain | `xxxx.execute-api.us-east-1.amazonaws.com` |
| Origin type   | Custom                                     |
| Protocol      | HTTPS only                                 |

#### Cache behavior (API)

#### Path pattern:

```
/dev/*
```

| Field                 | Value                   |
| --------------------- | ----------------------- |
| Allowed methods       | GET, POST, OPTIONS      |
| Cache policy          | Managed-CachingDisabled |
| Origin request policy | Managed-AllViewer       |
| Viewer protocol       | HTTPS only              |

✔ This ensures POST orders are NOT cached

### 🟨 STEP 7 — DEPLOY CLOUDFRONT CHANGES

#### Wait until:

```
Status: Deployed
```

---

## 🌍 PHASE 4 — UPDATE EC2 WEBSITE TO USE CLOUDFRONT API

### Edit order.php

#### ❌ OLD:

```
$apiUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/orders";
```

#### ✅ NEW:

```
$apiUrl = "https://<cloudfront-api-domain>/dev/orders";
```

#### Restart Apache:

```
sudo systemctl restart httpd
```

---

## 🌍 PHASE 5 — OPTIONAL API CACHING (GET ONLY)

### Example: /menu

### Create cache behavior:

```
/dev/menu
```

| Setting      | Value                    |
| ------------ | ------------------------ |
| Cache policy | Managed-CachingOptimized |
| TTL          | Default                  |

#### ⚠️ NEVER cache:

- POST

- PUT

- ORDER APIs

### 🧪 FINAL TESTING (MANDATORY)

#### ✅ Test 1 — Website

```
https://<cloudfront-ec2-domain>
```

#### ✅ Test 2 — Order Placement

Submit order → success message

#### ✅ Test 3 — Track Order

```
order-status.php?order_id=ORD-XXXX
```

#### ✅ Test 4 — Backend

- SQS message consumed

- Worker Lambda logs OK

- DB updated

### 🧠 WHY COMPANIES USE BOTH

| Use Case       | Architecture             |
| -------------- | ------------------------ |
| Legacy PHP     | CloudFront + ALB + EC2   |
| Mobile APIs    | CloudFront + API Gateway |
| High traffic   | CloudFront               |
| Cost optimized | API Gateway              |
| Complex logic  | EC2                      |

You now understand enterprise AWS, not tutorials.

---

