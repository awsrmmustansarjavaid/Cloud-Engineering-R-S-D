

## 📢 SECTION 3 — AWS Cafe PRODUCTION

## PHASE 1 — PRODUCTION (us‑west‑2)

## Create AMI

* Name: `CafeDevWebAMI`

## Launch Prod EC2

* Region: us‑west‑2
* From AMI
* New VPC/Subnet

---

## 📢 SECTION 13 — BILLING ALERTS & BUDGETS

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

## 📢 SECTION 14 — TESTING

## API Test
curl -X POST <api-url> -d '{"customer_name":"CI","item":"Coffee","quantity":1}'

## Verify
- SQS: messages consumed
- Lambda logs clean
- RDS rows inserted
- DynamoDB updated

## Cognito Test
- Sign up user
- Login → copy JWT token

## API Test with Token

```
curl -X POST <cloudfront-url>/dev/orders  -H "Authorization: Bearer <JWT>"  -H "Content-Type: application/json"  -d '{"customer_name":"AuthUser","item":"Coffee","quantity":1}'
```

Expected: 200 OK

---

## AWS Cafe Common Issues & Troubleshooting

[AWS Cafe Common Issues & Troubleshooting](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20Cafe%20Common%20Issues%20%26%20Troubleshooting.md)

---

# 🏁 FINAL RESULT

You now have a **real AWS production architecture** with:

✔ Secure credentials

✔ Automation

✔ Multi‑region deployment

✔ Exam‑ready design

✔ Authenticated users only  

✔ Cached & accelerated API 

✔ Protected costs  

✔ Billing alerts active 