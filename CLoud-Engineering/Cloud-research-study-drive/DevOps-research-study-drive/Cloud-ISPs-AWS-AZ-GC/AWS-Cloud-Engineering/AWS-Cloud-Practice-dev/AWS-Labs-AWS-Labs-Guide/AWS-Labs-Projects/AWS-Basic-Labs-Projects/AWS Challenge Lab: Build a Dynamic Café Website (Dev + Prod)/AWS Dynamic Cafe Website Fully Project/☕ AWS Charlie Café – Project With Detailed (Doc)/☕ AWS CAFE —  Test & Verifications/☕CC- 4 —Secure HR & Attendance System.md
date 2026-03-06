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

### 2️⃣ Verify attendance

```
SELECT * FROM attendance;
```

#### Expected output:

```
+---------------+-------------+-----------------+--------------+---------------+---------------------+
| attendance_id | employee_id | attendance_date | checkin_time | checkout_time | created_at          |
+---------------+-------------+-----------------+--------------+---------------+---------------------+
|             3 |           5 | 2026-03-05      | 12:19:38     | 12:20:16      | 2026-03-05 12:19:38 |
+---------------+-------------+-----------------+--------------+---------------+---------------------+
1 row in set (0.001 sec)
```

### Check Employees Table

```
DESCRIBE employees;
```

#### Expected output:

```
+-----------------+---------------+------+-----+-------------------+-------------------+
| Field           | Type          | Null | Key | Default           | Extra             |
+-----------------+---------------+------+-----+-------------------+-------------------+
| employee_id     | int           | NO   | PRI | NULL              | auto_increment    |
| cognito_user_id | varchar(100)  | NO   | UNI | NULL              |                   |
| name            | varchar(100)  | NO   |     | NULL              |                   |
| job_title       | varchar(50)   | YES  |     | NULL              |                   |
| salary          | decimal(10,2) | YES  |     | NULL              |                   |
| start_date      | date          | YES  |     | NULL              |                   |
| created_at      | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+-----------------+---------------+------+-----+-------------------+-------------------+
7 rows in set (0.015 sec)
```

### Get Ali's Employee ID

```
SELECT employee_id FROM employees
WHERE cognito_user_id = '44380458-0091-70a3-e16b-85f38973d335';
```

#### Expected output:

```
+-------------+
| employee_id |
+-------------+
|           3 |
+-------------+
1 row in set (0.001 sec)
```


### ✅ Shortest Way (One Command)

Use this single SQL command:

```
SELECT * 
FROM attendance
WHERE employee_id = (
    SELECT employee_id
    FROM employees
    WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962'
);
```

This will return Ali's attendance.

### ✅ Better View (Recommended)

Shows Ali name + attendance time

```
SELECT e.name, a.attendance_date, a.checkin_time, a.checkout_time
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
WHERE e.cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

#### Expected output:

| name | attendance_date | checkin_time | checkout_time |
| ---- | --------------- | ------------ | ------------- |
| Ali  | 2026-03-05      | 12:19:38     | 12:20:16      |


### ✅ Quick Check (Find Ali Employee ID)

If you want to see Ali's employee id:

```
SELECT employee_id, name
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

Example:

```
employee_id | name
5           | Ali
```

Then you can simply run:

```
SELECT * FROM attendance WHERE employee_id = 5;
```

### ✅ Best practice in real projects

Always use JOIN like this:

```
SELECT e.name, a.*
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id;
```

### ✅ How to Verify employee_id  (VERY IMPORTANT)

Open browser console on the portal page.

You already log this:

```
console.log("Decoded Token:",decoded)
```

#### You will see something like:

```
{
 "sub": "...",
 "email": "...",
 "cognito:username": "ali",
 "token_use": "id"
}
```

You will NOT see

```
custom:employee_id
```

That confirms the problem.




### ✅ RDS SQL script


Perfect! I’ll create a ready-to-run MySQL script for your RDS employees table. It will:

- Check if an employee with the given cognito_user_id exists.

- Insert a new employee if not exists.

- Verify the insertion and print the record.

#### Here’s the script:

```
-- =============================================
-- Charlie Cafe Employee Insert & Verification
-- =============================================

-- ===============================
-- ⚙️  CONFIGURATION
-- ===============================
SET @cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
SET @employee_name    = 'Ali';
SET @job_title        = 'Barista';
SET @salary           = 40000;
SET @start_date       = '2026-03-05';

-- ===============================
-- 1️⃣ Check if employee already exists
-- ===============================
SELECT * 
FROM employees
WHERE cognito_user_id = @cognito_user_id;

-- ===============================
-- 2️⃣ Insert new employee if not exists
-- ===============================
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
SELECT @cognito_user_id, @employee_name, @job_title, @salary, @start_date
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 
    FROM employees 
    WHERE cognito_user_id = @cognito_user_id
);

-- ===============================
-- 3️⃣ Verify insertion
-- ===============================
SELECT * 
FROM employees
WHERE cognito_user_id = @cognito_user_id;
```

### How to Use:

