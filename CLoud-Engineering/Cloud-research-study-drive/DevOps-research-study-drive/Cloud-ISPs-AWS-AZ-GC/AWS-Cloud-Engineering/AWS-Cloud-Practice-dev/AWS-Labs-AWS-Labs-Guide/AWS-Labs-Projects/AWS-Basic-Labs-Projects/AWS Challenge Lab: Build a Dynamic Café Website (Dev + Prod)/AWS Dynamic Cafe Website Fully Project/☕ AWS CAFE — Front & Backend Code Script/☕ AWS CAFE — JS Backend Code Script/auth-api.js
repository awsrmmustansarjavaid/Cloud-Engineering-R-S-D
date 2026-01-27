/* =====================================================
   AUTH & API SHARED UTILITIES
   Charlie Café HR System
   - Used by Admin & Employee pages
   - Production hardened
===================================================== */

/* ===============================
   GLOBAL CONFIG (FROM config.js)
   IMPORTANT:
   config.js MUST be loaded BEFORE this file
================================ */
const poolData = {
    UserPoolId: CONFIG.COGNITO.USER_POOL_ID,
    ClientId: CONFIG.COGNITO.CLIENT_ID
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const apiBase = CONFIG.API_BASE;

/* ===============================
   PAGE PROTECTION
   Blocks unauthenticated users
================================ */
function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===============================
   GET JWT TOKEN (WITH EXPIRY CHECK)
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) {
            reject("No active session");
            return;
        }

        user.getSession((err, session) => {
            if (err || !session.isValid()) {
                alert("Session expired. Please login again.");
                user.signOut();
                window.location.href = "login.html";
                reject("Session expired");
                return;
            }

            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
   Automatically attaches JWT
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);

    if (!response.ok) {
        throw new Error("API request failed or unauthorized");
    }

    return response.json();
}

/* ===============================
   ROLE DETECTION FROM JWT
================================ */
async function getUserRoles() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) reject("No user");

        user.getSession((err, session) => {
            if (err) reject(err);

            const payload = session.getIdToken().decodePayload();
            resolve(payload["cognito:groups"] || []);
        });
    });
}

/* ===============================
   ADMIN UI ENFORCEMENT
================================ */
async function enforceAdminAccess() {
    const roles = await getUserRoles();

    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
        return;
    }

    const adminSection = document.getElementById("admin-section");
    if (adminSection) {
        adminSection.style.display = "block";
    }
}

/* ===============================
   EMPLOYEE UI ENFORCEMENT
================================ */
async function enforceEmployeeAccess() {
    const roles = await getUserRoles();

    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}

/* ===============================
   LOGOUT (COGNITO)
================================ */
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html";
}

/* ===============================
   GLOBAL ERROR HANDLER
================================ */
function handleError(error) {
    console.error("Application Error:", error);
    alert("Something went wrong. Please try again.");
}

/* ===============================
   LOADER (UX POLISH)
================================ */
function showLoader() {
    const loader = document.getElementById("loader");
    if (loader) loader.style.display = "block";
}

function hideLoader() {
    const loader = document.getElementById("loader");
    if (loader) loader.style.display = "none";
}

/* ===============================
   API USAGE EXAMPLES
================================ */

/* Employee Profile */
async function loadEmployeeProfile() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/employee/profile");

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
        document.getElementById("profile-salary").innerText = data.salary;
        document.getElementById("profile-start").innerText = data.start_date;
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}

/* Admin: Load All Employees */
async function loadAllEmployees() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/admin/employees");
        console.log("Employees:", data);
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}