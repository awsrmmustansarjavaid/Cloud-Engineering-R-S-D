# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

### READ Me About

[☕ CC- 4 —Secure HR & Attendance System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

---


# ☕ Charlie Café SECTION 2️⃣ - Attendance System

## ☕ Charlie Café PHASE 1️⃣ — Database Layer (RDS) Configuration

#### 📢 Goal: Prepare database objects so Lambda can store and read attendance, employees, leaves, holidays.

### 🔹 Assumptions (Based on Your Existing Lab)

You already have:

✅ RDS instance running

✅ Database name: cafedb

✅ RDS security group already allows Lambda access

✅ Lambda already has DB credentials (or Secrets Manager)

✅ You can connect to RDS via:

    - EC2 (mysql / psql client) OR

    - RDS Query Editor

### 1️⃣ Connect to Existing cafedb

#### 1️⃣ Option A: From EC2 (recommended) 

```
mysql -h <RDS-ENDPOINT> -u <DB-USER> -p cafedb
```

> **Enter password when prompted.**

#### 1️⃣ Option B: RDS Query Editor

- Open Amazon RDS

- Databases → Your RDS instance

- Query Editor → Connect to cafedb

### 2️⃣ Create employees Table

> **This table links Cognito users with café employees.**

```
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Why each column exists

- cognito_user_id → maps Cognito JWT sub

- employee_id → internal café ID

- salary → HR-only field

- created_at → audit trail

### 3️⃣ Create attendance Table

```
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

#### Key points

UNIQUE(employee_id, attendance_date)

Prevents double check-in per day

checkin_time and checkout_time separated

Foreign key ensures valid employee

### 4️⃣ Create leaves Table

```
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

### 5️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6️⃣ Insert Test Data (Required for Frontend Testing)

#### 1️⃣ Insert Holidays

```
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');
```

#### 2️⃣ Insert Test Employee (TEMP)

> **We will later auto-create employees via Cognito, but this helps now.**

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
```

### 7️⃣ Verify Tables

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

### 8️⃣ HR & Attendance System Bash Script 

#### 1️⃣ Create File

```
sudo nano setup_cafe_hr_attendance.sh
```

#### 2️⃣ Bash Script 

[setup_cafe_hr_attendance.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/setup_cafe_hr_attendance.sh)

#### 3️⃣ Make the Script Executable

```
sudo chmod +x setup_cafe_hr_attendance.sh
```

#### 4️⃣ Run the Script

```
sudo ./setup_cafe_hr_attendance.sh
```

### 8️⃣ Confirm Lambda DB Access (Important Minor Step)

- Check Lambda Environment Variables

- Open Lambda → Any existing café Lambda

#### Ensure ALL exist:

| Variable | Example                        |
| -------- | ------------------------------ |
| DB_HOST  | cafedb.xxxxx.rds.amazonaws.com |
| DB_NAME  | cafedb                         |
| DB_USER  | admin                          |
| DB_PASS  | ********                       |

> **If missing → Add them, save, deploy.**

### 9️⃣ Final End  – What You Have Now

✅ Database schema ready

✅ Linked to Cognito via cognito_user_id

✅ Safe for production-style usage

✅ No change to existing infrastructure


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 1️⃣ IAM Role for HR Lambdas (ONE TIME ONLY)

If you already have a Lambda role that accesses RDS + CloudWatch, reuse it.
If not, follow every step below.

#### Step 1️⃣: Open IAM

- AWS Console → IAM

- Roles → Create role

#### Step 2️⃣: Select Trusted Entity

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

#### Step 3️⃣: Attach Permissions

- Attach exactly these policies:

    - AWSLambdaBasicExecutionRole

    - AmazonRDSDataFullAccess (or your custom RDS policy)

- Click Next

#### Step 4️⃣: Role Name

#### Role name:

```
cafe-hr-lambda-role
```

- Create role

### 2️⃣ Create Lambda: hr-checkin

#### Step 1️⃣: Open Lambda

- AWS Console → Lambda

- Click Create function

#### Step 2️⃣: Function Basics

- Author from scratch

#### Function name:

```
hr-checkin
```

#### Runtime:

```
Python 3.12
```

- Architecture: x86_64

#### Execution role:

- Use existing role

#### Select:

```
cafe-hr-lambda-role
```

- Click Create function

#### Step 3️⃣: Configure Environment Variables

- Lambda → Configuration → Environment variables

#### Add ALL:

| Key     | Value             |
| ------- | ----------------- |
| DB_HOST | your-rds-endpoint |
| DB_NAME | cafedb            |
| DB_USER | your-db-user      |
| DB_PASS | your-db-password  |

- Click Save

#### Step 4️⃣: Add VPC Configuration (CRITICAL)

- Lambda → Configuration → VPC

- VPC: same VPC as RDS

- Subnets: private subnets used by RDS

- Security group: Lambda SG that allows RDS access

- Click Save

#### Step 5️⃣: Lambda Code (Check-In)

> **Replace entire code with this:**

[hr-checkin.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/hr-checkin.py)

- Click Deploy

### 3️⃣ Create Lambda: hr-checkout
> **Repeat Steps Exactly Like hr-checkin**

#### Only change:

#### 1️⃣ Function name:

```
hr-checkout
```

#### 2️⃣ Code:

[hr-checkout.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/hr-checkout.py)

- Deploy.

### 4️⃣ Create Lambda: hr-employee-profile

#### 1️⃣ Function name

```
hr-employee-profile
```

#### 2️⃣ Code:

[hr-employee-profile.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/hr-employee-profile.py)

- Deploy.

### 5️⃣ Create Lambda: hr-attendance-history

#### 1️⃣ Function name

```
hr-attendance-history
```

#### 2️⃣ Code:

[hr-attendance-history.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/hr-attendance-history.py)

- Deploy.

6️⃣ Create Lambda: hr-leaves-holidays

#### 1️⃣ Function name

```
hr-leaves-holidays
```

#### 2️⃣ Code:

[hr-leaves-holidays.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/hr-leaves-holidays.py)

- Deploy.

### 7️⃣ Lambda Testing & Verification

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

> **Confirms Lambda reads both leaves and holidays tables**

### ✅ Verification Checklist

#### All 5 Lambdas invoke without error

✔️ Database writes/reads are successful

✔️ Test attendance table shows:

    ✔️ Today’s check-in

    ✔️ Today’s check-out

✔️ Employee profile matches employees table

✔️ Leaves and holidays return correct rows

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

### 🔹 Step 0 — Assumptions

#### We already have:

- EC2 Apache frontend

- Lambda functions (5 HR Lambdas) fully working and tested

- RDS database with employees, attendance, leaves, holidays

- Cognito User Pool already created

### 1️⃣ Open API Gateway

- Go to AWS Console → API Gateway → Create API

- Choose REST API (not HTTP API)

- API Name:

```
cafe-hr-api
```

- Description:

```
HR Secure Attendance & Employee Management API
```

- Endpoint Type: Regional

- Click Create API

### 2️⃣ Create Resources (Paths)

> **We will create 5 resources, one for each Lambda.**

| Resource           | Path                  | Lambda Function         |
| ------------------ | --------------------- | ----------------------- |
| Check-In           | `/checkin`            | `hr-checkin`            |
| Check-Out          | `/checkout`           | `hr-checkout`           |
| Employee Profile   | `/employee/profile`   | `hr-employee-profile`   |
| Attendance History | `/attendance/history` | `hr-attendance-history` |
| Leaves & Holidays  | `/leaves-holidays`    | `hr-leaves-holidays`    |

#### Step 1 — Add /checkin

- Click Actions → Create Resource

- Resource Name: CheckIn

- Resource Path: /checkin

- Click Create Resource

#### Step 2 — Repeat for remaining resources

- /checkout

- /employee/profile

- /attendance/history

- /leaves-holidays

### 3️⃣ Create Methods

#### For each resource:

    - Click on Resource → Actions → Create Method

    - Select POST for /checkin and /checkout

    - Select GET for /employee/profile, /attendance/history, /leaves-holidays

### 4️⃣ Integrate Lambda Function

#### For each method:

    - Integration type: Lambda Function

    - Check Use Lambda Proxy Integration

    - Lambda Region: your Lambda region

#### Lambda Function:

    - /checkin → hr-checkin

    - /checkout → hr-checkout

    - /employee/profile → hr-employee-profile

    - /attendance/history → hr-attendance-history

    - /leaves-holidays → hr-leaves-holidays

- Click Save

- Grant permissions when prompted → Yes

### 5️⃣ Enable Cognito Authorizer

#### Step 1 — Create Authorizer

- API Gateway → Authorizers → Create New Authorizer

- Name: HR-Cognito-Authorizer

- Type: Cognito

- Cognito User Pool: Select your café User Pool

- Token Source: Authorization (Header)

- Click Create

#### Step 2 — Attach Authorizer to Methods

#### For each resource method:

    - Click on Method → Method Request

    - Authorization: select HR-Cognito-Authorizer

    - Save

### 6️⃣ Enable CORS (Cross-Origin Resource Sharing)

#### For each resource method:

    - Click Method → Actions → Enable CORS

#### Settings:

    - Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token

    - Access-Control-Allow-Methods: GET,POST,OPTIONS

    - Access-Control-Allow-Origin: *

- Click Enable CORS and replace existing CORS headers

- Deploy API (Step 7)

### 7️⃣ Deploy API

- Actions → Deploy API

- Deployment stage: prod

- Stage description: HR Secure API

- Deploy

#### Copy the Invoke URL. Example:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod
```

### 8️⃣ Test Each API Endpoint

> **We will test using Postman or Lambda Test Console.**

#### 8.1 Test /checkin (POST)

#### Request:

    - URL:

```
https://<API-ID>.execute-api.<region>.amazonaws.com/prod/checkin
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

#### 8.2 Test /checkout (POST)

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

#### 8.3 Test /employee/profile (GET)

- URL: /employee/profile

- Method: GET

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"name\": \"Alice\",\"job_title\": \"Barista\",\"salary\": 40000.0,\"start_date\": \"2025-12-01\"}"
}
```

#### 8.4 Test /attendance/history (GET)

- URL: /attendance/history

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "[{\"attendance_date\": \"2026-01-19\",\"checkin_time\": \"09:00:00\",\"checkout_time\": \"17:00:00\"}]"
}
```

