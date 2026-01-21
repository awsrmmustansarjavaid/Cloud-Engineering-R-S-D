# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 6 — AWS CAFE SECURITY

## 🔒 PHASE 1 — AWS WAF (Security)

### Purpose: 

Protect your API Gateway from common attacks (SQL Injection, XSS, rate-limiting) and secure your serverless cafe orders API.

## 1️⃣ — Create WAF Protection Pack (Web ACL) for CafeOrderAPI

**Open the AWS Console → WAF & Shield → Web ACLs → Create Web ACL**

### 1️⃣ — “Tell us about your app”

- **App category:** Click the dropdown and select the most relevant category.

  - For your cafe order API, choose “Business Application” or something closest if available.

- **App focus:** Since your API is primarily for API Gateway requests:

  - Select Both API and web (recommended if you may later expose a website)

- Or select API if it’s purely API requests.

✅ This step tells AWS WAF what kind of attacks to prioritize.

### 2️⃣ — “Select resources to protect”

- Click Select resources to protect

- **Choose your API Gateway resource:** CafeOrderAPI

- Add the stage you want to protect (like prod or test)

- Click Add

✅ This associates your WAF with your API so the rules can start protecting it.

### 3️⃣ — “Choose initial protections”

- AWS will suggest protection rules based on your app category.

**You can either:**

  - Use the recommended protection package (simpler, automatic rules for SQLi, XSS, etc.)

  - Or select individual rules if you want more granular control:

    - AWSManagedRulesCommonRuleSet → common attacks

    - AWSManagedRulesSQLiRuleSet → SQL Injection attacks

- Optionally, add a rate-based rule:

  - Example: Limit to 1000 requests per 5 minutes per IP

✅ These rules are your main defense for API attacks.

### 4️⃣ — “Name and describe”

- Enter a name: CafeWebACL

- Optional description: "Protects CafeOrderAPI from common attacks, SQLi, XSS, and rate limiting"

### 5️⃣ — “Customize protection pack (optional)”

- This is optional.

- You can enable logging to CloudWatch here:

  - Turn on logging

  - Select or create a CloudWatch log group (e.g., /aws/waf/CafeWebACL)

- Leave other settings default for now.

✅ Logging is very useful to monitor attacks and blocked requests.

### 6️⃣ — Create protection pack

- Click Create protection pack (web ACL)

- AWS will provision the Web ACL, attach the rules, and associate it with your API Gateway.

✅ Once created, your API is protected, and WAF will start enforcing rules.

### 7️⃣ — Verification

- Normal API request: Should pass normally (HTTP 200)

- SQL injection attempt: Should be blocked (HTTP 403)

- Rate limit test: Exceed 1000 requests in 5 minutes → requests blocked

- CloudWatch logs: Check /aws/waf/CafeWebACL → confirm logs for blocked requests

### 💡 Tip: Protection packs are automated and recommended for beginners. If you want more granular control, you can manually create a Web ACL as in the previous step-by-step guide.

## 🚫 Important Reality Check — AWS WAF & Free Tier

### ❌ Why you should NOT proceed with WAF now

#### AWS WAF charges:

- Per Web ACL

- Per rule

- Per request

Even with zero traffic, just attaching WAF to API Gateway costs money.

#### ➡️ Conclusion:

- Skip PHASE 11 in hands-on execution
- Document it as a design / future enhancement only

This is how real AWS architects work on Free Tier.

## ✅ What You Should Do Instead (FREE & SAFE)

**We will REPLACE PHASE 11 execution with:**

## 🟢 PHASE 11 — SECURITY (FREE TIER SAFE VERSION)

### ✅ 1️⃣ API Gateway Security (FREE)

#### Already supported:

- IAM authorization

- Request validation

- Throttling

- Usage plans

- CORS control

### ✅ 2️⃣ Lambda-Level Input Validation (FREE)

Block SQLi/XSS inside Lambda
(No cost, no WAF)

### ✅ 3️⃣ CloudWatch Monitoring & Alarms (FREE tier limits)

### 🔐 FREE SECURITY CONTROLS YOU ALREADY HAVE

| Security Layer              | Status      | Cost               |
| --------------------------- | ----------- | ------------------ |
| IAM roles & least privilege | ✅ Done      | Free               |
| Secrets Manager             | ✅ Done      | Free (small usage) |
| API Gateway throttling      | ✅ Available | Free               |
| Lambda input validation     | ✅ Do this   | Free               |
| CloudWatch logs             | ✅ Done      | Free tier          |
| AWS WAF                     | ❌ SKIP      | Paid               |

