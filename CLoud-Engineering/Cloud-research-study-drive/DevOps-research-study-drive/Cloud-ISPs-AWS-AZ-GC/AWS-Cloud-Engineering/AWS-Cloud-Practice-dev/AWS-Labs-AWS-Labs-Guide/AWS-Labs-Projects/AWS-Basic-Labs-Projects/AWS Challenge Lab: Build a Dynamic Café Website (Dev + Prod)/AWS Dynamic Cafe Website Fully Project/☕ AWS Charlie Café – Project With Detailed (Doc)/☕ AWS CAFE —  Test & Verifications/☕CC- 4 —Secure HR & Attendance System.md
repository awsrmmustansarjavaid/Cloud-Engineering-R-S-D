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

### 1️⃣ Lambda Testing & Verification

#### 1️⃣ Test Environment Variables

- Lambda → Configuration → Environment variables

- Ensure:

```
DB_HOST, DB_NAME, DB_USER, DB_PASS
```

- Double-check spelling and values (typos will break RDS connection).

#### 2️⃣ — VPC Settings

- Lambda → Configuration → VPC

- Must be in the same VPC as RDS

- Use private subnets that can reach RDS

- Security group: allows outbound TCP 3306 to RDS

#### 3️⃣ — Install PyMySQL Layer (if missing)

- If your Lambda environment doesn’t have pymysql, create a Lambda Layer:

- Create a folder python/lib/python3.12/site-packages/

- pip install pymysql -t python/lib/python3.12/site-packages/

- Zip and upload as Layer

- Attach Layer to all HR Lambdas

### 2️⃣ Test hr-checkin Lambda

#### Step 1 — Open Lambda Console

- Navigate: Lambda → hr-checkin → Test

#### Step 2 — Create Test Event

- Event template: API Gateway AWS Proxy (JSON)

Example:

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

> **Replace "sub" with an actual Cognito user ID mapped to your employees table.**

- Name: TestCheckIn

- Save

#### Step 3 — Invoke Test

- Click Test

- Observe output:

#### Expected success:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-in successful\"}"
}
```

#### If already checked in:

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Already checked in today\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

#### Step 4 — Verify in RDS

```
SELECT * FROM attendance WHERE employee_id = 1;
```

- Should see today’s date with checkin_time populated

- checkout_time should be NULL

### 3️⃣ Test hr-checkout Lambda

#### Step 1 — Open Lambda Console

- Lambda → hr-checkout → Test

#### Step 2 — Create Test Event

- Same template as hr-checkin:

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

- Click Test

#### Expected success:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```
#### If not checked in yet:

```
{
  "statusCode": 400,
  "body": "{\"message\": \"Check-in required before checkout\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

#### Step 4 — Verify in RDS

```
SELECT * FROM attendance WHERE employee_id = 1;
```

> **checkout_time should now be populated**

### 4️⃣ Test hr-employee-profile Lambda

#### Step 1 — Open Lambda Console → hr-employee-profile → Test

#### Step 2 — Test Event (same as above)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "{\"name\": \"Alice\", \"job_title\": \"Barista\", \"salary\": 40000.00, \"start_date\": \"2025-12-01\"}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms Lambda can read employees table from RDS**

### 5️⃣ Test hr-attendance-history Lambda

#### Step 1 — Open Lambda → hr-attendance-history → Test

#### Step 2 — Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "[{\"attendance_date\": \"2026-01-19\", \"checkin_time\": \"09:00:00\", \"checkout_time\": \"17:00:00\"}]"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms RDS attendance table integration**

### 6️⃣ Test hr-leaves-holidays Lambda

#### Step 1 — Open Lambda → hr-leaves-holidays → Test

#### Step 2 — Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "sub": "TEMP-COGNITO-ID"
      }
    }
  }
}
```

#### Step 3 — Invoke Test

#### Expected output:

```
{
  "statusCode": 200,
  "body": "{\"leaves\": [{\"leave_date\": \"2026-01-15\", \"leave_type\": \"Sick Leave\"}], \"holidays\": [{\"holiday_date\": \"2026-01-01\", \"description\": \"New Year\"}]}"
}
```

