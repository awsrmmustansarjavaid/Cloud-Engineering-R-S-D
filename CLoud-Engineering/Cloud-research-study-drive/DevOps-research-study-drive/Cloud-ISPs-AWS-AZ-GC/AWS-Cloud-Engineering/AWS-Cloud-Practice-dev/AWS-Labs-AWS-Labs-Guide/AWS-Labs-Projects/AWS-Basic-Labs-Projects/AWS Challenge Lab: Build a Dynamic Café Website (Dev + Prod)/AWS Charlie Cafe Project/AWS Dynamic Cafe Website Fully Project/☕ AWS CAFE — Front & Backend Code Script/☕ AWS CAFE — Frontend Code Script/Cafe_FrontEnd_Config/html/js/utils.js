/* =========================================================
   CHARLIE CAFE — UTILITIES
   ---------------------------------------------------------
   ✔ JWT Parsing
   ✔ Token Expiry Check
   ✔ LocalStorage Token Helper
   ✔ Automatic CloudFront Link Builder
========================================================= */

window.CHARLIE_UTILS = (() => {

    /* =====================================================
       🔐 Parse JWT Token
       -----------------------------------------------------
       Converts JWT payload into JSON object
    ===================================================== */
    function parseJwt(token) {
        try {
            return JSON.parse(atob(token.split(".")[1]));
        } catch {
            return {};
        }
    }

    /* =====================================================
       ⏳ Check if Token is Expired
    ===================================================== */
    function isTokenExpired(token) {
        try {
            return parseJwt(token).exp * 1000 < Date.now();
        } catch {
            return true;
        }
    }

    /* =====================================================
       🔑 Get Access Token from LocalStorage
    ===================================================== */
    function getToken() {
        return localStorage.getItem("access_token");
    }

    /* =====================================================
       ☁ Automatic CloudFront Link Builder
       -----------------------------------------------------
       Updates all elements with data-page attribute
       Example:
       <a data-page="orders.html">
    ===================================================== */
    function initCloudFrontLinks() {

        if (!window.CHARLIE_CONFIG || !window.CHARLIE_CONFIG.CLOUDFRONT_BASE) {
            console.warn("CLOUDFRONT_BASE not found in config.js");
            return;
        }

        const base = window.CHARLIE_CONFIG.CLOUDFRONT_BASE;

        document.querySelectorAll("[data-page]").forEach(element => {

            const page = element.getAttribute("data-page");

            if (page) {
                element.href = `${base}/${page}`;
            }

        });
    }

    /* =====================================================
       🚀 Auto-run when page loads
    ===================================================== */
    document.addEventListener("DOMContentLoaded", () => {
        initCloudFrontLinks();
    });

    return {
        parseJwt,
        isTokenExpired,
        getToken,
        initCloudFrontLinks
    };

})();