#### 8.5 Test /leaves-holidays (GET)

- URL: /leaves-holidays

- Headers: Authorization: <Cognito JWT>

#### Expected Response:

```
{
  "statusCode": 200,
  "body": "{\"leaves\": [{\"leave_date\": \"2026-01-15\", \"leave_type\": \"Sick Leave\"}], \"holidays\": [{\"holiday_date\": \"2026-01-01\", \"description\": \"New Year\"}]}"
}
```

### 9️⃣ Verification Checklist

✅ All endpoints secured by Cognito JWT

✅ Lambda functions triggered via API Gateway

✅ RDS integration works for attendance, check-in/out, employee profile, leaves, holidays

✅ CORS enabled for frontend

✅ Can call endpoints from EC2 frontend or Postman


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 4️⃣ — Frontend Pages for HR System

We will create 3 main pages:

- Employee Check-In / Check-Out Page (Tablet / Employee)

- Employee Portal Page (Desktop / Employee)

- Admin Dashboard Page (Desktop / HR/Admin)

### 🔹 Step 0 — Assumptions

- Your EC2 Apache server is already hosting other café pages.

- Your API Gateway endpoints are ready (PART 3).

- Cognito User Pool exists, and employees/admin users are registered.

- We will use JavaScript fetch API to call API Gateway with JWT from Cognito.

> **Optional: We will use Bootstrap 5 for styling and responsive UI.**

### 1️⃣ Employee Check-In / Check-Out Page (Tablet Friendly)
> **📄 checkin.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/checkin.html
```

#### 2️⃣ checkin.html Code

[checkin.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT%20(single%20order))/order-receipt.php)

✅ This page allows employees to check in and check out and confirms success/failure messages.

### 2️⃣ Employee Portal Page
> **📄 employee-portal.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/employee-portal.html
```

#### 2️⃣ employee-portal.html Code

[employee-portal.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT%20(single%20order))/order-receipt.php)

✅ Employees can view profile, attendance, leaves, and holidays.

### 3️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)
> **📄 admin-dashboard.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/admin-dashboard.html
```

#### 2️⃣ admin-dashboard.html Code

[admin-dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT%20(single%20order))/order-receipt.php)

#### 3️⃣ Set permissions:

```
sudo chown apache:apache *.html
```

```
sudo chmod 644 *.html
```

#### 4️⃣ Open browser:

```
http://<EC2-Public-IP>/checkin.html
http://<EC2-Public-IP>/employee-portal.html
http://<EC2-Public-IP>/admin-dashboard.html
```

#### 5️⃣ Enter:

    - Valid employee ID → Check-In → ✅ success

    - Same ID again → backend should block duplicate

    - Check-Out after check-in → ✅ success

#### 6️⃣ Verify in RDS:

```
SELECT * FROM attendance ORDER BY attendance_date DESC;
```

### 4️⃣ — HOW LOGOUT INTEGRATES WITH COGNITO (STEP-BY-STEP)

#### 🧠 Step-by-Step Cognito Logout Flow

#### 1️⃣ Cognito keeps user session

When user logs in:

- ID Token

- Access Token

- Refresh Token

are stored by Cognito SDK in browser (local/session storage)

#### 2️⃣ This line logs the user out

```
user.signOut();
```

#### What happens:

- Tokens are removed

- Session invalidated

- getCurrentUser() returns null

#### 3️⃣ Protecting Pages (IMPORTANT)

On every protected page, you already do:

```
const user = userPool.getCurrentUser();
if (!user) {
    window.location.href = "login.html";
}
```

**👉 This prevents access after logout.**

#### 4️⃣ Redirect After Logout

```
window.location.href = "index.html";
```

You can redirect to:

- Login page

- Landing page

- Café homepage

#### 5️⃣ HOW TO TEST LOGOUT (VERIFICATION — VERY IMPORTANT)

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
> **Frontend & Backend Security, API Integration, and Role-Based UI (Production Ready)**

### 1️⃣ — CENTRAL CONFIG FILE (FRONTEND)

### 1️⃣ 📄 Create js/config.js

```
cd /var/www/html
```
```
sudo nano js/config.js
```

#### 2️⃣ Add this code

```
/* ======================================
   GLOBAL CONFIGURATION
   Charlie Café HR System
====================================== */

const CONFIG = {
    APP_NAME: "Charlie Café HR System",
    API_BASE: "https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod",

    COGNITO: {
        USER_POOL_ID: "us-east-1_XXXXXX",
        CLIENT_ID: "XXXXXXXXXXXX"
    }
};
```

#### 3️⃣ Permissions

```
sudo chown www-data:www-data js/config.js
```
```
sudo chmod 644 js/config.js
```

#### 4️⃣ ✅ Update auth-api.js to use config

#### Replace:

```
const poolData = {
    UserPoolId: 'us-east-1_XXXXXX',
    ClientId: 'XXXXXXXXXXXX'
};
```

#### With:

```
const poolData = {
    UserPoolId: CONFIG.COGNITO.USER_POOL_ID,
    ClientId: CONFIG.COGNITO.CLIENT_ID
};

