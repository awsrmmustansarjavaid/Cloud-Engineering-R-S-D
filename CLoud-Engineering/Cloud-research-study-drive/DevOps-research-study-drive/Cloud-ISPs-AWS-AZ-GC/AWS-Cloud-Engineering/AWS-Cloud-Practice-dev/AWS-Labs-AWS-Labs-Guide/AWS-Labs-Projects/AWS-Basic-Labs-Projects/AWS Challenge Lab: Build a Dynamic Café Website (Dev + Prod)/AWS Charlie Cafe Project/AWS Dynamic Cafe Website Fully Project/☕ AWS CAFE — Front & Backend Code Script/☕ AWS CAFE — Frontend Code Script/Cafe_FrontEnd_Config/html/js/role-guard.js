/* =========================================================
   CHARLIE CAFE — ROLE GUARD MODULE
   ---------------------------------------------------------
   ✔ Protects pages based on Cognito Groups
   ✔ Works with central-auth.js
   ✔ No Lambda required
   ✔ No API Gateway required
========================================================= */

window.CHARLIE_ROLE_GUARD = (() => {

    const AUTH = window.CHARLIE_AUTH;

    /* =====================================================
       🔐 ADMIN / MANAGER ONLY
    ===================================================== */
    async function adminOnly() {

        // Ensure user is logged in
        await AUTH.protectPage();

        const roles = AUTH.getUserRoles();

        const allowedRoles = ["admin", "manager"];

        const hasAccess = roles.some(role =>
            allowedRoles.includes(role)
        );

        if (!hasAccess) {
            alert("Access denied. Admin or Manager only.");
            AUTH.logout();
        }
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ONLY
    ===================================================== */
    async function employeeOnly() {

        await AUTH.protectPage();

        const roles = AUTH.getUserRoles();

        const allowedRoles = ["employee", "admin", "manager"];

        const hasAccess = roles.some(role =>
            allowedRoles.includes(role)
        );

        if (!hasAccess) {
            alert("Access denied. Employees only.");
            AUTH.logout();
        }
    }

    return {
        adminOnly,
        employeeOnly
    };

})();
