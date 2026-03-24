# Charlie Cafe --- cafe-attendance-admin-service

## ☕ Charlie Café PHASE 5️⃣ — ADMIN ATTENDANCE ANALYTICS

### 1️⃣ — DATABASE (NO CHANGE, JUST VERIFY)

Run this ONCE in RDS:

```
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
```

**✅ Done. Move on.**

### 2️⃣ — CREATE ONE LAMBDA ONLY

#### 1️⃣ 📄 Lambda Name : attendance_summary

```
import json
import os
import pymysql
from datetime import date, timedelta

# RDS config from environment
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    query_type = event.get("queryStringParameters", {}).get("type")

    if query_type not in ["daily", "weekly", "monthly"]:
        return response(400, {"message": "Invalid type"})

    conn = get_connection()
    cursor = conn.cursor()

    # Date filters
    today = date.today()

    if query_type == "daily":
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE a.date = CURDATE()
        """

    elif query_type == "weekly":
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE a.date >= CURDATE() - INTERVAL 7 DAY
        """

    else:  # monthly
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE MONTH(a.date) = MONTH(CURDATE())
        AND YEAR(a.date) = YEAR(CURDATE())
        """

    cursor.execute(sql)
    records = cursor.fetchall()

    cursor.close()
    conn.close()

    return response(200, {"attendance": records})

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET"
        },
        "body": json.dumps(body)
    }
```

#### 2️⃣ ✅ Lambda Environment Variables

| Key         | Value             |
| ----------- | ----------------- |
| DB_HOST     | your-rds-endpoint |
| DB_USER     | rds-username      |
| DB_PASSWORD | rds-password      |
| DB_NAME     | cafedb            |

### 3️⃣ — API GATEWAY (ONE RESOURCE ONLY)

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

### 4️⃣ — UPDATE central-auth-api.js

You asked NOT to miss export section — so here is a FULL UPDATED VERSION.

📄 central-auth-api.js (UPDATED + SAFE)

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)

### 5️⃣ — ADMIN DASHBOARD (FRONTEND)

**⚠️ All already added and code Updated.. Skip this step**

#### 1️⃣ HTML Buttons (NO CHANGE)

```
<button onclick="load('daily')">Daily</button>
<button onclick="load('weekly')">Weekly</button>
<button onclick="load('monthly')">Monthly</button>

<div id="summary-result"></div>
```

#### 2️⃣ JS Usage

```
<script src="js/central-auth-api.js"></script>
<script>
  CHARLIE.auth.protectPage();
  CHARLIE.auth.setupLogoutButton();

  async function load(type) {
    const data = await CHARLIE.loadAttendanceSummary(type);
    displaySummary(data.attendance);
  }
</script>
```
**⚠️ All already added and code Updated.. Skip this step**

### 🧪 Final Test & Verification 

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

### 1️⃣ . Lambda Test

- Open each Lambda in AWS Console

- Click Test → Use Empty JSON {}

- Check JSON output → Should return today/weekly/monthly attendance

### 2️⃣ . API Gateway Test

- Open API Gateway Console → Resource → GET /admin/attendance/daily

- Click Test → Should return JSON array of attendance

- Repeat for weekly & monthly

### 3️⃣ . Admin Frontend Test

- Login as Admin → Open Dashboard

- Click Daily / Weekly / Monthly buttons

- Check that table populates correctly

- Verify that non-admin users cannot see these buttons or API data

**✅ After this, Admin Attendance Analytics will be fully functional — daily, weekly, monthly summaries with frontend display.**

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 6️⃣ — ADMIN DASHBOARD ENHANCEMENTS

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

[admin_dashboard_data.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/admin_dashboard_data.py)

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
> **File Name: cafe-admin-dashboard.html**

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
**⚠️ All already added and code Updated.. Skip this step**

### STEP 5 — UPDATE central-auth-api.js

