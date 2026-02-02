# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

### ☕ AWS Charlie Café –READ Me About

[☕ CC- 4 —Secure HR & Attendance System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

### ☕ AWS Charlie Café – Test & Verifications

[☕ CC- 4 —Secure HR & Attendance System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

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

### 2️⃣ Method - 1 HR & Attendance System Create Tables

> **This table links Cognito users with café employees.**

#### 1️⃣ Create employees Table

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

#### 2️⃣ Create attendance Table

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

#### 3️⃣ Create leaves Table



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

#### 4️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
### 3️⃣ Insert Test Data (Required for Frontend Testing)

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

### 4️⃣ Method - 2 HR & Attendance System Create Tables Bash Script 

#### 1️⃣ Create File

```
sudo nano setup_cafe_hr_attendance.sh
```

#### 2️⃣ Bash Script 

[setup_cafe_hr_attendance.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/setup_cafe_hr_attendance/setup_cafe_hr_attendance.sh)

#### 3️⃣ Make the Script Executable

```
sudo chmod +x setup_cafe_hr_attendance.sh
```

#### 4️⃣ Run the Script

```
sudo ./setup_cafe_hr_attendance.sh
```

### 🌐 Final End  – What You Have Now

✅ Database schema ready

✅ Linked to Cognito via cognito_user_id

✅ Safe for production-style usage

✅ No change to existing infrastructure


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 1️⃣ Create Lambda: hr-checkin

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
| DB_USER | cafe_user     |
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

[hr-checkin.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-checkin.py)

- Click Deploy

### 2️⃣ Create Lambda: hr-checkout
> **Repeat Steps Exactly Like hr-checkin**

#### Only change:

#### 1️⃣ Function name:

```
hr-checkout
```

#### 2️⃣ Code:

[hr-checkout.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-checkout.py)

- Deploy.

### 3️⃣ Create Lambda: hr-employee-profile

#### 1️⃣ Function name

```
hr-employee-profile
```

#### 2️⃣ Code:

[hr-employee-profile.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-employee-profile.py)

- Deploy.

### 4️⃣ Create Lambda: hr-attendance-history

#### 1️⃣ Function name

```
hr-attendance-history
```

#### 2️⃣ Code:

[hr-attendance-history.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-attendance-history.py)

- Deploy.

### 5️⃣ Create Lambda: hr-leaves-holidays

#### 1️⃣ Function name

```
hr-leaves-holidays
```

#### 2️⃣ Code:

[hr-leaves-holidays.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-leaves-holidays.py)

- Deploy.

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
| checkin           | `/checkin`            | `hr-checkin`            |
| checkout         | `/checkout`           | `hr-checkout`           |
| Employee Profile   | `/employee-profile`   | `hr-employee-profile`   |
| Attendance History | `/attendance-history` | `hr-attendance-history` |
| Leaves & Holidays  | `/leaves-holidays`    | `hr-leaves-holidays`    |

#### Step 1 — Add /checkin

- Click Actions → Create Resource

- Resource Name: CheckIn

- Resource Path: /checkin

- Click Create Resource

#### Step 2 — Repeat for remaining resources

- /checkout

- /employee-profile

- /attendance-history

- /leaves-holidays

### 3️⃣ Create Methods

#### For each resource:

    - Click on Resource → Actions → Create Method

    - Select POST for /checkin and /checkout

    - Select GET for /employee-profile, /attendance-history, /leaves-holidays

### 4️⃣ Integrate Lambda Function

#### For each method:

    - Integration type: Lambda Function

    - Check Use Lambda Proxy Integration

    - Lambda Region: your Lambda region

#### Lambda Function:

    - /checkin → hr-checkin

    - /checkout → hr-checkout

    - /employee-profile → hr-employee-profile

    - /attendance-history → hr-attendance-history

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
https://abcdefg123.execute-api.us-east-1.amazonaws.com/dev
```

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

[checkin.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/checkin.html)

✅ This page allows employees to check in and check out and confirms success/failure messages.

### 2️⃣ Employee Portal Page
> **📄 employee-portal.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/employee-portal.html
```

#### 2️⃣ employee-portal.html Code

[employee-portal.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-portal.html)

✅ Employees can view profile, attendance, leaves, and holidays.

### 3️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)
> **📄 admin-dashboard.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/admin-dashboard.html
```

#### 2️⃣ admin-dashboard.html Code

[admin-dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/admin-dashboard.html)

#### 3️⃣ Set permissions:

```
sudo chown apache:apache *.html
```

```
sudo chmod 644 *.html
```

### 4️⃣ — HOW LOGOUT INTEGRATES WITH COGNITO (STEP-BY-STEP)

#### 🧠 Step-by-Step Cognito Logout Flow

#### 1️⃣ Cognito keeps user session

When a user logs in via Cognito:

- Cognito automatically stores 3 important tokens in browser (local/session storage):

    - ID Token

    - Access Token

    - Refresh Token

- These tokens allow Cognito SDK to know if a user is logged in.

#### 2️⃣ Logging Out the User

To log the user out, you call:

```
user.signOut();
```

#### What happens internally

- Tokens are removed from storage (ID, Access, Refresh).

- Session is invalidated on the client side.

- userPool.getCurrentUser() now returns null (because the session is gone).

✅ This is why the user cannot access protected pages anymore.

#### 3️⃣ Protecting Pages (IMPORTANT)

On every page you want only logged-in users to see, you need this check at the top:

```
const user = userPool.getCurrentUser();
if (!user) {
    window.location.href = "login.html"; // Redirect to login if not logged in
}
```

**👉 This prevents access after logout.**

#### Why this is important:

- After logout, userPool.getCurrentUser() returns null.

- User automatically gets redirected to login (or another page).

This ensures security: no one can access protected pages after logout.

#### 4️⃣ Redirect After Logout

After logging out, you often want to send the user somewhere:

```
user.signOut(); 
window.location.href = "index.html"; // Example: redirect to homepage
```

You can redirect to:

- Could be login page (login.html)

- Could be landing page (index.html)

- Could be home of your app

**This is purely optional, but good UX.**

#### 5️⃣ Optional: Logout Button Integration

Example logout button in HTML:

```
<button id="logoutBtn">Logout</button>
```

#### JavaScript:

```
document.getElementById("logoutBtn").addEventListener("click", () => {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
        window.location.href = "index.html"; // Redirect after logout
    }
});
```

**✅ Simple, clean, and works with Cognito.**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 5️⃣ Secure Frontend & API Integration with Production Hardening
> **Frontend & Backend Security, API Integration, and Role-Based UI (Production Ready)**

### 1️⃣ — CENTRAL CONFIG FILE (FRONTEND)

```
/var/www/html/js/central-auth-api.js
```

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)


### 2️⃣ FRONTEND CONFIGURATION

#### 1️⃣ File placement (ONLY ONE JS FILE NOW)

```
/var/www/html
├── admin-dashboard.html
├── employee-portal.html
└── js/
    └── central-auth-api.js
```

#### 2️⃣ Permissions:

```
sudo chown www-data:www-data js/central-auth-api.js
```
```
sudo chmod 755 js/central-auth-api.js
```

#### 3️⃣ ADMIN PAGE USAGE (FINAL)

```
<script src="js/central-auth-api.js"></script>
<script>
    CHARLIE.auth.protectPage();
    CHARLIE.enforceAdminAccess();

    async function loadEmployees() {
        const data = await CHARLIE.secureFetch(
            CHARLIE.apiBase + "/admin/employees"
        );
        console.log(data);
    }

    loadEmployees();
</script>

<div id="admin-section" style="display:none;">
    <button>Manage Employees</button>
</div>
```

#### 4️⃣ EMPLOYEE PAGE USAGE (FINAL)

```
<script src="js/central-auth-api.js"></script>
<script>
    CHARLIE.auth.protectPage();
    CHARLIE.enforceEmployeeAccess();

    async function loadProfile() {
        const data = await CHARLIE.secureFetch(
            CHARLIE.apiBase + "/employee/profile"
        );
        console.log(data);
    }

    loadProfile();
</script>
```

### 3️⃣ BACKEND CONFIGURATION

#### 1️⃣ FINAL PRODUCTION-SAFE COMMON LAMBDA TEMPLATE
> **👉 USE THIS IN ALL 5 HR LAMBDAS**

```
import json
import logging
from datetime import date, datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------- JSON SAFE ENCODER ----------
def json_safe(obj):
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_safe)
    }

