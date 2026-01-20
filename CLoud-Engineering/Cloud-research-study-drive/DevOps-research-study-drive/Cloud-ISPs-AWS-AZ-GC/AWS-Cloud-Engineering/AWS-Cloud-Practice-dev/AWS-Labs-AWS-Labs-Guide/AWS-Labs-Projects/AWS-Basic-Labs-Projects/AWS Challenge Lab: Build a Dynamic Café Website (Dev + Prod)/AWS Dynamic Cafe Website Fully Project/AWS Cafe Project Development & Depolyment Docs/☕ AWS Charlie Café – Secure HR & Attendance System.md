# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System

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

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Attendance</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Café Theme Styling ================= -->
    <style>
        /* ===== Full Page Café Background ===== */
        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Segoe UI", sans-serif;
        }

        /* ===== Main Card ===== */
        .attendance-card {
            background-color: rgba(255, 255, 255, 0.96);
            border-radius: 15px;
            padding: 30px;
            max-width: 420px;
            width: 100%;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        }

        /* ===== Café Heading ===== */
        .attendance-card h2 {
            font-family: Georgia, serif;
            color: #2b1b12;
        }

        /* ===== Buttons ===== */
        .btn-checkin {
            background-color: #2b1b12;
            color: #fff;
        }

        .btn-checkin:hover {
            background-color: #3d261a;
        }

        .btn-checkout {
            background-color: #8b0000;
            color: #fff;
        }

        .btn-checkout:hover {
            background-color: #a40000;
        }
    </style>
</head>

<body>

<!-- ================= Attendance Card ================= -->
<div class="attendance-card text-center">

    <!-- Café Title -->
    <h2>☕ Charlie Café</h2>
    <p class="text-muted">Employee Attendance System</p>

    <hr>

    <!-- ================= Employee ID Input ================= -->
    <!-- Employee must enter ID before check-in/out -->
    <div class="mb-3 text-start">
        <label for="employeeId" class="form-label fw-bold">Employee ID</label>
        <input
            type="number"
            id="employeeId"
            class="form-control"
            placeholder="Enter your Employee ID"
            required
        >
    </div>

    <!-- ================= Action Buttons ================= -->
    <div class="d-grid gap-3 mt-4">
        <button class="btn btn-checkin btn-lg" onclick="submitCheckin()">
            ✅ Check In
        </button>

        <button class="btn btn-checkout btn-lg" onclick="submitCheckout()">
            ⏰ Check Out
        </button>
    </div>

    <!-- ================= Status Message ================= -->
    <div class="mt-4">
        <div id="statusMsg" class="fw-bold"></div>
    </div>

</div>

<!-- ================= JavaScript Logic ================= -->
<script>
    /* ========= API Gateway Base URL ========= */
    const apiBase = "https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod";

    /* ========= Utility: Show Status Messages ========= */
    function showMessage(message, success = true) {
        const msg = document.getElementById("statusMsg");
        msg.innerText = message;
        msg.style.color = success ? "green" : "red";
    }

    /* ========= Validate Employee ID ========= */
    function getEmployeeId() {
        const empId = document.getElementById("employeeId").value.trim();
        if (!empId) {
            showMessage("❌ Please enter Employee ID", false);
            return null;
        }
        return empId;
    }

    /* ========= Submit Check-In ========= */
    async function submitCheckin() {
        const employeeId = getEmployeeId();
        if (!employeeId) return;

        try {
            const response = await fetch(`${apiBase}/attendance/checkin`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ employee_id: employeeId })
            });

            const result = await response.json();

            if (response.ok) {
                showMessage("✅ Check-In successful. Have a great shift!");
            } else {
                showMessage(result.message || "❌ Check-In failed", false);
            }
        } catch (error) {
            showMessage("❌ Server error. Please contact admin.", false);
        }
    }

    /* ========= Submit Check-Out ========= */
    async function submitCheckout() {
        const employeeId = getEmployeeId();
        if (!employeeId) return;

        try {
            const response = await fetch(`${apiBase}/attendance/checkout`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ employee_id: employeeId })
            });

            const result = await response.json();

            if (response.ok) {
                showMessage("⏰ Check-Out successful. Thank you!");
            } else {
                showMessage(result.message || "❌ Check-Out failed", false);
            }
        } catch (error) {
            showMessage("❌ Server error. Please contact admin.", false);
        }
    }