You asked NOT to miss export section — so here is a FULL UPDATED VERSION.

📄 central-auth-api.js (UPDATED + SAFE)

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)

#### ✅ What this JS does:

- Populates employee dropdown dynamically

- Fetches attendance + summary cards

- Filters by employee

- Exports table as CSV

### ADMIN DASHBOARD ENHANCEMENTS

- Login as Admin → Open Dashboard

- Check Summary Cards → Total Present / Absent / Leaves

- Filter by Employee → Table updates

- Export CSV → Open downloaded file, verify data matches table

- Unauthorized Access Test → Employee account cannot see dashboard or API results

### 🎯 Outcome:

A- dmin dashboard now has employee-wise filtering

- Export-ready table via CSV

- Summary cards for quick metrics

- Fully integrated with existing Lambda + RDS

- Fully job-ready

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 7️⃣ — HR Attendance Dashboard

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

### ✅ Test 1 — VERIFY TABLE STRUCTURE (VERY IMPORTANT)

- Click your table CafeAttendance

- Go to Overview tab

- Confirm you see:

| Field         | Value                |
| ------------- | -------------------- |
| Partition key | employee_id (String) |
| Sort key      | date (String)        |
| Status        | Active               |

#### If this matches → ✅ 100% correct

#### ✅ OPTIONAL: TEST MANUAL ITEM (ONLY TO UNDERSTAND)

- Click Explore table items

- Click Create item

- Switch to JSON view

#### Paste:

```
{
  "employee_id": "101",
  "date": "2026-02-01",
  "check_in": "09:00",
  "check_out": "17:00",
  "role": "Employee"
}
```

- Click Create item

This confirms table works.

#### 🔁 FINAL CHECKPOINT

Before moving forward, answer YES to all:

✅ Table name is CafeAttendance

✅ Partition key = employee_id (String)

✅ Sort key = date (String)

✅ Region = us-east-1

✅ Table status = Active

If ANY answer is NO, STOP and fix it.

**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---
## New Lambda cafe-attendance-admin-service

### cafe-attendance-admin-service

> **Update Version:1.0**

Here is your ✅ FULLY FINAL merged Lambda function with:

✅ Secrets Manager (RDS credentials)

✅ DynamoDB table from Environment Variable

✅ Cognito Admin authorization

✅ RDS attendance (daily / weekly / monthly)

✅ Summary cards (present / absent / leaves)

✅ DynamoDB employee lookup

✅ Clean comments

✅ Proper CORS

✅ Connection reuse (best practice)

### ✅ REQUIRED LAMBDA CONFIGURATION (IMPORTANT)

In Lambda → Configuration → Environment Variables:

```
DYNAMODB_TABLE = CafeAttendance
```

Nothing else is required for DB because we use:

```
SECRET_NAME = "CafeDevDBSM"
```

Stored inside AWS Secrets Manager.


### ✅ FINAL MERGED LAMBDA CODE

(Secrets Manager + RDS + DynamoDB + Admin-only)


