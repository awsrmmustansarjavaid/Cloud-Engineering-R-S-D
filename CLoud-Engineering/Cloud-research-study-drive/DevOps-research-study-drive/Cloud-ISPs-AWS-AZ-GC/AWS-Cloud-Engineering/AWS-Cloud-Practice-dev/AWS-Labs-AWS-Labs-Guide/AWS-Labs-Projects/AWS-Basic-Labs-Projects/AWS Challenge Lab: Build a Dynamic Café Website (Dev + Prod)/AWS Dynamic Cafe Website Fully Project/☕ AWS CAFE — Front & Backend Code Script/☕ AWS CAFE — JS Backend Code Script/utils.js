/* =========================================================
   SHARED UTILITIES
========================================================= */

export function parseJwt(token) {
    try {
        return JSON.parse(atob(token.split(".")[1]));
    } catch {
        return {};
    }
}

export function isTokenExpired(token) {
    try {
        return parseJwt(token).exp * 1000 < Date.now();
    } catch {
        return true;
    }
}

export function formatCurrency(amount) {
    return "$" + Number(amount).toFixed(2);
}
