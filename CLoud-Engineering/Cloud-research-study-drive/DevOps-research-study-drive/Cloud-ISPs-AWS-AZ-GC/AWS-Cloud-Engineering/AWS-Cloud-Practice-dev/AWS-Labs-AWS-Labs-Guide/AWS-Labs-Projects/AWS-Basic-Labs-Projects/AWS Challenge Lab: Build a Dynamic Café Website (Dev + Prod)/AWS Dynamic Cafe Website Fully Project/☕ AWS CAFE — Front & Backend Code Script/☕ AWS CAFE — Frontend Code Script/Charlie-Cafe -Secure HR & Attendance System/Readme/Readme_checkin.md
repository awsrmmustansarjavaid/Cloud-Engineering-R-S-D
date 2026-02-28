# Charlie Cafe - checkin

### checkin.html

> **Update Version: Old Architecture Design**

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Attendance</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Café Theme Styling ================= -->
    <style>
        /* ===== Full Page Café Background ===== */
        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Segoe UI", sans-serif;
        }

        /* ===== Main Card ===== */
        .attendance-card {
            background-color: rgba(255, 255, 255, 0.96);
            border-radius: 15px;
            padding: 30px;
            max-width: 420px;
            width: 100%;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        }

        /* ===== Café Heading ===== */
        .attendance-card h2 {
            font-family: Georgia, serif;
            color: #2b1b12;
        }

        /* ===== Buttons ===== */
        .btn-checkin {
            background-color: #2b1b12;
            color: #fff;
        }

        .btn-checkin:hover {
            background-color: #3d261a;
        }

        .btn-checkout {
            background-color: #8b0000;
            color: #fff;
        }

        .btn-checkout:hover {
            background-color: #a40000;
        }
    </style>
</head>

<body>

<!-- ================= Attendance Card ================= -->
<div class="attendance-card text-center">

    <!-- Café Title -->
    <h2>☕ Charlie Café</h2>
    <p class="text-muted">Employee Attendance System</p>

    <hr>

    <!-- ================= Employee ID Input ================= -->
    <!-- Employee must enter ID before check-in/out -->
    <div class="mb-3 text-start">
        <label for="employeeId" class="form-label fw-bold">Employee ID</label>
        <input
            type="number"
            id="employeeId"
            class="form-control"
            placeholder="Enter your Employee ID"
            required
        >
    </div>

    <!-- ================= Action Buttons ================= -->
    <div class="d-grid gap-3 mt-4">
        <button class="btn btn-checkin btn-lg" onclick="submitCheckin()">
            ✅ Check In
        </button>

        <button class="btn btn-checkout btn-lg" onclick="submitCheckout()">
            ⏰ Check Out
        </button>
    </div>

    <!-- ================= Status Message ================= -->
    <div class="mt-4">
        <div id="statusMsg" class="fw-bold"></div>
    </div>

</div>

<!-- ================= JavaScript Logic ================= -->
<script>
    /* ========= API Gateway Base URL ========= */
    const apiBase = "https://<API-ID>.execute-api.us-east-1.amazonaws.com/dev";

    /* ========= Utility: Show Status Messages ========= */
    function showMessage(message, success = true) {
        const msg = document.getElementById("statusMsg");
        msg.innerText = message;
        msg.style.color = success ? "green" : "red";
    }

    /* ========= Validate Employee ID ========= */
    function getEmployeeId() {
        const empId = document.getElementById("employeeId").value.trim();
        if (!empId) {
            showMessage("❌ Please enter Employee ID", false);
            return null;
        }
        return empId;
    }

    /* ========= Submit Check-In ========= */
    async function submitCheckin() {
        const employeeId = getEmployeeId();
        if (!employeeId) return;

        try {
            const response = await fetch(`${apiBase}/attendance/checkin`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ employee_id: employeeId })
            });

            const result = await response.json();

            if (response.ok) {
                showMessage("✅ Check-In successful. Have a great shift!");
            } else {
                showMessage(result.message || "❌ Check-In failed", false);
            }
        } catch (error) {
            showMessage("❌ Server error. Please contact admin.", false);
        }
    }

    /* ========= Submit Check-Out ========= */
    async function submitCheckout() {
        const employeeId = getEmployeeId();
        if (!employeeId) return;

        try {
            const response = await fetch(`${apiBase}/attendance/checkout`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ employee_id: employeeId })
            });

            const result = await response.json();

            if (response.ok) {
                showMessage("⏰ Check-Out successful. Thank you!");
            } else {
                showMessage(result.message || "❌ Check-Out failed", false);
            }
        } catch (error) {
            showMessage("❌ Server error. Please contact admin.", false);
        }
    }
</script>

</body>
</html>
```

---
### checkin.html

> **Update Version:1.0**


converting checkin.html to match your new modular architecture:

✅ Uses config.js

✅ Uses utils.js

✅ Uses central-auth.js

✅ Uses api.js

✅ Uses Cognito protected endpoints

✅ Uses /prod stage (no /dev)

✅ Requires Employee or Admin login

✅ Keeps your full background + styling untouched

This page is now Cognito protected because attendance is under:

```
/prod/hr/attendance   (Employee + Admin)
```

### ✅ WHAT CHANGED

❌ Removed

```
const apiBase = ".../dev";
fetch(...)
```

### ✅ Added

CHARLIE_AUTH.protectPage()

CHARLIE_API.protected.recordAttendance()

Role-based protection

Production stage

### ✅ FINAL UPDATED checkin.html

(Design and styling untouched)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Attendance</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Café Theme Styling ================= -->
    <style>
        body {
            min-height: 100vh;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Segoe UI", sans-serif;
        }

        .attendance-card {
            background-color: rgba(255, 255, 255, 0.96);
            border-radius: 15px;
            padding: 30px;
            max-width: 420px;
            width: 100%;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        }

        .attendance-card h2 {
            font-family: Georgia, serif;
            color: #2b1b12;
        }

        .btn-checkin {
            background-color: #2b1b12;
            color: #fff;
        }

        .btn-checkin:hover {
            background-color: #3d261a;
        }

        .btn-checkout {
            background-color: #8b0000;
            color: #fff;
        }

        .btn-checkout:hover {
            background-color: #a40000;
        }
    </style>
</head>

<body style="display:none;">

<!-- ================= Attendance Card ================= -->
<div class="attendance-card text-center">

    <h2>☕ Charlie Café</h2>
    <p class="text-muted">Employee Attendance System</p>

    <hr>

    <!-- ================= Employee ID Input ================= -->
    <div class="mb-3 text-start">
        <label for="employeeId" class="form-label fw-bold">Employee ID</label>
        <input
            type="number"
            id="employeeId"
            class="form-control"
            placeholder="Enter your Employee ID"
            required
        >
    </div>

    <!-- ================= Action Buttons ================= -->
    <div class="d-grid gap-3 mt-4">
        <button class="btn btn-checkin btn-lg" onclick="submitCheckin()">
            ✅ Check In
        </button>

        <button class="btn btn-checkout btn-lg" onclick="submitCheckout()">
            ⏰ Check Out
        </button>
    </div>

    <!-- ================= Status Message ================= -->
    <div class="mt-4">
        <div id="statusMsg" class="fw-bold"></div>
    </div>

</div>

<!-- =======================================================
     LOAD CENTRALIZED MODULES (ORDER MATTERS)
======================================================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   CHARLIE CAFE — ATTENDANCE PAGE (PROTECTED)
   ----------------------------------------------------------
   ✔ Requires Cognito Login
   ✔ Employee or Admin Role Required
   ✔ Uses /prod HR endpoints
========================================================== */

// ================= INIT PAGE SECURITY =================
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

// ================= Utility: Show Status Message =================
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "green" : "red";
}

// ================= Validate Employee ID =================
function getEmployeeId() {
    const empId = document.getElementById("employeeId").value.trim();
    if (!empId) {
        showMessage("❌ Please enter Employee ID", false);
        return null;
    }
    return empId;
}

// ==========================================================
// 1️⃣ CHECK-IN (Cognito Protected API)
// ==========================================================
async function submitCheckin() {

    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {

        const result = await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkin"
        });

        showMessage("✅ Check-In successful. Have a great shift!");

    } catch (error) {
        console.error(error);
        showMessage("❌ Check-In failed or unauthorized.", false);
    }
}

// ==========================================================
// 2️⃣ CHECK-OUT (Cognito Protected API)
// ==========================================================
async function submitCheckout() {

    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {

        const result = await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkout"
        });

        showMessage("⏰ Check-Out successful. Thank you!");

    } catch (error) {
        console.error(error);
        showMessage("❌ Check-Out failed or unauthorized.", false);
    }
}
</script>

</body>
</html>
```

