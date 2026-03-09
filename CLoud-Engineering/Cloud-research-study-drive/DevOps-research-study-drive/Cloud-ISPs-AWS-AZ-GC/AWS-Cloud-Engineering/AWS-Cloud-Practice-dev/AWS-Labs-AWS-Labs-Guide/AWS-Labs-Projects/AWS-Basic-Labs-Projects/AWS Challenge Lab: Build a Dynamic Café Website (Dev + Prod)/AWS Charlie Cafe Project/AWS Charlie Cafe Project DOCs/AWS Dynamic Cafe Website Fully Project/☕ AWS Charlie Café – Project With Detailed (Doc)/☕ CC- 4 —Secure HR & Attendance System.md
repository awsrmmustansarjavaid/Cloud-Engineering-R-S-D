# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

### ☕ AWS Charlie Café –READ Me About

[☕ CC- 4 —Secure HR & Attendance System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

### ☕ AWS Charlie Café – Test & Verifications

[☕ CC- 4 —Secure HR & Attendance System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

---

# ☕ Charlie Café SECTION 1️⃣ - Attendance System

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

### ✅ Quick Multi-Table Creation ( Recommanded)

You can create all 4 tables in one SQL script. Copy-paste this inside MySQL prompt:

```
-- 1️⃣ employees table
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2️⃣ attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 3️⃣ leaves table
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 4️⃣ holidays table
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
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

> **We will later auto-create employees via Cognito, but this helps now.**

### 3️⃣ Create Employee ID

### 1️⃣ create an employee record in your RDS database

#### Step 1: Identify the Cognito User ID

From Cognito, you have the employee details:

- User name: ali

- Sub (User ID): 74e8a458-a011-700d-dcdb-df9692b61962

- Group: Employee

- Other info → job_title, salary, start_date (you decide or get from HR)

The sub is the unique Cognito user ID, which we will use in RDS to link the Cognito account to your employees table.

#### Step 2: Insert Employee Record

Assuming your employees table has the following columns:

```
employees(
    id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE
)
```

#### ✅ You can insert the employee like this:

- Replace the TEMP-COGNITO-ID with the real Cognito sub for ali, and other fields as appropriate.

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
```

### ✅ Insert Test Data

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('74e8a458-a011-700d-dcdb-df9692b61962', 'Ali', 'Barista', 40000, '2026-03-05');
```

#### Explanation:

- cognito_user_id → Cognito sub

- name → Employee full name

- job_title → Employee position

- salary → Employee salary

- start_date → Employment start date

✅ Tip: 

- Always keep cognito_user_id unique so it maps exactly to a Cognito user.

- Make sure the employees table allows these columns (run DESCRIBE employees; to verify).


### ✅ Insert Test Data in One Go

```
-- Insert test holidays
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');

-- Insert temporary test employee
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
```

#### Step 3: Verify Employee Record

After insertion, check that the record exists:

```
SELECT * FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

#### ✅ Expected output:

| id | cognito_user_id                      | name | job_title | salary | start_date |
| -- | ------------------------------------ | ---- | --------- | ------ | ---------- |
| 1  | 74e8a458-a011-700d-dcdb-df9692b61962 | Ali  | Barista   | 40000  | 2026-03-05 |

#### Optional: Check all employees:

```
SELECT * FROM employees;
```

#### Check if employee is linked to group (if applicable):

If you have a groups table or employee_groups table, make sure the employee is assigned correctly:

```
SELECT * FROM employee_groups
WHERE employee_id = (
    SELECT id FROM employees WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962'
);
```

#### Testing Integration (Optional)

If your app uses cognito_user_id to fetch employee data:

```
SELECT name, job_title, salary 
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

- If the query returns data correctly, your Cognito → RDS mapping works.

- You can now create your app logic to fetch employee info by Cognito login.

#### Step 4: Insert Multiple Employees (Optional)

You can batch insert more employees from Cognito:

```
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('ID-2', 'Bob', 'Chef', 50000, '2026-03-01'),
('ID-3', 'Carol', 'Manager', 60000, '2026-02-15');
```

#### Step 5: Optional — Verify via Employee Portal

If your employee-portal.html fetches employees by cognito_user_id, you can now login as Ali in Cognito and check if the portal shows this employee.

#### Step 6: Automate Future Insertions

Later, you can auto-create employees whenever a new Cognito user is added. The general workflow:

- Lambda triggers on Cognito PostConfirmation event

- Lambda inserts a new employee in RDS using the sub as cognito_user_id

- Employee portal automatically shows new employees

Sample Lambda pseudo-query:

```
sql = """
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES (%s, %s, %s, %s, %s)
"""
cursor.execute(sql, (user_sub, full_name, 'Unknown', 0, today))
```

### ✅ Quick Verification

- Table structure is correct → DESCRIBE employees;

- Record inserted → SELECT * FROM employees WHERE cognito_user_id = '...';

- Linked correctly to any group → SELECT * FROM employee_groups WHERE employee_id = ...;

- App/API can fetch employee using Cognito sub.

#### ✅ Run these commands to confirm everything is working:

```
-- Check tables
SHOW TABLES;

-- Preview employees
SELECT * FROM employees;

-- Preview holidays
SELECT * FROM holidays;
```

If you see your inserted rows and table names, your RDS configuration is fully functional. ✅

### 2️⃣  Verify Employee ID on RDS

```
SELECT * FROM employees;
```

This must match the employee_id in your RDS employees table.

#### Example RDS:

```
employee_id | name | job_title
--------------------------------
5           | Ali  | Barista
```

### 3️⃣ Logout and Login Again

Clear old token:

```
localStorage.clear()
```

Then login again.

Now your console log will show:

```
Decoded Token:
{
 "custom:employee_id": "5",
 "email": "...",
 "cognito:username": "ali"
}
```

Now the portal will work.

### ✅ Another Small Improvement (Recommended)

Update your code to ensure number:

```
const employeeId = parseInt(
decoded["custom:employee_id"] ||
decoded["employee_id"] ||
decoded["cognito:username"]
)
```

Because your Lambda requires numeric employee_id.

### ✅ Verify Cognito Configuration 

### 1️⃣ Configure App Client (VERY IMPORTANT)

- Go to: User Pool → App clients

- Select your App Client

- Open Edit Hosted UI configuration

#### Enable OAuth Flow

- ✔ Authorization code grant

#### Enable  OAuth Scopes

```
openid
email
profile
```

openid is required to receive ID token.

### 2️⃣ Configure Redirect URLs

Add your portal URL.

#### Example:

```
https://d3hg4gkyr2w5ay.cloudfront.net/employee-portal.html
```

Also add logout URL:

```
https://d3hg4gkyr2w5ay.cloudfront.net/employee-login.html
```

### 3️⃣ Configure Domain

- Go to: User Pool → Domain

### Example domain:

```
charlie-cafe-auth
```

#### Your login URL becomes:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
```

### 4️⃣ Login URL Example

Your Login Button should redirect to:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://d3hg4gkyr2w5ay.cloudfront.net/employee-portal.html
```

After login Cognito redirects to:

```
employee-portal.html?code=xxxx
```

Your portal then exchanges the code → id_token.

### 5️⃣ Verify Token Contains Employee ID

After login open Chrome Console:

```
console.log(parseJwt(localStorage.getItem("id_token")))
```

#### Expected output:

```
{
 "sub": "abc123",
 "email": "ali@charliecafe.com",
 "custom:employee_id": "5"
}
```

Now your portal will read:

```
employeeId = decoded["custom:employee_id"]
```

And call:

```
GET /employee/profile?employee_id=5
```

Which triggers your AWS Lambda to query Amazon RDS.

### ✅ Final Flow (Complete Architecture)

```
Employee Login
      │
      ▼
Amazon Cognito
      │
      ▼
Returns id_token (JWT)
      │
      ▼
Employee Portal HTML
      │
      ▼
Extract custom:employee_id
      │
      ▼
API Gateway
      │
      ▼
AWS Lambda
      │
      ▼
Amazon RDS
      │
      ▼
Employee Data
```

Everything will work.

### ✅ Most Common Mistakes

❌ Employee ID not added to Cognito user

❌ openid scope missing

❌ Wrong redirect URL

❌ Using employee_id instead of custom:employee_id

❌ Token exchange not implemented

### 🌐 Final End  – What You Have Now

✅ Database schema ready

✅ Linked to Cognito via cognito_user_id

✅ Safe for production-style usage

✅ No change to existing infrastructure


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 1️⃣ Lambda: hr-checkin & hr-checkinout

- AWS Console → Lambda

- Click Create function

- Author from scratch

- Runtime: Python 3.12

- Architecture: x86_64

- Use existing role: cafe-hr-lambda-role

### hr-attendance

> **a single merged Lambda, Check-in and check-out are the same domain action (attendance), just different operations.**

[hr-attendance.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-attendance.py)


#### ✅ Add VPC Configuration (CRITICAL)

- Lambda → Configuration → VPC

- VPC: same VPC as RDS

- Subnets: private subnets used by RDS

- Security group: Lambda SG that allows RDS access

- Click Save

### 2️⃣ Create Lambda: hr-employee-profile

#### 1️⃣ Function name

```
hr-employee-profile
```

#### 2️⃣ Code:

[hr-employee-profile.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-employee-profile.py)

- Deploy.

### 3️⃣ Create Lambda: hr-attendance-history

#### 1️⃣ Function name

```
hr-attendance-history
```

#### 2️⃣ Code:

[hr-attendance-history.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-attendance-history.py)

- Deploy.

### 4️⃣ Create Lambda: hr-leaves-holidays

#### 1️⃣ Function name

```
hr-leaves-holidays
```

#### 2️⃣ Code:

[hr-leaves-holidays.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-leaves-holidays.py)

- Deploy.

### 5️⃣ Create Lambda: hr-cognito-token-exchange

> **AWS Cognito Authorization Code Exchange via API Gateway + Lambda**

We will build:

```
Browser
   ↓
API Gateway  →  Lambda (hr-cognito-token-exchange)
                    ↓
               Cognito /oauth2/token
```

### 1️⃣ Basic Configurations

- Function name: hr-cognito-token-exchange

- Runtime: Python 3.12

- Architecture: x86_64

### 2️⃣ Code:

[hr-cognito-token-exchange.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-cognito-token-exchange.py)

- Deploy

### 3️⃣ Configure Environment Variables

- Go to: Lambda → Configuration → Environment Variables

- Add:

| Key                  | Value                                                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| CLIENT_ID            | 7c5793cnvnbl110ljthmdiohch                                                                                               |
| COGNITO_DOMAIN       | us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com                                                                      |
| COGNITO_REDIRECT_URI | [https://d2xb54di3chfgj.cloudfront.net/employee-portal.html](https://d2xb54di3chfgj.cloudfront.net/employee-portal.html) |


- Save.

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

| Resource           | Path                  | Lambda Function         |
| ------------------ | --------------------- | ----------------------- |
| attendance          | `/attendance`            | `hr-attendance`     |
| Employee Profile   | `/employee-profile`   | `hr-employee-profile`   |
| Attendance History | `/attendance-history` | `hr-attendance-history` |
| Leaves & Holidays  | `/leaves-holidays`    | `hr-leaves-holidays`    |
| exchange-token  | `/exchange-token`    | `hr-cognito-token-exchange`    |

**⚠️ All methods = POST**

### 1️⃣ Open API Gateway

- Go to AWS Console → API Gateway → Open API

- Choose REST API (not HTTP API)

- API Name:

```
CafeOrderAPI
```

- Description:

```
HR Secure Attendance & Employee Management API
```

- Endpoint Type: Regional

- Click Create API

### 2️⃣ Create Resources (Paths)

| Resource           | Path                  | Lambda Function                | Method |
|--------------------|-----------------------|--------------------------------|--------|
| attendance         | `/attendance`         | `hr-attendance`                | POST   |
| Employee Profile   | `/employee-profile`   | `hr-employee-profile`          | POST   |
| Attendance History | `/attendance-history` | `hr-attendance-history`        | POST   |
| Leaves & Holidays  | `/leaves-holidays`    | `hr-leaves-holidays`           | POST   |
| exchange-token     | `/exchange-token`     | `hr-cognito-token-exchange`    | POST   |

#### Step 1 — Add /attendance 

- Click Actions → Create Resource

- Resource Name: attendance

- Resource Path: /attendance

- Click Create Resource

#### Step 2 — Repeat for remaining resources

- /employee-profile

- /attendance-history

- /leaves-holidays

- /exchange-token

### 3️⃣ Create Methods

#### For each resource:

    - Click on Resource → Actions → Create Method

    - Select POST for /attendance,  /employee-profile, /attendance-history, /leaves-holidays , /exchange-token

### 4️⃣ Integrate Lambda Function

#### For each method:

    - Integration type: Lambda Function

    - Check Use Lambda Proxy Integration

    - Lambda Region: your Lambda region

#### Lambda Function:

    - /attendance → hr-attendance

    - /employee-profile → hr-employee-profile

    - /attendance-history → hr-attendance-history

    - /leaves-holidays → hr-leaves-holidays

    - /exchange-token → hr-cognito-token-exchange

- Click Save

- Grant permissions when prompted → Yes

### 5️⃣ Enable CORS (Cross-Origin Resource Sharing)

#### For each resource method:

- Click Method → Actions → Enable CORS

- Integration type → Mock Integration

- Allowed:

    - POST

    - OPTIONS

- Headers: 

```
*
```

Now configure 

#### Method Response

- Add status code: 200

- Add Response Headers:

    - Access-Control-Allow-Origin

    - Access-Control-Allow-Headers

    - Access-Control-Allow-Methods

#### Integration Response

Under Header Mappings add:  

```
Access-Control-Allow-Origin  ->  '*'
Access-Control-Allow-Headers ->  'Content-Type'
Access-Control-Allow-Methods ->  'GET,POST,OPTIONS'
```

- Save.

- Repeat for all 4 resources.

#### ✅ CORRECT PUBLIC CORS CONFIGURATION

Because you are using Lambda Proxy Integration, API Gateway CORS headers are NOT required in Method Response.

Your Lambda already returns:

```
"headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
}
```

That is enough.

### 6️⃣ Deploy API

- Actions → Deploy API

- Deployment stage: prod

- Stage description: HR Secure API

- Deploy

### ✅ Copy the Invoke URL. Example:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/
```

### ✅ Final API Endpoint

Your endpoint becomes:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/attendance
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/employee-profile
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/attendance-history
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/leaves-holidays
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/exchange-token
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
> **📄 cafe-admin-dashboard.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/cafe-admin-dashboard.html
```

#### 2️⃣ cafe-admin-dashboard.html Code

[cafe-admin-dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script//Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)

#### 3️⃣ Set permissions:

```
sudo chown apache:apache *.html
```

```
sudo chmod 644 *.html
```


**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 5️⃣ — Cafe Attendance Admin Service

### 1️⃣ — DATABASE (NO CHANGE, JUST VERIFY)

Run this ONCE in RDS:

```
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
```

**✅ Done. Move on.**

### 2️⃣ — CREATE ONE LAMBDA ONLY

#### 1️⃣ 📄 Lambda Name : cafe-attendance-admin-service

[cafe-attendance-admin-service.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/cafe-attendance-admin-service.py)

### 3️⃣ —API Gateway Configuration

- Resource Structure: /hr-analytics

```
/hr-analytics
```

- Method: GET

- Integration:

    - Type: Lambda

    - Lambda: hr-admin-attendance-analytics

    - Enable Lambda Proxy Integration ✅

### 4️⃣ ENABLE CORS

Still inside /hr-analytics:

- Click Actions → Enable CORS

- Headers: None ,Content-Type

- Methods: GET,OPTIONS

- Origin: *

- Click Enable CORS and replace

- Deploy

- Stage: prod

You will get something like:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
```

Final endpoint becomes:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics
```

#### ✅ Final API Endpoints

```
GET /hr-analytics?type=daily
GET /hr-analytics?type=weekly&summary=true
GET /hr-analytics?employee_id=EMP001
GET /hr-analytics?employee_id=EMP001&date=2026-02-25
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
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



**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---
# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

