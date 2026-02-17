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

---
