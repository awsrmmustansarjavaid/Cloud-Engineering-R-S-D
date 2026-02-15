/* =========================================================
   API MODULE
   Handles ONLY API requests
========================================================= */

import { CONFIG } from "./config.js";
import { Auth } from "./central-auth.js";

/* ===============================
   PUBLIC FETCH (No token)
================================= */

export async function publicFetch(path, options = {}) {

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}

/* ===============================
   PROTECTED FETCH
================================= */

export async function protectedFetch(path, options = {}) {

    const token = Auth.getToken();

    if (!token) {
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