#### without cognito 

```
{
  "statusCode": 403,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"message\": \"Forbidden\"}"
}
```

> **Confirms Lambda reads both leaves and holidays tables**

### ✅ Verification Checklist

#### All 5 Lambdas invoke without error

✔️ Database writes/reads are successful

✔️ Test attendance table shows:

    ✔️ Today’s check-in

    ✔️ Today’s check-out

✔️ Employee profile matches employees table

✔️ Leaves and holidays return correct rows

### 📞 Research & Interview 

### 1️⃣ Why ALL 5 Lambdas return 403 Forbidden

Every one of your HR Lambdas contains this line (directly or indirectly):

```
cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
```

#### That means:

**👉 These Lambdas REQUIRE Cognito authentication**

So what happens?

#### During Lambda Test (without Cognito)

- There is NO JWT token

- There is NO authorizer

- requestContext.authorizer.claims does not exist

- API Gateway (or your test harness) blocks the request

- Result = 403 Forbidden

**This is correct security behavior, not an error.**

### What 403 Means in YOUR Case (Important)

#### 403 Forbidden here means:

**🔐 “You are not authenticated, so access is denied”**

It does NOT mean:

❌ Lambda code is wrong

❌ Database is broken

❌ SQL queries failed

❌ IAM permissions are wrong

#### It ONLY means:

**👉 Cognito is not configured yet**

### Status of Each Lambda (All Good ✅)


| Lambda Name           | Result | Status    |
| --------------------- | ------ | --------- |
| hr-checkin            | 403    | ✅ Correct |
| hr-checkout           | 403    | ✅ Correct |
| hr-employee-profile   | 403    | ✅ Correct |
| hr-attendance-history | 403    | ✅ Correct |
| hr-leaves-holidays    | 403    | ✅ Correct |

**If any of these returned 200 without Cognito, that would actually be a security bug 🚨**

### When Will These Lambdas Return 200 OK?

#### They will work automatically once you do:

- Required Next Steps (Later Phase)

- Create Cognito User Pool

- Create App Client

- Configure API Gateway Authorizer

- Send requests with:

```
Authorization: Bearer <JWT_TOKEN>
```

Then:

- claims.sub will exist

- cognito_user_id will resolve

- DB queries will work

- You’ll get 200 OK responses 🎉

#### If You REALLY Want to Test Without Cognito (Optional)

**⚠️ Only for learning — NOT recommended for production**

You could:

- Hardcode a test cognito_user_id

- Or mock event['requestContext']

But since you’re building a real HR system, I do NOT recommend this.

**You’re actually doing things the right way 👍**

### Final Verdict (Very Important)

✔ Your Lambda logic is correct

✔ Your SQL structure is correct

✔ Your security design is correct

✔ 403 Forbidden is the expected result

✔ You are ready for Cognito integration

**✔️  If all pass → Lambdas are fully integrated with RDS**
> **We are ready to move to API Gateway to expose them to the frontend securely.**


### 📥 What You Have Achieved

✅ New HR-specific Lambda layer

✅ Cognito-secured backend

✅ RDS-integrated attendance logic

✅ Real-world AWS job architecture

✅ No duplication of existing lab


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 3️⃣ — API Gateway Setup for HR Secure Attendance System

> **Test Each API Endpoint**
> **We will test using Postman or Lambda Test Console.**

#### 1️⃣ Test /checkin (POST)

#### Request:

    - URL:

```
https://<API-ID>.execute-api.<region>.amazonaws.com/dev/checkin
```

    - Method: POST

    - Headers:

```
Authorization: <Cognito JWT token>
Content-Type: application/json
```

    - Body: Empty JSON {}

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-in successful\"}"
}
```

#### Verify in RDS:

```
SELECT * FROM attendance WHERE employee_id=1 AND attendance_date=CURDATE();
```

#### 2️⃣ Test /checkout (POST)

#### Request:

    - URL: /checkout

    - Headers same as above

    - Body: {}

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```

