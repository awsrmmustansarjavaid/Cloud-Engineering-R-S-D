/* =========================================================
   API MODULE
   Handles ALL API requests (Public + Protected)
========================================================= */

import { CONFIG } from "./config.js";
import { Auth } from "./central-auth.js";

/* ========================================================
   BASE FETCH HELPERS
======================================================== */

/* ---------- PUBLIC FETCH (No token) ---------- */
async function publicFetch(path, options = {}) {
    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}

/* ---------- PROTECTED FETCH (JWT required) ---------- */
async function protectedFetch(path, options = {}) {

    const token = Auth.getToken();

    if (!token || Auth.isTokenExpired(token)) {
        Auth.logout();
        return;
    }

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            Authorization: "Bearer " + token,
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}

/* ========================================================
   PUBLIC API ENDPOINTS
======================================================== */

export const PublicAPI = {

    placeOrder(payload) {
        return publicFetch("/public/orders", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    cashPayment(payload) {
        return publicFetch("/public/orders/cash-payment", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    getOrderStatus(orderId) {
        return publicFetch(
            `/public/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }
};

/* ========================================================
   ADMIN API (Cognito Protected)
======================================================== */

export const AdminAPI = {

    getDashboard() {
        return protectedFetch("/admin/dashboard");
    },

    getOrders() {
        return protectedFetch("/admin/orders");
    },

    markPaid(orderId) {
        return protectedFetch("/admin/mark-paid", {
            method: "POST",
            body: JSON.stringify({ order_id: orderId })
        });
    },

    createUser(payload) {
        return protectedFetch("/admin/create-user", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    getAnalytics() {
        return protectedFetch("/admin/analytics");
    }
};

/* ========================================================
   EMPLOYEE API (Cognito Protected)
======================================================== */

export const EmployeeAPI = {

    getOrders() {
        return protectedFetch("/employee/orders");
    },

    createOrder(payload) {
        return protectedFetch("/employee/order", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    updateOrder(payload) {
        return protectedFetch("/employee/order-update", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    getOrderStatus(orderId) {
        return protectedFetch(
            `/employee/order-status?order_id=${encodeURIComponent(orderId)}`
        );
    }
};

/* ========================================================
   HR API (Cognito Protected)
======================================================== */

export const HRAPI = {

    checkIn(payload) {
        return protectedFetch("/hr/checkin", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    checkOut(payload) {
        return protectedFetch("/hr/checkout", {
            method: "POST",
            body: JSON.stringify(payload)
        });
    },

    getProfile() {
        return protectedFetch("/hr/employee-profile");
    },

    getAttendanceHistory() {
        return protectedFetch("/hr/attendance-history");
    },

    getLeavesAndHolidays() {
        return protectedFetch("/hr/leaves-holidays");
    }
};