---

# 🛡️ PHASE 2 — SECURITY WITHOUT WAF (RECOMMANDED)

Lambda Input Validation + API Gateway Throttling

This REPLACES AWS WAF safely.

## 🔐 PART A — Lambda Input Validation (MANDATORY)

### 🎯 Goal

Block bad / malicious requests BEFORE:

- SQS

- RDS

- DynamoDB

### ✅ STEP A1 — Open Correct Lambda Function

### ⚠️ IMPORTANT (No confusion here)

You must edit ONLY THIS FUNCTION:

✅ CafeOrderApiLambda

❌ NOT the Worker Lambda

❌ NOT the Secrets Lambda

#### Console Steps

- AWS Console → Lambda

- Click CafeOrderApiLambda

- Click Code tab

- Scroll to lambda_handler

### ✅ STEP A2 — Add Validation Function (COPY EXACT)

**📌 Paste this ABOVE lambda_handler**

```
def validate_order(order):
    if "item" not in order or "quantity" not in order:
        raise ValueError("Missing required fields")

    if not isinstance(order["quantity"], int) or order["quantity"] <= 0:
        raise ValueError("Invalid quantity")

    if len(order.get("customer_name", "")) > 50:
        raise ValueError("Invalid customer name")
```

### ✅ STEP A3 — Call Validation Inside lambda_handler

**Find this line:**

```
body = json.loads(event["body"])
```

#### 🔁 Replace with THIS BLOCK

```
order = json.loads(event["body"])
validate_order(order)
```

### ✅ STEP A4 — Full SAFE CafeOrderApiLambda Example

#### Use this REFERENCE VERSION (you can compare):

```
import json
import boto3
import os

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["SQS_QUEUE_URL"]

def validate_order(order):
    if "item" not in order or "quantity" not in order:
        raise ValueError("Missing required fields")

    if not isinstance(order["quantity"], int) or order["quantity"] <= 0:
        raise ValueError("Invalid quantity")

    if len(order.get("customer_name", "")) > 50:
        raise ValueError("Invalid customer name")

def lambda_handler(event, context):
    try:
        order = json.loads(event["body"])
        validate_order(order)

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Order accepted"})
        }

    except ValueError as ve:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(ve)})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Internal server error"})
        }
```

### ✅ STEP A5 — Deploy Lambda

- Click Deploy

Wait for green success bar

## 🧪 PART B — VERIFY LAMBDA INPUT VALIDATION (MANDATORY)

### ✅ TEST 1 — Valid Request (SHOULD PASS)

- API Gateway Console

- API Gateway → CafeOrderAPI

- Resources → /orders

- Method → POST

- Click Test

#### Request Body

```
{
  "customer_name": "Charlie",
  "item": "Tea",
  "quantity": 2
}
```

#### ✅ Expected Result

- Status: 202

- Message: "Order accepted"

- SQS receives message

- Worker Lambda processes order

### ❌ TEST 2 — Invalid Quantity (SHOULD FAIL)

#### Request Body

```
{
  "item": "Tea",
  "quantity": -5
}
```

#### ❌ Expected Result

- Status: 400

#### Response:

```
{"error": "Invalid quantity"}
```

✔️ Nothing sent to SQS

✔️ Nothing inserted in RDS

✔️ Nothing updated in DynamoDB

### ❌ TEST 3 — Missing Field

```
{
  "quantity": 1
}
```

#### ❌ Expected

```
{"error": "Missing required fields"}
```

### ❌ TEST 4 — Abuse Attempt

```
{
  "customer_name": "A" * 200,
  "item": "Tea",
  "quantity": 1
}
```

#### ❌ Expected

```
{"error": "Invalid customer name"}
```

## 🚦 PART C — API GATEWAY THROTTLING (FREE & REQUIRED)

### ✅ STEP C1 — Open API Stage

- AWS Console → API Gateway

- Click CafeOrderAPI

- Click Stages

- Click prod

### ✅ STEP C2 — Enable Throttling

Scroll to Default Method Throttling

- Set:

  - Rate: 10

  - Burst: 20

Click Save

### 🧪 STEP C3 — Verify Throttling
Test Rapid Requests

Send 20+ requests quickly (Postman / Test button)

#### Expected:

- First requests succeed

- Later requests fail with:

```
429 Too Many Requests
```

✔️ DoS protection working

✔️ Free Tier safe