const apiBase = CONFIG.API_BASE;
```

**📌 Now config changes need only ONE file**

### 2️⃣ Frontend  - auth-api.js
> **🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control**
> **➕ - A SHARED SCRIPT FILE (Recommanded)**

#### 🧱 PROPOSED FILE STRUCTURE (VERY IMPORTANT)

#### Create this structure:

```
/frontend
 ├── admin-dashboard.html
 ├── employee-portal.html
 ├── login.html
 ├── index.html
 └── js/
     └── auth-api.js   👈 (NEW SHARED FILE)
```

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

**📌 All Cognito + API + role logic goes into auth-api.js**

#### 🟢 STEP 1 — CREATE SHARED SCRIPT FILE
> **📄 js/auth-api.js (FINAL, PRODUCTION-READY)**

#### Assuming:

- Your Apache web root = /var/www/html

- Your project already exists

#### 1️⃣ Go to your web root

```
cd /var/www/html
```

#### 2️⃣ Create js folder (if not exists)

```
sudo mkdir -p js
```

#### 3️⃣ Create the shared file

```
sudo nano js/auth-api.js
```

#### 3️⃣ FINAL Updated AUTH-API.JS 
> **(includ config.j & ALL-IN-ONE)**

**👉 Paste your full auth-api.js code inside this file**
> **(save with CTRL+O, exit CTRL+X)**

```
/* =====================================================
   AUTH & API SHARED UTILITIES
   Charlie Café HR System
   - Used by Admin & Employee pages
   - Production hardened
===================================================== */

/* ===============================
   GLOBAL CONFIG (FROM config.js)
   IMPORTANT:
   config.js MUST be loaded BEFORE this file
================================ */
const poolData = {
    UserPoolId: CONFIG.COGNITO.USER_POOL_ID,
    ClientId: CONFIG.COGNITO.CLIENT_ID
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const apiBase = CONFIG.API_BASE;

/* ===============================
   PAGE PROTECTION
   Blocks unauthenticated users
================================ */
function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===============================
   GET JWT TOKEN (WITH EXPIRY CHECK)
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) {
            reject("No active session");
            return;
        }

        user.getSession((err, session) => {
            if (err || !session.isValid()) {
                alert("Session expired. Please login again.");
                user.signOut();
                window.location.href = "login.html";
                reject("Session expired");
                return;
            }

            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
   Automatically attaches JWT
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);

    if (!response.ok) {
        throw new Error("API request failed or unauthorized");
    }

    return response.json();
}

/* ===============================
   ROLE DETECTION FROM JWT
================================ */
async function getUserRoles() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) reject("No user");

        user.getSession((err, session) => {
            if (err) reject(err);

            const payload = session.getIdToken().decodePayload();
            resolve(payload["cognito:groups"] || []);
        });
    });
}

/* ===============================
   ADMIN UI ENFORCEMENT
================================ */
async function enforceAdminAccess() {
    const roles = await getUserRoles();

    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
        return;
    }

    const adminSection = document.getElementById("admin-section");
    if (adminSection) {
        adminSection.style.display = "block";
    }
}

/* ===============================
   EMPLOYEE UI ENFORCEMENT
================================ */
async function enforceEmployeeAccess() {
    const roles = await getUserRoles();

    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}

/* ===============================
   LOGOUT (COGNITO)
================================ */
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html";
}

/* ===============================
   GLOBAL ERROR HANDLER
================================ */
function handleError(error) {
    console.error("Application Error:", error);
    alert("Something went wrong. Please try again.");
}

/* ===============================
   LOADER (UX POLISH)
================================ */
function showLoader() {
    const loader = document.getElementById("loader");
    if (loader) loader.style.display = "block";
}

function hideLoader() {
    const loader = document.getElementById("loader");
    if (loader) loader.style.display = "none";
}

/* ===============================
   API USAGE EXAMPLES
================================ */

/* Employee Profile */
async function loadEmployeeProfile() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/employee/profile");

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
        document.getElementById("profile-salary").innerText = data.salary;
        document.getElementById("profile-start").innerText = data.start_date;
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}

/* Admin: Load All Employees */
async function loadAllEmployees() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/admin/employees");
        console.log("Employees:", data);
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}
```


#### 4️⃣ Set correct permissions

```
sudo chown -R www-data:www-data js
```
```
sudo chmod -R 755 js
```

✅ Apache can now read this file

✅ Secure & production-ready

### 3️⃣ Frontend → API Integration & Role-Based UI Control

#### 🟢 REQUIRED FILES STRUCTURE

```
/project-root
│
├── admin-dashboard.html
├── employee-portal.html
│
└── js/
    ├── config.js
    └── auth-api.js
```

#### 🟢 FINAL DIRECTORY CHECK

```
ls -l /var/www/html/js
```

#### You should see:

```
config.js
auth-api.js
```

#### Permissions should look like:

```
-rw-r--r--  config.js
```
```
-rwxr-xr-x  auth-api.js
```


#### 1️⃣ ADMIN PAGE (FINAL)
> **📄 admin-dashboard.html**

#### Add BEFORE </body>

```
<!-- Cognito SDK -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

<!-- Global Config -->
<script src="js/config.js"></script>

<!-- Shared Auth & API -->
<script src="js/auth-api.js"></script>

<script>
/* Protect page */
protectPage();

/* Enforce admin-only access */
enforceAdminAccess();

/* Optional admin API call */
async function loadAllEmployees() {
    const data = await secureFetch(apiBase + "/admin/employees");
    console.log("Employees:", data);
}
</script>

<!-- Admin-only UI -->
<div id="admin-section" style="display:none;">
    <button class="btn btn-warning">Manage Employees</button>
    <button class="btn btn-danger">View Payroll</button>
</div>

<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```

#### 2️⃣ EMPLOYEE PAGE (FINAL)
> **📄 employee-portal.html**

#### Add BEFORE </body>

```
<!-- Cognito SDK -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

<!-- Global Config -->
<script src="js/config.js"></script>

<!-- Shared Auth & API -->
<script src="js/auth-api.js"></script>

<script>
/* Protect page */
protectPage();

/* Enforce employee-only access */
enforceEmployeeAccess();

/* Load employee profile */
async function loadEmployeeProfile() {
    const data = await secureFetch(apiBase + "/employee/profile");

    document.getElementById("profile-name").innerText = data.name;
    document.getElementById("profile-job").innerText = data.job_title;
    document.getElementById("profile-salary").innerText = data.salary;
    document.getElementById("profile-start").innerText = data.start_date;
}

loadEmployeeProfile();
</script>

<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```

### 4️⃣ BACKEND  - Lambda 

#### 1️⃣ FINAL COMMON LAMBDA TEMPLATE (USE IN ALL 5)
> **This goes into EVERY HR & Attendance Lambda function.**

```
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Request received")
    logger.info(event)

    # -------------------------------
    # AUTHORIZATION (Cognito Groups)
    # -------------------------------
    claims = event['requestContext']['authorizer']['claims']
    groups = claims.get('cognito:groups', [])

    # -------------------------------
    # ROLE CHECK (CHANGE PER FUNCTION)
    # -------------------------------
    ALLOWED_ROLE = "Employee"   # or "Admin"

    if ALLOWED_ROLE not in groups:
        return {
            "statusCode": 403,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Forbidden"})
        }

    # -------------------------------
    # BUSINESS LOGIC (CHANGE PER FUNCTION)
    # -------------------------------
    # Example:
    # - Check-in
    # - Check-out
    # - Fetch attendance
    # - Fetch employees
    # - Fetch leaves

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Success"})
    }
