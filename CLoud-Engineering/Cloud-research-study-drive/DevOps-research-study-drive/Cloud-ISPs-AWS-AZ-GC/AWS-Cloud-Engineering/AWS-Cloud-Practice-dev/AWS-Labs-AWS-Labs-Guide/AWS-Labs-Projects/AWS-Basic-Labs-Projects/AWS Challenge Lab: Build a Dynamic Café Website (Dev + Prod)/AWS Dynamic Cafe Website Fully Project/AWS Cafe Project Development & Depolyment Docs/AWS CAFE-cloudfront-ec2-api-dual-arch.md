# ☕ AWS CAFE — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)


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


## 🌍 PHASE 1 — CloudFront + ALB + EC2 (Replacing API Gateway)

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

## 🌍 PHASE 2 — CLOUDFRONT + CACHING

## 1️⃣ Create CloudFront Distribution

AWS Console → CloudFront → Create distribution

### Origin
- Origin domain: API Gateway invoke URL (without https://)
- Origin type: Custom

### Default cache behavior
- Viewer protocol policy: Redirect HTTP to HTTPS
- Allowed HTTP methods: GET, HEAD, OPTIONS, POST
- Cache policy: Managed-CachingDisabled (for POST APIs)
- Origin request policy: Managed-AllViewer

Create distribution ⏳

Copy:
- CloudFront domain name

---

## 2️⃣ Update EC2 Web App

Replace API URL in `index.php`:

```php
$apiUrl = "https://<cloudfront-domain>/dev/orders";
```

Restart Apache:

```
sudo systemctl restart httpd
```

---

## 3️⃣ Optional: Cache Menu (GET)

For GET /menu:
- Cache policy: Managed-CachingOptimized
- TTL: Default

---

# 📢 SECTION 11 — COST OPTIMIZATION

## 1️⃣ EC2 Cost Optimization
- Instance type: t3.micro
- Enable EC2 auto-stop (Lambda scheduler)
- Delete unused AMIs & snapshots

## 2️⃣ RDS Cost Optimization
- Use db.t3.micro
- Disable Multi-AZ (Dev)
- Set backup retention: 1 day

## 3️⃣ Lambda Optimization
- Reduce timeout to 5 seconds
- Right-size memory
- Enable log retention (7 days)

## 4️⃣ DynamoDB Optimization
- On-demand capacity
- Enable TTL for cache tables

## 5️⃣ S3 Optimization
- Block public access
- Enable lifecycle rules (delete after 30 days)

---