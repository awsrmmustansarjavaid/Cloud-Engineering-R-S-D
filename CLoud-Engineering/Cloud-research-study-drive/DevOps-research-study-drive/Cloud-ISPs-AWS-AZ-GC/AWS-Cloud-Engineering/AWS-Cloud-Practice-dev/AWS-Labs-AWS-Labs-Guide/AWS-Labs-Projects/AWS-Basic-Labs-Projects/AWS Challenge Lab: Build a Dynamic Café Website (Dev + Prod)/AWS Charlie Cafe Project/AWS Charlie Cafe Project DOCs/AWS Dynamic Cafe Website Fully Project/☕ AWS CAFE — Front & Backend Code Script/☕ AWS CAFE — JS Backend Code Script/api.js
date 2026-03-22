/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL SECURE VERSION)
   ---------------------------------------------------------
   ✅ Uses Cognito JWT Authentication
   ✅ Automatically sends Authorization header (Bearer token)
   ✅ NO employee_id in frontend (secure)
   ✅ Compatible with Cognito Authorizer in API Gateway
   ✅ Clean, production-ready structure
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG; // Load config

    /* =====================================================
       🔐 HELPER — SECURE FETCH WRAPPER
       -----------------------------------------------------
       ✔ Adds JWT token automatically
       ✔ Handles API errors
       ✔ Parses Lambda proxy responses
    ===================================================== */
    async function apiFetch(url, options = {}) {

        // Get JWT token from browser storage
        const token = sessionStorage.getItem("id_token");

        const response = await fetch(url, {
            headers: {
                "Content-Type": "application/json",

                // ✅ IMPORTANT: Attach JWT for API Gateway Authorizer
                ...(token && { "Authorization": "Bearer " + token }),

                ...(options.headers || {})
            },
            ...options
        });

        // Handle API errors
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API Error: ${errorText}`);
        }

        const data = await response.json();

        // Handle Lambda proxy integration response
        if (typeof data.body === "string") {
            return JSON.parse(data.body);
        }

        return data;
    }

    /* =====================================================
       🛒 CUSTOMER ORDERS (OPTIONAL MODULE)
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

    function getOrders() {
        return apiFetch(`${CONFIG.API_BASE}/get-order-status`);
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
       👨‍💼 HR — ATTENDANCE (PUBLIC DEVICE / BIOMETRIC STYLE)
       -----------------------------------------------------
       ⚠️ Still uses employee_id (OK for check-in devices only)
    ===================================================== */

    function recordAttendance(payload) {
        // payload: { employee_id, action: "checkin" | "checkout" }

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
       🟢 HR — SECURE EMPLOYEE APIs (JWT BASED)
       -----------------------------------------------------
       ✔ NO employee_id sent from frontend
       ✔ Extracted from JWT in Lambda
    ===================================================== */

    function getEmployeeProfile() {
        return apiFetch(`${CONFIG.API_BASE}/employee-profile`, {
            method: "POST"
        });
    }

    function getAttendanceHistory() {
        return apiFetch(`${CONFIG.API_BASE}/attendance-history`, {
            method: "POST"
        });
    }

    function getLeavesAndHolidays() {
        return apiFetch(`${CONFIG.API_BASE}/leaves-holidays`, {
            method: "POST"
        });
    }

    /* =====================================================
       📊 ADMIN — ANALYTICS
    ===================================================== */

    function getAnalytics(period = "today") {
        const url = `${CONFIG.API_BASE}/analytics?period=${encodeURIComponent(period)}`;
        return apiFetch(url);
    }

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
       📈 ADMIN DASHBOARD
    ===================================================== */

    const adminDashboard = {
        fetchData() {
            return apiFetch(`${CONFIG.API_BASE}/admin/dashboard`);
        },
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        }
    };

    /* =====================================================
       ❌ REMOVED (NO LONGER NEEDED)
       -----------------------------------------------------
       exchangeCognitoToken()
       → Not required when using Cognito Authorizer
    ===================================================== */

    /* =====================================================
       🚀 EXPORT MODULE
    ===================================================== */

    return {

        // Orders
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getOrders,
        getEmployeeOrders,
        createEmployeeOrder,

        // HR Attendance (public device)
        recordAttendance,
        getAllEmployees,

        // Secure HR APIs (JWT)
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

        // Admin
        getAnalytics,
        adminAttendance,
        adminDashboard

    };

})();