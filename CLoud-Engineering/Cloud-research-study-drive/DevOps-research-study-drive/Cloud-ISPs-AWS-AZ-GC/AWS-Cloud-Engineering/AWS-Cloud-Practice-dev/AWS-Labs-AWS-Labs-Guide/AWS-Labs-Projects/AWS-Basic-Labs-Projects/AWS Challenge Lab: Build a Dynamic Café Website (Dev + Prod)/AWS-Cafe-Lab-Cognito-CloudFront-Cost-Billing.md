
# ☕ AWS Café Lab — Advanced Upgrade Guide
## Cognito Authentication • CloudFront + Caching • Cost Optimization • Billing Alarms

**👨‍🏫 Author & Architecture Designer:** Charlie

**Level:** Intermediate → Advanced (Real Production)

---

## 🎯 Objective

Secure, accelerate, and control costs for the AWS Café system by adding:

- ✅ Amazon Cognito (authentication & authorization)
- ✅ Amazon CloudFront (CDN + caching)
- ✅ Cost optimization best practices
- ✅ AWS Budgets & Billing Alarms
- ✅ Automate deployments using **CI/CD (CodePipeline + CodeBuild)**


This guide is **AWS Console first**, **zero skipped steps**, and **GitHub-ready**.

---

## 🧱 Target Architecture (Upgraded)

Browser
→ CloudFront
→ WAF
→ API Gateway
→ Lambda (API)
→ SQS (Orders Queue)
→ Lambda (Worker)
→ RDS (Orders - source of truth)
→ DynamoDB (Menu / Recent Orders cache)

EC2 (Web UI) → API Gateway (no direct DB access)

---

## AWS Architecture Diagram 

![AWS Architecture Diagram](./AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Café%20Website%20(Dev%20%2B%20Prod)/AWS-Cafe-Lab-Cognito-CloudFront-Cost-Billing.jpeg)

---


# PHASE 1 — AMAZON COGNITO (AUTHENTICATION)

## 1️⃣ Create Cognito User Pool

AWS Console → Search **Cognito** → User Pools → **Create user pool**

### Step 1: Configure sign-in
- Sign-in options: **Email**
- User name: Email
Click **Next**

### Step 2: Security requirements
- Password policy: Default
- MFA: Optional (recommended later)
Click **Next**

### Step 3: Sign-up experience
- Enable self sign-up: ✅ Enabled
- Required attributes: Email
Click **Next**

### Step 4: Email configuration
- Email provider: Cognito default
Click **Next**

### Step 5: App integration
- User pool name: `CafeUserPool`
- Hosted authentication pages: ❌ Disable
Click **Next**

### Step 6: Review
Click **Create user pool**

✅ User Pool created

---

## 2️⃣ Create App Client

Inside User Pool → **App integration** → App clients → **Create app client**

- App client name: `CafeWebClient`
- Generate client secret: ❌ No (required for browser apps)
- Authentication flows:
  - ALLOW_USER_PASSWORD_AUTH
  - ALLOW_REFRESH_TOKEN_AUTH

Click **Create app client**

Save:
- User Pool ID
- App Client ID

---

## 3️⃣ Create Cognito Domain

User Pool → App integration → Domain
- Domain type: Cognito domain
- Domain prefix: `cafe-auth-<unique>`

Save

---

## 4️⃣ Integrate Cognito with API Gateway

API Gateway → CafeOrderAPI

### Step 1: Create Authorizer
- Authorizers → Create
- Type: Cognito
- Name: CafeCognitoAuthorizer
- User pool: CafeUserPool
- Token source: Authorization

Create

### Step 2: Attach Authorizer
Resources → /orders → POST
- Authorization: CafeCognitoAuthorizer
Save

### Step 3: Redeploy API
Actions → Deploy API → Stage: dev

---

# PHASE 2 — CLOUDFRONT + CACHING

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

# PHASE 3 — COST OPTIMIZATION

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

# PHASE 4 — BILLING ALERTS & BUDGETS

## 1️⃣ Enable Billing Alerts

AWS Console → Billing → Billing preferences
- Receive billing alerts: ✅ Enable

Save

---

## 2️⃣ Create Budget

Billing → Budgets → Create budget

### Budget details
- Type: Cost budget
- Amount: $5
- Period: Monthly

### Alerts
- Alert at 80%
- Alert at 100%
- Email: your email

Create budget

---

## 3️⃣ CloudWatch Billing Alarm

CloudWatch → Alarms → Create alarm
- Metric: Billing → EstimatedCharges
- Threshold: $5
- SNS Topic: Create new → Email

Create alarm

---

# PHASE 5 — TESTING

## Cognito Test
- Sign up user
- Login → copy JWT token

## API Test with Token

```
curl -X POST <cloudfront-url>/dev/orders  -H "Authorization: Bearer <JWT>"  -H "Content-Type: application/json"  -d '{"customer_name":"AuthUser","item":"Coffee","quantity":1}'
```

Expected: 200 OK

---

# 🏁 FINAL RESULT

✔ Authenticated users only  
✔ Cached & accelerated API  
✔ Protected costs  
✔ Billing alerts active  

---

## 🚀 Next Steps
- Cognito + IAM fine-grained roles
- CloudFront + WAF
- Savings Plans
- Multi-account billing