```

**✅ Use this template in all Lambda functions and only adjust the logic for checkin/checkout vs admin/employee.**

#### 2️⃣ HOW TO APPLY THIS TO EACH LAMBDA

#### 1️⃣ Check-In Lambda

```
ALLOWED_ROLE = "Employee"
# Insert check-in record
```

#### 2️⃣ Check-Out Lambda

```
ALLOWED_ROLE = "Employee"
# Update checkout time
```

#### 3️⃣ Employee Info Lambda

```
ALLOWED_ROLE = "Employee"
# Select leaves + holidays
```

#### 4️⃣ Leaves & Holidays Lambda

```
ALLOWED_ROLE = "Employee"
# Select leaves + holidays
```

5️⃣ Admin Employees Lambda

```
ALLOWED_ROLE = "Admin"
# Select all employees
```

**📌 Nothing else changes.**

#### 3️⃣ — PERFORMANCE & SAFETY SETTINGS

#### ✅ Lambda

- Timeout: 10 seconds

- Memory: 512 MB

- Enable X-Ray tracing

#### ✅ API Gateway

- Enable Access Logging

- Enable Execution Logs

- Throttle (optional):

    - 10 req/sec

    - Burst 20

### 5️⃣ — FULL TEST & VERIFICATION (NO SKIP)

#### 🧪 TEST 1️⃣ — Browser Console

1️⃣ Open DevTools → Console

2️⃣ You should NOT see:

```
CONFIG is not defined
```

#### 🧪 TEST 2️⃣ — Employee Normal Flow

1️⃣ Login as Employee

2️⃣ Open employee portal

3️⃣ Profile loads

4️⃣ Attendance loads

5️⃣ Admin buttons NOT visible

✅ PASS

#### 🧪 TEST 3️⃣ — Employee Tries Admin URL

1️⃣ Login as Employee

2️⃣ Open admin-dashboard.html manually

❌ Access denied

✅ Redirect to login

#### 🧪 TEST 4️⃣ — Admin Normal Flow

1️⃣ Login as Admin

2️⃣ Open admin dashboard

3️⃣ Admin buttons visible

4️⃣ Employee list loads

✅ PASS

#### 🧪 TEST 5️⃣ — JWT Verification

1️⃣ Open DevTools → Network

2️⃣ Click any API call

3️⃣ Check Headers

#### You MUST see:

```
Authorization: eyJraWQiOiJ...
```

✅ Token attached

✅ Cognito authorizer working

#### 🧪 TEST 6️⃣ — API Protection

1️⃣ Copy API URL

2️⃣ Open in browser without token

❌ 401 / 403 error

✅ Secure

#### 🧪 TEST 7️⃣ — Authentication

- Token expires → auto logout

- Logout destroys session

- Back button blocked

#### 🧪 TEST 8️⃣  Authorization

Admin cannot be Employee

Employee cannot be Admin

Backend blocks unauthorized API calls

#### 🧪 TEST 9️⃣ UX

Loader visible

Errors friendly

No raw error messages

#### 🧪 TEST 🔟 Observability

CloudWatch logs visible

Errors traceable

Requests traceable

#### 🧪 TEST 1️⃣1️⃣ Token Expiry

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

### 1️⃣ — Database Preparation (RDS)

We need to ensure our database has the right structure for analytics.

#### 1️⃣ Tables Needed

You already have:

- **employees (employee_id, name, job_title, salary, start_date)**

- **attendance (attendance_id, employee_id, date, checkin_time, checkout_time)**

#### 2️⃣ Verify / Add Index for Fast Queries

#### Run this SQL on your RDS (MySQL example):

```
-- Index for faster aggregation
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
```

**✅ Purpose: Queries for daily, weekly, monthly summaries will be faster.**

### 2️⃣ — Lambda Functions

We will create 3 separate Lambda functions:

- attendance_daily_summary

- attendance_weekly_summary

- attendance_monthly_summary

All will query RDS and return JSON data to API Gateway.

#### 1️⃣ — Daily Attendance Lambda
> **📄 Filename: attendance_daily_summary.py**

```
import json
import pymysql
import os
from datetime import date

