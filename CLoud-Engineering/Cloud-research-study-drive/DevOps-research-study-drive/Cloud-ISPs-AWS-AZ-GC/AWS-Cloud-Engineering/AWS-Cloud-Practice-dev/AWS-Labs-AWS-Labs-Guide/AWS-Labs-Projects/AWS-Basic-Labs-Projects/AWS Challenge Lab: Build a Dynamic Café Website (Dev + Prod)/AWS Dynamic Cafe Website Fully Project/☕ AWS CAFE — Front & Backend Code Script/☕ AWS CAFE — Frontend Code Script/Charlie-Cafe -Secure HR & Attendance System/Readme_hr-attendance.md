# Charlie-Cafe -Secure HR & Attendance System

## hr-attendance.html

> **Update Version:1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>HR Attendance Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { display:none; background:#f8f9fa; }
</style>
</head>

<body>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center">
        <h2>📊 HR Attendance Dashboard</h2>
        <button id="logoutBtn" class="btn btn-danger">Logout</button>
    </div>

    <hr>

    <!-- Filters -->
    <div class="row mb-3">
        <div class="col-md-4">
            <input id="employeeId" class="form-control" placeholder="Employee ID">
        </div>
        <div class="col-md-4">
            <input id="date" type="date" class="form-control">
        </div>
        <div class="col-md-4">
            <button class="btn btn-primary w-100" onclick="loadAttendance()">Search</button>
        </div>
    </div>

    <!-- Table -->
    <table class="table table-bordered">
        <thead class="table-dark">
            <tr>
                <th>Employee ID</th>
                <th>Date</th>
                <th>Check In</th>
                <th>Check Out</th>
            </tr>
        </thead>
        <tbody id="attendanceTable"></tbody>
    </table>
</div>

<script src="js/central-auth-api.js"></script>

<script>
/* 🔐 Protect page (Admin only) */
CHARLIE.auth.protectPage();
CHARLIE.auth.setupLogoutButton();

/* 📊 Load Attendance */
async function loadAttendance() {
    const empId = document.getElementById("employeeId").value;
    const date = document.getElementById("date").value;

    let url = `${CHARLIE.apiBase}/dev/hr/attendance?employee_id=${empId}`;
    if (date) url += `&date=${date}`;

    const data = await CHARLIE.secureFetch(url);

    const tbody = document.getElementById("attendanceTable");
    tbody.innerHTML = "";

    data.forEach(row => {
        tbody.innerHTML += `
            <tr>
                <td>${row.employee_id}</td>
                <td>${row.date}</td>
                <td>${row.check_in || "-"}</td>
                <td>${row.check_out || "-"}</td>
            </tr>`;
    });
}
</script>

</body>
</html>
```

---
## hr-attendance.html

> **Update Version:1.1**

- It uses CHARLIE.initProtectedPage() for centralized login/logout.

- The attendance search calls the centralized API (CHARLIE.api.recordAttendance / CHARLIE.secureFetch).

- Added comments throughout for clarity and maintainability.

- Keeps your existing layout, styles, and table untouched.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>HR Attendance Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { display:none; background:#f8f9fa; }
</style>
</head>

<body>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center">
        <h2>📊 HR Attendance Dashboard</h2>
        <!-- 🔹 LOGOUT BUTTON (UI ONLY) -->
        <button id="logoutBtn" class="btn btn-danger">Logout</button>
    </div>

    <hr>

    <!-- Filters -->
    <div class="row mb-3">
        <div class="col-md-4">
            <input id="employeeId" class="form-control" placeholder="Employee ID">
        </div>
        <div class="col-md-4">
            <input id="date" type="date" class="form-control">
        </div>
        <div class="col-md-4">
            <button class="btn btn-primary w-100" onclick="loadAttendance()">Search</button>
        </div>
    </div>

    <!-- Table -->
    <table class="table table-bordered">
        <thead class="table-dark">
            <tr>
                <th>Employee ID</th>
                <th>Date</th>
                <th>Check In</th>
                <th>Check Out</th>
            </tr>
        </thead>
        <tbody id="attendanceTable"></tbody>
    </table>
</div>

<!-- =====================================================
     CENTRAL AUTH
===================================================== -->
<script src="js/central-auth-api.js"></script>

<script>
/* =====================================================
   🔹 CENTRALIZED PAGE PROTECTION
   - Handles login redirect automatically
   - Sets up logout button
   - Starts auto-logout watcher
===================================================== */
CHARLIE.initProtectedPage({
    requireAuth: true,        // 🔐 protect page (login required)
    enableLogout: true,       // ✅ setup logout button
    logoutButtonId: "logoutBtn"
});

/* =====================================================
   📊 LOAD ATTENDANCE FUNCTION
   - Uses centralized secureFetch
   - Filters by Employee ID & Date
===================================================== */
async function loadAttendance() {
    const empId = document.getElementById("employeeId").value;
    const date = document.getElementById("date").value;

    // Construct payload for centralized API call
    const payload = {};
    if (empId) payload.employee_id = empId;
    if (date) payload.date = date;

    try {
        // 🔹 CENTRALIZED SECURE API CALL
        const data = await CHARLIE.secureFetch(`${CHARLIE.apiBase}/dev/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        });

        // Render table
        const tbody = document.getElementById("attendanceTable");
        tbody.innerHTML = "";

        data.forEach(row => {
            tbody.innerHTML += `
                <tr>
                    <td>${row.employee_id}</td>
                    <td>${row.date}</td>
                    <td>${row.check_in || "-"}</td>
                    <td>${row.check_out || "-"}</td>
                </tr>`;
        });
    } catch (err) {
        console.error("❌ Failed to load attendance:", err);
        alert("Failed to load attendance. See console for details.");
    }
}