</script>

</body>
</html>
```
✅ This page allows employees to check in and check out and confirms success/failure messages.

### 2️⃣ Employee Portal Page
> **📄 employee-portal.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/employee-portal.html
```

#### 2️⃣ employee-portal.html Code

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Employee Portal</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Cognito SDK ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

    <!-- ================= jsPDF (PDF Export) ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <style>
        /* ===== Café Background ===== */
        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-attachment: fixed;
            font-family: "Segoe UI", sans-serif;
            padding: 20px;
            transition: background 0.3s;
        }

        /* ===== Light Mode ===== */
        body.light-mode {
            background: #f8f5f2;
        }

        .page-title {
            font-family: Georgia, serif;
            color: #f5c16c;
        }

        .content-card {
            background-color: rgba(255, 255, 255, 0.97);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 22px rgba(0,0,0,0.45);
            margin-bottom: 25px;
        }

        table th {
            background-color: #2b1b12;
            color: #fff;
        }

        #emp-name {
            color: #fff;
            font-size: 1.2rem;
        }

        .status-badge {
            font-size: 1rem;
        }
    </style>
</head>

<body>

<div class="container">

    <!-- ================= Header & Controls ================= -->
    <div class="text-center mb-4">
        <h1 class="page-title">☕ Charlie Café</h1>
        <p class="text-light">Employee Self-Service Portal</p>
        <p id="emp-name"></p>

        <!-- Status Badge -->
        <span id="today-status" class="badge status-badge bg-secondary">
            Loading today status...
        </span>

        <!-- Controls -->
        <div class="mt-3 d-flex justify-content-center gap-2 flex-wrap">
            <button class="btn btn-outline-light btn-sm" onclick="toggleTheme()">
                🌗 Toggle Theme
            </button>
            <button class="btn btn-outline-light btn-sm" onclick="downloadPDF()">
                📄 Download Attendance
            </button>
            <button class="btn btn-warning btn-sm" onclick="logout()">
                🔒 Logout
            </button>
        </div>
    </div>

    <!-- ================= Profile ================= -->
    <div class="content-card">
        <h4>👤 My Profile</h4>
        <div class="table-responsive">
            <table class="table table-bordered mb-0">
                <tr><th>Name</th><td id="profile-name"></td></tr>
                <tr><th>Job Title</th><td id="profile-job"></td></tr>
                <tr><th>Salary</th><td id="profile-salary"></td></tr>
                <tr><th>Start Date</th><td id="profile-start"></td></tr>
            </table>
        </div>
    </div>

    <!-- ================= Attendance ================= -->
    <div class="content-card">
        <h4>🕒 Attendance History</h4>
        <div class="table-responsive">
            <table class="table table-striped table-bordered" id="attendance-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <!-- ================= Leaves ================= -->
    <div class="content-card">
        <h4>📅 Leaves & Holidays</h4>
        <div class="table-responsive">
            <table class="table table-striped table-bordered" id="leaves-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Type / Description</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

</div>

