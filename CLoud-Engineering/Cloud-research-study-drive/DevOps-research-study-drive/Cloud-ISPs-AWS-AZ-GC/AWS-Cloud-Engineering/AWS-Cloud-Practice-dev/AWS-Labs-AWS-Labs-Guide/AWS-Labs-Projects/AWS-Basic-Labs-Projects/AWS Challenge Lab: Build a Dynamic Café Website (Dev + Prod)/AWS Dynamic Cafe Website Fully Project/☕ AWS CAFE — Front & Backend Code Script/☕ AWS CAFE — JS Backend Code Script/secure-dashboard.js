/* =================================================
   SECURE DASHBOARD MODULE
   =================================================
   This JS file packages:
   ✅ Page hidden until auth success
   ✅ auth.js loaded
   ✅ protectPage() applied
   ✅ Secure API call placeholder
   ✅ Cognito-ready logout()
   ✅ Comments explaining each step
================================================= */

(function() {
    // ================== PAGE HIDDEN INITIALLY ==================
    document.body.style.display = "none"; // Hide until auth

    // ================== LOAD AUTH.JS ==================
    const authScript = document.createElement('script');
    authScript.src = 'assets/auth.js'; // Make sure path is correct
    authScript.onload = () => initSecureDashboard();
    document.head.appendChild(authScript);

    // ================== INIT FUNCTION ==================
    function initSecureDashboard() {
        // Protect the page
        protectPage();

        // Show body only after auth success
        document.body.style.display = "block";

        // Example secure API call placeholder
        const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard";
        authFetch(API_URL)
            .then(res => res.json())
            .then(data => {
                console.log("Secure dashboard data:", data);
                // TODO: update KPI cards dynamically
            })
            .catch(err => console.error("API error:", err));

        // Attach logout functionality to all buttons with class .logout-btn
        document.querySelectorAll('.logout-btn').forEach(btn => {
            btn.addEventListener('click', () => cognitoLogout());
        });
    }

})();