# Database configuration (set in Lambda environment variables)
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # Get today's date
        today = date.today().strftime('%Y-%m-%d')
        
        # SQL query: daily attendance
        sql = """
            SELECT e.employee_id, e.name, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE a.date = %s
        """
        cursor.execute(sql, (today,))
        result = cursor.fetchall()
        
        return {
            'statusCode': 200,
            'body': json.dumps({'date': today, 'attendance': result})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()
```

#### 2️⃣ — Weekly Attendance Lambda
> **📄 Filename: attendance_weekly_summary.py**

```
import json
import pymysql
import os
from datetime import date, timedelta

DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # Get last 7 days
        today = date.today()
        week_ago = today - timedelta(days=6)
        
        sql = """
            SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE a.date BETWEEN %s AND %s
            ORDER BY a.date ASC
        """
        cursor.execute(sql, (week_ago, today))
        result = cursor.fetchall()
        
        return {
            'statusCode': 200,
            'body': json.dumps({'start_date': str(week_ago), 'end_date': str(today), 'attendance': result})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()
```

#### 3️⃣ — Monthly Attendance Lambda
> **📄 Filename: attendance_monthly_summary.py**

```
import json
import pymysql
import os
from datetime import date

DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # First and last day of current month
        today = date.today()
        start_month = today.replace(day=1)
        end_month = today
        
        sql = """
            SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE a.date BETWEEN %s AND %s
            ORDER BY a.date ASC
        """
        cursor.execute(sql, (start_month, end_month))
        result = cursor.fetchall()
        
        return {
            'statusCode': 200,
            'body': json.dumps({'start_date': str(start_month), 'end_date': str(end_month), 'attendance': result})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()
```

### 3️⃣ — Lambda Environment Variables

Set the following for all three Lambdas:

| Key         | Value                 |
| ----------- | --------------------- |
| DB_HOST     | `<your-RDS-endpoint>` |
| DB_USER     | `<your-RDS-username>` |
| DB_PASSWORD | `<your-RDS-password>` |
| DB_NAME     | `cafedb`              |

**✅ Purpose: Lambda connects securely to RDS without hardcoding credentials.**

### 4️⃣ — API Gateway Setup

- Open API Gateway → Existing API (used for HR system)

- Create new resources:

| Resource                    | Method | Lambda Integration           |
| --------------------------- | ------ | ---------------------------- |
| `/admin/attendance/daily`   | GET    | `attendance_daily_summary`   |
| `/admin/attendance/weekly`  | GET    | `attendance_weekly_summary`  |
| `/admin/attendance/monthly` | GET    | `attendance_monthly_summary` |

- Enable Cognito Authorizer for all three endpoints

- Enable CORS → Allow origin: * (or your EC2 frontend)

- Deploy API → Stage: prod

### 5️⃣ — Frontend Integration (Admin Dashboard)


#### 1️⃣ — HTML Buttons (Admin Dashboard)

```
<div id="admin-attendance-summary">
    <button class="btn btn-info" onclick="loadDailySummary()">Daily</button>
    <button class="btn btn-warning" onclick="loadWeeklySummary()">Weekly</button>
    <button class="btn btn-success" onclick="loadMonthlySummary()">Monthly</button>
</div>

<div id="summary-result">
    <!-- Summary Table will be populated here -->
</div>
```

#### 2️⃣ — Shared Script Functions (auth-api.js or separate admin.js)

```
// Load Daily Attendance
async function loadDailySummary() {
    const data = await secureFetch(apiBase + "/admin/attendance/daily");
    displaySummary(data.attendance);
}

// Load Weekly Attendance
async function loadWeeklySummary() {
    const data = await secureFetch(apiBase + "/admin/attendance/weekly");
    displaySummary(data.attendance);
}

// Load Monthly Attendance
async function loadMonthlySummary() {
    const data = await secureFetch(apiBase + "/admin/attendance/monthly");
    displaySummary(data.attendance);
}

// Display function
function displaySummary(records) {
    const container = document.getElementById("summary-result");
    let html = `<table class="table table-striped">
                    <tr>
                        <th>Employee ID</th>
                        <th>Name</th>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>`;
    records.forEach(r => {
        html += `<tr>
                    <td>${r.employee_id}</td>
                    <td>${r.name}</td>
                    <td>${r.date}</td>
                    <td>${r.checkin_time}</td>
                    <td>${r.checkout_time}</td>
                 </tr>`;
    });
    html += `</table>`;
    container.innerHTML = html;
}
```

### 6️⃣ — Testing & Verification

#### 1️⃣ . Lambda Test

- Open each Lambda in AWS Console

- Click Test → Use Empty JSON {}

- Check JSON output → Should return today/weekly/monthly attendance

#### 2️⃣ . API Gateway Test

- Open API Gateway Console → Resource → GET /admin/attendance/daily

- Click Test → Should return JSON array of attendance

- Repeat for weekly & monthly

#### 3️⃣ . Admin Frontend Test

- Login as Admin → Open Dashboard

- Click Daily / Weekly / Monthly buttons

- Check that table populates correctly

- Verify that non-admin users cannot see these buttons or API data

**✅ After this, Admin Attendance Analytics will be fully functional — daily, weekly, monthly summaries with frontend display.**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 7️⃣ — ADMIN DASHBOARD ENHANCEMENTS

STEP 1 — Database & Backend Preparation
1️⃣ Verify RDS Tables

You already have:

employees (employee_id, name, job_title)

attendance (attendance_id, employee_id, date, checkin_time, checkout_time)

leaves (leave_id, employee_id, leave_date, leave_type)

✅ No changes needed here; all data is ready for filtering and summary.

2️⃣ Optional: Add Indexes (Performance)

```
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_leaves_employee_date ON leaves(employee_id, leave_date);
```

✅ Purpose: Fast filtering by employee and date.

STEP 2 — Lambda Functions for Admin Dashboard Enhancements

We will create one main Lambda that supports filtering and summary cards.

Filename: admin_dashboard_data.py

```
import json
import pymysql
import os
from datetime import date

# RDS connection details from Lambda environment variables
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def lambda_handler(event, context):
    """
    Returns:
    - Filtered attendance records (optionally by employee_id)
    - Summary counts: total present, absent, leaves
    """

    # Optional query parameter for employee filtering
    employee_id = event.get('queryStringParameters', {}).get('employee_id')

    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        cursor = connection.cursor(pymysql.cursors.DictCursor)

        # 1️⃣ Attendance Records
        if employee_id:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE e.employee_id = %s
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance, (employee_id,))
        else:
            sql_attendance = """
                SELECT a.date, e.employee_id, e.name, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                ORDER BY a.date DESC
            """
            cursor.execute(sql_attendance)

        attendance_records = cursor.fetchall()

        # 2️⃣ Summary Cards
        sql_summary = """
            SELECT 
                COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN a.employee_id END) AS total_present,
                COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN a.employee_id END) AS total_absent,
                (SELECT COUNT(*) FROM leaves) AS total_leaves
            FROM employees e
            LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
        """
        cursor.execute(sql_summary)
        summary = cursor.fetchone()

        return {
            'statusCode': 200,
            'body': json.dumps({'attendance': attendance_records, 'summary': summary})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        cursor.close()
        connection.close()
```

✅ This Lambda:

Supports optional employee filter

Returns attendance records + summary cards (present / absent / leaves)

STEP 3 — API Gateway Integration

Open API Gateway → Existing HR API

Create Resource: /admin/dashboard

Method: GET → Lambda integration → admin_dashboard_data

Enable Cognito Authorizer → Admin-only access

Enable CORS → Allowed origin: your EC2 frontend

Deploy → Stage: prod

STEP 4 — Admin Frontend — HTML Enhancements
4️⃣1 — Add Filter Dropdown & Summary Cards

```
<div class="container my-4">
    <!-- Summary Cards -->
    <div class="row mb-3">
        <div class="col-md-4">
            <div class="card bg-success text-white p-3">
                <h5>Total Present</h5>
                <p id="card-present">0</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-danger text-white p-3">
                <h5>Total Absent</h5>
                <p id="card-absent">0</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-warning text-dark p-3">
                <h5>Total Leaves</h5>
                <p id="card-leaves">0</p>
            </div>
        </div>
    </div>

    <!-- Employee Filter -->
    <div class="row mb-3">
        <div class="col-md-6">
            <label for="employeeFilter" class="form-label">Filter by Employee</label>
            <select id="employeeFilter" class="form-select" onchange="loadDashboardData()">
                <option value="">All Employees</option>
                <!-- Employee options populated dynamically -->
            </select>
        </div>
    </div>

    <!-- Attendance Table -->
    <div id="dashboard-table-container"></div>

    <!-- Export Button -->
    <button class="btn btn-primary mt-3" onclick="exportCSV()">Export CSV</button>
</div>
```

STEP 5 — Admin Frontend — JS Functions

Add these to your shared script (admin.js or auth-api.js):

```
// Load Employee Filter Options
async function loadEmployeeFilter() {
    const employees = await secureFetch(apiBase + "/admin/employees");
    const select = document.getElementById("employeeFilter");
    employees.forEach(emp => {
        const option = document.createElement("option");
        option.value = emp.employee_id;
        option.text = emp.name;
        select.add(option);
    });
}

// Load Dashboard Data
async function loadDashboardData() {
    const empId = document.getElementById("employeeFilter").value;
    let url = apiBase + "/admin/dashboard";
    if (empId) url += "?employee_id=" + empId;

    const data = await secureFetch(url);

    // Populate summary cards
    document.getElementById("card-present").innerText = data.summary.total_present;
    document.getElementById("card-absent").innerText = data.summary.total_absent;
    document.getElementById("card-leaves").innerText = data.summary.total_leaves;

    // Populate attendance table
    const container = document.getElementById("dashboard-table-container");
    let html = `<table class="table table-striped table-bordered">
                    <tr>
                        <th>Employee ID</th>
                        <th>Name</th>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>`;
    data.attendance.forEach(r => {
        html += `<tr>
                    <td>${r.employee_id}</td>
                    <td>${r.name}</td>
                    <td>${r.date}</td>
                    <td>${r.checkin_time}</td>
                    <td>${r.checkout_time}</td>
                 </tr>`;
    });
    html += `</table>`;
    container.innerHTML = html;
}

// Export CSV Function
function exportCSV() {
    const table = document.querySelector("#dashboard-table-container table");
    let csv = [];
    for (let row of table.rows) {
        let cols = Array.from(row.cells).map(cell => '"' + cell.innerText + '"');
        csv.push(cols.join(","));
    }
    const csvContent = "data:text/csv;charset=utf-8," + csv.join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "attendance_dashboard.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// Initialize dashboard
async function initAdminDashboard() {
    await loadEmployeeFilter();
    await loadDashboardData();
}

initAdminDashboard();
```

✅ What this JS does:

Populates employee dropdown dynamically

Fetches attendance + summary cards

Filters by employee

Exports table as CSV

STEP 6 — Testing & Verification

Login as Admin → Open Dashboard

Check Summary Cards → Total Present / Absent / Leaves

Filter by Employee → Table updates

Export CSV → Open downloaded file, verify data matches table

Unauthorized Access Test → Employee account cannot see dashboard or API results

🎯 Outcome:

Admin dashboard now has employee-wise filtering

Export-ready table via CSV

Summary cards for quick metrics

Fully integrated with existing Lambda + RDS

Fully job-ready


**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 8️⃣ — Update Cafe Security Configuration

### 1️⃣ — EC2 Frontend Security Group

#### 1️⃣ Identify your EC2 SG

- Go to EC2 → Instances → Select your frontend EC2.

- Scroll to Security → Security groups → Click on SG name.

- Note Inbound and Outbound rules.

#### 2️⃣  EC2 Inbound Rules

- SSH (optional, admin only)

    - Type: SSH

    - Protocol: TCP

    - Port: 22

    - Source: Your IP only (example: 203.0.113.25/32)

- HTTP / HTTPS (frontend access)

    - Type: HTTP → Port 80 → Source: 0.0.0.0/0

    - Type: HTTPS → Port 443 → Source: 0.0.0.0/0

#### Document in a table like this:

| Port | Protocol | Source    | Purpose      |
| ---- | -------- | --------- | ------------ |
| 22   | TCP      | Your IP   | SSH Admin    |
| 80   | TCP      | 0.0.0.0/0 | Frontend Web |
| 443  | TCP      | 0.0.0.0/0 | Frontend Web |

#### 3️⃣  EC2 Outbound Rules

- Usually default is All traffic → 0.0.0.0/0.

- If restrictive, ensure outbound allows Lambda to connect to EC2 if needed, e.g., API calls.

### 2️⃣  Lambda Security Group

#### 1️⃣ Identify Lambda SG

- Go to Lambda → Functions → Your Lambda → Configuration → VPC.

- Check VPC / Subnets / Security Groups.

- Lambda must have an SG that allows outbound to RDS SG on the database port (default MySQL 3306 or Postgres 5432).

#### 2️⃣  Lambda Outbound Rule

- Type: MySQL/Aurora (or Postgres)

- Protocol: TCP

- Port: 3306 (or 5432)

- Destination: RDS SG ID

> **Lambda should not allow 0.0.0.0/0 outbound to database — security best practice.**

### 3️⃣ RDS Security Group

#### 1️⃣ Identify RDS SG

- Go to RDS → Databases → Select your DB → Connectivity & security → VPC security groups.

#### 2️⃣ RDS Inbound Rules

- Allow access only from Lambda SG:

    - Type: MySQL/Aurora (or Postgres)

    - Protocol: TCP

    - Port: 3306 (or 5432)

    - Source: Lambda SG ID

#### Example Table:

| Port | Protocol | Source    | Purpose               |
| ---- | -------- | --------- | --------------------- |
| 3306 | TCP      | Lambda SG | Lambda DB Access Only |

#### 3️⃣ RDS Outbound Rules

- Usually default “All traffic → 0.0.0.0/0” is fine.

- No need to modify if DB is only accessed by Lambda.

### 4️⃣ — Verification Steps

- EC2 Verification

    - Try connecting via SSH from your IP → should work.

    - Access frontend in browser → should work.

- Lambda Verification

    - Test Lambda function in AWS console.

    - Ensure it can connect to RDS (e.g., query SELECT 1).

- RDS Verification

    - Check Connectivity & Security → VPC security groups.

    - Optional: Test from another EC2 → should fail if SG is correct.

### 5️⃣ — Documentation for Audit

- Create a security document (Markdown or Excel) listing:

    - All SG names

    - Inbound/outbound rules

    - Purpose for each rule

#### Example Markdown snippet:

```
# Security Group Documentation

## EC2 Frontend SG
- Port 22 (SSH) → Your IP
- Port 80 (HTTP) → 0.0.0.0/0
- Port 443 (HTTPS) → 0.0.0.0/0

## Lambda SG
- Outbound → RDS SG: 3306/TCP

## RDS SG
- Inbound → Lambda SG: 3306/TCP
```

#### ✅ Result:

- Your environment is now locked down.

- Only Lambda can access the database.

- Frontend EC2 is secure for admin & public traffic.


**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 9️⃣ — Minor UX / UI Polish
> **🌐 (Optional but Professional)**

Step 5.1 — Choose Toast Notification Method
✅ Recommended (No Library)

Pure HTML + CSS + JavaScript

Lightweight

Works everywhere

Perfect for labs & production

(We will use this)

Step 5.2 — Add Toast HTML (ONE TIME ONLY)

Add this once near the end of your HTML body (Admin / Check-in / Checkout pages):

```
<!-- Toast Container -->
<div id="toast-container"></div>
```

Step 5.3 — Add Toast CSS (GLOBAL)

Add this inside your main CSS file or <style> tag:

```
#toast-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
}

.toast {
    min-width: 250px;
    margin-bottom: 10px;
    padding: 15px 20px;
    border-radius: 6px;
    color: #fff;
    font-size: 14px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    animation: slideIn 0.4s ease, fadeOut 0.4s ease 3s forwards;
}

.toast-success { background-color: #28a745; }
.toast-error { background-color: #dc3545; }
.toast-info { background-color: #007bff; }

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

@keyframes fadeOut {
    to { opacity: 0; transform: translateX(100%); }
}
```

Step 5.4 — Add Toast JavaScript (GLOBAL FUNCTION)

Add this once in your main JS file:

```
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerText = message;

    container.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3500);
}
```

Step 5.5 — Replace alert() in Your Code
❌ Old (Bad UX)

```
alert("Check-in successful");
```

✅ New (Professional UX)

```
showToast("Check-in successful", "success");
```

Step 5.6 — Apply to Holiday Admin Page
Add Success Message

```
await fetch(apiUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ holidayId, name, date })
});

showToast("Holiday saved successfully", "success");
fetchHolidays();
```

Add Error Handling

```
try {
    const res = await fetch(apiUrl);
    if (!res.ok) throw new Error("Failed to fetch holidays");
    const data = await res.json();
} catch (err) {
    showToast(err.message, "error");
}
```

Step 5.7 — Apply to Check-In / Check-Out Pages
Check-In Example

```
try {
    const response = await fetch(checkInApi, { method: 'POST' });

    if (!response.ok) throw new Error("Check-in failed");

    showToast("Checked in successfully", "success");
} catch (error) {
    showToast(error.message, "error");
}
```

Check-Out Example

```
showToast("Checked out successfully", "success");
```

Step 5.8 — Add Loading State (Professional Touch)
HTML Button

```
<button id="checkInBtn">Check In</button>
```

JS

```
const btn = document.getElementById('checkInBtn');
btn.disabled = true;
btn.innerText = "Processing...";

await fetch(checkInApi);

btn.disabled = false;
btn.innerText = "Check In";
```

Step 5.9 — Improve Error Messages (Human Friendly)

❌ Bad:

```
Error 500
```

✅ Good:

```
Unable to process request. Please try again.
```

Example:

```
catch {
    showToast("Something went wrong. Please try again.", "error");
}
```





**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 🔟 — Update CafePDFReportLambda for HR & Attendance

### 📃 Research and Development (Just for CaseStudy)

#### 1️⃣ Can we reuse the existing PDF Lambda?

✅ Yes, you can reuse it, because:

- Your current Lambda already:

    - Generates a PDF using ReportLab

    - Uploads it to S3

    - Handles dynamic content based on page_type

- It’s generic enough to handle any tabular report, including attendance or employee reports

- It already has environment variables for S3 bucket and files, so you don’t need a new Lambda for PDF generation unless you want totally separate deployment for HR.

#### 2️⃣ How to integrate HR/Attendance into existing Lambda

#### Step 1: Add a new page_type for HR

#### In your Lambda:

```
page_type = event.get("queryStringParameters", {}).get("page", "analytics")
```

- Right now it checks "analytics" or "order-status"

- We can add "attendance":

```
elif page_type == "attendance":
    elements.append(Paragraph("📋 Employee Attendance Report", styles["Title"]))
    elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
    elements.append(Spacer(1, 15))

    # Fetch attendance data from RDS
    import pymysql

    connection = pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASS'],
        database=os.environ['DB_NAME'],
        cursorclass=pymysql.cursors.DictCursor
    )

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT e.name, e.job_title, a.attendance_date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            ORDER BY a.attendance_date DESC
        """)
        records = cursor.fetchall()

    table_data = [["Employee", "Job Title", "Date", "Check-In", "Check-Out"]]
    for r in records:
        table_data.append([
            r["name"],
            r["job_title"],
            str(r["attendance_date"]),
            str(r.get("checkin_time") or ""),
            str(r.get("checkout_time") or "")
        ])

    table = Table(table_data, colWidths=[120, 100, 80, 60, 60])
    table.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,0), colors.darkgreen),
        ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
        ("ALIGN", (0,0), (-1,-1), "CENTER"),
        ("GRID", (0,0), (-1,-1), 0.5, colors.black),
        ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
    ]))

    elements.append(table)
```

#### Step 2: Add HR-specific environment variables

- DB_HOST → RDS endpoint

- DB_NAME → cafedb

- DB_USER / DB_PASS → credentials

- S3 bucket can remain the same (or use a new folder hr/attendance/ for organization)

#### Step 3: Use page=attendance in your API call

Example URL from frontend:

```
https://<your-api-gateway>/generate-pdf?page=attendance
```

- Lambda will detect page_type="attendance" and generate Attendance PDF

- No need for new Lambda function

- You save time and resources

#### ✅ My Recommendation (Time-Saving, Professional)

- Do not create a new Lambda for PDF yet

- Use your existing PDF Lambda

- Just add a new page_type branch for "attendance" (and optionally "employee-profile" if needed)

- Hook your HR Lambda data (attendance, leaves, profile) via RDS queries inside this branch

#### This way:

- 1 Lambda handles all PDF generation

- No duplication

- Easy maintenance

---

### 1️⃣ Step 1️⃣ – Update CafePDFReportLambda for HR & Attendance

> *8We are going to add a new page_type branch for HR/Attendance reports.**

#### Updated Lambda Code

```
import os
import boto3
import io
import datetime
import pymysql  # Required for RDS access
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# =======================
# ENVIRONMENT VARIABLES
# =======================
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")  # Existing DynamoDB orders table
REPORTS_BUCKET_NAME = os.environ.get("REPORTS_BUCKET_NAME")  # S3 bucket for storing PDFs
LOGO_FILE_NAME = os.environ.get("LOGO_FILE_NAME", "")  # Optional logo file
DB_HOST = os.environ.get("DB_HOST")  # RDS endpoint for HR/Attendance
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")

# =======================
# AWS CLIENTS
# =======================
dynamodb = boto3.resource("dynamodb")
orders_table = dynamodb.Table(ORDERS_TABLE_NAME)
s3 = boto3.client("s3")

# =======================
# DATABASE CONNECTION
# =======================
def get_db_connection():
    """Return a pymysql connection to RDS"""
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    """Main Lambda Handler"""
    
    # Determine type of report to generate
    page_type = event.get("queryStringParameters", {}).get("page", "analytics")
    today = datetime.date.today()

    # PDF buffer setup
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=40)
    styles = getSampleStyleSheet()
    elements = []

    # =======================
    # LOGO (OPTIONAL)
    # =======================
    if LOGO_FILE_NAME:
        try:
            elements.append(Image(LOGO_FILE_NAME, width=120, height=60))
            elements.append(Spacer(1, 20))
        except:
            pass

    # =======================
    # CAFE SALES ANALYTICS PDF
    # =======================
    if page_type == "analytics":
        elements.append(Paragraph("📊 Cafe Sales Analytics Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))
        total_sales = 12000
        total_cost = 8000
        profit = total_sales - total_cost
        data = [
            ["Metric", "Amount"],
            ["Total Sales", total_sales],
            ["Total Cost", total_cost],
            ["Profit", profit]
        ]
        table = Table(data, colWidths=[200, 150])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.brown),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 1, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.beige)
        ]))
        elements.append(table)

    # =======================
    # ORDER STATUS PDF
    # =======================
    elif page_type == "order-status":
        elements.append(Paragraph("📝 Cafe Order Status Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))
        orders = orders_table.scan().get("Items", [])
        table_data = [["Order ID", "Item", "Qty", "Cost", "Price", "Profit"]]
        for o in orders:
            qty = int(o.get("quantity", 1))
            cost = float(o.get("item_cost", 0)) * qty
            price = float(o.get("item_price", 0)) * qty
            profit = price - cost
            table_data.append([
                o.get("order_id"),
                o.get("item_name"),
                qty,
                cost,
                price,
                profit
            ])
        table = Table(table_data, colWidths=[80, 110, 50, 60, 60, 60])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.darkblue),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 0.5, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
        ]))
        elements.append(table)

    # =======================
    # HR & ATTENDANCE PDF
    # =======================
    elif page_type == "attendance":
        elements.append(Paragraph("📋 Employee Attendance Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        # Connect to RDS and fetch attendance & employee data
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT e.name, e.job_title, a.attendance_date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                ORDER BY a.attendance_date DESC
            """)
            records = cursor.fetchall()

        # Create table data
        table_data = [["Employee", "Job Title", "Date", "Check-In", "Check-Out"]]
        for r in records:
            table_data.append([
                r["name"],
                r["job_title"],
                str(r["attendance_date"]),
                str(r.get("checkin_time") or ""),
                str(r.get("checkout_time") or "")
            ])

        # Format table
        table = Table(table_data, colWidths=[120, 100, 80, 60, 60])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.darkgreen),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 0.5, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
        ]))
        elements.append(table)

    # =======================
    # BUILD PDF
    # =======================
    doc.build(elements)
    buffer.seek(0)

    # Upload to S3
    s3_key = f"{page_type}_report_{today}.pdf"
    s3.put_object(
        Bucket=REPORTS_BUCKET_NAME,
        Key=s3_key,
        Body=buffer.getvalue(),
        ContentType="application/pdf"
    )

    # Return PDF as response (for testing)
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode("latin1"),
        "isBase64Encoded": False
    }