<!-- ================= JavaScript ================= -->
<script>
    /* ===== Cognito Config ===== */
    const poolData = {
        UserPoolId: 'us-east-1_XXXXXX',
        ClientId: 'XXXXXXXXXXXX'
    };
    const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    const apiBase = 'https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod';

    /* ===== Get JWT ===== */
    async function getJWT() {
        const user = userPool.getCurrentUser();
        return new Promise((resolve, reject) => {
            if (!user) reject("Not logged in");
            user.getSession((err, session) => {
                if (err) reject(err);
                resolve(session.getIdToken().getJwtToken());
            });
        });
    }

    /* ===== Load Profile ===== */
    async function loadProfile() {
        const token = await getJWT();
        const res = await fetch(`${apiBase}/employee/profile`, {
            headers: { Authorization: token }
        });
        const data = await res.json();

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
        document.getElementById("profile-salary").innerText = data.salary;
        document.getElementById("profile-start").innerText = data.start_date;
        document.getElementById("emp-name").innerText = `Welcome, ${data.name} ☕`;
    }

    /* ===== Load Attendance + Today Status ===== */
    async function loadAttendance() {
        const token = await getJWT();
        const res = await fetch(`${apiBase}/attendance/history`, {
            headers: { Authorization: token }
        });
        const records = await res.json();
        const tbody = document.querySelector("#attendance-table tbody");
        tbody.innerHTML = "";

        const today = new Date().toISOString().slice(0,10);
        let todayRecord = null;

        records.forEach(r => {
            if (r.attendance_date === today) todayRecord = r;
            tbody.innerHTML += `
                <tr>
                    <td>${r.attendance_date}</td>
                    <td>${r.checkin_time || "-"}</td>
                    <td>${r.checkout_time || "-"}</td>
                </tr>
            `;
        });

        updateTodayStatus(todayRecord);
    }

    function updateTodayStatus(record) {
        const badge = document.getElementById("today-status");
        if (!record) {
            badge.textContent = "Not Checked-In Today";
            badge.className = "badge bg-danger status-badge";
        } else if (record.checkin_time && !record.checkout_time) {
            badge.textContent = "Checked-In";
            badge.className = "badge bg-success status-badge";
        } else {
            badge.textContent = "Checked-Out";
            badge.className = "badge bg-secondary status-badge";
        }
    }

    /* ===== Load Leaves ===== */
    async function loadLeaves() {
        const token = await getJWT();
        const res = await fetch(`${apiBase}/leaves-holidays`, {
            headers: { Authorization: token }
        });
        const data = await res.json();
        const tbody = document.querySelector("#leaves-table tbody");
        tbody.innerHTML = "";

        data.leaves.forEach(l => {
            tbody.innerHTML += `<tr><td>${l.leave_date}</td><td>${l.leave_type}</td></tr>`;
        });
        data.holidays.forEach(h => {
            tbody.innerHTML += `<tr><td>${h.holiday_date}</td><td>${h.description}</td></tr>`;
        });
    }

    /* ===== PDF Export ===== */
    function downloadPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.text("Charlie Café – Attendance History", 10, 10);
        doc.text(document.getElementById("attendance-table").innerText, 10, 20);
        doc.save("attendance.pdf");
    }

    /* ===== Theme Toggle ===== */
    function toggleTheme() {
        document.body.classList.toggle("light-mode");
    }

    /* ===== Cognito Logout ===== */
    function logout() {
        const user = userPool.getCurrentUser();
        if (user) user.signOut();
        alert("Logged out successfully");
        window.location.href = "index.html"; // or login page
    }

    /* ===== Initial Load ===== */
    loadProfile();
    loadAttendance();
    loadLeaves();
</script>

</body>
</html>
```

✅ Employees can view profile, attendance, leaves, and holidays.

### 3️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)
> **📄 admin-dashboard.html**

#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/admin-dashboard.html
```

