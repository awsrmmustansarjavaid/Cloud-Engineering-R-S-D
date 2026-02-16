/* =========================================================
   CHARLIE CAFE — UTILITIES
   ---------------------------------------------------------
   ✔ JWT Parsing
   ✔ Token Expiry Check
   ✔ LocalStorage Token Helper
========================================================= */

window.CHARLIE_UTILS = (() => {

    function parseJwt(token) {
        try {
            return JSON.parse(atob(token.split(".")[1]));
        } catch {
            return {};
        }
    }

    function isTokenExpired(token) {
        try {
            return parseJwt(token).exp * 1000 < Date.now();
        } catch {
            return true;
        }
    }

    function getToken() {
        return localStorage.getItem("access_token");
    }

    return {
        parseJwt,
        isTokenExpired,
        getToken
    };

})();
