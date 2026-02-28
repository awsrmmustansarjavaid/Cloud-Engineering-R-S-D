# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

## ☕ AWS Charlie Café – Test & Verifications


# ☕ Charlie Café SECTION 2️⃣ - Attendance System

## ☕ Charlie Café PHASE 1️⃣ — Database Layer (RDS) Configuration

### 1️⃣ Verify Cafe_DB Tables

```
SHOW TABLES;
```

#### Expected output:

```
employees
attendance
leaves
holidays
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)




**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 3️⃣ — API Gateway Setup for HR Secure Attendance System

> **Test Each API Endpoint**
> **We will test using Postman or Lambda Test Console.**

### 1️⃣ Testing on API Gateway Console

- Go to API Gateway → Your API → Resources.

- Click the method you want to test (e.g., POST /checkin).

- Click Test.

- Select the stage: prod

- Click Test → see response code (200, 400, 403, 500) and body.

### 1️⃣ Test /attendance

- Enter the JSON body exactly as your Lambda expects. For your attendance Lambda, the body may be empty, but you still need proper JSON:

#### Request body:

```
{
  "employee_id": "EMP001",
  "action": "checkin"
}
```

Click Test 

#### Expected result:

```
Status: 200
{
  "message": "Check-in successful"
}
```

#### Now test checkout:

```
{
  "employee_id": "EMP001",
  "action": "checkout"
}
```

#### Expected result:

```
Status: 200
{
  "message": "Check-out successful"
}
```

→ You should see "Check-out successful".

### 2️⃣ Test /employee-profile

```
{
  "employee_id": "EMP001"
}
```

#### Expected:

```
Status: 200
{
  "employee_id": "EMP001",
  "name": "...",
  "job_title": "...",
  "salary": ...,
  "start_date": "2023-01-01"
}
```

#### If employee does not exist:

```
Status: 404
{
  "message": "Employee not found"
}
```

### 3️⃣ Test /attendance-history

```
{
  "employee_id": "EMP001"
}
```

#### Expected:

```
Status: 200
[
  {
    "attendance_date": "2024-02-10",
    "checkin_time": "09:00:00",
    "checkout_time": "17:00:00"
  }
]
```

### 4️⃣ Test /leaves-holidays

```
{
  "employee_id": "EMP001"
}
```

#### Expected:

```
Status: 200
{
  "leaves": [...],
  "holidays": [...]
}
```

#### ✅ API Gateway console is the fastest for functional verification.

### 2️⃣ Testing from EC2 CLI using curl

Important: Your endpoints are protected with Cognito Authorizer, so Authorization header is required.

### 1️⃣ Test Attendance

#### 1️⃣ Check-in:

```
curl -X POST $API_URL/attendance \
-H "Content-Type: application/json" \
-d '{"employee_id":"EMP001","action":"checkin"}'
```

#### Expected:

```
{"message":"Check-in successful"}
```

#### 2️⃣ Checkout:

```
curl -X POST $API_URL/attendance \
-H "Content-Type: application/json" \
-d '{"employee_id":"EMP001","action":"checkout"}'
```

#### Expected:

```
{"message":"Check-out successful"}
```

### 2️⃣ Test Employee Profile

```
curl -X POST $API_URL/employee-profile \
-H "Content-Type: application/json" \
-d '{"employee_id":"EMP001"}'
```

#### Expected:

JSON employee data.

### 3️⃣ Test Attendance History

```
curl -X POST $API_URL/attendance-history \
-H "Content-Type: application/json" \
-d '{"employee_id":"EMP001"}'
```

#### Expected:

JSON array of attendance records.

### 4️⃣ Test Leaves & Holidays

```
curl -X POST $API_URL/leaves-holidays \
-H "Content-Type: application/json" \
-d '{"employee_id":"EMP001"}'
```

#### Expected:

```
{"leaves":[...],"holidays":[...]}
```

### ✅ If Something Fails

#### If 500 Error

- Go to:  

CloudWatch → Log groups →
/aws/lambda/hr-attendance
(or respective lambda)

- Check error message.

#### If 403 Forbidden

- Check API deployed to correct stage

- Check correct URL

- Ensure Lambda permission added

- If CORS error (frontend only)

- Your Lambda headers already allow:

```
Access-Control-Allow-Origin: *
```

So you are safe.

### 🎯 FINAL CONFIRMATION CHECKLIST

| Item                          | Status |
| ----------------------------- | ------ |
| All endpoints use POST        | ✅      |
| Lambda Proxy enabled          | ✅      |
| CORS OPTIONS added            | ✅      |
| API deployed to prod          | ✅      |
| EC2 can access HTTPS outbound | ✅      |

### 🚀 Architecture Status

You now have a clean architecture:

Client → API Gateway (REST Regional) → Lambda → RDS → Secrets Manager

This is production-grade design.


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 4️⃣ — Frontend Pages for HR System

### 1️⃣ Open browser:

```
http://<EC2-Public-IP>/checkin.html
http://<EC2-Public-IP>/employee-portal.html
http://<EC2-Public-IP>/admin-dashboard.html
```

#### Enter:

    - Valid employee ID → Check-In → ✅ success

    - Same ID again → backend should block duplicate

    - Check-Out after check-in → ✅ success

### 2️ Verify in RDS:

```
SELECT * FROM attendance ORDER BY attendance_date DESC;
```

### 3️⃣ HOW TO TEST LOGOUT (VERIFICATION — VERY IMPORTANT)

> **Do this test for both roles:**

#### Test Steps

1️⃣ Login as Admin or Employee

2️⃣ Open dashboard

3️⃣ Click Logout

4️⃣ Redirect happens

5️⃣ Press Browser Back Button

#### Expected Result

❌ Page does NOT load

✅ Redirects again

✅ Session fully destroyed

**👉 This confirms Cognito is correctly integrated**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 5️⃣ — Cafe Attendance Admin Service

### ✅ Lambda Console Test Events

### 🧪 1️⃣ Daily Attendance

```
{
  "queryStringParameters": {
    "type": "daily"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```

### 🧪 2️⃣ Weekly + Summary

```
{
  "queryStringParameters": {
    "type": "weekly",
    "summary": "true"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```

### 🧪 3️⃣ Employee Dynamo Lookup

```
{
  "attendance_rds": [...],
  "attendance_dynamo": [...],
  "summary": {
    "total_present": 4,
    "total_absent": 2,
    "total_leaves": 1
  }
}
```

### ✅ API Test Events

IMPORTANT:

Since this API uses Cognito Authorizer, you MUST include:

```
Authorization: Bearer <JWT_TOKEN>
```

You get JWT token from:

- Cognito Hosted UI login

- Browser DevTools → Application → Local Storage

- Copy idToken

### ✅ TEST 1 — API Gateway Console

- Go to /admin/analytics

- Click GET

- Click Test

- Add Query String:

  - Key: type

  - Value: daily

- Add Header: Authorization: Bearer eyJraWQiOiJ....

- Click Test

- Body: {}

#### ✅ Expected Result (Example)

```
{
  "attendance_rds": [
    {
      "employee_id": "EMP001",
      "name": "Ali",
      "date": "2026-02-26",
      "checkin_time": "09:01:00",
      "checkout_time": null
    }
  ],
  "attendance_dynamo": [],
  "summary": {}
}
```

### ✅ TEST 2 — BROWSER TEST

Paste:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics?type=daily
```

⚠ Browser will return:

```
401 Unauthorized
```

Because browser does NOT automatically send JWT token.

That is normal.

### ✅ TEST 3 — EC2 CLI (CORRECT WAY)

Run:

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics?type=daily" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example with Summary

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics?type=weekly&summary=true" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example With Employee Filter

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics?employee_id=EMP001" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example With DynamoDB Date Filter

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics?employee_id=EMP001&date=2026-02-25" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### ✅ EXPECTED RESPONSES

#### 1️⃣ Daily

Returns today attendance from RDS

#### 2️⃣ Weekly + summary=true

Returns:

```
{
  "attendance_rds": [...],
  "attendance_dynamo": [],
  "summary": {
    "total_present": 8,
    "total_absent": 2,
    "total_leaves": 1
  }
}
```

#### 3️⃣ employee_id only

Returns:

```
attendance_rds → filtered from MySQL
attendance_dynamo → all Dynamo records for that employee
```

#### 4️⃣ employee_id + date

Returns:

```
attendance_dynamo → only that specific date record
```

### 🚨 COMMON ERRORS & WHY

| Error            | Reason                  |
| ---------------- | ----------------------- |
| 401 Unauthorized | Missing or invalid JWT  |
| 403 Forbidden    | User not in Admin group |
| 500 RDS error    | DB security group issue |
| 500 Dynamo error | IAM permission missing  |
| 502 Bad Gateway  | Lambda crashed          |

### 🔐 REQUIRED IAM PERMISSIONS

Lambda Role must have:

```
secretsmanager:GetSecretValue
dynamodb:Query
```

### 🎯 FINAL ARCHITECTURE

```
Cognito (Admin login)
↓
API Gateway (Cognito Authorizer)
↓
Lambda (hr-admin-attendance-analytics)
↓
Secrets Manager (DB credentials)
↓
RDS (MySQL)
↓
DynamoDB (CafeAttendance)
```





**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