def lambda_handler(event, context):
    logger.info("Request received")
    logger.info(event)

    # -------------------------------
    # AUTHORIZATION (Cognito Authorizer)
    # -------------------------------
    try:
        claims = event["requestContext"]["authorizer"]["claims"]
    except KeyError:
        return response(401, {"message": "Unauthorized"})

    groups = claims.get("cognito:groups", [])

    # Normalize groups (string → list)
    if isinstance(groups, str):
        groups = [groups]

    # -------------------------------
    # ROLE CHECK (CHANGE PER FUNCTION)
    # -------------------------------
    ALLOWED_ROLE = "Employee"  # CHANGE PER LAMBDA

    if ALLOWED_ROLE not in groups:
        return response(403, {"message": "Forbidden"})

    # -------------------------------
    # BUSINESS LOGIC (PER LAMBDA)
    # -------------------------------
    # Write your DB / logic here

    return response(200, {"message": "Success"})
```

**⚠️ All these 5 HR Lambda Updated.. Skip this step**

#### 2️⃣ 🧩 HOW TO APPLY THIS TO EACH LAMBDA (NO CONFUSION)
> **This step (ALLOWED_ROLE = Employee/Admin) is part of Cognito role-based access control (RBAC).**

#### 1️⃣ Create Cognito User Pool

#### Step 1: Open Cognito

- AWS Console → Cognito

- Click Create user pool

#### Step 2: Basic setup

- User pool name:

```
HR-User-Pool
```

- Sign-in options:          ✔ Email

- Password policy:          Default (OK)

#### Step 3: Attributes

- Required attributes:      ✔ email

#### Step 4: App Client

- App client name:

```
hr-web-client
```

**❌ Disable client secret (IMPORTANT for frontend)**

- Create the pool ✅

#### 2️⃣ Create Cognito Groups (ROLES)

#### Step 1: Go to your User Pool

- User Pool → Groups

#### Step 2: Create Groups

- Create two groups:

- Group 1 Name: Employee

- Group 2 Name: Admin

**👉 These group names are your roles**

#### 3️⃣ Create Test Users

#### Step 1: Users → Create user

- Create Employee user

    - Email: employee@test.com

    - Add to group: Employee

- Create Admin user

    - Email: admin@test.com

    - Add to group: Admin

- Set permanent passwords.

#### 4️⃣ Attach Cognito Authorizer to API Gateway

#### Step 1: API Gateway

- Open your HR API

- Go to Authorizers

- Create Authorizer

#### Step 2: Configure

- Type: Cognito

- User Pool: HR-User-Pool

- Token source:

```
Authorization
```

- Save.

#### Step 3: Attach Authorizer to Routes

- For each HR route:

- Method → Method Request

- Authorization → Cognito Authorizer

- Save & Redeploy API

#### 5️⃣ Add ROLE CHECK

Now comes your ALLOWED_ROLE logic.

#### 🔹 Common Role Check Snippet (SAFE & CLEAN)

Add this after extracting Cognito claims
(does NOT break your existing logic)

```
def check_role(event, allowed_role):
    claims = event['requestContext']['authorizer']['claims']
    groups = claims.get('cognito:groups', '')
    return allowed_role in groups