### ✅ WHAT THIS PAGE NOW DOES

✔ Redirects to Cognito if not logged in
✔ Automatically attaches JWT
✔ Uses /prod/hr/attendance
✔ Requires Employee or Admin role
✔ Auto logout on token expiry
✔ No /dev anywhere
✔ Styling 100% untouched

### 🔐 Security Level Now

This page is now:

Cognito Protected

Role Protected

Production Stage

Token Expiry Protected

Centralized API Controlled

### Here’s the fully updated and styled checkin.html with comments:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= Bootstrap CSS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= Google Font ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ===================================================
   Global Body & Background
=================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: #fff;
    overflow: hidden;
}

/* Dark overlay for readability */
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
    z-index: 0;
}

/* ===================================================
   Attendance Card (Styled Like Login Card)
=================================================== */
.attendance-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 400px;
    text-align: center;
    z-index: 2;
}

/* Card Titles */
.attendance-card .logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.attendance-card h2 {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 10px;
    color: #fff;
}

.attendance-card p {
    color: #f0e6dc;
    margin-bottom: 25px;
}

/* Input Field Styling */
.attendance-card input.form-control {
    border-radius: 10px;
    padding: 10px;
    font-size: 16px;
}

/* Buttons */
.btn-checkin {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    color: #fff;
    border-radius: 50px;
    font-weight: 600;
    padding: 12px;
    transition: 0.3s;
}

.btn-checkin:hover {
    transform: scale(1.05);
}

.btn-checkout {
    background: linear-gradient(135deg,#8b0000,#ff4500);
    color: #fff;
    border-radius: 50px;
    font-weight: 600;
    padding: 12px;
    transition: 0.3s;
}

.btn-checkout:hover {
    transform: scale(1.05);
}

/* Status Message */
#statusMsg {
    margin-top: 20px;
    font-weight: 600;
    font-size: 16px;
}
</style>
</head>

<body>

<!-- Overlay -->
<div class="overlay"></div>

<!-- ================= Attendance Card ================= -->
<div class="attendance-card">

    <div class="logo">☕</div>
    <h2>Charlie Café</h2>
    <p>Employee Attendance System</p>
    <hr style="border-top: 1px solid rgba(255,255,255,0.3);">

    <!-- Employee ID Input -->
    <div class="mb-3 text-start">
        <label for="employeeId" class="form-label fw-bold">Employee ID</label>
        <input
            type="number"
            id="employeeId"
            class="form-control"
            placeholder="Enter your Employee ID"
            required
        >
    </div>

    <!-- Action Buttons -->
    <div class="d-grid gap-3 mt-4">
        <button class="btn btn-checkin btn-lg" onclick="submitCheckin()">✅ Check In</button>
        <button class="btn btn-checkout btn-lg" onclick="submitCheckout()">⏰ Check Out</button>
    </div>

    <!-- Status Message -->
    <div id="statusMsg"></div>
</div>

<!-- =======================================================
     LOAD CENTRALIZED MODULES (ORDER MATTERS)
======================================================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   CHARLIE CAFÉ — ATTENDANCE PAGE (PROTECTED)
   ----------------------------------------------------------
   ✔ Requires Cognito Login
   ✔ Employee or Admin Role Required
   ✔ Uses /prod HR endpoints
========================================================== */

// ================= INIT PAGE SECURITY =================
CHARLIE_AUTH.protectPage();           // Ensure only logged-in users can access
CHARLIE_AUTH.startAutoLogoutWatcher(); // Auto logout on inactivity

// ================= Utility: Show Status Message =================
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}

// ================= Validate Employee ID =================
function getEmployeeId() {
    const empId = document.getElementById("employeeId").value.trim();
    if (!empId) {
        showMessage("❌ Please enter Employee ID", false);
        return null;
    }
    return empId;
}

// ==========================================================
// 1️⃣ CHECK-IN (Cognito Protected API)
// ==========================================================
async function submitCheckin() {
    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {
        const result = await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkin"
        });
        showMessage("✅ Check-In successful. Have a great shift!");
    } catch (error) {
        console.error(error);
        showMessage("❌ Check-In failed or unauthorized.", false);
    }
}

// ==========================================================
// 2️⃣ CHECK-OUT (Cognito Protected API)
// ==========================================================
async function submitCheckout() {
    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {
        const result = await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkout"
        });
        showMessage("⏰ Check-Out successful. Thank you!");
    } catch (error) {
        console.error(error);
        showMessage("❌ Check-Out failed or unauthorized.", false);
    }
}

// ==========================================================
// Show page after JS is loaded to avoid FOUC
// ==========================================================
document.body.style.display = "flex";
</script>

</body>
</html>
```

### ✅ What’s updated:

- Modern “Charlie Café” card layout like your employee login page.

- Background + dark overlay for consistency with login page.

- Poppins font + styled buttons with gradient hover effects.

- Attendance card input and buttons now fully match the style of login card.

- Cognito protection and modular JS integration retained (config.js, utils.js, central-auth.js, api.js).

- Status messages styled with green/red colors for success/error.

### live clock with timezone selection

absolutely add a live clock with timezone selection using only frontend JavaScript.
No Lambda, no backend, no API required.

We’ll use:

setInterval() for live updates

Intl.DateTimeFormat() for timezone support

A dropdown to select timezone (including Pakistan Standard Time 🇵🇰)

Auto-detect user timezone by default

Below is your fully updated checkin.html with:

✔ Modern Charlie Café UI
✔ Cognito protection
✔ Check-in / Check-out
✔ Live clock
✔ Timezone selector (Pakistan included)
✔ Fully commented

### ✅ FULL UPDATED checkin.html (With Live Time Clock + Timezone Selector)

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= Bootstrap CSS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= Google Font ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ===================================================
   Global Body & Background
=================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: #fff;
}

/* Dark overlay */
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
    z-index: 0;
}

/* Attendance Card */
.attendance-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 420px;
    text-align: center;
    z-index: 2;
}

/* Logo */
.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

/* Buttons */
.btn-checkin, .btn-checkout {
    border-radius: 50px;
    font-weight: 600;
    padding: 12px;
    transition: 0.3s;
}

.btn-checkin {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    color: #fff;
}

.btn-checkout {
    background: linear-gradient(135deg,#8b0000,#ff4500);
    color: #fff;
}

.btn-checkin:hover,
.btn-checkout:hover {
    transform: scale(1.05);
}

/* Live Clock Style */
.clock-box {
    background: rgba(255,255,255,0.1);
    border-radius: 12px;
    padding: 15px;
    margin-bottom: 20px;
}

#liveClock {
    font-size: 20px;
    font-weight: 600;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="attendance-card">

    <div class="logo">☕</div>
    <h2>Charlie Café</h2>
    <p>Employee Attendance System</p>

    <!-- ================= LIVE CLOCK SECTION ================= -->
    <div class="clock-box">
        <div id="liveClock">Loading time...</div>

        <!-- Timezone Selector -->
        <select id="timezoneSelect" class="form-select mt-3">
            <option value="Asia/Karachi">🇵🇰 Pakistan Standard Time</option>
            <option value="UTC">🌍 UTC</option>
            <option value="Asia/Dubai">🇦🇪 UAE</option>
            <option value="Europe/London">🇬🇧 London</option>
            <option value="America/New_York">🇺🇸 New York</option>
        </select>
    </div>

    <hr style="border-top:1px solid rgba(255,255,255,0.3);">

    <!-- Employee ID -->
    <div class="mb-3 text-start">
        <label class="form-label fw-bold">Employee ID</label>
        <input type="number" id="employeeId" class="form-control" placeholder="Enter your Employee ID">
    </div>

    <!-- Buttons -->
    <div class="d-grid gap-3 mt-4">
        <button class="btn btn-checkin btn-lg" onclick="submitCheckin()">✅ Check In</button>
        <button class="btn btn-checkout btn-lg" onclick="submitCheckout()">⏰ Check Out</button>
    </div>

    <!-- Status -->
    <div id="statusMsg" class="mt-4 fw-bold"></div>
</div>

<!-- ================= Load Modules ================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   PAGE SECURITY (Cognito Protected)
========================================================== */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ==========================================================
   LIVE CLOCK WITH TIMEZONE SUPPORT
   - No backend required
   - Uses Intl.DateTimeFormat
========================================================== */

// Default timezone (Pakistan)
let selectedTimezone = "Asia/Karachi";

// Function to update live time
function updateClock() {
    const now = new Date();

    const options = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit"
    };

    const formatted = new Intl.DateTimeFormat("en-US", options).format(now);

    document.getElementById("liveClock").innerText = formatted;
}

// Run every second
setInterval(updateClock, 1000);
updateClock();

// Change timezone when dropdown changes
document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   ATTENDANCE FUNCTIONS
========================================================== */

function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}

function getEmployeeId() {
    const empId = document.getElementById("employeeId").value.trim();
    if (!empId) {
        showMessage("❌ Please enter Employee ID", false);
        return null;
    }
    return empId;
}

async function submitCheckin() {
    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {
        await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkin"
        });

        showMessage("✅ Check-In successful!");
    } catch (error) {
        showMessage("❌ Check-In failed.", false);
    }
}

async function submitCheckout() {
    const employeeId = getEmployeeId();
    if (!employeeId) return;

    try {
        await CHARLIE_API.protected.recordAttendance({
            employee_id: employeeId,
            action: "checkout"
        });

        showMessage("⏰ Check-Out successful!");
    } catch (error) {
        showMessage("❌ Check-Out failed.", false);
    }
}
</script>

</body>
</html>
```