#### 2️⃣ admin-dashboard.html Code

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Cognito SDK ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

    <!-- ================= jsPDF ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <!-- ================= Café Theme ================= -->
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-attachment: fixed;
            font-family: "Segoe UI", sans-serif;
            display: flex;
            transition: background 0.3s;
        }

        body.light-mode {
            background: #f4efe9;
        }

        /* ===== Sidebar ===== */
        #sidebar {
            width: 230px;
            background-color: #2b1b12;
            color: #fff;
            flex-shrink: 0;
            padding: 20px;
        }

        #sidebar h3 {
            font-family: Georgia, serif;
            color: #f5c16c;
            text-align: center;
        }

        #sidebar .nav-link {
            color: #f1f1f1;
            margin-bottom: 6px;
            border-radius: 6px;
        }

        #sidebar .nav-link:hover {
            background-color: #3d261a;
            color: #f5c16c;
        }

        /* ===== Content ===== */
        #content {
            flex-grow: 1;
            padding: 30px;
        }

        .content-card {
            background-color: rgba(255,255,255,0.97);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 22px rgba(0,0,0,0.45);
        }

        table th {
            background-color: #2b1b12;
            color: #fff;
        }

        .status-badge {
            font-size: 1rem;
        }

        @media (max-width: 768px) {
            body {
                flex-direction: column;
            }
            #sidebar {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<!-- ================= Sidebar (ADMIN ONLY) ================= -->
<nav id="sidebar">
    <h3>☕ Charlie Café</h3>
    <hr>

    <ul class="nav nav-pills flex-column mb-3">
        <li><a class="nav-link active" href="#">Dashboard</a></li>
        <li><a class="nav-link" href="#">Attendance</a></li>
        <li><a class="nav-link" href="#">Employees</a></li>
        <li><a class="nav-link" href="#">Leaves</a></li>
        <li><a class="nav-link" href="#">Reports</a></li>
    </ul>

    <hr>

    <!-- Admin Controls -->
    <div class="d-grid gap-2">
        <button class="btn btn-outline-light btn-sm" onclick="toggleTheme()">🌗 Toggle Theme</button>
        <button class="btn btn-outline-light btn-sm" onclick="downloadPDF()">📄 Download Report</button>
        <button class="btn btn-warning btn-sm" onclick="logout()">🔒 Logout</button>
    </div>
</nav>

<!-- ================= Main Content ================= -->
<div id="content">

    <div class="content-card">
        <h2>Admin Dashboard</h2>
        <p class="text-muted">HR & Attendance Management</p>

        <!-- Status Badge -->
        <span id="today-status" class="badge bg-secondary status-badge">
            Loading today status...
        </span>

        <hr>

        <!-- Attendance Table -->
        <div class="table-responsive mt-3">
            <table class="table table-striped table-bordered" id="attendance-table">
                <thead>
                    <tr>
                        <th>Employee ID</th>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

</div>

<!-- ================= JavaScript ================= -->
<script>
    /* ===== Cognito Config ===== */
    const poolData = {
        UserPoolId: 'us-east-1_XXXXXX',
        ClientId: 'XXXXXXXXXXXX'
    };
    const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    const apiBase = 'https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod';

    async function getJWT() {
        const user = userPool.getCurrentUser();
        return new Promise((resolve, reject) => {
            if (!user) reject("Not logged in");
            user.getSession((err, session) => {
                if (err) reject(err);
                resolve(session.getIdToken().getJwtToken());
            });
        });
    }

    /* ===== Load Attendance (Admin View) ===== */
    async function loadAttendance() {
        const token = await getJWT();
        const res = await fetch(`${apiBase}/attendance/all`, {
            headers: { Authorization: token }
        });
        const records = await res.json();

        const tbody = document.querySelector("#attendance-table tbody");
        tbody.innerHTML = "";

        const today = new Date().toISOString().slice(0,10);
        let countToday = 0;

        records.forEach(r => {
            if (r.attendance_date === today) countToday++;
            tbody.innerHTML += `
                <tr>
                    <td>${r.employee_id}</td>
                    <td>${r.attendance_date}</td>
                    <td>${r.checkin_time || "-"}</td>
                    <td>${r.checkout_time || "-"}</td>
                </tr>
            `;
        });

        updateTodayStatus(countToday);
    }

    function updateTodayStatus(count) {
        const badge = document.getElementById("today-status");
        badge.textContent = `${count} employees checked in today`;
        badge.className = "badge bg-success status-badge";
    }

    /* ===== PDF Export ===== */
    function downloadPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.text("Charlie Café – Attendance Report", 10, 10);
        doc.text(document.getElementById("attendance-table").innerText, 10, 20);
        doc.save("attendance-report.pdf");
    }

    /* ===== Theme Toggle ===== */
    function toggleTheme() {
        document.body.classList.toggle("light-mode");
    }

    /* ===== Logout ===== */
    function logout() {
        const user = userPool.getCurrentUser();
        if (user) user.signOut();
        alert("Logged out successfully");
        window.location.href = "index.html";
    }

    /* ===== Initial Load ===== */
    loadAttendance();