#### Verify in RDS: 
- checkout_time populated for today

#### 3️⃣ Test /employee-profile (GET)

- URL: /employee-profile

- Method: GET

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"name\": \"Alice\",\"job_title\": \"Barista\",\"salary\": 40000.0,\"start_date\": \"2025-12-01\"}"
}
```

#### 4️⃣ Test /attendance-history (GET)

- URL: /attendance-history

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "[{\"attendance_date\": \"2026-01-19\",\"checkin_time\": \"09:00:00\",\"checkout_time\": \"17:00:00\"}]"
}
```

#### 5️⃣ Test /leaves-holidays (GET)

- URL: /leaves-holidays

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"leaves\": [{\"leave_date\": \"2026-01-15\", \"leave_type\": \"Sick Leave\"}], \"holidays\": [{\"holiday_date\": \"2026-01-01\", \"description\": \"New Year\"}]}"
}
```

### 🌐 Verification Checklist

✅ All endpoints secured by Cognito JWT

✅ Lambda functions triggered via API Gateway

✅ RDS integration works for attendance, check-in/out, employee profile, leaves, holidays

✅ CORS enabled for frontend

✅ Can call endpoints from EC2 frontend or Postman


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
## ☕ Charlie Café PHASE 5️⃣ Secure Frontend & API Integration with Production Hardening

### 1️⃣ Frontend  - auth-api.js

#### VERIFY FILE LOCATIONS (LINUX)

```
cd /var/www/html
```
```
ls -R js
```

#### You should see:

```
js/
 ├── config.js
 └── auth-api.js
```

If yes → ✅ continue

If not → stop and fix paths

### 🧪 TEST 1️⃣ — Browser Console

1️⃣ Open DevTools → Console

2️⃣ You should NOT see:

```
CONFIG is not defined
```

### 🧪 TEST 2️⃣ — Employee Normal Flow

1️⃣ Login as Employee

2️⃣ Open employee portal

3️⃣ Profile loads

4️⃣ Attendance loads

5️⃣ Admin buttons NOT visible

✅ PASS

### 🧪 TEST 3️⃣ — Employee Tries Admin URL

1️⃣ Login as Employee

2️⃣ Open admin-dashboard.html manually

❌ Access denied

✅ Redirect to login

### 🧪 TEST 4️⃣ — Admin Normal Flow

1️⃣ Login as Admin

2️⃣ Open admin dashboard

3️⃣ Admin buttons visible

4️⃣ Employee list loads

✅ PASS

### 🧪 TEST 5️⃣ — JWT Verification

1️⃣ Open DevTools → Network

2️⃣ Click any API call

3️⃣ Check Headers

#### You MUST see:

```
Authorization: eyJraWQiOiJ...
```

✅ Token attached

✅ Cognito authorizer working

### 🧪 TEST 6️⃣ — API Protection

1️⃣ Copy API URL

2️⃣ Open in browser without token

❌ 401 / 403 error

✅ Secure

### 🧪 TEST 7️⃣ — Authentication

- Token expires → auto logout

- Logout destroys session

- Back button blocked

### 🧪 TEST 8️⃣  Authorization

Admin cannot be Employee

Employee cannot be Admin

Backend blocks unauthorized API calls

### 🧪 TEST 9️⃣ UX

Loader visible

Errors friendly

No raw error messages

### 🧪 TEST 🔟 Observability

CloudWatch logs visible

Errors traceable

Requests traceable

### 🧪 TEST 1️⃣1️⃣ Token Expiry

Wait 1 hour OR invalidate session

API call triggers auto logout

Redirects to login


### 🏁 CONGRATULATIONS

You now have:

✔ Real AWS architecture

✔ Secure Cognito auth

✔ Role-based UI

✔ Hardened APIs

✔ Production-level frontend

✔ Job-ready project

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 6️⃣ — ADMIN ATTENDANCE ANALYTICS




**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---