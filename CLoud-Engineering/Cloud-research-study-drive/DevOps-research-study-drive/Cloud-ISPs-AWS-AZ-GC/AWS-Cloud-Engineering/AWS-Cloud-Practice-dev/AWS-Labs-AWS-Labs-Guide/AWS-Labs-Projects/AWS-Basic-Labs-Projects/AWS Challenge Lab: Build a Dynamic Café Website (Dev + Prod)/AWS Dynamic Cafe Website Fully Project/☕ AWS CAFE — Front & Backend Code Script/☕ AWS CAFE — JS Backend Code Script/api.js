/* =========================================================
   CHARLIE CAFE — API MODULE (FINAL - ALL PUBLIC)
   ---------------------------------------------------------
   ✔ All APIs are public
   ✔ No Authorization headers
   ✔ No Cognito token usage
   ✔ Clean & production ready
========================================================= */

window.CHARLIE_API = (() => {

    const CONFIG = window.CHARLIE_CONFIG;

    /* =====================================================
       🛒 ORDERS
    ===================================================== */

    function placeOrder(payload) {
        return fetch(`${CONFIG.API_BASE}/orders`, {
            method: "POST",
            headers: { 
                "Content-Type": "application/json" 
            },
            body: JSON.stringify(payload)
        }).then(res => res.json());
    }

    function updateOrder(payload) {
        return fetch(`${CONFIG.API_BASE}/order-update`, {
            method: "POST",
            headers: { 
                "Content-Type": "application/json" 
            },
            body: JSON.stringify(payload)
        }).then(res => res.json());
    }

    function cashPayment(payload) {
        return fetch(`${CONFIG.API_BASE}/orders/cash-payment`, {
            method: "POST",
            headers: { 
                "Content-Type": "application/json" 
            },
            body: JSON.stringify(payload)
        }).then(res => res.json());
    }

    function getOrderStatus(orderId) {
        return fetch(
            `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
        ).then(res => res.json());
    }

    /* =====================================================
       👨‍🍳 HR
    ===================================================== */

    function recordAttendance(payload) {
        return fetch(`${CONFIG.API_BASE}/hr/attendance`, {
            method: "POST",
            headers: { 
                "Content-Type": "application/json" 
            },
            body: JSON.stringify(payload)
        }).then(res => res.json());
    }

    function getAttendance(employeeId) {
        return fetch(
            `${CONFIG.API_BASE}/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
        ).then(res => res.json());
    }

    function getAllEmployees() {
        return fetch(`${CONFIG.API_BASE}/hr/employees`)
            .then(res => res.json());
    }

    /* =====================================================
       📊 ADMIN DASHBOARD
    ===================================================== */

    function adminDashboard(employeeId = "") {
        let url = `${CONFIG.API_BASE}/admin/dashboard`;
        if (employeeId) {
            url += `?employee_id=${encodeURIComponent(employeeId)}`;
        }

        return fetch(url).then(res => res.json());
    }

    /* =====================================================
       EXPORTS
    ===================================================== */

    return {
        placeOrder,
        updateOrder,
        cashPayment,
        getOrderStatus,
        recordAttendance,
        getAttendance,
        getAllEmployees,
        adminDashboard
    };

})();