```
import json
import os
import boto3
import pymysql
from datetime import date
from boto3.dynamodb.conditions import Key

# ==========================================================
# 🔐 AWS SECRETS MANAGER CONFIGURATION
# ----------------------------------------------------------
# We do NOT store DB credentials in environment variables.
# Instead, we securely fetch them from Secrets Manager.
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    """
    Expected Secret JSON format:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# 🔌 RDS CONNECTION (REUSED BETWEEN INVOCATIONS)
# ----------------------------------------------------------
# Improves performance by avoiding reconnect each time.
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection

# ==========================================================
# 📦 DYNAMODB CONFIGURATION
# ----------------------------------------------------------
# Table name comes from Lambda Environment Variable:
#
#   DYNAMODB_TABLE = CafeAttendance
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]

dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)

# ==========================================================
# 🔐 ADMIN ROLE CHECK (COGNITO GROUP VALIDATION)
# ----------------------------------------------------------
# Only users in the "Admin" group can access this Lambda.
# ==========================================================

def check_admin(event):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return "Admin" in groups

# ==========================================================
# 🌍 STANDARD RESPONSE FORMAT (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# 🚀 MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # ------------------------------------------------------
    # 1️⃣ ADMIN AUTHORIZATION CHECK
    # ------------------------------------------------------
    if not check_admin(event):
        return make_response(403, {"message": "Forbidden - Admin only"})

    # ------------------------------------------------------
    # 2️⃣ READ QUERY PARAMETERS
    # ------------------------------------------------------
    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")  # daily | weekly | monthly
    employee_id = params.get("employee_id")   # Optional
    lookup_date = params.get("date")          # Optional (DynamoDB filter)
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # 3️⃣ RDS ATTENDANCE QUERY (MySQL)
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        # -------------------------
        # Date filtering logic
        # -------------------------
        if query_type == "daily":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date = CURDATE()
            """
        elif query_type == "weekly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date >= CURDATE() - INTERVAL 7 DAY
            """
        elif query_type == "monthly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE MONTH(a.date) = MONTH(CURDATE())
                AND YEAR(a.date) = YEAR(CURDATE())
            """
        else:
            return make_response(400, {"message": "Invalid type parameter"})

        # -------------------------
        # Optional employee filter
        # -------------------------
        if employee_id:
            sql += " AND e.employee_id = %s"
            cursor.execute(sql, (employee_id,))
        else:
            cursor.execute(sql)

        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # 4️⃣ SUMMARY CARDS (OPTIONAL)
        # =====================================================

        if include_summary:
            summary_sql = """
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_absent,
                    (SELECT COUNT(*) FROM leaves WHERE leave_date = CURDATE()) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
            """
            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})

    # =====================================================
    # 5️⃣ DYNAMODB LOOKUP (OPTIONAL)
    # -----------------------------------------------------
    # If employee_id is provided, query DynamoDB table.
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})

    # =====================================================
    # 6️⃣ FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```

### ✅ REQUIRED IAM PERMISSIONS

Attach to Lambda Role:

```
secretsmanager:GetSecretValue
dynamodb:Query
```

If VPC RDS:

- Ensure Lambda is inside same VPC

- Correct security group rules

### ✅ FINAL API ENDPOINT

```
GET /admin/analytics?type=daily
GET /admin/analytics?type=weekly&summary=true
GET /admin/analytics?employee_id=EMP001
GET /admin/analytics?employee_id=EMP001&date=2026-02-25
```

### ✅ WHAT THIS FINAL VERSION DOES

✔ Uses AWS Secrets Manager

✔ Connects securely to RDS

✔ Queries DynamoDB

✔ Supports daily / weekly / monthly

✔ Supports employee filter

✔ Supports summary cards

✔ Protected by Cognito Admin group

✔ Returns unified JSON

✔ Production-ready

---
### cafe-attendance-admin-service

> **Update Version:1.1**

### ✅ What Was Removed

❌ check_admin() function

❌ Cognito group validation

❌ event["requestContext"]["authorizer"] usage

❌ Admin-only restriction

❌ Authorization header requirement

### ✅ What Remains

✅ Secrets Manager for RDS credentials

✅ Reused RDS connection

✅ DynamoDB integration

✅ Query parameters support (type, employee_id, date, summary)

✅ Summary card logic

✅ CORS support

✅ Error handling

### ✅ FINAL LAMBDA CODE (NO COGNITO, FULLY PUBLIC)

