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