```

#### ✅ What changed / added:

- Added elif page_type == "attendance"

    - Queries RDS attendance & employees table

    - Generates a table PDF

- Added pymysql connection inside Lambda (environment variables required)

Fully commented code

- No other code changes, still handles analytics and order-status

### 2️⃣ Step 2️⃣ – Verify & Test Your HR Lambdas with PDF

#### 1️⃣ A) Quick Unit Test (Lambda Console)

- Go to AWS Lambda → CafePDFReportLambda → Test

#### 2️⃣ Sample test event:

#### 1️⃣ attendance test event

```
{
  "queryStringParameters": {
    "page": "attendance"
  }
}
```
#### Expected Result:
- Lambda generates Employee Attendance PDF using RDS attendance + employees table

#### PDF includes:

    - Title: 📋 Employee Attendance Report

    - Generated date

    - Table with attendance records:
```
Employee | Job Title | Date       | Check-In | Check-Out
Alice    | Barista   | 2026-01-19 | 09:00    | 17:00
Bob      | Manager   | 2026-01-19 | 08:50    | 16:50
...      | ...       | ...        | ...      | ...
```
- Sorted by attendance_date DESC (most recent first)

#### PDF is:

    - Stored in S3 bucket: attendance_report_<today>.pdf

    - Returned in Lambda response body

**✅ StatusCode 200, PDF content returned**

#### 2️⃣ analytics test event

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### Expected Result:

- Lambda generates a PDF for Cafe Sales Analytics

#### PDF includes:

    - Title: 📊 Cafe Sales Analytics Report

    - Generated date (today)

    - Table with:

```
Metric       | Amount
Total Sales  | 12000
Total Cost   | 8000
Profit       | 4000
```

#### PDF is:

    - Stored in S3 bucket: analytics_report_<today>.pdf

    - Returned in Lambda response body (as Base64-ish content, decoded in console)

**✅ Success: StatusCode 200, PDF content returned**

#### 3️⃣ order-status test event

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```
#### Expected Result:

- Lambda generates Order Status PDF using DynamoDB ORDERS_TABLE_NAME

- PDF includes:

    - Title: 📝 Cafe Order Status Report

    - Generated date

    - Table with order details:
```
Order ID | Item | Qty | Cost | Price | Profit
```

#### Each row shows:

    - order_id

    - item_name

    - quantity

    - item_cost

    - item_price

    - calculated profit

#### PDF is:

    - Stored in S3 bucket: order-status_report_<today>.pdf

    - Returned in Lambda response body

**✅ Success: StatusCode 200, PDF content returned**

#### 4️⃣ Notes for All Tests

- If S3 bucket is missing, Lambda will throw a NoSuchBucket error

- If RDS is inaccessible, the "attendance" test will fail

- The PDF content returned in Lambda console is not human-readable (binary-ish), but downloading from S3 will give a normal PDF

- All tests should return HTTP statusCode 200 if everything is correct

##### ✅ In short:
| Page Type      | PDF Contents                                     | S3 File Name                    | StatusCode |
| -------------- | ------------------------------------------------ | ------------------------------- | ---------- |
| `analytics`    | Cafe sales metrics table                         | analytics_report_<today>.pdf    | 200        |
| `order-status` | Order table from DynamoDB                        | order-status_report_<today>.pdf | 200        |
| `attendance`   | Attendance table from RDS (employees+attendance) | attendance_report_<today>.pdf   | 200        |