### ✅ What You Now Have

✔ Live running clock
✔ Timezone dropdown
✔ Pakistan Standard Time (Asia/Karachi)
✔ No backend required
✔ Updates every second
✔ Styled to match Charlie Café theme

### 💡 professional biometric-style attendance UI

### 🏢 What Makes It “Biometric-Style”?

A professional biometric attendance UI usually has:

#### 1️⃣ Large Digital Clock (Center Focus)

- Big bold time (HH:MM:SS)

- Date below it

- Selected timezone displayed

- Shift status (On Time / Late / Overtime)

#### 2️⃣ Employee Identity Panel

- Instead of typing ID manually:

    - Enter ID

    - OR Scan barcode (optional)

    - OR Simulated fingerprint button

    - Show employee name + role after lookup

#### 3️⃣ Fingerprint Animation Area

- Big circular scan area

- Animated pulse

- "Place Finger" message
- 
Success / Failed scan animation

#### 4️⃣ Status Feedback System

- Color-coded:

    🟢 Green → Check-in success

    🔵 Blue → Check-out

    🔴 Red → Error

    🟡 Orange → Late

#### 5️⃣ Session Timer

After check-in:

- Shows: “You have been working for 02:15:23”

- Updates every second

### 🎨 UI Structure (Professional Layout)

```
 -----------------------------------
|  LIVE CLOCK (Large)              |
|  Monday, 17 Feb 2026             |
|  Asia/Karachi                    |
 -----------------------------------
|         🔵 SCAN AREA             |
|      [ Fingerprint Icon ]        |
|       Tap to Check In            |
 -----------------------------------
|  Employee Name                   |
|  Role                            |
|  Status Message                  |
 -----------------------------------
```

### 🔥 Key Professional Features You Can Add (Frontend Only)

#### ✅ 1. Large Digital Clock

```
.big-clock {
    font-size: 48px;
    font-weight: 700;
    letter-spacing: 2px;
}
```

#### ✅ 2. Fingerprint Scan Animation

```
<div class="fingerprint" onclick="simulateScan()">
    <div class="pulse"></div>
    <div class="icon">🔐</div>
    <p>Tap to Scan</p>
</div>
```

```
.fingerprint {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    margin: auto;
    cursor: pointer;
    transition: 0.3s;
}

.fingerprint:hover {
    transform: scale(1.1);
}
```

#### ✅ 3. Scan Simulation Logic

```
function simulateScan() {
    showMessage("🔍 Scanning fingerprint...", true);

    setTimeout(() => {
        showMessage("✅ Identity verified. Checked In!", true);
    }, 2000);
}
```

This creates a realistic biometric effect.

#### ✅ 4. Auto Late Detection (Professional Feature)

You can automatically detect late arrival:

```
function isLate() {
    const now = new Date();
    const hour = now.getHours();
    return hour >= 10; // Example: Late after 10 AM
}
```

Then:

```
if (isLate()) {
    showMessage("⚠️ Late Check-In", false);
}
```

#### ✅ 5. Work Session Timer

```
let sessionStart = null;
let sessionInterval;

function startSessionTimer() {
    sessionStart = new Date();
    sessionInterval = setInterval(() => {
        const now = new Date();
        const diff = Math.floor((now - sessionStart)/1000);

        const hrs = String(Math.floor(diff/3600)).padStart(2,"0");
        const mins = String(Math.floor((diff%3600)/60)).padStart(2,"0");
        const secs = String(diff%60).padStart(2,"0");

        document.getElementById("sessionTimer").innerText =
            `Working Time: ${hrs}:${mins}:${secs}`;
    }, 1000);
}
```

### 🏆 If You Want REAL Professional Level

You can upgrade further:

#### 🔹 Auto Employee Recognition

When ID entered:

- Fetch employee name from API

- Show photo

- Show department

- Show last check-in time

#### 🔹 Dark / Light Terminal Mode

Toggle theme like real attendance machines.

#### 🔹 Sound Effects

Add beep sound on success:

```
new Audio("beep.mp3").play();
```

#### 🔹 Full Screen Mode

Make it kiosk mode:

```
document.documentElement.requestFullscreen();
```

### 🧠 Important: Frontend vs Real Biometric

Frontend simulation = UI experience only
Real biometric system = Requires:

- Fingerprint hardware

- Device SDK

- Backend verification

But for company attendance UI — simulation is 100% acceptable if login is Cognito-protected.

### ✅ FINAL PROFESSIONAL BIOMETRIC-STYLE checkin.html

below is your fully upgraded Professional Biometric-Style Attendance UI
✔ Live Digital Clock
✔ Timezone Selector (Pakistan default 🇵🇰)
✔ Fingerprint Scan Animation
✔ Late Detection
✔ Work Session Timer
✔ Cognito Protected
✔ Modern Charlie Café Theme
✔ Fully Commented

This is a complete final version of your checkin.html.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= Bootstrap ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= Google Font ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ==========================================================
   GLOBAL BACKGROUND
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: white;
}

/* Dark overlay */
.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

/* ==========================================================
   MAIN TERMINAL CARD
========================================================== */
.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
    box-shadow: 0 15px 40px rgba(0,0,0,0.6);
}

/* Big Live Clock */
.big-clock {
    font-size: 42px;
    font-weight: 700;
    letter-spacing: 2px;
}

/* Date */
.date-text {
    font-size: 14px;
    opacity: 0.8;
}

/* ==========================================================
   FINGERPRINT SCAN AREA
========================================================== */
.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
}

.fingerprint:hover {
    transform: scale(1.1);
}

/* Pulse animation */
.fingerprint::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.6);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1.4); opacity: 0; }
}

/* Session Timer */
.session-timer {
    font-size: 14px;
    margin-top: 10px;
    color: #90ee90;
}

