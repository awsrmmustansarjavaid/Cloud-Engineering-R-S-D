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