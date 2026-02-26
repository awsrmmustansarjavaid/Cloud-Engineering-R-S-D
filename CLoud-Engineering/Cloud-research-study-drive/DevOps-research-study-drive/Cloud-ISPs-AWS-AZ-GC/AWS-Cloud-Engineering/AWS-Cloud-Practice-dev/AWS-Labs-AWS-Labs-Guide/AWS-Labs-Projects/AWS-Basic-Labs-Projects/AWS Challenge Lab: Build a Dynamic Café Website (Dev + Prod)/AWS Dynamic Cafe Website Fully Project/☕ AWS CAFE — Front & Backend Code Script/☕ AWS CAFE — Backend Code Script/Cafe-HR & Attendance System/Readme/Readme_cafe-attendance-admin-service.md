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

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 8️⃣ — HR Attendance Dashboard

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



**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---