</script>

</body>
</html>
```

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

#### 3️⃣ FINAL AUTH-API.JS (ALL-IN-ONE)

**👉 Paste your full auth-api.js code inside this file**
> **(save with CTRL+O, exit CTRL+X)**

```
/* =====================================================
   AUTH & API SHARED UTILITIES
   Charlie Café HR System
   - Used by Admin & Employee pages
   - Includes production hardening & UX polish
===================================================== */

/* ===============================
   GLOBAL CONFIG (Use config.js)
================================ */
const poolData = {
    UserPoolId: CONFIG.COGNITO.USER_POOL_ID,
    ClientId: CONFIG.COGNITO.CLIENT_ID
};
const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const apiBase = CONFIG.API_BASE;

/* ===============================
   PAGE PROTECTION
================================ */
function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===============================
   GET JWT TOKEN (WITH EXPIRATION CHECK)
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");

        user.getSession((err, session) => {
            if (err || !session.isValid()) {
                alert("Session expired. Please login again.");
                user.signOut();
                window.location.href = "login.html";
                reject("Session expired");
            }

            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
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

    if (body) options.body = JSON.stringify(body);

    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error("API request failed or unauthorized");
    }

    return response.json();
}

/* ===============================
   ROLE DETECTION
================================ */
async function getUserRoles() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        user.getSession((err, session) => {
            if (err) reject(err);
            const payload = session.getIdToken().decodePayload();
            resolve(payload["cognito:groups"] || []);
        });
    });
}

/* ===============================
   ADMIN UI CONTROL
================================ */
async function enforceAdminAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
    document.getElementById("admin-section").style.display = "block";
}

/* ===============================
   EMPLOYEE UI CONTROL
================================ */
async function enforceEmployeeAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}