/* Status Message */
#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

    <!-- Logo -->
    <h3>☕ Charlie Café</h3>
    <p>Biometric Attendance Terminal</p>

    <!-- ================= LIVE CLOCK ================= -->
    <div class="big-clock" id="liveClock">00:00:00</div>
    <div class="date-text" id="liveDate"></div>

    <!-- Timezone Selector -->
    <select id="timezoneSelect" class="form-select mt-2 mb-3">
        <option value="Asia/Karachi">🇵🇰 Pakistan Standard Time</option>
        <option value="UTC">🌍 UTC</option>
        <option value="Asia/Dubai">🇦🇪 UAE</option>
        <option value="Europe/London">🇬🇧 London</option>
        <option value="America/New_York">🇺🇸 New York</option>
    </select>

    <hr style="border-top:1px solid rgba(255,255,255,0.3);">

    <!-- Employee ID -->
    <input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

    <!-- ================= FINGERPRINT SCAN AREA ================= -->
    <div class="fingerprint" onclick="simulateScan()">
        🔐
    </div>
    <p>Tap fingerprint to Check In / Out</p>

    <!-- Status -->
    <div id="statusMsg"></div>

    <!-- Session Timer -->
    <div class="session-timer" id="sessionTimer"></div>

</div>

<!-- ================= Load Protected Modules ================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   PROTECT PAGE WITH COGNITO
========================================================== */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ==========================================================
   LIVE CLOCK WITH TIMEZONE
========================================================== */

let selectedTimezone = "Asia/Karachi";

function updateClock() {
    const now = new Date();

    const timeOptions = {
        timeZone: selectedTimezone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false
    };

    const dateOptions = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    };

    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", timeOptions).format(now);

    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", dateOptions).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   SESSION TIMER
========================================================== */

let sessionStart = null;
let sessionInterval = null;

function startSessionTimer() {
    sessionStart = new Date();

    sessionInterval = setInterval(() => {
        const diff = Math.floor((new Date() - sessionStart) / 1000);

        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");

        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;
    }, 1000);
}

/* ==========================================================
   LATE DETECTION (After 10 AM)
========================================================== */
function isLate() {
    const now = new Date();
    return now.getHours() >= 10;
}

/* ==========================================================
   BIOMETRIC SCAN SIMULATION
========================================================== */
async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();

    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    showMessage("🔍 Scanning fingerprint...", true);

    // Simulate scanning delay
    setTimeout(async () => {
        try {

            const action = "checkin";

            await CHARLIE_API.protected.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (isLate()) {
                showMessage("⚠️ Late Check-In recorded", false);
            } else {
                showMessage("✅ Check-In Successful", true);
            }

            startSessionTimer();

        } catch (error) {
            showMessage("❌ Scan failed or unauthorized", false);
        }

    }, 2000);
}

/* ==========================================================
   STATUS MESSAGE FUNCTION
========================================================== */
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

### 🚀 What You Now Have

This looks like a real biometric terminal:

✔ Large live digital clock
✔ Timezone selector (Pakistan default)
✔ Fingerprint animated scan
✔ Late detection
✔ Work session timer
✔ Cognito protected
✔ Professional dark terminal UI

When you see:

“Tap fingerprint to Check In / Out”

It does NOT mean a real fingerprint scanner.

In your current system, it means:

👉 It is a UI simulation button
👉 When you tap the fingerprint circle, it runs a JavaScript function
👉 That function sends the attendance request to your API

So it behaves like a biometric machine — but it's only frontend simulation.

### 🔍 What Actually Happens When You Tap It

This line connects the circle to the function:

```
<div class="fingerprint" onclick="simulateScan()">
```

When you click the fingerprint circle:

#### 1️⃣ It calls:

```
simulateScan()
```

#### 2️⃣ It checks:

Did you enter Employee ID?

If not → show error

#### 3️⃣ It shows:

```
🔍 Scanning fingerprint...
```

#### 4️⃣ After 2 seconds delay (fake scanning):

```
await CHARLIE_API.protected.recordAttendance({
    employee_id: employeeId,
    action: "checkin"
});
```

That sends attendance to your backend.

### 🧠 Why It Says “Check In / Out”

Right now, the code always sends:

```
action: "checkin"
```

So technically it is only doing Check-In, even though the UI says “Check In / Out”.

If you want it to:

- First tap = Check-In

- Second tap = Check-Out

We need to add toggle logic.

### 🎯 How Real Biometric Machines Work

#### Real fingerprint machine:

- Employee places finger

- Device scans fingerprint

- Device verifies fingerprint in hardware

- Sends verified employee ID to server

#### Your version:

- Employee enters ID

- Clicks fingerprint icon

- JavaScript pretends to scan

- Sends ID to server

So it's a visual professional simulation, not real biometric hardware.

### 🏢 Why This Is Still Professional

Many modern systems do this:

- Web-based attendance terminal

- Employee ID + face scan simulation

- Or badge tap simulation

- Cognito login protection

So this approach is completely acceptable for web attendance systems.

### ⚡ If You Want It To Be Smarter

Right now it's:

### 👉 Always check-in.

We can upgrade it to:

#### Option A — Auto Toggle

- If already checked in → do checkout

- If not checked in → do checkin

#### Option B — Two Modes

Add buttons:

- Mode: Check-In

- Mode: Check-Out

#### Option C — Fully Automatic

Detect based on last attendance record from API.

### CheckIn & CheckOut Toggle

Right now your fingerprint always does:

```
const action = "checkin";
```

So there is no way to checkout.

The cleanest professional solution is exactly what you suggested:

### ✅ Add a toggle selector to switch between Check-In and Check-Out.

That is how many real attendance terminals work.

#### ✅ What We Will Add

We will add:

A toggle button group:

🔵 Check In

🔴 Check Out

The fingerprint will read which mode is selected

Session timer will:

Start on Check-In

Stop on Check-Out

Status colors will change properly

### 🚀 FULL UPDATED CODE (With Toggle + Checkout Support)

Replace your current file with this version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    color: white;
    position: relative;
}

.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
}

.big-clock {
    font-size: 42px;
    font-weight: 700;
}

.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
}

.fingerprint:hover {
    transform: scale(1.1);
}

#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

<h3>☕ Charlie Café</h3>
<p>Biometric Attendance Terminal</p>

<div class="big-clock" id="liveClock"></div>
<div id="liveDate"></div>

<select id="timezoneSelect" class="form-select mt-2 mb-3">
    <option value="Asia/Karachi">🇵🇰 Pakistan Standard Time</option>
    <option value="UTC">🌍 UTC</option>
    <option value="Europe/London">🇬🇧 London</option>
</select>

<hr>

<input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

<!-- ================= TOGGLE BUTTON ================= -->
<div class="btn-group w-100 mb-3" role="group">
    <input type="radio" class="btn-check" name="mode" id="checkinMode" autocomplete="off" checked>
    <label class="btn btn-success" for="checkinMode">Check In</label>

    <input type="radio" class="btn-check" name="mode" id="checkoutMode" autocomplete="off">
    <label class="btn btn-danger" for="checkoutMode">Check Out</label>
</div>

<div class="fingerprint" onclick="simulateScan()">
    🔐
</div>

<p>Tap fingerprint to confirm</p>

<div id="statusMsg"></div>
<div id="sessionTimer" class="mt-2"></div>

</div>

<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ================= LIVE CLOCK ================= */

let selectedTimezone = "Asia/Karachi";

function updateClock() {
    const now = new Date();
    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", {
            timeZone: selectedTimezone,
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: false
        }).format(now);

    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", {
            timeZone: selectedTimezone,
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "numeric"
        }).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ================= SESSION TIMER ================= */

let sessionInterval;

function startSessionTimer() {
    const startTime = new Date();

    sessionInterval = setInterval(() => {
        const diff = Math.floor((new Date() - startTime) / 1000);
        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");
        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;
    }, 1000);
}

function stopSessionTimer() {
    clearInterval(sessionInterval);
    document.getElementById("sessionTimer").innerText = "";
}

/* ================= SCAN FUNCTION ================= */

async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();
    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    // Detect selected mode
    const action = document.getElementById("checkinMode").checked ? "checkin" : "checkout";

    showMessage("🔍 Processing " + action + "...", true);

    setTimeout(async () => {
        try {

            await CHARLIE_API.protected.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (action === "checkin") {
                showMessage("✅ Check-In Successful", true);
                startSessionTimer();
            } else {
                showMessage("👋 Check-Out Successful", true);
                stopSessionTimer();
            }

        } catch (error) {
            showMessage("❌ Failed or Unauthorized", false);
        }

    }, 1500);
}

/* ================= MESSAGE ================= */

function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

### ✅ Now How It Works

- Select Check In or Check Out

- Enter Employee ID