**✅ This is enough — Lambda will handle the correct report.**

#### 2️⃣ B) Test Individual HR Lambda Functions

- hr-checkin → Invoke test with Cognito JWT in event

- hr-checkout → Invoke test after check-in

- hr-employee-profile → Should return employee info

- hr-attendance-history → Should return attendance records

- hr-leaves-holidays → Should return leaves + holidays

#### Tips:

Use Lambda console → Test events → Include requestContext.authorizer.claims.sub as a dummy Cognito user ID

#### Example:

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

- Check logs in CloudWatch → Lambda → Logs if errors occur.

#### 3️⃣ C) Verify PDF Integration

- After generating some attendance records:

    - hr-checkin and hr-checkout must have created today’s attendance

- Invoke CafePDFReportLambda with page=attendance

- Download PDF from S3 bucket → Verify:

    - Employee name

    - Job title

    - Check-in time

    - Check-out time

### ✅ After this step:

- Your HR & Attendance system is fully integrated with PDF generation

- No need for a new PDF Lambda

- All Lambda functions are ready for API Gateway integration


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — ☕ Charlie Café – Lambda Verification & Testing






**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — ☕ Charlie Café – Lambda Verification & Testing

#### We are testing all 5 HR Lambdas:

- hr-checkin

- hr-checkout

- hr-employee-profile

- hr-attendance-history

- hr-leaves-holidays

### ⚡ Pre-requisite

- You have test employee in RDS (employees table)

- You have Cognito user ID for test (can use any existing Cognito user in your pool)

- You have DB credentials in Lambda env variables

- You can open Lambda console

### 1️⃣ Testing hr-checkin

#### Step 1: Open Lambda

- AWS Console → Lambda → hr-checkin → Test tab

#### Step 2: Create Test Event

- Click Configure test event

- Event template: API Gateway AWS Proxy

- Event name: test-checkin

- Replace body with minimal event (simulated API Gateway + Cognito JWT):

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

> **Note: Replace "TEMP-COGNITO-ID" with actual Cognito sub from your test user.**

#### Step 3: Run Test

- Click Test

- Check Execution result

#### ✅ Expected:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-in successful\"}"
}
```

#### Step 4: Verify DB

```
SELECT * FROM attendance WHERE employee_id=1 AND attendance_date=CURDATE();
```

- You should see today’s check-in timestamp

- If IntegrityError occurs → already checked-in → remove row and retest

### 2️⃣ Testing hr-checkout

#### Step 1: Open Lambda → hr-checkout → Test tab

#### Step 2: Create Test Event

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

#### Step 3: Run Test

- Click Test

- Check Execution result

#### ✅ Expected:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```

#### Step 4: Verify DB

```
SELECT * FROM attendance WHERE employee_id=1 AND attendance_date=CURDATE();
```

- Check that checkout_time is filled

- If no check-in exists → error 400 as expected

### 3️⃣ Testing hr-employee-profile

#### Step 1: Open Lambda → hr-employee-profile → Test tab

#### Step 2: Test Event

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

#### Step 3: Run Test

#### ✅ Expected result:

```
{
  "name": "Alice",
  "job_title": "Barista",
  "salary": 40000,
  "start_date": "2025-12-01"
}
```

- Verify matches RDS record

### 4️⃣ Testing hr-attendance-history

#### Step 1: Open Lambda → hr-attendance-history → Test tab

#### Step 2: Test Event

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

#### Step 3: Run Test

#### ✅ Expected result:

```
[
  {
    "attendance_date": "2026-01-19",
    "checkin_time": "09:00:00",
    "checkout_time": "17:00:00"
  },
  ...
]
```

- Cross-check with attendance table

- Ensure dates & times match

### 5️⃣ Testing hr-leaves-holidays

#### Step 1: Open Lambda → hr-leaves-holidays → Test tab

#### Step 2: Test Event

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

#### Step 3: Run Test

#### ✅ Expected result:

```
{
  "leaves": [
    {"leave_date": "2026-01-15", "leave_type": "Sick Leave"}
  ],
  "holidays": [
    {"holiday_date": "2026-01-01", "description": "New Year"}
  ]
}
```

- Cross-check leaves table and holidays table

### ⚠ Notes & Common Issues

| Problem                    | Fix                                                             |
| -------------------------- | --------------------------------------------------------------- |
| `Employee not found`       | Check `cognito_user_id` matches RDS `employees.cognito_user_id` |
| `Access denied to DB`      | Check Lambda SG & env vars, ensure RDS allows Lambda SG         |
| `Already checked in today` | Delete today's attendance row, then retest                      |
| `Cannot connect to DB`     | Check Lambda VPC & subnets allow access to RDS                  |


**✅ Now all 5 Lambdas are tested & verified**



**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---