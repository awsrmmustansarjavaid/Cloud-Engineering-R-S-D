/* =========================================================
   CHARLIE CAFE — API MODULE (PRODUCTION)
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;
    const AUTH = window.CHARLIE_AUTH;
    const { getToken, isTokenExpired } = window.CHARLIE_UTILS;

    /* =====================================================
       🔓 1️⃣ PUBLIC API GATEWAY ENDPOINTS (NO COGNITO)
       --------------------------------------------------
       Resource Path               Method   Lambda
       /prod/orders                POST     CafeOrderProcessor
       /prod/orders/cash-payment   POST     CashPaymentLambda
       /prod/order-status          GET      OrderStatusLambda
    ===================================================== */

    const publicAPI = {

        placeOrder(payload) {
            return fetch(`${CONFIG.API_BASE}/orders`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        cashPayment(payload) {
            return fetch(`${CONFIG.API_BASE}/orders/cash-payment`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        getOrderStatus(orderId) {
            return fetch(`${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`)
                .then(res => res.json());
        }
    };

    /* =====================================================
       🔐 2️⃣ COGNITO PROTECTED API ENDPOINTS (PROD)
    ===================================================== */

    async function secureFetch(url, options = {}) {

        const token = getToken();

        if (!token || isTokenExpired(token)) {
            AUTH.logout();
            return;
        }

        const headers = {
            Authorization: "Bearer " + token,
            ...(options.headers || {})
        };

        const response = await fetch(url, {
            method: options.method || "GET",
            ...options,
            headers
        });

        return response.json();
    }

    const protectedAPI = {

        updateOrder(payload) {
            return secureFetch(`${CONFIG.API_BASE}/order-update`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        /* 🧑‍🍳 HR — Employee + Admin */
        recordAttendance(payload) {
            AUTH.requireEmployee();
            return secureFetch(`${CONFIG.API_BASE}/hr/attendance`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        getAttendance(employeeId) {
            AUTH.requireEmployee();
            return secureFetch(`${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`);
        },

        /* 👨‍💼 Admin Only */
        getAllEmployees() {
            AUTH.requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/hr/employees`);
        },

        /* 📊 Admin Dashboard */
        adminDashboard(employeeId = "") {
            AUTH.requireAdmin();
            let url = `${CONFIG.API_BASE}/admin/dashboard`;
            if (employeeId) url += `?employee_id=${employeeId}`;
            return secureFetch(url);
        }
    };

    return {
        public: publicAPI,
        protected: protectedAPI
    };

})();