- Copy this script into your MySQL client (CLI, Workbench, etc.).

- Change the values of:

```
@cognito_user_id → Cognito Sub ID of the user
@employee_name    → Employee full name
@job_title        → Employee role
@salary           → Employee salary
@start_date       → Employment start date
```

- Run the script.

### ✅ What happens:

- If the employee already exists, it won’t insert a duplicate.

- You get a SELECT output before and after insertion for verification.


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 1️⃣ hr-attendance Test Event in Lambda Console

- Open your Lambda in AWS console.

- Click “Test” → Configure test event.

- Choose “Create new test event” with type API Gateway AWS Proxy (or plain JSON).

- For check-in, example event:

```
{
  "httpMethod": "POST",
  "resource": "/checkin",
  "body": "{\"employee_id\": 1}"
}
```

For check-out, example event:

```
{
  "httpMethod": "POST",
  "resource": "/checkout",
  "body": "{\"employee_id\": 1}"
}
```

For CORS preflight test, example event:

```
{
  "httpMethod": "OPTIONS",
  "resource": "/checkin"
}
```

### ✅ Example Test & Response

Test Event (Check-in):

```
{
  "httpMethod": "POST",
  "resource": "/checkin",
  "body": "{\"employee_id\": 1}"
}
```

Expected Response:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"Check-in successful\"}"
}
```

If the employee already checked in today:

```
{
  "statusCode": 400,
  "headers": { ... },
  "body": "{\"message\": \"Already checked in today\"}"
}
```

Test Event (Check-out):

```
{
  "httpMethod": "POST",
  "resource": "/checkout",
  "body": "{\"employee_id\": 1}"
}
```

Expected Response:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"message\": \"checkout successful\"}"
}
```


#### ✅ Once you set this up, you can test check-in first, then check-out, and verify the attendance table in MySQL to see the records inserted/updated.

### 2️⃣ hr-employee-profile

- Open your Lambda in AWS console.

- Click “Test” → “Configure test event” → “Create new test event”.

- Choose “API Gateway AWS Proxy” (or plain JSON).

- Example test events:

- Check Employee Profile (Valid ID):

```
{
  "httpMethod": "POST",
  "resource": "/employee-profile",
  "body": "{\"employee_id\": 1}"
}
```

Expected Response:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "{\"employee_id\": 1, \"name\": \"Alice\", \"job_title\": \"Barista\", \"salary\": 40000.0, \"start_date\": \"2025-12-01\"}"
}
```


Check Employee Profile (Missing ID):

```
{
  "httpMethod": "POST",
  "body": "{}"
}
```

CORS Preflight Test:

```
{
  "httpMethod": "OPTIONS"
}
```

Employee Not Found:

```
{
  "httpMethod": "POST",
  "body": "{\"employee_id\": \"99999\"}"
}
```

### 3️⃣ hr-attendance-history

- Open your Lambda in AWS console.

- Click “Test” → “Configure test event” → “Create new test event”.

- Choose “API Gateway AWS Proxy” (or plain JSON).

- Example Test Events

- Valid Employee History Request:

```
{
  "httpMethod": "POST",
  "resource": "/attendance-history",
  "body": "{\"employee_id\": 1}"
}
```

Expected Response:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
  },
  "body": "[{\"attendance_date\": \"2026-03-02\", \"checkin_time\": \"21:40:55\", \"checkout_time\": \"21:42:09\"}]"
}
```

Missing employee_id:

```
{
  "httpMethod": "POST",
  "body": "{}"
}
```

CORS Preflight:

```
{
  "httpMethod": "OPTIONS"
}
```

Employee with No Records (optional):

```
{
  "httpMethod": "POST",
  "body": "{\"employee_id\":\"99999\"}"
}
```

#### Expected Results

| Scenario                         | Input Example             | Expected Response                                                                                                                                                                                                                                        |
| -------------------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CORS Preflight                   | `OPTIONS`                 | 200 OK → `{"message":"CORS preflight successful"}`                                                                                                                                                                                                       |
| Missing Body                     | `{}` (body missing)       | 400 Bad Request → `{"message":"Missing request body"}`                                                                                                                                                                                                   |
| Missing `employee_id`            | `{"body":"{}"}`           | 400 Bad Request → `{"message":"employee_id is required"}`                                                                                                                                                                                                |
| Employee with No Records         | `{"employee_id":"99999"}` | 200 OK → empty array: `[]`                                                                                                                                                                                                                               |
| Employee with Attendance Records | `{"employee_id":"12345"}` | 200 OK → array of records, newest first, e.g.: <br>`json [ { "attendance_date": "2026-02-27", "checkin_time": "09:05:00", "checkout_time": "17:10:00" }, { "attendance_date": "2026-02-26", "checkin_time": "09:00:00", "checkout_time": "17:00:00" } ]` |


### 4️⃣ hr-leaves-holidays 

- Open your Lambda in AWS console.

- Click “Test” → “Configure test event” → “Create new test event”.

- Choose “API Gateway AWS Proxy” (or plain JSON).

