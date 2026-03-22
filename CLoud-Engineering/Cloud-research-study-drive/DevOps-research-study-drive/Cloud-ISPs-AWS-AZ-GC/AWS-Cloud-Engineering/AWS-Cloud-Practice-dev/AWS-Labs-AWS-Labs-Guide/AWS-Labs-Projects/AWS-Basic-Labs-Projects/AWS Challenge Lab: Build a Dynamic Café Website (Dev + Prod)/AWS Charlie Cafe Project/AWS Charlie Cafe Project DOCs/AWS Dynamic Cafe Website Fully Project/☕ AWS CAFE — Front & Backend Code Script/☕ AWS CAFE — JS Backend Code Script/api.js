/* =============================================================================
   CHARLIE CAFÉ ☕ — api.js
   -----------------------------------------------------------------------------
   Central API module for the employee portal frontend.

   Architecture:
     Browser → CloudFront → API Gateway → Cognito Authorizer → Lambda → RDS

   Authentication:
     All secure endpoints require a Cognito id_token stored in localStorage
     under the key "id_token". The token is attached as:
       Authorization: Bearer <id_token>
     API Gateway's Cognito Authorizer validates it before Lambda even runs.

   Secure endpoints (JWT required — employee_id comes from the token):
     getEmployeeProfile()     POST /employee-profile
     getAttendanceHistory()   POST /attendance-history
     getLeavesAndHolidays()   POST /leaves-holidays

   Public/device endpoint (employee_id sent in body — kiosk use only):
     recordAttendance()       POST /attendance/checkin  or  /attendance/checkout

   Usage (from employee-portal.html):
     const profile    = await CHARLIE_API.getEmployeeProfile();
     const attendance = await CHARLIE_API.getAttendanceHistory();
     const { leaves, holidays } = await CHARLIE_API.getLeavesAndHolidays();
     await CHARLIE_API.recordAttendance({ employee_id: 5, action: "checkin" });
============================================================================= */

