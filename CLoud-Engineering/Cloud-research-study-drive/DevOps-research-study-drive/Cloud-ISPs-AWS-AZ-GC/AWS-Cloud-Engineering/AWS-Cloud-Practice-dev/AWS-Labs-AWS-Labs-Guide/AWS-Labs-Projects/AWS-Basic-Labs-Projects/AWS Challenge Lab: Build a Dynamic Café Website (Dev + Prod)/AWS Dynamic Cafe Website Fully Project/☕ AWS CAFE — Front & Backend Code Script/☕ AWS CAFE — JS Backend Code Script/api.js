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