```

#### 6️⃣ Check-In Lambda

```
ALLOWED_ROLE = "Employee"
# INSERT attendance record
```

#### 7️⃣ Check-Out Lambda

```
ALLOWED_ROLE = "Employee"
# UPDATE checkout_time
```

#### 8️⃣ Attendance History Lambda

```
ALLOWED_ROLE = "Employee"
# SELECT attendance rows
# return list → auto JSON-safe
```

#### 9️⃣ Leaves & Holidays Lambda

```
ALLOWED_ROLE = "Employee"
# SELECT leaves + holidays
```

#### 🔟 Admin Employees Lambda

```
ALLOWED_ROLE = "Admin"
# SELECT all employees
```

### 4️⃣ REQUIRED API GATEWAY CONFIG

#### ✅ Authorizer

- Type: Cognito User Pool

- Token Source: Authorization

- Identity validation: Bearer .*

#### ✅ Method Request (ALL methods)

- Authorization: Cognito Authorizer

- API Key: false

#### ✅ Enable CORS (ALL resources)

- Allow:

```
Authorization
Content-Type
```

#### 🔐 SECURITY MODEL
> **(YOU DID THIS RIGHT)**

| Layer       | Responsibility   |
| ----------- | ---------------- |
| Frontend    | UX + redirect    |
| Backend     | REAL security    |
| Cognito     | Identity         |
| API Gateway | Token validation |


✔️ No frontend trust

✔️ No role bypass

✔️ Production-grade

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

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 6️⃣ — ADMIN ATTENDANCE ANALYTICS

### 1️⃣ — DATABASE (NO CHANGE, JUST VERIFY)

Run this ONCE in RDS:

```
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
```

**✅ Done. Move on.**

### 1️⃣ — CREATE ONE LAMBDA ONLY

#### 1️⃣ 📄 Lambda Name : attendance_summary

[attendance_summary.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/attendance_summary.py)

#### 1️⃣ ✅ Lambda Environment Variables

| Key         | Value             |
| ----------- | ----------------- |
| DB_HOST     | your-rds-endpoint |
| DB_USER     | rds-username      |
| DB_PASSWORD | rds-password      |
| DB_NAME     | cafedb            |

### 🟢 STEP 3 — API GATEWAY (ONE RESOURCE ONLY)

1️⃣ Open API Gateway → Existing API

2️⃣ Create Resource

```
/admin
   └── /attendance
