# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

# ☕ Charlie Café SECTION 1️⃣ - Research & Development


## PHASE 1️⃣ System Scope

### 1️⃣ Attendance Management

- Employee daily check-in and check-out

- Automatic capture of:

    - Date

    - Time

    - Employee ID

- Centralized attendance records stored in RDS

- Admin/HR dashboard to view:

    - Daily attendance

    - Weekly summary

    - Monthly summary

### 2️⃣ Employee Portal

- Secure employee login using Amazon Cognito

- Employee can:

    - View personal attendance history

    - View approved leaves

    - View official café holidays

    - View HR profile information:

        - Job title

        - Salary

        - Start date

### 3️⃣ Access Control & Security

- Application access restricted using Security Groups

- 1️⃣ Frontend EC2:

    - HTTP/HTTPS allowed only from allowed IP ranges (practice lab)

- 2️⃣ Backend services protected using:

    - API Gateway authorization

    - Cognito JWT validation

- 3️⃣ Database access:

    - RDS accessible only from Lambda security group

## PHASE 2️⃣ Architecture Overview   

### 1️⃣ Frontend Layer

- Hosted on **EC2 Apache Web Server**

- Pages:

    - Attendance Check-In / Check-Out page (tablet/kiosk style)

    - Employee Portal page

    - Admin / HR Dashboard page

- Frontend communicates with backend using API Gateway endpoints

### 2️⃣ Backend Layer

#### 1️⃣ AWS API Gateway (REST API)

#### 2️⃣ AWS Lambda functions:

    - checkin

    - checkout

    - employeeProfile

    - attendanceHistory

    - leavesAndHolidays

#### 3️⃣ Amazon Cognito:

    - User authentication

    - JWT-based access control for APIs


## PHASE 3️⃣ Database Layer (RDS)

### 1️⃣ Database Type

    - MySQL or PostgreSQL

### 2️⃣ Tables

#### 1️⃣ employees

    - employee_id

    - name

    - job_title

    - salary

    - start_date

    - cognito_user_id

#### 2️⃣ attendance

    - attendance_id

    - employee_id

    - date

    - checkin_time

    - checkout_time

#### 3️⃣ leaves

    - leave_id

    - employee_id

    - leave_date

    - leave_type

#### 4️⃣ holidays

    - holiday_date

    - description

## PHASE 4️⃣ Frontend Pages

### 1️⃣ A) Attendance Check-In / Check-Out Page

    - Tablet-friendly layout

    - Employee authentication via Cognito

    - Buttons:

        - Check-In

        - Check-Out

    - Auto timestamp capture

    - Success / error notification

### 2️⃣ B) Employee Portal Page

    - Authenticated access only

    - Sections:

        - Employee profile summary

        - Attendance table

        - Leaves and holidays list

#### Displayed Data Example

```
Employee Name: Alice
Job Title: Barista
Salary: 40,000 / month

Attendance:
Date        | Check-In | Check-Out
2026-01-19  | 09:00    | 17:00
2026-01-18  | 09:10    | 17:00

Leaves:
- 2026-01-15 | Sick Leave
- 2026-01-01 | Public Holiday
```

### 2️⃣ C) Admin / HR Dashboard

    - Secure Cognito-admin access

    - View:

        - Daily attendance

        - Weekly summary

        - Monthly summary

    - Employee-wise filtering

    - Export-ready table structure (future use)


## PHASE 5️⃣ API Endpoints (API Gateway + Lambda)

    - POST /api/checkin

    - POST /api/checkout

    - GET /api/employee/profile

    - GET /api/attendance

    - GET /api/leaves-holidays

#### Security

    - Cognito Authorizer enabled

    - JWT required for all endpoints

## PHASE 6️⃣ Security Configuration

### 1️⃣ Security Groups

#### 1️⃣ Frontend EC2

    - Allow HTTP/HTTPS from allowed IP ranges

#### 2️⃣ Lambda

    - Allow outbound access to RDS

#### 3️⃣ RDS

    - Allow inbound only from Lambda security group