window.CHARLIE_API = (() => {

    /* =========================================================================
       CONFIG REFERENCE
       Pulled from config.js which must be loaded before this file.
    ========================================================================= */
    const CONFIG = window.CHARLIE_CONFIG;


    /* =========================================================================
       apiFetch()  — internal helper, not exported
       -------------------------------------------------------------------------
       Wraps the native fetch() with:
         1. Automatic Authorization header (Bearer token from localStorage)
         2. Content-Type: application/json on every request
         3. HTTP error detection (throws on non-2xx status)
         4. Lambda proxy response unwrapping:
              API Gateway wraps Lambda responses in { statusCode, headers, body }
              where body is a JSON STRING. We parse it so callers get plain objects.
    ========================================================================= */
    async function apiFetch(url, options = {}) {

        // Read the Cognito id_token stored after login
        const token = localStorage.getItem("id_token");

        const res = await fetch(url, {
            headers: {
                "Content-Type": "application/json",

                // Attach JWT only when a token exists.
                // Public endpoints (e.g. recordAttendance) work without a token.
                ...(token ? { "Authorization": "Bearer " + token } : {}),

                // Allow callers to override or extend headers if needed
                ...(options.headers || {})
            },
            // Spread all other fetch options (method, body, signal, etc.)
            ...options
        });

        // Throw a descriptive error for any non-2xx HTTP status
        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`API Error ${res.status}: ${errorText}`);
        }

        const data = await res.json();

        // Unwrap Lambda proxy integration response.
        // Lambda returns: { statusCode: 200, headers: {...}, body: "\"{ ... }\"" }
        // The body field is always a JSON-encoded STRING — we parse it once more.
        if (typeof data.body === "string") {
            return JSON.parse(data.body);
        }

        // If the response is already a plain object (direct integration), return as-is
        return data;
    }


    /* =========================================================================
       HR — ATTENDANCE KIOSK (public device, no JWT required)
       -------------------------------------------------------------------------
       Used by a shared check-in tablet/kiosk, not the employee portal.
       employee_id is submitted by the user or scanned from a badge.
       action must be "checkin" or "checkout".

       Lambda: hr-attendance
       Routes: POST /attendance/checkin
               POST /attendance/checkout
    ========================================================================= */

    /**
     * recordAttendance({ employee_id, action })
     * Records a check-in or check-out for the given employee.
     *
     * @param {Object} payload
     * @param {number} payload.employee_id  - The employee's numeric ID
     * @param {string} payload.action       - "checkin" or "checkout"
     * @returns {Promise<{message: string}>}
     */
    function recordAttendance(payload) {
        // The URL path itself tells the Lambda which action to perform
        const url = `${CONFIG.API_BASE}/attendance/${payload.action}`;
        return apiFetch(url, {
            method: "POST",
            body: JSON.stringify({
                employee_id: payload.employee_id,
                action:      payload.action
            })
        });
    }

    /**
     * getAllEmployees()
     * Returns a list of all employees (used by admin/kiosk screens).
     * @returns {Promise<Array>}
     */
    function getAllEmployees() {
        return apiFetch(`${CONFIG.API_BASE}/employees`);
    }


    /* =========================================================================
       HR — SECURE EMPLOYEE APIs (Cognito JWT required)
       -------------------------------------------------------------------------
       These endpoints use API Gateway's Cognito Authorizer.
       The employee_id is extracted server-side from the JWT custom claim.
       The frontend sends NO employee_id in the body — just the Bearer token.
    ========================================================================= */

    /**
     * getEmployeeProfile()
     * Returns the logged-in employee's name, job title, salary, and start date.
     * Lambda: hr-employee-profile
     *
     * @returns {Promise<{employee_id, name, job_title, salary, start_date}>}
     */
    function getEmployeeProfile() {
        return apiFetch(`${CONFIG.API_BASE}/employee-profile`, {
            method: "POST"
            // No body — employee_id is extracted from the JWT in Lambda
        });
    }

    /**
     * getAttendanceHistory()
     * Returns the full attendance history for the logged-in employee.
     * Lambda: hr-attendance-history
     *
     * @returns {Promise<Array<{attendance_date, checkin_time, checkout_time}>>}
     */
    function getAttendanceHistory() {
        return apiFetch(`${CONFIG.API_BASE}/attendance-history`, {
            method: "POST"
            // No body — employee_id is extracted from the JWT in Lambda
        });
    }

    /**
     * getLeavesAndHolidays()
     * Returns the employee's leave history + the company holiday list.
     * Lambda: hr-leaves-holidays
     *
     * @returns {Promise<{leaves: Array, holidays: Array}>}
     */
    function getLeavesAndHolidays() {
        return apiFetch(`${CONFIG.API_BASE}/leaves-holidays`, {
            method: "POST"
            // No body — employee_id is extracted from the JWT in Lambda
        });
    }


    /* =========================================================================
       ORDER MANAGEMENT (customer and employee ordering flows)
    ========================================================================= */

    /** Place a new customer order */
    function placeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /** Update an existing order (e.g. status change by café staff) */
    function updateOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }

    /** Get order status by order_id (customer-facing polling) */
    function getOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /** Get order status as seen by café staff */
    function getCafeOrderStatus(orderId) {
        return apiFetch(
            `${CONFIG.API_BASE}/cafe-order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }

    /** Get all orders (admin/staff view) */
    function getOrders() {
        return apiFetch(`${CONFIG.API_BASE}/get-order-status`);
    }

    /** Get orders placed by the logged-in employee */
    function getEmployeeOrders() {
        return apiFetch(`${CONFIG.API_BASE}/employee/orders`);
    }

    /** Create an order on behalf of an employee */
    function createEmployeeOrder(payload) {
        return apiFetch(`${CONFIG.API_BASE}/employee/order`, {
            method: "POST",
            body: JSON.stringify(payload)
        });
    }


    /* =========================================================================
       ANALYTICS
    ========================================================================= */

    /**
     * getAnalytics(period)
     * Fetches sales/operational analytics for the given period.
     * @param {string} period - "today" | "week" | "month" (default: "today")
     */
    function getAnalytics(period = "today") {
        return apiFetch(
            `${CONFIG.API_BASE}/analytics?period=${encodeURIComponent(period)}`
        );
    }

    /**
     * adminAttendance — HR analytics summaries for the admin dashboard.
     * getDailySummary()   → attendance summary for today
     * getWeeklySummary()  → attendance summary for the current week
     * getMonthlySummary() → attendance summary for the current month
     */
    const adminAttendance = {
        getDailySummary()   { return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=daily`);   },
        getWeeklySummary()  { return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=weekly`);  },
        getMonthlySummary() { return apiFetch(`${CONFIG.API_BASE}/hr-analytics?type=monthly`); }
    };


    /* =========================================================================
       ADMIN DASHBOARD
    ========================================================================= */

    const adminDashboard = {
        /** Fetch aggregate data for the admin overview screen */
        fetchData() {
            return apiFetch(`${CONFIG.API_BASE}/admin/dashboard`);
        },

        /** Create a new user account (admin action) */
        createUser(payload) {
            return apiFetch(`${CONFIG.API_BASE}/admin/create-user`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        }
    };


    /* =========================================================================
       PUBLIC API — exported from the IIFE
       Only expose what the portal pages actually need.
    ========================================================================= */
    return {

        // Kiosk / device attendance (no JWT)
        recordAttendance,
        getAllEmployees,

        // Secure employee portal APIs (JWT required)
        getEmployeeProfile,
        getAttendanceHistory,
        getLeavesAndHolidays,

       // Orders
        placeOrder,
        updateOrder,
        getOrderStatus,
        getCafeOrderStatus,
        getOrders,
        getEmployeeOrders,
        createEmployeeOrder,

        // Analytics & admin
        getAnalytics,
        adminAttendance,
        adminDashboard
    };

})();