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