```

3️⃣ Create Method

```
GET
```

4️⃣ Integration

Type: Lambda

Lambda: attendance_summary

Enable Lambda Proxy

5️⃣ Enable Cognito Authorizer

✔ REQUIRED
✔ Admin only

6️⃣ Deploy

Stage: prod

✅ FINAL API ENDPOINT

```
GET /admin/attendance?type=daily
GET /admin/attendance?type=weekly
GET /admin/attendance?type=monthly
```

🟢 STEP 4 — UPDATE central-auth-api.js

You asked NOT to miss export section — so here is a FULL UPDATED VERSION.

📄 central-auth-api.js (UPDATED + SAFE)

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)








```
sudo nano /var/www/html/attendance_summary
```






**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 7️⃣ — ADMIN DASHBOARD ENHANCEMENTS

### STEP 1 — Database & Backend Preparation

#### 1️⃣ Verify RDS Tables

You already have:

- employees (employee_id, name, job_title)

- attendance (attendance_id, employee_id, date, checkin_time, checkout_time)

- leaves (leave_id, employee_id, leave_date, leave_type)

**✅ No changes needed here; all data is ready for filtering and summary.**

#### 2️⃣ Optional: Add Indexes (Performance)

```
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_leaves_employee_date ON leaves(employee_id, leave_date);
```

**✅ Purpose: Fast filtering by employee and date.**

### STEP 2 — Lambda Functions for Admin Dashboard Enhancements

We will create one main Lambda that supports filtering and summary cards.

#### Filename: admin_dashboard_data.py

[admin_dashboard_data.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/admin_dashboard_data.py)

#### ✅ This Lambda:

- Supports optional employee filter

- Returns attendance records + summary cards (present / absent / leaves)

### STEP 3 — API Gateway Integration

- Open API Gateway → Existing HR API

- Create Resource: /admin/dashboard

- Method: GET → Lambda integration → admin_dashboard_data

- Enable Cognito Authorizer → Admin-only access

- Enable CORS → Allowed origin: your EC2 frontend

- Deploy → Stage: prod

### STEP 4 — Admin Frontend — HTML Enhancements

#### 4️⃣1 — Add Filter Dropdown & Summary Cards

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

### STEP 5 — Admin Frontend — JS Functions

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

#### ✅ What this JS does:

- Populates employee dropdown dynamically

- Fetches attendance + summary cards

- Filters by employee

- Exports table as CSV

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 8️⃣ — HR Attendance Dashboard

### 1️⃣ — FRONTEND HR ATTENDANCE DASHBOARD

#### 🔹 STEP 1 — Create Folder & File

#### 📁 Create file:

```
sudo nano /var/www/html/hr-attendance.html
```

[hr-attendance.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/hr-attendance.html)

### 2️⃣ BACKEND — HR ATTENDANCE DASHBOARD

#### 1️⃣ DynamoDB Table (Attendance)

- Create table:

| Setting       | Value                       |
| ------------- | --------------------------- |
| Table name    | `CafeAttendance`            |
| Partition key | `employee_id` (String)      |
| Sort key      | `date` (String, YYYY-MM-DD) |

📌 This allows:

- One record per day

- Easy query by date

📌 Format you will store:

- Other attributes:

    - check_in

    - check_out

    - role

#### TABLE SETTINGS

#### Capacity mode

- Select: On-demand (recommended)

👉 No billing surprises

👉 Best for learning & small projects

#### Table class

- Leave default (Standard)

#### Encryption

- Leave default (AWS owned key)

#### Tags

- Optional → Skip for now

#### CLICK “CREATE TABLE”

- Scroll down

- Click Create table

**⏳ Wait ~10–20 seconds**

Status will change from Creating → Active

#### ✅ Table is now created

#### ✅ DO NOT CREATE “OTHER ATTRIBUTES” MANUALLY ❗❗❗

This is where beginners get confused.

#### ❌ You do NOT add:

- check_in

- check_out

- role

inside table settings.

#### ✅ DynamoDB is schema-less

Attributes are added automatically when Lambda inserts data.

Example item inserted later:

```
{
  "employee_id": "101",
  "date": "2026-02-01",
  "check_in": "09:03",
  "check_out": "17:11",
  "role": "Employee"
}
```

#### 2️⃣ Lambda: GetAttendanceAdminLambda

📍 Purpose: HR/Admin can view attendance records

[GetAttendanceAdminLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/Charile%20Cafe%20-%20Attendance%20System/GetAttendanceAdminLambda.py)

#### 3️⃣ API Gateway

- Create REST API resource:

```
/dev/hr/attendance
```

- Method: GET

-  Attach Lambda: GetAttendanceAdminLambda

-  Authorizer: Cognito User Pool

-  Required group: Admin

### 3️⃣ 🔐 HOW LOGOUT WORKS ON ALL PAGES (CLEAR & SIMPLE)

### 🟢 OPTION 1 (RECOMMENDED)

**👉 Keep EVERYTHING inside central-auth-api.js**

This is what large production apps do.

#### 🔹 STEP 1 — ADD A NEW INIT FUNCTION (CENTRALIZED)

Open central-auth-api.js

Add this near the bottom, before return {}:

```
/* =====================================================
   GLOBAL PAGE INITIALIZER (ONE-LINE SETUP)
===================================================== */
function initProtectedPage(options = {}) {
    const {
        requireAuth = true,
        enableLogout = true,
        logoutButtonId = "logoutBtn"
    } = options;

    // Step 1: Protect page (login required)
    if (requireAuth) {
        auth.protectPage();
    }

    // Step 2: Setup logout button
    if (enableLogout) {
        auth.setupLogoutButton(logoutButtonId);
    }
}
```

#### 🔹 STEP 2 — EXPORT IT

Inside return {} add:

```
initProtectedPage
```

Now this function becomes usable on ALL pages.

#### 🔹 STEP 3 — USE IT ON ANY PAGE (VERY SIMPLE)

Now your pages become EXTREMELY CLEAN:

```
<script src="js/central-auth-api.js"></script>