- Tap fingerprint

- System sends:

```
action: "checkin"
```

OR

```
action: "checkout"
```

Timer starts or stops accordingly.

### 🎯 This Is Now Professional Level

✔ Clear mode selection
✔ Clean UI
✔ No confusion
✔ Proper check-in & check-out
✔ Session timer control

### Upgrade CheckIN & CheckOut Toggle 

let’s upgrade your toggle to look more professional biometric-machine style instead of default Bootstrap buttons.

We’ll create:

✅ Sliding animated toggle
✅ Color-coded modes

🟢 Green = Check-In

🔴 Red = Check-Out
✅ Smooth transition
✅ Modern terminal look
✅ Fully commented code

### 🔥 WHAT WE ARE CHANGING

We will replace this:

```
<div class="btn-group w-100 mb-3">
```

With a custom animated biometric-style switch.

### ✅ ✅ FULL UPDATED CODE (Only the Toggle Section + CSS + JS update)

You only need to:

- Replace the toggle HTML section

- Add the new CSS

- Replace the toggle JS

- Everything else stays the same.

### 🟢 1️⃣ REPLACE YOUR TOGGLE HTML WITH THIS

Place this above Employee ID input

```
<!-- ==========================================================
   BIOMETRIC STYLE CHECK-IN / CHECK-OUT TOGGLE
========================================================== -->
<div class="mode-toggle-container mb-3">

    <!-- Hidden radio buttons (real logic controllers) -->
    <input type="radio" name="attendanceMode" id="checkinMode" value="checkin" checked>
    <input type="radio" name="attendanceMode" id="checkoutMode" value="checkout">

    <!-- Visual Toggle -->
    <div class="mode-toggle">
        <div class="toggle-slider"></div>

        <label for="checkinMode" class="toggle-option checkin-label">
            🟢 Check-In
        </label>

        <label for="checkoutMode" class="toggle-option checkout-label">
            🔴 Check-Out
        </label>
    </div>

</div>
```

### 🎨 2️⃣ ADD THIS CSS INSIDE YOUR <style> SECTION

```
/* ==========================================================
   PROFESSIONAL BIOMETRIC TOGGLE STYLE
========================================================== */

.mode-toggle-container {
    position: relative;
    width: 100%;
}

/* Hide actual radio buttons */
.mode-toggle-container input {
    display: none;
}

/* Main toggle background */
.mode-toggle {
    position: relative;
    display: flex;
    background: #2b1b14;
    border-radius: 50px;
    height: 55px;
    cursor: pointer;
    overflow: hidden;
    border: 2px solid rgba(255,255,255,0.2);
}

/* Sliding background */
.toggle-slider {
    position: absolute;
    width: 50%;
    height: 100%;
    background: linear-gradient(135deg, #4caf50, #2e7d32);
    border-radius: 50px;
    transition: 0.4s ease;
}

/* Toggle labels */
.toggle-option {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    z-index: 2;
    color: white;
    transition: 0.3s;
    font-size: 15px;
}

/* Checkout active color */
#checkoutMode:checked ~ .mode-toggle .toggle-slider {
    left: 50%;
    background: linear-gradient(135deg, #e53935, #b71c1c);
}

/* Text brightness */
#checkinMode:checked ~ .mode-toggle .checkin-label {
    color: white;
}

#checkoutMode:checked ~ .mode-toggle .checkout-label {
    color: white;
}
```

### 🧠 3️⃣ UPDATE YOUR simulateScan() FUNCTION

Replace this line:

```
const action = document.querySelector('input[name="attendanceMode"]:checked').value;
```

Make sure your function contains:

```
const action = document.querySelector('input[name="attendanceMode"]:checked').value;
```

And update the success message section to:

```
if (action === "checkin") {
    if (isLate()) {
        showMessage("⚠️ Late Check-In recorded", false);
    } else {
        showMessage("✅ Check-In Successful", true);
    }
    startSessionTimer();
} else {
    showMessage("🔴 Check-Out Successful", true);
    clearInterval(sessionInterval);
    document.getElementById("sessionTimer").innerText = "";
}
```

### ✅ ✅ FULL FINAL CODE (Production Ready)

Below is your FULL FINAL checkin.html code with:

✅ Live clock with timezone selector
✅ Professional biometric-style animated toggle
✅ Check-In / Check-Out working properly
✅ Session working timer
✅ Late detection
✅ Cognito protection
✅ Clean professional styling
✅ FULL COMMENTS everywhere

You can copy-paste this entire file directly.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==========================================================
   BOOTSTRAP (UI Framework)
========================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ==========================================================
   GOOGLE FONT
========================================================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ==========================================================
   GLOBAL BACKGROUND
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: white;
}

/* Dark overlay */
.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

/* ==========================================================
   MAIN TERMINAL CARD
========================================================== */
.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
    box-shadow: 0 15px 40px rgba(0,0,0,0.6);
}

/* Big Live Clock */
.big-clock {
    font-size: 42px;
    font-weight: 700;
    letter-spacing: 2px;
}

/* Date */
.date-text {
    font-size: 14px;
    opacity: 0.8;
}

/* ==========================================================
   PROFESSIONAL BIOMETRIC TOGGLE
========================================================== */
.mode-toggle-container {
    position: relative;
    width: 100%;
}

/* Hide radio buttons */
.mode-toggle-container input {
    display: none;
}

/* Toggle base */
.mode-toggle {
    position: relative;
    display: flex;
    background: #2b1b14;
    border-radius: 50px;
    height: 55px;
    overflow: hidden;
    border: 2px solid rgba(255,255,255,0.2);
}

/* Sliding color background */
.toggle-slider {
    position: absolute;
    width: 50%;
    height: 100%;
    background: linear-gradient(135deg, #4caf50, #2e7d32);
    border-radius: 50px;
    transition: 0.4s ease;
}

/* Labels */
.toggle-option {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    z-index: 2;
    cursor: pointer;
}

/* Red color when checkout selected */
#checkoutMode:checked ~ .mode-toggle .toggle-slider {
    left: 50%;
    background: linear-gradient(135deg, #e53935, #b71c1c);
}

/* ==========================================================
   FINGERPRINT AREA
========================================================== */
.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
}

.fingerprint:hover {
    transform: scale(1.1);
}

/* Pulse effect */
.fingerprint::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.6);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1.4); opacity: 0; }
}

/* Status Message */
#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}