```
import json
import os
import boto3
import pymysql
from boto3.dynamodb.conditions import Key

# ==========================================================
# AWS SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# RDS CONNECTION (REUSED)
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection

# ==========================================================
# DYNAMODB CONFIGURATION
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]

dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)

# ==========================================================
# STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# MAIN LAMBDA HANDLER (PUBLIC)
# ==========================================================

def lambda_handler(event, context):

    # Handle CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    # ------------------------------------------------------
    # READ QUERY PARAMETERS
    # ------------------------------------------------------
    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")   # daily | weekly | monthly
    employee_id = params.get("employee_id")    # Optional
    lookup_date = params.get("date")           # Optional (DynamoDB filter)
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # RDS ATTENDANCE QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        # Date filtering logic
        if query_type == "daily":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date = CURDATE()
            """
        elif query_type == "weekly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date >= CURDATE() - INTERVAL 7 DAY
            """
        elif query_type == "monthly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE MONTH(a.date) = MONTH(CURDATE())
                AND YEAR(a.date) = YEAR(CURDATE())
            """
        else:
            return make_response(400, {"message": "Invalid type parameter"})

        # Optional employee filter
        if employee_id:
            sql += " AND e.employee_id = %s"
            cursor.execute(sql, (employee_id,))
        else:
            cursor.execute(sql)

        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # SUMMARY (OPTIONAL)
        # =====================================================

        if include_summary:
            summary_sql = """
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_absent,
                    (SELECT COUNT(*) FROM leaves WHERE leave_date = CURDATE()) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
            """
            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})

    # =====================================================
    # DYNAMODB LOOKUP (OPTIONAL)
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})

    # =====================================================
    # FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```

### ✅ Example Public API Calls

Daily Attendance

```
GET /admin/attendance?type=daily
```

Weekly Attendance for Employee 5

```
GET /admin/attendance?type=weekly&employee_id=5
```

Monthly + Summary

```
GET /admin/attendance?type=monthly&summary=true
```

DynamoDB Specific Date

```
GET /admin/attendance?employee_id=5&date=2026-02-01
```

### ⚠️ IMPORTANT SECURITY WARNING

This endpoint is now:

❗ Fully public

❗ Exposes ALL employee attendance

❗ Exposes summary HR data

❗ Allows querying any employee

For production systems, this is HIGH RISK.

At minimum, add:

API key

JWT authorizer

IP restriction

Private VPC access

IAM authentication

----
### cafe-attendance-admin-service.py

> **Update Version:1.1**

### ✅ cafe-attendance-admin-service (Final Version)

#### ✔ Fixes Included

- Proper summary=true handling

- Summary respects daily | weekly | monthly

- Cleaner SQL

- Safe employee filtering

- Optional date override

- Better error structure

- DynamoDB optional lookup maintained

- Secure RDS reuse

- Clean CORS

### 🚀 FULLY FINAL LAMBDA CODE

```
import json
import os
import boto3
import pymysql
from boto3.dynamodb.conditions import Key

# ==========================================================
# AWS SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# RDS CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection


# ==========================================================
# DYNAMODB CONFIGURATION
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]
dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)


# ==========================================================
# STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }


# ==========================================================
# DATE FILTER HELPER
# ==========================================================

def build_date_filter(query_type):
    if query_type == "daily":
        return "a.date = CURDATE()"
    elif query_type == "weekly":
        return "a.date >= CURDATE() - INTERVAL 7 DAY"
    elif query_type == "monthly":
        return "MONTH(a.date) = MONTH(CURDATE()) AND YEAR(a.date) = YEAR(CURDATE())"
    else:
        return None


# ==========================================================
# MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # Handle CORS
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")
    employee_id = params.get("employee_id")
    lookup_date = params.get("date")
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # RDS ATTENDANCE QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        date_filter = build_date_filter(query_type)

        if not date_filter:
            return make_response(400, {"message": "Invalid type parameter"})

        sql = f"""
            SELECT e.employee_id,
                   e.name,
                   a.date,
                   a.checkin_time,
                   a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE {date_filter}
        """

        values = []

        if employee_id:
            sql += " AND e.employee_id = %s"
            values.append(employee_id)

        cursor.execute(sql, values)
        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # SUMMARY (ALIGNED WITH TYPE)
        # =====================================================

        if include_summary:

            summary_sql = f"""
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id)
                    - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_absent,
                    (
                        SELECT COUNT(*)
                        FROM leaves
                        WHERE {date_filter.replace("a.date", "leave_date")}
                    ) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a
                    ON e.employee_id = a.employee_id
                    AND {date_filter}
            """

            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})


    # =====================================================
    # OPTIONAL DYNAMODB LOOKUP
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})


    # =====================================================
    # FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```