<script>
  CHARLIE.initProtectedPage();
</script>
```

That’s it.
No Cognito logic.
No duplication.
No confusion.

#### 🔹 STEP 4 — LOGOUT BUTTON (UI ONLY)

Wherever you want logout:

```
<button id="logoutBtn">Logout</button>
```

No JS code here.
Everything handled centrally.

#### 🔹 STEP 5 — API CALLS (SECURE)

Replace ALL fetch calls with:

```
CHARLIE.secureFetch(`${CHARLIE.apiBase}/dev/hr/attendance`, {
    method: "POST",
    body: JSON.stringify({ employee_id: employeeId })
});
```

Security, token, expiration, auto-logout — all handled centrally.

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)

#### ✅ HOW TO USE THIS (NO CONFUSION)

#### 🔹 Any protected page (Admin / HR / Employee):

```
<button id="logoutBtn">Logout</button>

<script src="js/central-auth-api.js"></script>
<script>
  CHARLIE.initProtectedPage();
</script>
```

#### 🔹 API call example:

```
CHARLIE.api.recordAttendance({
  employee_id: "E101"
});
```


### 🟢 OPTION 2

#### Step 1 — Add central auth

- Open ANY page (check-in, dashboard, HR page, admin page)

- At the BOTTOM of <body>, add:

```
<script src="js/central-auth-api.js"></script>
```

#### Step 2 — Protect page

- Immediately AFTER loading the script, add:

```
<script>
  CHARLIE.auth.protectPage();