/* Session Timer */
.session-timer {
    font-size: 14px;
    margin-top: 10px;
    color: #90ee90;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

    <!-- ==========================================================
       HEADER
    ========================================================== -->
    <h3>☕ Charlie Café</h3>
    <p>Biometric Attendance Terminal</p>

    <!-- ==========================================================
       LIVE CLOCK SECTION
    ========================================================== -->
    <div class="big-clock" id="liveClock">00:00:00</div>
    <div class="date-text" id="liveDate"></div>

    <!-- Timezone Selector -->
    <select id="timezoneSelect" class="form-select mt-2 mb-3">
        <option value="Asia/Karachi">🇵🇰 Pakistan</option>
        <option value="UTC">🌍 UTC</option>
        <option value="Asia/Dubai">🇦🇪 UAE</option>
        <option value="Europe/London">🇬🇧 London</option>
        <option value="America/New_York">🇺🇸 New York</option>
    </select>

    <hr>

    <!-- ==========================================================
       CHECK-IN / CHECK-OUT TOGGLE
    ========================================================== -->
    <div class="mode-toggle-container mb-3">

        <!-- Hidden radio inputs -->
        <input type="radio" name="attendanceMode" id="checkinMode" value="checkin" checked>
        <input type="radio" name="attendanceMode" id="checkoutMode" value="checkout">

        <!-- Visual Toggle -->
        <div class="mode-toggle">
            <div class="toggle-slider"></div>

            <label for="checkinMode" class="toggle-option">
                🟢 Check-In
            </label>

            <label for="checkoutMode" class="toggle-option">
                🔴 Check-Out
            </label>
        </div>
    </div>

    <!-- Employee ID -->
    <input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

    <!-- Fingerprint -->
    <div class="fingerprint" onclick="simulateScan()">
        🔐
    </div>

    <p>Tap fingerprint to confirm attendance</p>

    <div id="statusMsg"></div>
    <div class="session-timer" id="sessionTimer"></div>

</div>

<!-- ==========================================================
   LOAD YOUR EXISTING SYSTEM FILES
========================================================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   COGNITO PAGE PROTECTION
========================================================== */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ==========================================================
   LIVE CLOCK WITH TIMEZONE SUPPORT
========================================================== */

let selectedTimezone = "Asia/Karachi";

function updateClock() {

    const now = new Date();

    const timeOptions = {
        timeZone: selectedTimezone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false
    };

    const dateOptions = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    };

    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", timeOptions).format(now);

    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", dateOptions).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   SESSION TIMER (Tracks working duration after check-in)
========================================================== */

let sessionStart = null;
let sessionInterval = null;

function startSessionTimer() {

    sessionStart = new Date();

    sessionInterval = setInterval(() => {

        const diff = Math.floor((new Date() - sessionStart) / 1000);

        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");

        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;

    }, 1000);
}

/* ==========================================================
   LATE DETECTION (After 10 AM local browser time)
========================================================== */
function isLate() {
    const now = new Date();
    return now.getHours() >= 10;
}

/* ==========================================================
   FINGERPRINT SCAN SIMULATION
========================================================== */
async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();
    const action = document.querySelector('input[name="attendanceMode"]:checked').value;

    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    showMessage("🔍 Scanning fingerprint...", true);

    setTimeout(async () => {

        try {

            await CHARLIE_API.protected.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (action === "checkin") {

                if (isLate()) {
                    showMessage("⚠️ Late Check-In recorded", false);
                } else {
                    showMessage("✅ Check-In Successful", true);
                }

                startSessionTimer();

            } else {

                showMessage("🔴 Check-Out Successful", true);
                clearInterval(sessionInterval);
                document.getElementById("sessionTimer").innerText = "";

            }

        } catch (error) {
            showMessage("❌ Scan failed or unauthorized", false);
        }

    }, 2000);
}

/* ==========================================================
   STATUS MESSAGE DISPLAY
========================================================== */
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

### 🎯 FINAL RESULT

Now your toggle:

- Looks like a biometric terminal control

- Slides smoothly left/right

- Changes color dynamically

- Sends correct action to backend

- Controls session timer properly

- Looks enterprise-level

### 🚀 VISUAL EFFECT

When user switches:

🟢 Check-In → Green glow
🔴 Check-Out → Red glow
Fingerprint tap → Records selected mode

### 🧐 an important point

let’s clarify carefully. 🧐

#### 1️⃣ Your old checkin.html

Your old file was calling this function:

```
await CHARLIE_API.protected.recordAttendance({
    employee_id: employeeId,
    action: action
});
```

- This function is defined in your api.js and sends data to your Lambda backend or Cognito-protected API.

- The rest of the UI (clock, timer) was frontend only.

- Everything worked without changing Lambda, because the API endpoint expected { employee_id, action }.

#### 2️⃣ This new checkin.html

Backend logic is unchanged:

```
await CHARLIE_API.protected.recordAttendance({
    employee_id: employeeId,
    action: action
});
```

✅ Same CHARLIE_API object is called

✅ Same Lambda backend receives the same payload: employee_id + action

✅ Check-In / Check-Out now sends "checkin" or "checkout" based on toggle

#### 3️⃣ What you DO NOT need to change

- api.js functions that handle recordAttendance()

- Your Lambda backend itself (it still expects employee_id and action)

- Cognito protection code (central-auth.js)

#### 4️⃣ What is different in this new UI

- Toggle input lets you select Check-In or Check-Out

- Fingerprint button calls same API but sends correct action

- Session timer starts on Check-In and stops on Check-Out

- Late detection shows warning if check-in is after 10 AM

- UI is upgraded (professional animated toggle + fingerprint + clock)

### ✅ Summary

- This new checkin.html will work exactly the same with your old Lambda backend.

- No backend modification is required.

- Only difference is frontend now has Check-In / Check-Out toggle.

### ✅ Fully final code


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==========================================================
   BOOTSTRAP (UI Framework)
========================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ==========================================================
   GOOGLE FONT
========================================================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ==========================================================
   GLOBAL BACKGROUND
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: white;
}

/* Dark overlay */
.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

/* ==========================================================
   MAIN TERMINAL CARD
========================================================== */
.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
    box-shadow: 0 15px 40px rgba(0,0,0,0.6);
}

/* Big Live Clock */
.big-clock {
    font-size: 42px;
    font-weight: 700;
    letter-spacing: 2px;
}

/* Date */
.date-text {
    font-size: 14px;
    opacity: 0.8;
}

/* ==========================================================
   PROFESSIONAL BIOMETRIC TOGGLE
========================================================== */
.mode-toggle-container {
    position: relative;
    width: 100%;
}

/* Hide radio buttons */
.mode-toggle-container input {
    display: none;
}

/* Toggle base */
.mode-toggle {
    position: relative;
    display: flex;
    background: #2b1b14;
    border-radius: 50px;
    height: 55px;
    overflow: hidden;
    border: 2px solid rgba(255,255,255,0.2);
}

/* Sliding color background */
.toggle-slider {
    position: absolute;
    width: 50%;
    height: 100%;
    background: linear-gradient(135deg, #4caf50, #2e7d32);
    border-radius: 50px;
    transition: 0.4s ease;
}

/* Labels */
.toggle-option {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    z-index: 2;
    cursor: pointer;
}

/* Red color when checkout selected */
#checkoutMode:checked ~ .mode-toggle .toggle-slider {
    left: 50%;
    background: linear-gradient(135deg, #e53935, #b71c1c);
}

/* ==========================================================
   FINGERPRINT AREA
========================================================== */
.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
}

.fingerprint:hover {
    transform: scale(1.1);
}

/* Pulse effect */
.fingerprint::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.6);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1.4); opacity: 0; }
}

/* Status Message */
#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}

/* Session Timer */
.session-timer {
    font-size: 14px;
    margin-top: 10px;
    color: #90ee90;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

    <!-- ==========================================================
       HEADER
    ========================================================== -->
    <h3>☕ Charlie Café</h3>
    <p>Biometric Attendance Terminal</p>

    <!-- ==========================================================
       LIVE CLOCK SECTION
    ========================================================== -->
    <div class="big-clock" id="liveClock">00:00:00</div>
    <div class="date-text" id="liveDate"></div>

    <!-- Timezone Selector -->
    <select id="timezoneSelect" class="form-select mt-2 mb-3">
        <option value="Asia/Karachi">🇵🇰 Pakistan</option>
        <option value="UTC">🌍 UTC</option>
        <option value="Asia/Dubai">🇦🇪 UAE</option>
        <option value="Europe/London">🇬🇧 London</option>
        <option value="America/New_York">🇺🇸 New York</option>
    </select>

    <hr>

    <!-- ==========================================================
       CHECK-IN / CHECK-OUT TOGGLE
    ========================================================== -->
    <div class="mode-toggle-container mb-3">

        <!-- Hidden radio inputs -->
        <input type="radio" name="attendanceMode" id="checkinMode" value="checkin" checked>
        <input type="radio" name="attendanceMode" id="checkoutMode" value="checkout">

        <!-- Visual Toggle -->
        <div class="mode-toggle">
            <div class="toggle-slider"></div>

            <label for="checkinMode" class="toggle-option">
                🟢 Check-In
            </label>

            <label for="checkoutMode" class="toggle-option">
                🔴 Check-Out
            </label>
        </div>
    </div>

    <!-- Employee ID -->
    <input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

    <!-- Fingerprint -->
    <div class="fingerprint" onclick="simulateScan()">
        🔐
    </div>

    <p>Tap fingerprint to confirm attendance</p>

    <div id="statusMsg"></div>
    <div class="session-timer" id="sessionTimer"></div>

</div>

<!-- ==========================================================
   LOAD YOUR EXISTING SYSTEM FILES
========================================================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   COGNITO PAGE PROTECTION
========================================================== */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ==========================================================
   LIVE CLOCK WITH TIMEZONE SUPPORT
========================================================== */

let selectedTimezone = "Asia/Karachi";

function updateClock() {

    const now = new Date();

    const timeOptions = {
        timeZone: selectedTimezone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false
    };

    const dateOptions = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    };

    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", timeOptions).format(now);

    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", dateOptions).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   SESSION TIMER (Tracks working duration after check-in)
========================================================== */

let sessionStart = null;
let sessionInterval = null;

function startSessionTimer() {

    sessionStart = new Date();

    sessionInterval = setInterval(() => {

        const diff = Math.floor((new Date() - sessionStart) / 1000);

        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");

        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;

    }, 1000);
}

/* ==========================================================
   LATE DETECTION (After 10 AM local browser time)
========================================================== */
function isLate() {
    const now = new Date();
    return now.getHours() >= 10;
}

/* ==========================================================
   FINGERPRINT SCAN SIMULATION
========================================================== */
async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();
    const action = document.querySelector('input[name="attendanceMode"]:checked').value;

    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    showMessage("🔍 Scanning fingerprint...", true);

    setTimeout(async () => {

        try {

            await CHARLIE_API.protected.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (action === "checkin") {

                if (isLate()) {
                    showMessage("⚠️ Late Check-In recorded", false);
                } else {
                    showMessage("✅ Check-In Successful", true);
                }

                startSessionTimer();

            } else {

                showMessage("🔴 Check-Out Successful", true);
                clearInterval(sessionInterval);
                document.getElementById("sessionTimer").innerText = "";

            }

        } catch (error) {
            showMessage("❌ Scan failed or unauthorized", false);
        }

    }, 2000);
}