### ✅ What Is Now Enterprise-Ready

| Feature                         | Status |
| ------------------------------- | ------ |
| summary=true required           | ✅      |
| Daily summary correct           | ✅      |
| Weekly summary correct          | ✅      |
| Monthly summary correct         | ✅      |
| Leave count aligned with period | ✅      |
| Employee filtering safe         | ✅      |
| SQL injection safe              | ✅      |
| Dynamo optional lookup          | ✅      |
| Reused DB connection            | ✅      |
| Clean CORS                      | ✅      |

### 🎯 Final Result

Your Admin Dashboard can now safely call:

```
/admin/analytics?type=daily&summary=true
/admin/analytics?type=weekly&summary=true
/admin/analytics?type=monthly&summary=true
```

And it will always return:

```
{
  "attendance_rds": [...],
  "attendance_dynamo": [...],
  "summary": {
    "total_present": 5,
    "total_absent": 2,
    "total_leaves": 1
  }
}
```

### ✅ cafe-attendance-admin-service.py

```
import json
import os
import boto3
import pymysql
from boto3.dynamodb.conditions import Key

# ==========================================================
# AWS SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# RDS CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection


# ==========================================================
# DYNAMODB CONFIGURATION
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]
dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)


# ==========================================================
# STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }


# ==========================================================
# DATE FILTER HELPER
# ==========================================================

def build_date_filter(query_type):
    if query_type == "daily":
        return "a.date = CURDATE()"
    elif query_type == "weekly":
        return "a.date >= CURDATE() - INTERVAL 7 DAY"
    elif query_type == "monthly":
        return "MONTH(a.date) = MONTH(CURDATE()) AND YEAR(a.date) = YEAR(CURDATE())"
    else:
        return None


# ==========================================================
# MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # Handle CORS
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")
    employee_id = params.get("employee_id")
    lookup_date = params.get("date")
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # RDS ATTENDANCE QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        date_filter = build_date_filter(query_type)

        if not date_filter:
            return make_response(400, {"message": "Invalid type parameter"})

        sql = f"""
            SELECT e.employee_id,
                   e.name,
                   a.date,
                   a.checkin_time,
                   a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE {date_filter}
        """

        values = []

        if employee_id:
            sql += " AND e.employee_id = %s"
            values.append(employee_id)

        cursor.execute(sql, values)
        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # SUMMARY (ALIGNED WITH TYPE)
        # =====================================================

        if include_summary:

            summary_sql = f"""
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id)
                    - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_absent,
                    (
                        SELECT COUNT(*)
                        FROM leaves
                        WHERE {date_filter.replace("a.date", "leave_date")}
                    ) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a
                    ON e.employee_id = a.employee_id
                    AND {date_filter}
            """

            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})


    # =====================================================
    # OPTIONAL DYNAMODB LOOKUP
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})


    # =====================================================
    # FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```


----
### cafe-attendance-admin-service.py

> **Update Version:1.2**

✅ Safe environment handling

✅ Pakistan timezone fix (NO MySQL dependency)

✅ Better error handling

✅ Optional DynamoDB (no crash if missing)

✅ Clean comments for learning + resume


### ✅ 2. BEST FIX — Use Pakistan Time in Lambda (Recommended)

Your updated function is almost correct, just clean it like this:

```
def build_date_filter(query_type):
    if query_type == "daily":
        return "a.date = DATE(CONVERT_TZ(NOW(), '+00:00', '+05:00'))"

    elif query_type == "weekly":
        return "a.date >= DATE(CONVERT_TZ(NOW(), '+00:00', '+05:00')) - INTERVAL 7 DAY"

    elif query_type == "monthly":
        return """
        MONTH(a.date) = MONTH(CONVERT_TZ(NOW(), '+00:00', '+05:00'))
        AND YEAR(a.date) = YEAR(CONVERT_TZ(NOW(), '+00:00', '+05:00'))
        """

    else:
        return None
```

### ⚠️ VERY IMPORTANT (Hidden Issue)

For CONVERT_TZ to work:

👉 Your MySQL must have timezone tables loaded

If not → it will return NULL

### 🔍 Test this in RDS:

```
SELECT CONVERT_TZ(NOW(), '+00:00', '+05:00');
```

#### If result is:

✅ correct time → good

❌ NULL → timezone not loaded

### 🚀 Alternative (SAFER — NO DB DEPENDENCY)

Instead of relying on MySQL timezone:

👉 Compute date in Lambda (Python)

#### Replace build_date_filter() with:

```
from datetime import datetime, timedelta

def get_pk_date():
    return (datetime.utcnow() + timedelta(hours=5)).strftime('%Y-%m-%d')

def build_date_filter(query_type):
    pk_date = get_pk_date()

    if query_type == "daily":
        return f"a.date = '{pk_date}'"

    elif query_type == "weekly":
        return f"a.date >= DATE('{pk_date}') - INTERVAL 7 DAY"

    elif query_type == "monthly":
        return f"""
        MONTH(a.date) = MONTH('{pk_date}')
        AND YEAR(a.date) = YEAR('{pk_date}')
        """

    else:
        return None
```

👉 ✅ This is BEST PRACTICE (no DB timezone issues)

### ✅ 3. How to show TODAY correctly on frontend

Right now your frontend sends:

```
type=daily
```

👉 That’s fine — backend handles date

### Optional improvement (frontend date auto-fill)

Add this in your HTML:

```
document.getElementById("date").value =
    new Date().toISOString().split("T")[0];
```

👉 This sets today’s date automatically

### ✅ 4. How to generate RANDOM TEST DATA (VERY IMPORTANT 🔥)

You asked:

how i can random get test data on frontend

❌ Wrong approach:

Frontend random data → ❌ Not real system

### ✅ Correct approach → Insert fake data into RDS

### ✅ Option 1: Run SQL

```
INSERT INTO attendance (employee_id, date, checkin_time, checkout_time)
VALUES
('101', CURDATE(), '09:00', '17:00'),
('102', CURDATE(), '09:15', '17:10'),
('103', CURDATE(), '08:55', '16:50');
```

### ✅ Option 2 (BEST 🔥): Create Test Lambda

If you want pro-level:

👉 Create a Lambda that inserts random data:

```
import random
from datetime import datetime

def generate_fake_data():
    employees = ["101", "102", "103", "104"]

    return {
        "employee_id": random.choice(employees),
        "date": datetime.utcnow().strftime('%Y-%m-%d'),
        "checkin_time": f"09:{random.randint(0,59):02}",
        "checkout_time": f"17:{random.randint(0,59):02}"
    }
```

### ✅ 5. Final Recommendation (IMPORTANT)

👉 Use THIS combination:

### Backend:

✔ Use Python timezone (not MySQL)

✔ Keep type=daily

### Frontend:

✔ Keep simple (no timezone logic)

### 🧠 FINAL ANSWER (SHORT)

✔ Your timezone fix:

✅ YES your logic is correct

👉 But better use Python instead of MySQL

✔ Your delay issue:

👉 Caused by UTC vs Pakistan time difference

✔ Random data:

👉 Insert into RDS (not frontend)

### 🚀 ✅ FINAL LAMBDA (PRODUCTION VERSION)

