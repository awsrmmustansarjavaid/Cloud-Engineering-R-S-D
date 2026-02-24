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