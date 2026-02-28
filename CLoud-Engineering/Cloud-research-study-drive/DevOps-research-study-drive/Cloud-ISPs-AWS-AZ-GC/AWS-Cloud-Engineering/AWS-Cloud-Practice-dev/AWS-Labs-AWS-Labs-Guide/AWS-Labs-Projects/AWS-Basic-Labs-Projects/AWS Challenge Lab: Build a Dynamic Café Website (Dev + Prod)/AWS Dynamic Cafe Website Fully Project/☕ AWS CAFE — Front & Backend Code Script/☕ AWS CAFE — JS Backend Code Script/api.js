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