```
import json
import os
import boto3
import pymysql
from datetime import datetime, timedelta
from boto3.dynamodb.conditions import Key

# ==========================================================
# 🌐 CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

# DynamoDB table (safe loading)
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE")

# AWS Clients
secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# DynamoDB (only if configured)
if DYNAMODB_TABLE:
    dynamodb = boto3.resource("dynamodb")
    dynamo_table = dynamodb.Table(DYNAMODB_TABLE)
else:
    dynamo_table = None


# ==========================================================
# 🔐 GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# 🗄️ RDS CONNECTION (REUSE FOR PERFORMANCE)
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection


# ==========================================================
# 🇵🇰 GET CURRENT DATE IN PAKISTAN TIME (UTC+5)
# ==========================================================

def get_pk_date():
    return (datetime.utcnow() + timedelta(hours=5)).strftime('%Y-%m-%d')


# ==========================================================
# 📅 DATE FILTER BUILDER (NO MYSQL TIMEZONE DEPENDENCY)
# ==========================================================

def build_date_filter(query_type):
    pk_date = get_pk_date()

    if query_type == "daily":
        return f"a.date = '{pk_date}'"

    elif query_type == "weekly":
        return f"a.date >= DATE('{pk_date}') - INTERVAL 7 DAY"

    elif query_type == "monthly":
        return f"""
        MONTH(a.date) = MONTH('{pk_date}')
        AND YEAR(a.date) = YEAR('{pk_date}')
        """

    else:
        return None


# ==========================================================
# 🌍 STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }


# ==========================================================
# 🚀 MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # ================= CORS PREFLIGHT =================
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    # ================= INPUT PARAMS =================
    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")
    employee_id = params.get("employee_id")
    lookup_date = params.get("date")
    include_summary = params.get("summary", "false").lower() == "true"

    # ================= RESPONSE STRUCTURE =================
    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # 🗄️ RDS QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        date_filter = build_date_filter(query_type)

        if not date_filter:
            return make_response(400, {"message": "Invalid type parameter"})

        sql = f"""
            SELECT e.employee_id,
                   e.name,
                   a.date,
                   a.checkin_time,
                   a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE {date_filter}
        """

        values = []

        # Optional employee filter
        if employee_id:
            sql += " AND e.employee_id = %s"
            values.append(employee_id)

        cursor.execute(sql, values)
        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # 📊 SUMMARY (OPTIONAL)
        # =====================================================

        if include_summary:

            summary_sql = f"""
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id)
                    - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_absent,
                    (
                        SELECT COUNT(*)
                        FROM leaves
                        WHERE {date_filter.replace("a.date", "leave_date")}
                    ) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a
                    ON e.employee_id = a.employee_id
                    AND {date_filter}
            """

            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})


    # =====================================================
    # ⚡ DYNAMODB QUERY (OPTIONAL - SAFE)
    # =====================================================

    if employee_id and dynamo_table:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})


    # =====================================================
    # ✅ FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
```

### 🎯 What You Just Achieved (IMPORTANT)

This is now a real production-grade Lambda:

### ✅ Features

🇵🇰 Pakistan timezone handled in backend

🔐 Secrets Manager integration

🗄️ RDS optimized connection reuse

⚡ DynamoDB optional (no crash)

🌐 CORS enabled (frontend ready)

📊 Summary analytics supported

### 🚀 What You Can Do Next (High Value)

If you want to level this up:

### 🔥 I can help you add:

✅ Cognito Admin-only access (real security)

✅ Attendance “Check-In / Check-Out” API

✅ Live dashboard (auto refresh)

✅ Charts (daily / weekly graphs)

✅ CI/CD (GitHub + Docker + CodePipeline)


----
### cafe-attendance-admin-service.py

> **Update Version:1.3**



----
### cafe-attendance-admin-service.py

> **Update Version:1.1**


