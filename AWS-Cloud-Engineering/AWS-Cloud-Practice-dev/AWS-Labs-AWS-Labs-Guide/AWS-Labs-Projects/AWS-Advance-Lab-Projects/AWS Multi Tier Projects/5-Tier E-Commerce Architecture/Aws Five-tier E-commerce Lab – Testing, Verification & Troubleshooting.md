# ✅ AWS Five-Tier E-Commerce Lab

## 🧪 Testing, Verification & Troublesbleshooting Guide

> **Author & Architecture Designer:** Charlie
---

## 📌 PURPOSE OF THIS DOCUMENT

This guide helps you:

* ✅ Verify each AWS tier is working correctly
* 🧪 Test frontend, APIs, databases, authentication, and security
* 🐞 Identify common bugs
* 🛠️ Apply clear solutions
* 📸 Collect proof for GitHub & LinkedIn

---

# 🧱 TIER-WISE TEST & VERIFICATION

---

## 🧩 TIER 1: NETWORK TIER TESTING

### 1️⃣ VPC & Subnets Verification

**Test**

* Go to **VPC → Subnets**
* Verify route tables

**Expected Result**

**Public Route Table**

```
0.0.0.0/0 → Internet Gateway
```

**Private Route Table**

```
0.0.0.0/0 → NAT Gateway
```

**Common Bug**

❌ EC2 in private subnet cannot access internet

**Solution**

✔ NAT Gateway exists
✔ Private subnet route table points to NAT

---

### 2️⃣ Security Group Validation

**Test**

* ALB SG allows:

  * HTTP (80)
  * HTTPS (443)
* App SG allows:

  * HTTP (80) **from ALB SG only**

**Common Bug**

❌ App API unreachable

**Solution**

✔ Allow inbound from ALB SG only
✔ Do NOT allow 0.0.0.0/0 on App SG

---

## 🌐 TIER 2: WEB TIER TESTING

### 3️⃣ S3 Static Site Test

**Test**

* Open S3 bucket
* Click `index.html`

**Expected Result**

✔ HTML loads successfully

**Common Bug**

❌ Access Denied

**Solution**

✔ Disable Block Public Access
✔ Attach correct bucket policy
✔ CloudFront origin access configured

---

### 4️⃣ CloudFront Distribution Test

**Test**

* Copy CloudFront domain name
* Open in browser

**Expected Result**

✔ Website loads via HTTPS

**Common Bug**

❌ 403 Forbidden

**Solution**

✔ S3 permissions correct
✔ Default root object set to `index.html`

---

### 5️⃣ Route 53 DNS Test

**Test**

```
nslookup yourdomain.com
```

**Expected Result**

✔ Domain resolves to CloudFront

---

## 🧠 TIER 3: APPLICATION TIER TESTING

### 6️⃣ ALB Health Check Test

**Test**

* EC2 → Target Groups → Targets

**Expected Result**

✔ Target status = Healthy

**Common Bug**

❌ Unhealthy targets

**Solution**

✔ `/health` endpoint exists
✔ App listens on port 80
✔ Security groups allow traffic

---

### 7️⃣ EC2 App Local Test

**Test (SSH or SSM)**

```bash
curl http://localhost/health
```

**Expected Result**

```
OK
```

---

### 8️⃣ API Gateway Test

**Test**

* API Gateway → Stages → Invoke URL

```bash
curl https://api-id.execute-api.region.amazonaws.com/products
```

**Expected Result**

✔ JSON response

**Common Bug**

❌ 502 Bad Gateway

**Solution**

✔ ALB integration correct
✔ Target group healthy
✔ IAM permissions valid

---

## 🗄️ TIER 4: DATABASE TIER TESTING

### 9️⃣ DynamoDB Test

**Insert Test Item**

```json
{
  "product_id": "p1001",
  "name": "Laptop",
  "price": 500
}
```

**API Test**

```bash
curl https://api-url/products
```

**Expected Result**

✔ Product appears on website

---

### 🔟 RDS MySQL Test

**Connect from EC2**

```bash
mysql -h <rds-endpoint> -u admin -p
```

**Test Query**

```sql
SHOW DATABASES;
```

**Common Bug**

❌ Connection timeout

**Solution**

✔ DB in private subnet
✔ App SG allowed in DB SG

---

### 1️⃣1️⃣ Secrets Manager Test

**Test**

* Secrets Manager → Retrieve secret

**Expected Result**

✔ Username & password exist

**App Validation**

✔ App fetches secret dynamically
✔ No hardcoded credentials

---

### 1️⃣2️⃣ EFS Test

**Test**

```bash
df -h | grep efs
```

**Expected Result**

✔ EFS mounted

**Common Bug**

❌ Permission denied

**Solution**

✔ Security group allows NFS (2049)
✔ Mount target in correct subnet

---

## 🔐 TIER 5: SECURITY & AUTOMATION TESTING

### 1️⃣3️⃣ Cognito Authentication Test

**Test**

* Sign up user in Cognito
* Login and obtain JWT token

```bash
curl -H "Authorization: Bearer <TOKEN>" https://api-url/products
```

**Expected Result**

✔ Authorized request

---

### 1️⃣4️⃣ AWS WAF Test

**Test**

```text
?search=<script>alert(1)</script>
```

**Expected Result**

✔ Request blocked

---

### 1️⃣5️⃣ CloudWatch Logs Test

**Check Logs**

* EC2 application logs
* ALB access logs
* API Gateway execution logs

**Expected Result**

✔ Logs visible

---

## 🐞 MOST COMMON LAB ISSUES & FIXES

| Issue             | Cause         | Fix                 |
| ----------------- | ------------- | ------------------- |
| 403 CloudFront    | S3 permission | Fix bucket policy   |
| 502 API Gateway   | ALB unhealthy | Fix health check    |
| DB timeout        | SG misconfig  | Allow App SG        |
| EFS mount fail    | NFS blocked   | Open port 2049      |
| Cognito auth fail | Token missing | Add Authorizer      |
| No logs           | IAM missing   | Add CloudWatch role |

---

## 🧪 FINAL END-TO-END TEST

**Browser Test**

* Open website URL
* Products load
* API responds
* DynamoDB data visible
* HTTPS enabled
* WAF active

✔ **SUCCESS = LAB COMPLETE**

---

## 📸 WHAT TO CAPTURE FOR GITHUB & LINKEDIN

* CloudFront working site
* API Gateway logs
* DynamoDB table
* RDS instance
* ALB healthy targets
* CloudWatch dashboard

---

## 🎉 CONGRATULATIONS

You now have:

✔ Tested
✔ Verified
✔ Debugged
✔ Documented
✔ Production-style AWS lab

🚀 **This is perfect for your first AWS e-commerce project.**