/* ==========================================================
   STATUS MESSAGE DISPLAY
========================================================== */
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

---
### checkin.html

> **Update Version:1.2**

- Works with your POST-only public HR APIs

- Removes unnecessary Cognito headers for API calls (Cognito only protects page display)

- Keeps all current features (live clock, timezone, session timer, late detection, fingerprint simulation)

- Includes comments for clarity

### Here’s the final polished version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==========================================================
   BOOTSTRAP (UI Framework)
========================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ==========================================================
   GOOGLE FONT
========================================================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ==========================================================
   GLOBAL BACKGROUND
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: white;
}

/* Dark overlay */
.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

/* ==========================================================
   MAIN TERMINAL CARD
========================================================== */
.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
    box-shadow: 0 15px 40px rgba(0,0,0,0.6);
}

/* Big Live Clock */
.big-clock {
    font-size: 42px;
    font-weight: 700;
    letter-spacing: 2px;
}

/* Date */
.date-text {
    font-size: 14px;
    opacity: 0.8;
}

/* ==========================================================
   PROFESSIONAL BIOMETRIC TOGGLE
========================================================== */
.mode-toggle-container {
    position: relative;
    width: 100%;
}

/* Hide radio buttons */
.mode-toggle-container input {
    display: none;
}

/* Toggle base */
.mode-toggle {
    position: relative;
    display: flex;
    background: #2b1b14;
    border-radius: 50px;
    height: 55px;
    overflow: hidden;
    border: 2px solid rgba(255,255,255,0.2);
}

/* Sliding color background */
.toggle-slider {
    position: absolute;
    width: 50%;
    height: 100%;
    background: linear-gradient(135deg, #4caf50, #2e7d32);
    border-radius: 50px;
    transition: 0.4s ease;
}

/* Labels */
.toggle-option {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    z-index: 2;
    cursor: pointer;
}

/* Red color when checkout selected */
#checkoutMode:checked ~ .mode-toggle .toggle-slider {
    left: 50%;
    background: linear-gradient(135deg, #e53935, #b71c1c);
}

/* ==========================================================
   FINGERPRINT AREA
========================================================== */
.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
}

.fingerprint:hover {
    transform: scale(1.1);
}

/* Pulse effect */
.fingerprint::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.6);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1.4); opacity: 0; }
}

/* Status Message */
#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}

/* Session Timer */
.session-timer {
    font-size: 14px;
    margin-top: 10px;
    color: #90ee90;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

    <!-- ==========================================================
       HEADER
    ========================================================== -->
    <h3>☕ Charlie Café</h3>
    <p>Biometric Attendance Terminal</p>

    <!-- ==========================================================
       LIVE CLOCK SECTION
    ========================================================== -->
    <div class="big-clock" id="liveClock">00:00:00</div>
    <div class="date-text" id="liveDate"></div>

    <!-- Timezone Selector -->
    <select id="timezoneSelect" class="form-select mt-2 mb-3">
        <option value="Asia/Karachi">🇵🇰 Pakistan</option>
        <option value="UTC">🌍 UTC</option>
        <option value="Asia/Dubai">🇦🇪 UAE</option>
        <option value="Europe/London">🇬🇧 London</option>
        <option value="America/New_York">🇺🇸 New York</option>
    </select>

    <hr>

    <!-- ==========================================================
       CHECK-IN / CHECK-OUT TOGGLE
    ========================================================== -->
    <div class="mode-toggle-container mb-3">

        <!-- Hidden radio inputs -->
        <input type="radio" name="attendanceMode" id="checkinMode" value="checkin" checked>
        <input type="radio" name="attendanceMode" id="checkoutMode" value="checkout">

        <!-- Visual Toggle -->
        <div class="mode-toggle">
            <div class="toggle-slider"></div>

            <label for="checkinMode" class="toggle-option">
                🟢 Check-In
            </label>

            <label for="checkoutMode" class="toggle-option">
                🔴 Check-Out
            </label>
        </div>
    </div>

    <!-- Employee ID -->
    <input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

    <!-- Fingerprint -->
    <div class="fingerprint" onclick="simulateScan()">
        🔐
    </div>

    <p>Tap fingerprint to confirm attendance</p>

    <div id="statusMsg"></div>
    <div class="session-timer" id="sessionTimer"></div>

</div>

<!-- ==========================================================
   LOAD EXISTING SYSTEM FILES
========================================================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   COGNITO PAGE PROTECTION
   - Protects page visibility
   - Does NOT affect HR APIs (public)
========================================================== */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ==========================================================
   LIVE CLOCK WITH TIMEZONE SUPPORT
========================================================== */
let selectedTimezone = "Asia/Karachi";

function updateClock() {
    const now = new Date();

    const timeOptions = {
        timeZone: selectedTimezone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false
    };

    const dateOptions = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    };

    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", timeOptions).format(now);
    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", dateOptions).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   SESSION TIMER
   - Tracks working duration after check-in
========================================================== */
let sessionStart = null;
let sessionInterval = null;

function startSessionTimer() {
    sessionStart = new Date();
    sessionInterval = setInterval(() => {
        const diff = Math.floor((new Date() - sessionStart) / 1000);
        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");
        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;
    }, 1000);
}

/* ==========================================================
   LATE DETECTION
   - After 10 AM local browser time
========================================================== */
function isLate() {
    const now = new Date();
    return now.getHours() >= 10;
}

/* ==========================================================
   FINGERPRINT SCAN SIMULATION
   - Calls public POST HR API: /attendance
========================================================== */
async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();
    const action = document.querySelector('input[name="attendanceMode"]:checked').value;

    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    showMessage("🔍 Scanning fingerprint...", true);

    setTimeout(async () => {
        try {
            // ✅ Public HR API call, POST /attendance
            await CHARLIE_API.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (action === "checkin") {
                if (isLate()) {
                    showMessage("⚠️ Late Check-In recorded", false);
                } else {
                    showMessage("✅ Check-In Successful", true);
                }
                startSessionTimer();
            } else {
                showMessage("🔴 Check-Out Successful", true);
                clearInterval(sessionInterval);
                document.getElementById("sessionTimer").innerText = "";
            }

        } catch (error) {
            showMessage("❌ Scan failed or API error", false);
            console.error("Attendance API error:", error);
        }
    }, 2000);
}

/* ==========================================================
   STATUS MESSAGE DISPLAY
========================================================== */
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

### ✅ Key Fixes & Notes

- HR API is now fully public → no Authorization headers.

- simulateScan() calls POST /attendance exactly like Lambda expects.

- Cognito only protects page visibility, does not interfere with API calls.

- Added line-level comments to clarify clock, session timer, late detection, and API call.

- Everything else (toggle, fingerprint animation, session timer) works as intended.


### ✅ Fully final checkin.html