- Example Test Events

- Valid Employee Request:

```
{
  "httpMethod": "POST",
  "resource": "/leave-history",
  "body": "{\"employee_id\": 1}"
}
```

Missing employee_id:

```
{
  "httpMethod": "POST",
  "body": "{}"
}
```

CORS Preflight:

```
{
  "httpMethod": "OPTIONS"
}
```

Employee with No Leaves (optional):

```
{
  "httpMethod": "POST",
  "body": "{\"employee_id\":\"99999\"}"
}
```

#### Expected Results

| Scenario                | Input Example             | Expected Response                                                                                                                                                                                                                                                                                           |
| ----------------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CORS Preflight          | `OPTIONS`                 | 200 OK → `{"message":"CORS preflight successful"}`                                                                                                                                                                                                                                                          |
| Missing Body            | `{}` (body missing)       | 400 Bad Request → `{"message":"Missing request body"}`                                                                                                                                                                                                                                                      |
| Missing `employee_id`   | `{"body":"{}"}`           | 400 Bad Request → `{"message":"employee_id is required"}`                                                                                                                                                                                                                                                   |
| Employee with No Leaves | `{"employee_id":"99999"}` | 200 OK → `{ "leaves": [], "holidays": [ ... all company holidays ... ] }`                                                                                                                                                                                                                                   |
| Employee with Leaves    | `{"employee_id":"12345"}` | 200 OK → example:<br>`json { "leaves": [ { "leave_date": "2026-02-25", "leave_type": "Sick" }, { "leave_date": "2026-02-15", "leave_type": "Casual" } ], "holidays": [ { "holiday_date": "2026-01-01", "description": "New Year" }, { "holiday_date": "2026-02-14", "description": "Valentine's Day" } ] }` |


### RDS Verification


### 1️⃣ Connect to RDS from EC2 CLI

```
mysql -h <RDS-ENDPOINT> -u <DB-USER> -p cafedb
```
Replace <RDS-ENDPOINT> with your RDS endpoint.

Replace <DB-USER> with your database username.

Enter password when prompted.

You should see:

```
mysql>
```

2️⃣ Lambda Verification Plan

We’ll verify each Lambda against the corresponding tables.

A. HR Attendance Lambda (Check-in / Check-out)

Tables: attendance, employees

SQL Verification:

Check employees exist:

```
SELECT * FROM employees;
```

Must include the employee ID you used in the Lambda test.

Check attendance records:

```
SELECT * FROM attendance
WHERE employee_id = 1
ORDER BY attendance_date DESC;
```

For check-in test, checkin_time should be populated.

For check-out test, checkout_time should also be populated.

✅ This confirms the Lambda successfully inserted/updated attendance records.

B. Employee Profile Lambda

Table: employees

SQL Verification:

```
SELECT employee_id, name, job_title, salary, start_date
FROM employees
WHERE employee_id = 1;
```

The result should match the Lambda’s JSON response.

C. Attendance History Lambda

Table: attendance

SQL Verification:

```
SELECT attendance_date, checkin_time, checkout_time
FROM attendance
WHERE employee_id = 1
ORDER BY attendance_date DESC;
```
he result should exactly match the JSON array returned by the Lambda.

D. Leaves & Holidays Lambda

Tables: leaves, holidays

SQL Verification:

Employee leaves:

```
SELECT leave_date, leave_type
FROM leaves
WHERE employee_id = 1
ORDER BY leave_date DESC;
```
Company holidays:

```
SELECT holiday_date, description
FROM holidays
ORDER BY holiday_date DESC;
```

he output should match the Lambda response JSON for leaves and holidays.

3️⃣ Quick Tips

Use ORDER BY to match the Lambda sorting (attendance date DESC, leave date DESC).

If testing check-in/checkout, rerun the Lambda and verify using:

```
SELECT * FROM attendance WHERE employee_id = 1 AND attendance_date = CURDATE();
```

For test data cleanup, you can delete old test entries:

```
DELETE FROM attendance WHERE employee_id = 1 AND attendance_date < '2026-01-01';
DELETE FROM leaves WHERE employee_id = 1;
```

If your Lambda returns empty arrays, check for existing data in the table.

✅ Using this method, you can fully verify all 4 Lambdas by comparing the RDS data with your Lambda JSON responses.

### Quick Test 

```
SELECT * FROM employees WHERE employee_id = 1;
SELECT * FROM attendance WHERE employee_id = 1 ORDER BY attendance_date DESC;
SELECT leave_date, leave_type FROM leaves WHERE employee_id = 1 ORDER BY leave_date DESC;
SELECT holiday_date, description FROM holidays ORDER BY holiday_date DESC;
```

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

- Go to /hr-analytics

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
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics?type=daily
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
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics?type=daily" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example with Summary

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics?type=weekly&summary=true" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example With Employee Filter

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics?employee_id=EMP001" \
-H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Example With DynamoDB Date Filter

```
curl -X GET "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics?employee_id=EMP001&date=2026-02-25" \
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
