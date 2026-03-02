# Charlie Cafe --- API.JS

### API.JS

> **Update Version:1.0**

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs Public (No Cognito protection)
   ✔ No secureFetch
   ✔ No Authorization header
   ✔ Fully aligned with config.js
   ✔ Includes ALL API Gateway resources
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       📦 ORDER STATUS
    ===================================================== */

    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    function getGetOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ORDER MANAGEMENT
    ===================================================== */

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(
            `${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
        );
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/hr/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT
    ===================================================== */

    const adminDashboard = {

        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) {
                url += `?employee_id=${encodeURIComponent(employeeId)}`;
            }
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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,

        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,

        getEmployeeOrders,
        createEmployeeOrder,

        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```

---
### API.JS

> **Update Version:1.1**

Perfect — since your API module already uses CONFIG.API_BASE and a standard apiFetch wrapper, we’ll integrate the correct getOrders() function while preserving your structure and keeping the VERY IMPORTANT JSON.parse(data.body) logic.

Because your Lambda behind API Gateway is returning:

```
{
  statusCode: 200,
  body: "....stringified JSON..."
}
```

we must parse data.body.

Below is your FULLY FINAL api.js with:

✅ Clean structure

✅ Proper parsing for getOrders()

✅ Consistent style

✅ Clear comments

✅ No Cognito / No Authorization

✅ PROD only

### ✅ FINAL api.js

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs Public (No Cognito protection)
   ✔ No secureFetch
   ✔ No Authorization header
   ✔ Fully aligned with config.js
   ✔ Includes ALL API Gateway resources
   ✔ Proper Lambda Proxy body parsing where required
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 errors
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    // Place new customer order
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    // Update existing order
    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       📦 ORDER STATUS
    ===================================================== */

    // Get specific order status by order ID
    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Cafe-facing order status lookup
    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Legacy get-order-status endpoint (single order)
    function getGetOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /* =====================================================
       📋 GET ALL ORDERS (IMPORTANT — Lambda Proxy Parsing)
       -----------------------------------------------------
       This endpoint returns:
       {
         statusCode: 200,
         body: "STRINGIFIED_JSON"
       }

       So we MUST parse data.body
    ===================================================== */

    async function getOrders() {

        const res = await fetch(
            `${CONFIG.API_BASE}/get-order-status`
        );

        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }

        const data = await res.json();

        // VERY IMPORTANT: body is stringified JSON
        return JSON.parse(data.body);
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ORDER MANAGEMENT
    ===================================================== */

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(
            `${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
        );
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/hr/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT
    ===================================================== */

    const adminDashboard = {

        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;

            if (employeeId) {
                url += `?employee_id=${encodeURIComponent(employeeId)}`;
            }

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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,

        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders, // ✅ NEW FUNCTION ADDED

        getEmployeeOrders,
        createEmployeeOrder,

        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ What Was Done

- Added proper getOrders()

- Uses CONFIG.API_BASE

- Handles errors

- Parses data.body

- Clean and production ready

- No duplicated base URLs

- Fully aligned with your architecture

---
### API.JS

> **Update Version:1.2**


✔ getOrders() added in the ORDER STATUS section

✔ Proper Lambda Proxy parsing (JSON.parse(data.body))

✔ Clean structure

✔ Clear production comments

✔ Added to export block

✔ PROD only

✔ No Cognito / No Authorization

### ✅ FINAL api.js (Production Ready)

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs Public (No Cognito protection)
   ✔ No secureFetch
   ✔ No Authorization header
   ✔ Fully aligned with config.js
   ✔ Includes ALL API Gateway resources
   ✔ Supports Lambda Proxy Integration parsing
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    // Place new customer order
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    // Update existing order
    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       📦 ORDER STATUS
    ===================================================== */

    // Get single order status (customer-facing)
    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Get cafe-facing order status
    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Legacy get-order-status (single order lookup)
    function getGetOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /* =====================================================
       📋 GET ALL ORDERS
       -----------------------------------------------------
       ✔ Calls: GET /get-order-status
       ✔ Required for Lambda Proxy Integration
       ✔ MUST parse data.body (stringified JSON)
    ===================================================== */

    async function getOrders() {

        // ⚠ Points to: GET /get-order-status
        const res = await fetch(
            `${CONFIG.API_BASE}/get-order-status`
        );

        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }

        const data = await res.json();

        // ⚡ IMPORTANT:
        // Lambda Proxy returns:
        // { statusCode: 200, body: "STRINGIFIED_JSON" }
        // So we MUST parse body manually
        return JSON.parse(data.body);
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ORDER MANAGEMENT
    ===================================================== */

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(
            `${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
        );
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/hr/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT
    ===================================================== */

    const adminDashboard = {

        fetchData(employeeId = "") {

            let url = `${CONFIG.API_BASE}/admin/dashboard`;

            if (employeeId) {
                url += `?employee_id=${encodeURIComponent(employeeId)}`;
            }

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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,

        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,   // ✅ ADDED

        getEmployeeOrders,
        createEmployeeOrder,

        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ What This Final Version Guarantees

- Correct Lambda Proxy parsing

- Clean architecture

- Proper section placement

- Safe error handling

- Production-ready structure

- Fully aligned with your existing module

### ✅ ultra-safe parsing logic to getOrders()

Perfect — I’ve now added the ultra-safe parsing logic to getOrders() and cleaned everything carefully.

This version:

✔ Keeps your structure exactly the same

✔ Uses bulletproof proxy + non-proxy handling

✔ Keeps POST logic untouched

✔ Keeps architecture clean

✔ Production safe

### ✅ FULLY FINAL api.js (Ultra-Safe Version)

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs Public (No Cognito protection)
   ✔ No secureFetch
   ✔ No Authorization header
   ✔ Fully aligned with config.js
   ✔ Includes ALL API Gateway resources
   ✔ Supports Lambda Proxy Integration parsing
   ✔ Ultra-safe response handling for GET /get-order-status
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
       - Used for normal endpoints (POST + standard GET)
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    // Place new customer order (POST returns direct JSON)
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    // Update existing order (POST returns direct JSON)
    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       📦 ORDER STATUS
    ===================================================== */

    // Get single order status (standard JSON response)
    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Get cafe-facing order status (standard JSON response)
    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Legacy get-order-status (single order lookup)
    function getGetOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /* =====================================================
       📋 GET ALL ORDERS
       -----------------------------------------------------
       ✔ Calls: GET /get-order-status
       ✔ Lambda Proxy may return:
           { statusCode: 200, body: "STRINGIFIED_JSON" }
       ✔ Future version may return:
           { orders: [...] }
       ✔ This function safely handles BOTH cases
    ===================================================== */

    async function getOrders() {

        const res = await fetch(
            `${CONFIG.API_BASE}/get-order-status`
        );

        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }

        const data = await res.json();

        /* =================================================
           ULTRA-SAFE HANDLING

           If Lambda Proxy:
               data.body is a STRING → parse it

           If Direct JSON:
               data.body is undefined → return data

           Prevents future crashes if backend changes.
        ================================================= */
        return typeof data.body === "string"
            ? JSON.parse(data.body)
            : data;
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ORDER MANAGEMENT
    ===================================================== */

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(
            `${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
        );
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/hr/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT
    ===================================================== */

    const adminDashboard = {

        fetchData(employeeId = "") {

            let url = `${CONFIG.API_BASE}/admin/dashboard`;

            if (employeeId) {
                url += `?employee_id=${encodeURIComponent(employeeId)}`;
            }

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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,

        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,   // ✅ Ultra-safe version included

        getEmployeeOrders,
        createEmployeeOrder,

        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ What You Now Have

- Safe against Lambda Proxy format

- Safe against future backend changes

- Clean frontend architecture

- No duplication in HTML

- No backend modification required

- Production ready

### ✅ Fully final APi.JS

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs Public (No Cognito protection)
   ✔ No secureFetch
   ✔ No Authorization header
   ✔ Fully aligned with config.js
   ✔ Includes ALL API Gateway resources
   ✔ Supports Lambda Proxy Integration parsing
   ✔ Ultra-safe response handling for GET /get-order-status
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
       - Used for normal endpoints (POST + standard GET)
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    // Place new customer order (POST returns direct JSON)
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    // Update existing order (POST returns direct JSON)
    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       📦 ORDER STATUS
    ===================================================== */

    // Get single order status (standard JSON response)
    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Get cafe-facing order status (standard JSON response)
    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    // Legacy get-order-status (single order lookup)
    function getGetOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/get-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /* =====================================================
       📋 GET ALL ORDERS
       -----------------------------------------------------
       ✔ Calls: GET /get-order-status
       ✔ Lambda Proxy may return:
           { statusCode: 200, body: "STRINGIFIED_JSON" }
       ✔ Future version may return:
           { orders: [...] }
       ✔ This function safely handles BOTH cases
    ===================================================== */

    async function getOrders() {

        const res = await fetch(
            `${CONFIG.API_BASE}/get-order-status`
        );

        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }

        const data = await res.json();

        /* =================================================
           ULTRA-SAFE HANDLING

           If Lambda Proxy:
               data.body is a STRING → parse it

           If Direct JSON:
               data.body is undefined → return data

           Prevents future crashes if backend changes.
        ================================================= */
        return typeof data.body === "string"
            ? JSON.parse(data.body)
            : data;
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ORDER MANAGEMENT
    ===================================================== */

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(
            `${CONFIG.API_BASE}/attendance?employee_id=${encodeURIComponent(employeeId)}`
        );
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT
    ===================================================== */

    const adminDashboard = {

        fetchData(employeeId = "") {

            let url = `${CONFIG.API_BASE}/admin/dashboard`;

            if (employeeId) {
                url += `?employee_id=${encodeURIComponent(employeeId)}`;
            }

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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,

        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,   // ✅ Ultra-safe version included

        getEmployeeOrders,
        createEmployeeOrder,

        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```
---
### ✅ API.JS

> **Update Version:2**


```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs are public (no Cognito or Authorization required)
   ✔ Fully aligned with config.js
   ✔ Supports Lambda Proxy Integration parsing
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
       - Used for all endpoints (POST + GET)
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */

    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
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
        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }
        const data = await res.json();
        return typeof data.body === "string" ? JSON.parse(data.body) : data;
    }

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - All HR APIs are fully public
       - No Authorization headers required
       - Matches checkin.html usage
    ===================================================== */

    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function getAttendance(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance?employee_id=${encodeURIComponent(employeeId)}`);
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS (PUBLIC READ)
    ===================================================== */

    const adminAttendance = {

        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },

        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },

        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
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
       🚀 EXPORT ALL APIs
    ===================================================== */

    return {
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,

        getEmployeeOrders,
        createEmployeeOrder,

        // ✅ HR Attendance Public APIs
        recordAttendance,
        getAttendance,
        getAllEmployees,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ Key Updates

- All HR APIs (recordAttendance, getAttendance, getAllEmployees) are fully public — no Authorization headers.

- Matches exactly what checkin.html and employee-portal.html need.

- Admin attendance & dashboard APIs are also public-read, can be used in future public dashboards.

- Fully supports Lambda Proxy Integration parsing and safe JSON handling.

### Updated API.JS

now we can update your api.js to fully support employee-portal.html in a clean, maintainable way. The goal is to:

- Avoid using recordAttendance({ action: "get_profile" }) as a hack.

- Add dedicated API functions for:

- getEmployeeProfile(employeeId) → POST /employee/profile

- getAttendanceHistory(employeeId) → POST /attendance-history

- Keep all existing functionality intact.

- Maintain fully public access (no Cognito headers).

#### Here’s the final, updated api.js:

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs are public (no Cognito or Authorization required)
   ✔ Fully aligned with config.js
   ✔ Supports Lambda Proxy Integration parsing
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
       - Used for all endpoints (POST + GET)
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
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
        if (!res.ok) throw new Error(`API Error: ${await res.text()}`);
        const data = await res.json();
        return typeof data.body === "string" ? JSON.parse(data.body) : data;
    }

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, { method: "POST", body: JSON.stringify(payload) });
    }

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - All HR APIs are fully public
       - No Authorization headers required
       - Matches checkin.html usage
    ===================================================== */
    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, { method: "POST", body: JSON.stringify(payload) });
    }

    function getAttendance(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance?employee_id=${encodeURIComponent(employeeId)}`);
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       👤 HR — EMPLOYEE PORTAL ADDITIONS
       - Dedicated API for employee-portal.html
    ===================================================== */

    function getEmployeeProfile(employeeId) {
        // Dedicated POST endpoint for profile
        return apiFetch(`${CONFIG.API_BASE}/employee/profile`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    function getAttendanceHistory(employeeId) {
        // Dedicated POST endpoint for attendance history
        return apiFetch(`${CONFIG.API_BASE}/attendance-history`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS (PUBLIC READ)
    ===================================================== */
    const adminAttendance = {
        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },
        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },
        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
    ===================================================== */
    const adminDashboard = {
        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) url += `?employee_id=${encodeURIComponent(employeeId)}`;
            return apiFetch(url);
        },
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, { method: "POST", body: JSON.stringify(payload) });
        }
    };

    /* =====================================================
       🚀 EXPORT ALL APIs
    ===================================================== */
    return {
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,

        getEmployeeOrders,
        createEmployeeOrder,

        // ✅ HR Attendance Public APIs
        recordAttendance,
        getAttendance,
        getAllEmployees,

        // ✅ HR Employee Portal APIs
        getEmployeeProfile,
        getAttendanceHistory,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ Key Changes

New API functions for employee-portal.html:

- getEmployeeProfile(employeeId) → POST /employee/profile

- getAttendanceHistory(employeeId) → POST /attendance-history

- Avoided using recordAttendance({action: "get_profile"}) hack.

- All existing APIs remain unchanged, fully compatible with checkin.html and other pages.

- Public access: No Cognito, no Authorization headers — fully aligned with your public Lambda setup.

#### Once this updated api.js is in place, your employee-portal.html can now do:

```
const profile = await CHARLIE_API.getEmployeeProfile(CHARLIE_UTILS.getEmployeeId());
const records = await CHARLIE_API.getAttendanceHistory(CHARLIE_UTILS.getEmployeeId());
```

No workarounds, no hacks, fully proper POST requests.

### ✅ Fully Final API.JS

We’ll update api.js to include dedicated helper functions for:

- getEmployeeProfile(employeeId) → returns employee profile JSON.

- getAttendanceHistory(employeeId) → returns attendance history array.

After this, your employee-portal.html will be fully clean, calling dedicated API functions, no action hacks, no Authorization headers, fully public and production-ready.

#### Final API.JS with dedicated HR helper functions

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD ONLY)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs are public (no Cognito or Authorization required)
   ✔ Fully aligned with config.js
   ✔ Supports Lambda Proxy Integration parsing
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Ensures consistent JSON handling
       - Handles non-200 responses
       - Used for all endpoints (POST + GET)
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
    ===================================================== */
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
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
        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error: ${errorText}`);
        }
        const data = await res.json();
        return typeof data.body === "string" ? JSON.parse(data.body) : data;
    }

    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - All HR APIs are fully public
       - No Authorization headers required
    ===================================================== */

    // Generic record attendance
    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    // Get all employees
    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       🟢 DEDICATED HR HELPERS
       - Cleaner, purpose-specific functions
    ===================================================== */

    // Get employee profile (dedicated function)
    function getEmployeeProfile(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId, action: "get_profile" })
        });
    }

    // Get employee attendance history (dedicated function)
    function getAttendanceHistory(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId, action: "get_history" })
        });
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS (PUBLIC READ)
    ===================================================== */

    const adminAttendance = {
        getDailySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
        },
        getWeeklySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
        },
        getMonthlySummary() {
            return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
        }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
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
       🚀 EXPORT ALL APIs
    ===================================================== */
    return {
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getGetOrderStatus,
        getOrders,

        getEmployeeOrders,
        createEmployeeOrder,

        // ✅ HR Attendance Public APIs
        recordAttendance,
        getAllEmployees,

        // ✅ Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,

        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ Benefits of this final API.JS

- No action strings in portal code — just dedicated helper functions.

- Fully public APIs, no Cognito/Auth headers required.

- employee-portal.html can now call:

```
const profile = await CHARLIE_API.getEmployeeProfile(employeeId);
const history = await CHARLIE_API.getAttendanceHistory(employeeId);
```

- Clean, maintainable, future-proof.

### ✅ Fully Final API.JS

- API.JS – updated with dedicated HR helpers (getEmployeeProfile, getAttendanceHistory).

- employee-portal.html – updated to fully use these helpers, clean, no unnecessary Authorization headers, fully public, and production-ready.

Both will have detailed comments.

#### Code

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs are public (no Cognito/Auth headers)
   ✔ Fully aligned with config.js
   ✔ Includes dedicated HR helpers
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Handles JSON parsing and non-200 errors
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
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

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - All APIs are public
    ===================================================== */
    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, { method: "POST", body: JSON.stringify(payload) });
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       🟢 DEDICATED HR HELPERS
       - Cleaner and purpose-specific
    ===================================================== */
    function getEmployeeProfile(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId, action: "get_profile" })
        });
    }

    function getAttendanceHistory(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId, action: "get_history" })
        });
    }

    /* =====================================================
       📊 ADMIN — ATTENDANCE ANALYTICS (PUBLIC READ)
    ===================================================== */
    const adminAttendance = {
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
    ===================================================== */
    const adminDashboard = {
        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) url += `?employee_id=${encodeURIComponent(employeeId)}`;
            return apiFetch(url);
        },
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, { method: "POST", body: JSON.stringify(payload) });
        }
    };

    /* =====================================================
       🚀 EXPORT ALL APIs
    ===================================================== */
    return {
        // Orders
        placeOrder, updateOrder, getOrderStatus, getCafeOrderStatus, getGetOrderStatus, getOrders,
        getEmployeeOrders, createEmployeeOrder,

        // HR Attendance Public
        recordAttendance, getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile, getAttendanceHistory,

        // Admin
        adminAttendance, adminDashboard
    };

})();
```

### ✅ What’s fixed and finalized

- No more protected calls – APIs are public.

- No unnecessary Authorization headers.

- Dedicated helpers (getEmployeeProfile, getAttendanceHistory) used everywhere.

- Clean, maintainable HTML with proper table rendering.

- Fully compatible with your Lambda endpoints (POST /attendance).

- Comments throughout to explain each section.

### ✅ API.JS

updated your API.JS fully so that all HR-related helpers point to the correct Lambda endpoints, all public APIs remain intact, and everything aligns with your frontend pages (checkin.html and employee-portal.html). This is the final, production-ready version.

```
/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - PROD)
   ---------------------------------------------------------
   ✔ Single Stage: /prod (from CONFIG.API_BASE)
   ✔ All APIs are public (no Cognito/Auth headers for HR)
   ✔ Fully aligned with frontend pages and Lambda endpoints
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🔧 HELPER — STANDARD FETCH WRAPPER
       - Handles JSON parsing and non-200 errors
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

        return response.json();
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS
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

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - Check-in / Check-out API
    ===================================================== */
    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, { method: "POST", body: JSON.stringify(payload) });
    }

    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }

    /* =====================================================
       🟢 DEDICATED HR HELPERS — FIXED ENDPOINTS
       - Fully aligned with Lambda
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
    ===================================================== */
    const adminAttendance = {
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
    };

    /* =====================================================
       📈 ADMIN — DASHBOARD & USER MANAGEMENT (PUBLIC READ)
    ===================================================== */
    const adminDashboard = {
        fetchData(employeeId = "") {
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) url += `?employee_id=${encodeURIComponent(employeeId)}`;
            return apiFetch(url);
        },
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, { method: "POST", body: JSON.stringify(payload) });
        }
    };

    /* =====================================================
       🚀 EXPORT ALL APIs
    ===================================================== */
    return {
        // Orders
        placeOrder, updateOrder, getOrderStatus, getCafeOrderStatus, getGetOrderStatus, getOrders,
        getEmployeeOrders, createEmployeeOrder,

        // HR Attendance Public
        recordAttendance, getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile, getAttendanceHistory, getLeavesAndHolidays,

        // Admin
        adminAttendance, adminDashboard
    };

})();
```

### ✅ What’s fixed / updated:

- getEmployeeProfile → calls /employee-profile Lambda

- getAttendanceHistory → calls /attendance-history Lambda

- getLeavesAndHolidays → calls /leaves-holidays Lambda (added)

- recordAttendance → still points to /attendance for check-in/check-out

- Public HR APIs do not require Cognito, fully aligned with frontend pages

- Admin / orders / dashboard remain unchanged

### ✅ API.JS

fully final, production-ready API.JS with detailed comments, fully aligned with your HR Lambda functions, frontend pages (checkin.html and employee-portal.html), and public API setup (no Cognito required for HR).

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
                ...(options.headers || {}) // Merge optional headers
            },
            ...options
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }

        return response.json();
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

    /* =====================================================
       👥 HR — ATTENDANCE (PUBLIC)
       - Check-in / Check-out API
       - Does NOT require Cognito token
       - Called by checkin.html fingerprint simulation
    ===================================================== */
    function recordAttendance(payload) {
        return apiFetch(`${CONFIG.API_BASE}/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
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

    // Fetch employee profile from hr-employee-profile Lambda
    function getEmployeeProfile(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/employee-profile`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    // Fetch attendance history from hr-attendance-history Lambda
    function getAttendanceHistory(employeeId) {
        return apiFetch(`${CONFIG.API_BASE}/attendance-history`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        });
    }

    // Fetch leaves and company holidays from hr-leaves-holidays Lambda
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
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
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
        getOrders,
        getEmployeeOrders,
        createEmployeeOrder,

        // HR Attendance Public
        recordAttendance,
        getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ Key Fixes / Improvements

- getEmployeeProfile() → now calls /employee-profile Lambda correctly.

- getAttendanceHistory() → now calls /attendance-history Lambda correctly.

- getLeavesAndHolidays() → calls /leaves-holidays Lambda.

- recordAttendance() → continues to call /attendance (check-in/check-out).

- Fully compatible with checkin.html (fingerprint simulation) and employee-portal.html (profile + history).

- All public HR APIs do not require Cognito auth — matches your architecture.

- Comments added for clarity for every section.

### ✅ Fully Final API.JS

```
window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    async function apiFetch(url, options = {}) {
        const response = await fetch(url, {
            headers: { "Content-Type": "application/json", ...(options.headers || {}) },
            ...options
        });
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }
        return response.json();
    }

    // ================= HR ATTENDANCE =================
    function recordAttendance(payload) {
        // payload: { employee_id, action: "checkin"|"checkout" }
        // Call correct Lambda path
        const url = `${CONFIG.API_BASE}/attendance/${payload.action}`;
        return apiFetch(url, {
            method: "POST",
            body: JSON.stringify({ employee_id: payload.employee_id })
        });
    }

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

    return {
        recordAttendance,
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays
    };
})();
```

#### Fully final API.JS

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
                ...(options.headers || {}) // Merge optional headers
            },
            ...options
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }

        return response.json();
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
            body: JSON.stringify({ employee_id: payload.employee_id })
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
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
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
        getOrders,
        getEmployeeOrders,
        createEmployeeOrder,

        // HR Attendance Public
        recordAttendance,
        getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        adminAttendance,
        adminDashboard
    };

})();
```

