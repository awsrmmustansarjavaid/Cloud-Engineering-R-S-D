<script>
/* ================= CONFIG ================= */
const USER_POOL_ID = "CHANGE_ME";
const CLIENT_ID = "CHANGE_ME";
const COGNITO_DOMAIN = "CHANGE_ME.auth.ap-south-1.amazoncognito.com";
const REDIRECT_URI = window.location.origin + window.location.pathname;

/* ================= TOKEN HELPERS ================= */
function parseJwt(token) {
    return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
    return parseJwt(token).exp * 1000 < Date.now();
}

/* ================= AUTH ACTIONS ================= */
function login() {
    const url =
        `https://${COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

function logout() {
    localStorage.removeItem("access_token");

    const url =
        `https://${COGNITO_DOMAIN}/logout` +
        `?client_id=${CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

/* ================= HANDLE REDIRECT ================= */
function handleAuthRedirect() {
    if (!window.location.hash) return;

    const params = new URLSearchParams(window.location.hash.substring(1));
    const token = params.get("access_token");

    if (token) {
        localStorage.setItem("access_token", token);
        window.location.hash = "";
    }
}

/* ================= PAGE GUARD ================= */
function protectPage() {
    handleAuthRedirect();

    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) {
        login();
        return;
    }

    // page is safe now
    document.body.style.display = "block";
}

/* ================= API FETCH HELPER ================= */
function authFetch(url, options = {}) {
    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) logout();

    return fetch(url, {
        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: "Bearer " + token
        }
    });
}
</script>