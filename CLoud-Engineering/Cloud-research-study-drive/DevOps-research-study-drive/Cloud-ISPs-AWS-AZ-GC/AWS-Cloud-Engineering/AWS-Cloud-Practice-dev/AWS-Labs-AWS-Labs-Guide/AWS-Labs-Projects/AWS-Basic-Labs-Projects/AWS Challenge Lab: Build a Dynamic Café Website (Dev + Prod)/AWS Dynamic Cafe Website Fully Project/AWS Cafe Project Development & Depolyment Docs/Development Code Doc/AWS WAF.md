# 🔒 PHASE 11 — AWS WAF (Security)

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