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

#### Optional - A 

| Resource           | Path                  | Lambda Function         |
| ------------------ | --------------------- | ----------------------- |
| attendance          | `/attendance`            | `hr-attendance`            |
| Employee Profile   | `/employee-profile`   | `hr-employee-profile`   |
| Attendance History | `/attendance-history` | `hr-attendance-history` |
| Leaves & Holidays  | `/leaves-holidays`    | `hr-leaves-holidays`    |

**⚠️ If you are following optional -B then follow this below configureations**

#### Step 1 — Add /checkin

- Click Actions → Create Resource

- Resource Name: CheckIn

- Resource Path: /attendance

- Click Create Resource

#### Step 2 — Repeat for remaining resources

- /employee-profile

- /attendance-history

- /leaves-holidays

### 3️⃣ Create Methods

#### For each resource:

    - Click on Resource → Actions → Create Method

    - Select POST for /attendance

    - Select GET for /employee-profile, /attendance-history, /leaves-holidays

### 4️⃣ Integrate Lambda Function

#### For each method:

    - Integration type: Lambda Function

    - Check Use Lambda Proxy Integration

    - Lambda Region: your Lambda region

#### Lambda Function:

    - /checkin → hr-attendance

    - /checkout → hr-attendance

    - /employee-profile → hr-employee-profile

    - /attendance-history → hr-attendance-history

    - /leaves-holidays → hr-leaves-holidays

- Click Save

- Grant permissions when prompted → Yes

### 5️⃣ Enable CORS (Cross-Origin Resource Sharing)

#### For each resource method:

    - Click Method → Actions → Enable CORS

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

### 🎯 Proper Public CORS Setup in API Gateway

For each resource:

#### Step 1 — Create OPTIONS Method

- Click Resource

- Actions → Create Method

- Select OPTIONS

- Integration Type: Mock Integration

- Save

### Step 2 — Configure OPTIONS Response

Method Response → Add:

```
200
```

Integration Response → Add Headers:

```
Access-Control-Allow-Origin: '*'
Access-Control-Allow-Headers: 'Content-Type'
Access-Control-Allow-Methods: 'GET,POST,OPTIONS'
```

Your final public CORS headers should be:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Content-Type
Access-Control-Allow-Methods: GET,POST,OPTIONS
```

- Deploy API (Step 7)

### 6️⃣ Deploy API

- Actions → Deploy API

- Deployment stage: prod

- Stage description: HR Secure API

- Deploy

#### Copy the Invoke URL. Example:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/
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

- Resource Structure: /admin/analytics

```
/admin
   └── /analytics
```

- Method: GET

- Integration:

    - Type: Lambda

    - Lambda: hr-admin-attendance-analytics

    - Enable Lambda Proxy Integration ✅

### 4️⃣ ENABLE CORS

Still inside /admin/analytics:

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
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/analytics
```

#### ✅ Final API Endpoints

```
GET /admin/analytics?type=daily
GET /admin/analytics?type=weekly&summary=true
GET /admin/analytics?employee_id=EMP001
GET /admin/analytics?employee_id=EMP001&date=2026-02-25
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