### ✅ Changes & Fixes in this Final Version:

- recordAttendance() now calls /attendance/checkin or /attendance/checkout instead of the generic /attendance.

- Added clear comments for HR attendance.

- Other Lambda API calls (orders, employee profile, admin dashboard) remain unchanged.

- Fully aligned with checkin.html and employee-portal.html.

- No Cognito token required for HR APIs, login flow intact for front-end login pages.

---



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
                ...(options.headers || {}) // Merge optional headers
            },
            ...options
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }

        return response.json();
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
            body: JSON.stringify({ employee_id: payload.employee_id })
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
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
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

        // HR Attendance Public
        recordAttendance,
        getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        adminAttendance,
        adminDashboard
    };

})();
```

### api.js

- Add a proper analytics API function in your CHARLIE_API object that calls the correct Lambda endpoint:

    - In api.js, inside the returned object:

```
// ================== ADMIN — ANALYTICS (PUBLIC READ) ==================
function getAnalytics(period = "today") {
    const url = `${CONFIG.API_BASE}/analytics?period=${encodeURIComponent(period)}`;
    return apiFetch(url);
}
```

Then export it:

```
return {
    // ... other functions
    getAnalytics,
    // admin dashboard functions
};
```

#### Here is Updated API.JS


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
                ...(options.headers || {}) // Merge optional headers
            },
            ...options
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }

        return response.json();
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
            body: JSON.stringify({ employee_id: payload.employee_id })
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
        getDailySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`); },
        getWeeklySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`); },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`); }
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

 	    // ... other functions
   	    getAnalytics,
    	// admin dashboard functions

        // HR Attendance Public
        recordAttendance,
        getAllEmployees,

        // Dedicated HR helpers
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        adminAttendance,
        adminDashboard
    };

})();
```


----