/* ===============================
   LOGOUT (Cognito)
================================ */
function logout() {
    const user = userPool.getCurrentUser();
    if (user) user.signOut();
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
   LOADER FUNCTIONS (UX)
================================ */
function showLoader() {
    document.getElementById("loader").style.display = "block";
}

function hideLoader() {
    document.getElementById("loader").style.display = "none";
}

/* ===============================
   API EXAMPLES
================================ */

// Employee Profile Load
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

// Admin Load All Employees
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


### 3️⃣  🟢 STEP 2 — INCLUDE SCRIPT IN ADMIN PAGE
> **📄 admin-dashboard.html**

#### ✅ Add these BEFORE closing </body>

#### 1️⃣ Add Cognito SDK (REQUIRED)

```
<script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>
```

#### 2️⃣ Add Shared Auth & API Script

```
<script src="js/auth-api.js"></script>
```

#### 3️⃣ Page Protection + Role Enforcement
> **Call required functions**

```
<script>
/* Protect page from unauthenticated access */
protectPage();

/* Allow only Admin users */
enforceAdminAccess();
</script>
```

#### 4️⃣ Admin-Only HTML Section

```
<div id="admin-section" style="display:none;">
    <button class="btn btn-warning">Manage Employees</button>
    <button class="btn btn-danger">View Payroll</button>
</div>
```

#### 5️⃣ Logout Button (Admin)

```
<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```


#### 🟢 STEP 3 — INCLUDE SCRIPT IN EMPLOYEE PAGE
> **📄 employee-portal.html**

#### ✅ Add these BEFORE closing </body>

#### 1️⃣ Cognito SDK

```
<script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>
```

#### 2️⃣ Shared Script

```
<script src="js/auth-api.js"></script>
```

#### 3️⃣ Page Protection + Employee Role Check

```
<script>
/* Block unauthenticated users */
protectPage();

/* Allow only Employee users */
enforceEmployeeAccess();
</script>
```

#### 4️⃣ Logout Button (Employee)

```
<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```

#### 🟢 STEP 4 — USING API FUNCTIONS (REAL DATA)

#### ✅ Employee Profile (Employee Page)

```
<script>
async function loadProfile() {
    try {
        const data = await secureFetch(apiBase + "/employee/profile");

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
        document.getElementById("profile-salary").innerText = data.salary;
        document.getElementById("profile-start").innerText = data.start_date;
    } catch (err) {
        alert("Failed to load profile");
    }
}

loadProfile();
</script>
```

#### ✅ Admin Fetch All Employees (Admin Page)

```
<script>
async function loadEmployees() {
    try {
        const data = await secureFetch(apiBase + "/admin/employees");
        console.log("Employees:", data);
    } catch (err) {
        alert("Unauthorized or failed request");
    }
}
</script>
```

#### 🟢 STEP 5 — LOGOUT FLOW (BOTH PAGES)

#### Button

```
<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```
### 4️⃣ BACKEND  - Lambda 

#### 1️⃣ COMMON SECURITY TEMPLATE (Python)

```
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Request received")
    logger.info(event)

    # Role check from Cognito JWT
    groups = event['requestContext']['authorizer']['claims'].get('cognito:groups', [])
    
    # Example: Only Admin for admin function
    if 'Admin' not in groups and event['resource'] == "/admin/employees":
        return {
            "statusCode": 403,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Forbidden"})
        }

    # Function logic goes here
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Success"})
    }
```

**✅ Use this template in all Lambda functions and only adjust the logic for checkin/checkout vs admin/employee.**



#### 2️⃣ — PERFORMANCE & SAFETY SETTINGS

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

### ✅ STEP 7 — FULL TEST & VERIFICATION (NO SKIP)

#### 🧪 TEST 1 — Employee Normal Flow

1️⃣ Login as Employee

2️⃣ Open employee portal

3️⃣ Profile loads

4️⃣ Attendance loads

5️⃣ Admin buttons NOT visible

✅ PASS

#### 🧪 TEST 2 — Employee Tries Admin URL

1️⃣ Login as Employee

2️⃣ Open admin-dashboard.html manually

❌ Access denied

✅ Redirect to login

#### 🧪 TEST 3 — Admin Normal Flow

1️⃣ Login as Admin

2️⃣ Open admin dashboard

3️⃣ Admin buttons visible

4️⃣ Employee list loads

✅ PASS

#### 🧪 TEST 4 — JWT Verification

1️⃣ Open DevTools → Network

2️⃣ Click any API call

3️⃣ Check Headers

#### You MUST see:

```
Authorization: eyJraWQiOiJ...
```

✅ Token attached

✅ Cognito authorizer working

#### 🧪 TEST 5 — API Protection

1️⃣ Copy API URL

2️⃣ Open in browser without token

❌ 401 / 403 error

✅ Secure

#### ☕ WHAT YOU HAVE BUILT (REALITY CHECK)

✔ Secure frontend → backend integration

✔ Cognito JWT handled correctly

✔ Role-based UI control

✔ Role-based API security

✔ HR system architecture

✔ Resume + interview ready

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 6️⃣ — PRODUCTION HARDENING (ENTERPRISE-GRADE)

















🧪 FINAL VERIFICATION CHECKLIST (CRITICAL)
✅ Authentication

Token expires → auto logout

Logout destroys session

Back button blocked

✅ Authorization

Admin cannot be Employee

Employee cannot be Admin

Backend blocks unauthorized API calls

✅ UX

Loader visible

Errors friendly

No raw error messages

✅ Observability

CloudWatch logs visible

Errors traceable

Requests traceable

🎓 HOW YOU EXPLAIN THIS IN INTERVIEW

“I hardened the system by centralizing configuration, implementing JWT expiration handling, role-based access at both frontend and backend, global error handling, UX loaders, and CloudWatch observability.”

That answer = strong hire signal.

🏁 CONGRATULATIONS

You now have:

✔ Real AWS architecture
✔ Secure Cognito auth
✔ Role-based UI
✔ Hardened APIs
✔ Production-level frontend
✔ Job-ready project







**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 6️⃣ — Update CafePDFReportLambda for HR & Attendance

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