### 2️⃣ Authentication & Authorization

    - Amazon Cognito User Pool

    - Role-based access:

        - Employee

        - Admin / HR

    - JWT validation enforced at API Gateway

## PHASE 7️⃣ Deployment Alignment

    - Frontend deployed on existing EC2 Apache server

    - Backend integrated into existing API Gateway + Lambda

    - Authentication integrated with existing Cognito

    - Database hosted in existing RDS

    - Logging via CloudWatch

## PHASE 8️⃣ Completion Outcome

    - Fully integrated internal café attendance system

    - Professional AWS architecture aligned with real job requirements

    - Secure, scalable, and production-style setup

    - Completes the final 20% of the Charlie Café lab

**✅ SECTION 1️⃣ R & D STATUS**

> **🟢 SECTION 1️⃣  R & D COMPLETE & VERIFIED**

---

# ☕ Charlie Café SECTION 2️⃣ - Attendance System

## PHASE 1️⃣ — Database Layer (RDS) Configuration

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

```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS Schema Setup (Employees + Attendance)..."

# ================= CONFIG =================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV" # ← CHANGE TO YOUR REAL SECRET ARN
DB_NAME="cafe_db"   # ← change to "cafedb" if that's your actual database name

# ================= FETCH SECRET FROM SECRETS MANAGER =================
echo "🔐 Fetching RDS credentials..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Missing required fields in secret (host/username/password)"
    exit 1
fi

echo "✅ Secret loaded"
echo "🔗 RDS Endpoint: $DB_HOST"
echo " Port: $DB_PORT"
echo "👤 DB User: $DB_USER"
echo "🗄 Database: $DB_NAME"
echo ""

# ================= CREATE TEMP CREDENTIALS FILE =================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# ================= TEST CONNECTION =================
echo "🔌 Testing RDS connection..."
if ! mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ Connection failed. Check:"
    echo " • Security Group allows inbound 3306 from this EC2"
    echo " • Credentials & endpoint correct"
    exit 1
fi
echo "✅ Connection OK"
echo ""

# ================= CREATE/USE DATABASE =================
echo "🗄 Ensuring database '$DB_NAME' exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
    CREATE DATABASE IF NOT EXISTS $DB_NAME 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;
"

# ================= CREATE TABLES =================
echo "📋 Creating employee management tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Employees table (links to Cognito)
CREATE TABLE IF NOT EXISTS employees (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    job_title       VARCHAR(50),
    salary          DECIMAL(10,2),
    start_date      DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_cognito (cognito_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id   INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time    TIME,
    checkout_time   TIME,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_day (employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leaves
CREATE TABLE IF NOT EXISTS leaves (
    leave_id        INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    leave_date      DATE NOT NULL,
    leave_type      VARCHAR(50),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    UNIQUE KEY uk_leave_day (employee_id, leave_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Holidays (global)
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id      INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date    DATE NOT NULL UNIQUE,
    description     VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

# ================= INSERT TEST / SEED DATA =================
echo "🌱 Inserting test data & holidays..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Holidays (2026 examples)
INSERT IGNORE INTO holidays (holiday_date, description) VALUES
    ('2026-01-01', 'New Year'),
    ('2026-03-23', 'Pakistan Day');

-- Temporary test employee (later replaced by Cognito trigger)
INSERT IGNORE INTO employees 
    (cognito_user_id, name, job_title, salary, start_date)
VALUES 
    ('TEMP-COGNITO-ID-123456', 'Alice', 'Barista', 40000.00, '2025-12-01');
EOF

# ================= VERIFY =================
echo ""
echo "🔍 Verifying tables and test data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
    SHOW TABLES;
    SELECT * FROM holidays ORDER BY holiday_date;
    SELECT employee_id, name, job_title, cognito_user_id FROM employees LIMIT 3;
    SELECT 'Schema & test data look good' AS status;
"

echo ""
echo "✅ Cafe employee/attendance schema setup completed successfully ☕"
echo "Next steps:"
echo "  • Connect:  mysql -h $DB_HOST -u $DB_USER -p $DB_NAME"
echo "  • Use Cognito Post-Confirmation trigger to auto-create real employee rows"
echo "  • Remove the TEMP employee later when going to production"
```

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

## PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 🎯 What We Are Creating in This Part

#### You will create 5 NEW Lambda functions:

- hr-checkin

- hr-checkout

- hr-employee-profile

- hr-attendance-history

- hr-leaves-holidays

#### Each Lambda will:

- Use existing RDS (cafedb)

- Be protected by existing Cognito

- Be callable from existing API Gateway

- Follow real job-level backend standards

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

```
import json
import os
import pymysql
from datetime import date, datetime

# Database connection
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    try:
        # Extract Cognito user ID from JWT
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            # Get employee ID
            cursor.execute(
                "SELECT employee_id FROM employees WHERE cognito_user_id=%s",
                (cognito_user_id,)
            )
            employee = cursor.fetchone()

            if not employee:
                return response(404, "Employee not found")

            employee_id = employee['employee_id']

            # Insert attendance
            cursor.execute("""
                INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                VALUES (%s, %s, %s)
            """, (employee_id, today, now))

            connection.commit()

        return response(200, "Check-in successful")

    except pymysql.err.IntegrityError:
        return response(400, "Already checked in today")

    except Exception as e:
        return response(500, str(e))

def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": message})
    }
```

- Click Deploy

### 3️⃣ Create Lambda: hr-checkout
> **Repeat Steps Exactly Like hr-checkin**

#### Only change:

#### 1️⃣ Function name:

```
hr-checkout
```

#### 2️⃣ Code:

```
import json
import os
import pymysql
from datetime import date, datetime

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    try:
        cognito_user_id = event['requestContext']['authorizer']['claims']['sub']
        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                SET a.checkout_time=%s
                WHERE e.cognito_user_id=%s
                AND a.attendance_date=%s
            """, (now, cognito_user_id, today))

            if cursor.rowcount == 0:
                return response(400, "Check-in required before checkout")

            connection.commit()

        return response(200, "Check-out successful")

    except Exception as e:
        return response(500, str(e))

def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": message})
    }
```

- Deploy.

### 4️⃣ Create Lambda: hr-employee-profile

#### 1️⃣ Function name

```
hr-employee-profile
```

#### 2️⃣ Code:

```
import json
import os
import pymysql

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee)
    }
```

- Deploy.

### 5️⃣ Create Lambda: hr-attendance-history

#### 1️⃣ Function name

```
hr-attendance-history
```

#### 2️⃣ Code:

```
import json
import os
import pymysql

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT a.attendance_date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
            ORDER BY a.attendance_date DESC
        """, (cognito_user_id,))
        records = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(records)
    }
```

- Deploy.

6️⃣ Create Lambda: hr-leaves-holidays

#### 1️⃣ Function name

```
hr-leaves-holidays
```

#### 2️⃣ Code:

```
import json
import os
import pymysql

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    cognito_user_id = event['requestContext']['authorizer']['claims']['sub']

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT l.leave_date, l.leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        cursor.execute("SELECT holiday_date, description FROM holidays")
        holidays = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "leaves": leaves,
            "holidays": holidays
        })
    }
```

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

Should see today’s date with checkin_time populated

checkout_time should be NULL

### 2️⃣ Test hr-checkout Lambda

#### Step 1 — Open Lambda Console

Lambda → hr-checkout → Test

#### Step 2 — Create Test Event

Same template as hr-checkin:

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

Step 3 — Invoke Test

Click Test

Expected success:

```
{
  "statusCode": 200,
  "body": "{\"message\": \"Check-out successful\"}"
}
```




### 📥 What You Have Achieved

✅ New HR-specific Lambda layer

✅ Cognito-secured backend

✅ RDS-integrated attendance logic

✅ Real-world AWS job architecture

✅ No duplication of existing lab



**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣ — Update CafePDFReportLambda for HR & Attendance

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