/* =====================================================
   🔹 API USAGE EXAMPLE
   - Demonstrates centralized pattern
   - Handles token, expiration, auto-logout
===================================================== */
// CHARLIE.api.recordAttendance({ employee_id: "E101" });
</script>

</body>
</html>
```

#### ✅ What’s new in this version:

- Replaced manual URL construction with centralized POST request using CHARLIE.secureFetch.

```
await CHARLIE.secureFetch(`${CHARLIE.apiBase}/dev/hr/attendance`, {
    method: "POST",
    body: JSON.stringify(payload)
});
```

- Uses initProtectedPage() for login/logout and auto token expiration handling.

- Added full comments for each section: Page protection, API call, and example usage.

- Error handling added for API failure.

---
## hr-attendance.html

> **Update Version:1.2**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>HR Attendance Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { display:none; background:#f8f9fa; }
</style>
</head>

<body>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center">
        <h2>📊 HR Attendance Dashboard</h2>

        <!-- 🔹 ACTION BUTTONS -->
        <div>
            <!-- 🖨️ CENTRAL PRINT BUTTON -->
            <button class="btn btn-outline-dark me-2"
                    onclick="openCentralPrint('#attendanceTableWrapper')">
                🖨️ Print / Export
            </button>

            <!-- 🔒 LOGOUT BUTTON -->
            <button id="logoutBtn" class="btn btn-danger">
                Logout
            </button>
        </div>
    </div>

    <hr>

    <!-- Filters -->
    <div class="row mb-3">
        <div class="col-md-4">
            <input id="employeeId" class="form-control" placeholder="Employee ID">
        </div>
        <div class="col-md-4">
            <input id="date" type="date" class="form-control">
        </div>
        <div class="col-md-4">
            <button class="btn btn-primary w-100" onclick="loadAttendance()">
                Search
            </button>
        </div>
    </div>

    <!-- TABLE WRAPPER (IMPORTANT FOR PRINTING) -->
    <div id="attendanceTableWrapper">
        <table class="table table-bordered">
            <thead class="table-dark">
                <tr>
                    <th>Employee ID</th>
                    <th>Date</th>
                    <th>Check In</th>
                    <th>Check Out</th>
                </tr>
            </thead>
            <tbody id="attendanceTable"></tbody>
        </table>
    </div>
</div>

<!-- =====================================================
     CENTRAL AUTH (DO NOT MOVE)
===================================================== -->
<script src="js/central-auth-api.js"></script>

<script>
/* =====================================================
   🔐 CENTRALIZED PAGE PROTECTION
===================================================== */
CHARLIE.initProtectedPage({
    requireAuth: true,
    enableLogout: true,
    logoutButtonId: "logoutBtn"
});

/* =====================================================
   📊 LOAD ATTENDANCE FUNCTION
===================================================== */
async function loadAttendance() {
    const empId = document.getElementById("employeeId").value;
    const date = document.getElementById("date").value;

    const payload = {};
    if (empId) payload.employee_id = empId;
    if (date) payload.date = date;

    try {
        const data = await CHARLIE.secureFetch(
            `${CHARLIE.apiBase}/dev/hr/attendance`,
            {
                method: "POST",
                body: JSON.stringify(payload)
            }
        );

        const tbody = document.getElementById("attendanceTable");
        tbody.innerHTML = "";

        data.forEach(row => {
            tbody.innerHTML += `
                <tr>
                    <td>${row.employee_id}</td>
                    <td>${row.date}</td>
                    <td>${row.check_in || "-"}</td>
                    <td>${row.check_out || "-"}</td>
                </tr>`;
        });

    } catch (err) {
        console.error("❌ Failed to load attendance:", err);
        alert("Failed to load attendance. See console for details.");
    }
}

/* =====================================================
   🖨️ CENTRAL PRINT HANDLER
   - Opens central-print.html
   - Sends table HTML safely
   - Reusable for any page
===================================================== */
function openCentralPrint(selector) {
    const source = document.querySelector(selector);

    if (!source) {
        alert("Printable content not found.");
        return;
    }

    const contentHTML = source.outerHTML;

    const printWindow = window.open(
        "/central-print.html",
        "_blank"
    );

    printWindow.onload = function () {
        if (printWindow.centralPrint &&
            typeof printWindow.centralPrint.loadContent === "function") {
            printWindow.centralPrint.loadContent(contentHTML);
        } else {
            console.error("❌ centralPrint not available");
        }
    };
}
</script>

</body>
</html>
```

---