Here's the fully final checkin.html that is fully aligned with the final API.JS you have. It’s public, uses CHARLIE_API.recordAttendance(), includes live clock, session timer, late detection, and full comments for clarity:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Biometric Attendance</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==========================================================
   BOOTSTRAP (UI Framework)
========================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ==========================================================
   GOOGLE FONT
========================================================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ==========================================================
   GLOBAL BACKGROUND
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: white;
}

/* Dark overlay */
.overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.7);
}

/* ==========================================================
   MAIN TERMINAL CARD
========================================================== */
.terminal-card {
    position: relative;
    z-index: 2;
    width: 450px;
    background: rgba(58,37,28,0.95);
    border-radius: 20px;
    padding: 35px;
    text-align: center;
    box-shadow: 0 15px 40px rgba(0,0,0,0.6);
}

/* Big Live Clock */
.big-clock {
    font-size: 42px;
    font-weight: 700;
    letter-spacing: 2px;
}

/* Date */
.date-text {
    font-size: 14px;
    opacity: 0.8;
}

/* ==========================================================
   CHECK-IN / CHECK-OUT TOGGLE
========================================================== */
.mode-toggle-container {
    position: relative;
    width: 100%;
}

/* Hide radio buttons */
.mode-toggle-container input {
    display: none;
}

/* Toggle base */
.mode-toggle {
    position: relative;
    display: flex;
    background: #2b1b14;
    border-radius: 50px;
    height: 55px;
    overflow: hidden;
    border: 2px solid rgba(255,255,255,0.2);
}

/* Sliding color background */
.toggle-slider {
    position: absolute;
    width: 50%;
    height: 100%;
    background: linear-gradient(135deg, #4caf50, #2e7d32);
    border-radius: 50px;
    transition: 0.4s ease;
}

/* Labels */
.toggle-option {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    z-index: 2;
    cursor: pointer;
}

/* Red color when checkout selected */
#checkoutMode:checked ~ .mode-toggle .toggle-slider {
    left: 50%;
    background: linear-gradient(135deg, #e53935, #b71c1c);
}

/* ==========================================================
   FINGERPRINT AREA
========================================================== */
.fingerprint {
    width: 160px;
    height: 160px;
    margin: 20px auto;
    border-radius: 50%;
    background: radial-gradient(circle, #ff9800, #ff5722);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    cursor: pointer;
    transition: 0.3s;
    position: relative;
}

.fingerprint:hover {
    transform: scale(1.1);
}

/* Pulse effect */
.fingerprint::after {
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.6);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1.4); opacity: 0; }
}

/* Status Message */
#statusMsg {
    margin-top: 15px;
    font-weight: bold;
}

/* Session Timer */
.session-timer {
    font-size: 14px;
    margin-top: 10px;
    color: #90ee90;
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="terminal-card">

    <!-- ==========================================================
       HEADER
    ========================================================== -->
    <h3>☕ Charlie Café</h3>
    <p>Biometric Attendance Terminal</p>

    <!-- ==========================================================
       LIVE CLOCK SECTION
    ========================================================== -->
    <div class="big-clock" id="liveClock">00:00:00</div>
    <div class="date-text" id="liveDate"></div>

    <!-- Timezone Selector -->
    <select id="timezoneSelect" class="form-select mt-2 mb-3">
        <option value="Asia/Karachi">🇵🇰 Pakistan</option>
        <option value="UTC">🌍 UTC</option>
        <option value="Asia/Dubai">🇦🇪 UAE</option>
        <option value="Europe/London">🇬🇧 London</option>
        <option value="America/New_York">🇺🇸 New York</option>
    </select>

    <hr>

    <!-- ==========================================================
       CHECK-IN / CHECK-OUT TOGGLE
    ========================================================== -->
    <div class="mode-toggle-container mb-3">
        <input type="radio" name="attendanceMode" id="checkinMode" value="checkin" checked>
        <input type="radio" name="attendanceMode" id="checkoutMode" value="checkout">

        <div class="mode-toggle">
            <div class="toggle-slider"></div>

            <label for="checkinMode" class="toggle-option">
                🟢 Check-In
            </label>

            <label for="checkoutMode" class="toggle-option">
                🔴 Check-Out
            </label>
        </div>
    </div>

    <!-- Employee ID -->
    <input type="number" id="employeeId" class="form-control mb-3" placeholder="Enter Employee ID">

    <!-- Fingerprint -->
    <div class="fingerprint" onclick="simulateScan()">
        🔐
    </div>

    <p>Tap fingerprint to confirm attendance</p>

    <div id="statusMsg"></div>
    <div class="session-timer" id="sessionTimer"></div>

</div>

<!-- ==========================================================
   LOAD SYSTEM FILES
========================================================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="api.js"></script>

<script>
/* ==========================================================
   LIVE CLOCK WITH TIMEZONE SUPPORT
========================================================== */
let selectedTimezone = "Asia/Karachi";

function updateClock() {
    const now = new Date();

    const timeOptions = {
        timeZone: selectedTimezone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false
    };

    const dateOptions = {
        timeZone: selectedTimezone,
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    };

    document.getElementById("liveClock").innerText =
        new Intl.DateTimeFormat("en-GB", timeOptions).format(now);
    document.getElementById("liveDate").innerText =
        new Intl.DateTimeFormat("en-GB", dateOptions).format(now);
}

setInterval(updateClock, 1000);
updateClock();

document.getElementById("timezoneSelect").addEventListener("change", function() {
    selectedTimezone = this.value;
    updateClock();
});

/* ==========================================================
   SESSION TIMER
========================================================== */
let sessionStart = null;
let sessionInterval = null;

function startSessionTimer() {
    sessionStart = new Date();
    sessionInterval = setInterval(() => {
        const diff = Math.floor((new Date() - sessionStart) / 1000);
        const hrs = String(Math.floor(diff / 3600)).padStart(2,"0");
        const mins = String(Math.floor((diff % 3600) / 60)).padStart(2,"0");
        const secs = String(diff % 60).padStart(2,"0");
        document.getElementById("sessionTimer").innerText =
            "Working Time: " + hrs + ":" + mins + ":" + secs;
    }, 1000);
}

/* ==========================================================
   LATE DETECTION
   - After 10 AM local browser time
========================================================== */
function isLate() {
    const now = new Date();
    return now.getHours() >= 10;
}

/* ==========================================================
   FINGERPRINT SCAN SIMULATION
   - Calls public POST HR API: /attendance
   - Fully aligned with final api.js
========================================================== */
async function simulateScan() {

    const employeeId = document.getElementById("employeeId").value.trim();
    const action = document.querySelector('input[name="attendanceMode"]:checked').value;

    if (!employeeId) {
        showMessage("❌ Enter Employee ID first", false);
        return;
    }

    showMessage("🔍 Scanning fingerprint...", true);

    setTimeout(async () => {
        try {
            // ✅ Public HR API call
            await CHARLIE_API.recordAttendance({
                employee_id: employeeId,
                action: action
            });

            if (action === "checkin") {
                if (isLate()) {
                    showMessage("⚠️ Late Check-In recorded", false);
                } else {
                    showMessage("✅ Check-In Successful", true);
                }
                startSessionTimer();
            } else {
                showMessage("🔴 Check-Out Successful", true);
                clearInterval(sessionInterval);
                document.getElementById("sessionTimer").innerText = "";
            }

        } catch (error) {
            showMessage("❌ Scan failed or API error", false);
            console.error("Attendance API error:", error);
        }
    }, 2000);
}

/* ==========================================================
   STATUS MESSAGE DISPLAY
========================================================== */
function showMessage(message, success = true) {
    const msg = document.getElementById("statusMsg");
    msg.innerText = message;
    msg.style.color = success ? "lightgreen" : "tomato";
}
</script>

</body>
</html>
```

### ✅ Highlights of this final checkin.html:

- Fully public — no Cognito/Authorization.

- Calls CHARLIE_API.recordAttendance() for check-in/check-out.

- Live clock with timezone selection.

- Session timer starts on check-in, stops on check-out.

- Late check-in detection (after 10 AM).

- Fully commented for clarity and maintainability.

- Fully aligned with your final API.JS and employee-portal.html.
---