</script>
```

#### Step 3 — ADD LOGOUT BUTTON (UI)

- On the page where you want logout (navbar, dashboard, etc):

```
<button id="logoutBtn">Logout</button>
```

#### Step 4 — CONNECT LOGOUT BUTTON TO CENTRAL LOGIC

Below protectPage() add:

```
<script>
  CHARLIE.auth.setupLogoutButton();
</script>
```

#### Step 5 — Replace fetch with secureFetch

```
CHARLIE.secureFetch(`${CHARLIE.apiBase}/dev/hr/attendance`, {
    method: "POST",
    body: JSON.stringify({ employee_id: employeeId })
});
```

👉 UI stays same

👉 Security added



**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 9️⃣ — Update Cafe Security Configuration

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

**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 🔟 — Minor UX / UI Polish
> **🌐 (Optional but Professional)**

### Step 5.1 — Choose Toast Notification Method

#### ✅ Recommended (No Library)

- Pure HTML + CSS + JavaScript

- Lightweight

- Works everywhere

- Perfect for labs & production

(We will use this)

### Step 5.2 — Add Toast HTML (ONE TIME ONLY)

Add this once near the end of your HTML body (Admin / Check-in / Checkout pages):

```
<!-- Toast Container -->
<div id="toast-container"></div>
```

### Step 5.3 — Add Toast CSS (GLOBAL)

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

### Step 5.4 — Add Toast JavaScript (GLOBAL FUNCTION)

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

### Step 5.5 — Replace alert() in Your Code
❌ Old (Bad UX)

```
alert("Check-in successful");
```

#### ✅ New (Professional UX)

```
showToast("Check-in successful", "success");
```

### Step 5.6 — Apply to Holiday Admin Page
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

### Step 5.7 — Apply to Check-In / Check-Out Pages
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

#### Step 5.8 — Add Loading State (Professional Touch)
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

#### Step 5.9 — Improve Error Messages (Human Friendly)

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

**✅ PHASE 🔟 STATUS**

> **🟢 PHASE 🔟 COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 1️⃣1️⃣ — Update CafePDFReportLambda for HR & Attendance

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

**✅ PHASE 1️⃣1️⃣ STATUS**

> **🟢 PHASE 1️⃣1️⃣ COMPLETE & VERIFIED**
---
