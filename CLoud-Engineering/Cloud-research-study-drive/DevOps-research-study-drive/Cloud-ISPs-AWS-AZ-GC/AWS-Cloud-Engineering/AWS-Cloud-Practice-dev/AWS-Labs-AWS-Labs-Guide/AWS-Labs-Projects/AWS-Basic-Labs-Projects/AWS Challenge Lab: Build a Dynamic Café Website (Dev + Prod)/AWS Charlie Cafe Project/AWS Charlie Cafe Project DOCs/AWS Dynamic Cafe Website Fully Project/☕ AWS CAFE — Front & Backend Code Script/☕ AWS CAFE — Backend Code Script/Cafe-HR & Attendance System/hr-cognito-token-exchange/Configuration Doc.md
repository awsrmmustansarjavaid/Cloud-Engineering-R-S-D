# Charlie Cafe - hr-cognito-token-exchange

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

[hr-cognito-token-exchange.py](./hr-cognito-token-exchange.py)

- Deploy

### 3️⃣ Configure Environment Variables

- Go to: Lambda → Configuration → Environment Variables

- Add:

| Key                  | Value                                                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| CLIENT_ID            | 7c5793cnvnbl110ljthmdiohch                                                                                               |
| COGNITO_DOMAIN       | https://us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com                                                                      |
| COGNITO_REDIRECT_URI | [https://d2xb54di3chfgj.cloudfront.net/employee-portal.html](https://d2xb54di3chfgj.cloudfront.net/employee-portal.html) |


- Save.

### 5️⃣ hr-cognito-token-exchange

- Click Test → Configure test event

- Event name: tokenTest

- **Test JSON:**

```
{
  "body": "{\"code\":\"TEST_AUTH_CODE\"}"
}
```

#### ✅ Expected Results

Because the code is fake:

```
{
 "statusCode": 500,
 "body": "{\"error\":\"HTTP Error 400: Bad Request\"}"
}
```

#### This means:

✅ Lambda executed correctly

✅ Cognito endpoint reached

### ✅ RDS Verification


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

---
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

| Method | Resource           | Path                   | Lambda Function             |
|-------|-------------------|------------------------|-----------------------------|
| POST  | Attendance        | `/attendance/checkin`  | `hr-attendance`             |
| POST  | Attendance        | `/attendance/checkout` | `hr-attendance`             |
|  POST    | Employee Profile  | `/employee-profile`    | `hr-employee-profile`       |
|  POST   | Attendance History| `/attendance-history`  | `hr-attendance-history`     |
|  POST    | Leaves & Holidays | `/leaves-holidays`     | `hr-leaves-holidays`        |
| POST  | Exchange Token    | `/exchange-token`      | `hr-cognito-token-exchange` |

---
### API.JS

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD)
   ---------------------------------------------------------
   ✅ Single Stage: /prod (from CONFIG.API_BASE)
   ✅ Public HR APIs (no Cognito/Auth headers)
   ✅ Dedicated HR helpers fixed to correct Lambda endpoints
   ✅ Fully compatible with checkin.html & employee-portal.html
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG; // Load API base from config.js

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Centralized fetch for all API calls
       - Handles JSON parsing & throws errors for non-200 responses
    ===================================================== */
    async function apiFetch(url, options = {}) {

    const response = await fetch(url, {
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API Error: ${errorText}`);
    }

    const data = await response.json();

    // unwrap Lambda proxy response
    if (typeof data.body === "string") {
        return JSON.parse(data.body);
    }

    return data;
}

    /* =====================================================
       🛒 CUSTOMER ORDERS
       - Example: Coffee orders, status tracking, employee orders
    ===================================================== */
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, { method: "POST", body: JSON.stringify(payload) });
    }

    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, { method: "POST", body: JSON.stringify(payload) });
    }

    function getOrderStatus(orderId) {
        return apiFetch(`${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`);
    }

    function getCafeOrderStatus(orderId) {
        return apiFetch(`${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`);
    }

    function getGetOrderStatus(orderId) {
        return apiFetch(`${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`);
    }

    async function getOrders() {
        const res = await fetch(`${CONFIG.API_BASE}/get-order-status`);
        if (!res.ok) throw new Error(await res.text());
        const data = await res.json();
        return typeof data.body === "string" ? JSON.parse(data.body) : data;
    }

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, { method: "POST", body: JSON.stringify(payload) });
    }

  // ================== ADMIN — MARK CASH ORDER AS PAID ==================
    function markCashOrderPaid(orderId) {
        return apiFetch(`${CONFIG.API_BASE}/admin/mark-paid`, {
            method: "POST",
            body: JSON.stringify({ order_id: orderId })
        });
    }

// ================== ADMIN — ANALYTICS (PUBLIC READ) ==================
function getAnalytics(period = "today") {
    const url = `${CONFIG.API_BASE}/analytics?period=${encodeURIComponent(period)}`;
    return apiFetch(url);
}

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - Check-in / Check-out API
       - Does NOT require Cognito token
       - Called by checkin.html fingerprint simulation
       - ✅ FIXED: Now calls /attendance/checkin or /attendance/checkout
    ===================================================== */
    function recordAttendance(payload) {
        // payload: { employee_id, action: "checkin"|"checkout" }
        const url = `${CONFIG.API_BASE}/attendance/${payload.action}`;
        return apiFetch(url, {
            method: "POST",
            body: JSON.stringify({
            employee_id: payload.employee_id,
            action: payload.action
            })
            });
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       🟢 DEDICATED HR HELPERS — FIXED ENDPOINTS
       - Correctly call Lambda endpoints
       - Fully aligned with employee-portal.html
    ===================================================== */

    function getEmployeeProfile(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/employee-profile`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    function getAttendanceHistory(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance-history`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    function getLeavesAndHolidays(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/leaves-holidays`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS (PUBLIC READ)
       - Daily / Weekly / Monthly summaries
       - Optional admin dashboard integration
    ===================================================== */
    const adminAttendance = {
    getDailySummary() { 
        return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=daily`); 
    },
    getWeeklySummary() { 
        return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=weekly`); 
    },
    getMonthlySummary() { 
        return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=monthly`); 
    }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
       - Fetch dashboard data
       - Create users
    ===================================================== */
    const adminDashboard = {
        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) url += `?employee_id=${encodeURIComponent(employeeId)}`;
            return apiFetch(url);
        },
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        }
    };

    /* =====================================================
       🔐 AUTH — COGNITO TOKEN EXCHANGE
       - Exchanges OAuth authorization code for id_token
       - Uses API Gateway → Lambda → Cognito
       ===================================================== */

        function exchangeCognitoToken(code) {
            return apiFetch(`${CONFIG.API_BASE}/exchange-token`, {
        method: "POST",
        body: JSON.stringify({ code: code })
    });
    }

    /* =====================================================
       🚀 EXPORT ALL APIs
       - Orders, HR (public), HR helpers, Admin
    ===================================================== */
    return {
        // Orders
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
 	    markCashOrderPaid,
        getOrders,
        getEmployeeOrders,
        createEmployeeOrder,

 	    // ADMIN — ANALYTICS 
   	    getAnalytics,

    	// ADMIN — ATTENDANCE ANALYTICS
        adminAttendance,

        // HR Attendance Public
        recordAttendance,
        getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        adminDashboard,

        // Cognito AUTH
        exchangeCognitoToken,  // ✅ Add this

    };

})();
```

---
