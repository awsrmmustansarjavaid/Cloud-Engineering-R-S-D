/* =================================================
   SECURE DASHBOARD MODULE
   =================================================
   This JS file handles:
   ✅ Page hidden until authentication succeeds
   ✅ auth.js loading
   ✅ protectPage() enforcement
   ✅ Secure API call placeholder
   ✅ Cognito logout handling
   ✅ Clean reusable design
================================================= */

(function () {

    /* ================= PAGE HIDDEN INIT =================
       Prevents dashboard content from flashing
       before authentication validation completes
    ===================================================== */
    document.body.style.display = "none";

    /* ================= LOAD AUTH.JS =================
       Dynamically loads Cognito authentication logic
       Ensures auth functions exist before execution
    ================================================== */
    const authScript = document.createElement("script");
    authScript.src = "assets/auth.js"; // Adjust path if needed
    authScript.onload = () => initSecureDashboard();
    document.head.appendChild(authScript);

    /* ================= INIT SECURE DASHBOARD ================= */
    function initSecureDashboard() {

        /* ---- Enforce authentication ---- */
        protectPage();

        /* ---- Auth successful → show dashboard ---- */
        document.body.style.display = "block";

        /* ================= SECURE API CALL =================
           All dashboard APIs should be accessed
           using authFetch() for token injection
        ==================================================== */
        const API_URL =
            "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard";

        authFetch(API_URL)
            .then(res => res.json())
            .then(data => {
                console.log("✅ Secure dashboard data:", data);
                // TODO: Update KPI cards dynamically
            })
            .catch(err => console.error("❌ Secure API error:", err));

        /* ================= LOGOUT HANDLER =================
           Any button with class `.logout-btn`
           will automatically log user out
        =================================================== */
        document.querySelectorAll(".logout-btn").forEach(btn => {
            btn.addEventListener("click", () => cognitoLogout());
        });
    }

})();