# Charlie-Cafe -Secure HR & Attendance System

## 1️⃣ hr-attendance.html

> **Update Version: 1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | HR Attendance</title>

    <!-- Bootstrap 5 CSS -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
    >

    <!-- Optional icons -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
        rel="stylesheet"
    >

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        /* Page hidden until Cognito auth passes */
        body {
            display: none;
            background-color: #f8f9fa;
        }

        .brand {
            font-weight: bold;
            letter-spacing: 1px;
        }

        .card {
            border-radius: 12px;
        }
    </style>
</head>

<body>

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <span class="navbar-brand brand">
            ☕ Charlie Café – HR
        </span>

        <div class="d-flex">
            <!-- GLOBAL LOGOUT BUTTON -->
            <button id="logoutBtn" class="btn btn-outline-light btn-sm">
                <i class="bi bi-box-arrow-right"></i> Logout
            </button>
        </div>
    </div>
</nav>

<!-- ================= MAIN CONTAINER ================= -->
<div class="container my-5">

    <!-- ===== PAGE TITLE ===== -->
    <div class="text-center mb-4">
        <h2>HR Attendance Dashboard</h2>
        <p class="text-muted">
            Employee check-in / check-out & admin attendance view
        </p>
    </div>

    <div class="row g-4">

        <!-- ================= EMPLOYEE CARD ================= -->
        <div class="col-lg-6">
            <div class="card shadow-sm">
                <div class="card-body text-center">

                    <h5 class="card-title mb-3">
                        <i class="bi bi-person-check"></i>
                        Employee Attendance
                    </h5>

                    <p class="text-muted">
                        Mark your attendance for today
                    </p>

                    <div class="d-grid gap-3">
                        <button id="checkInBtn" class="btn btn-success btn-lg">
                            <i class="bi bi-box-arrow-in-right"></i>
                            Check In
                        </button>

                        <button id="checkOutBtn" class="btn btn-danger btn-lg">
                            <i class="bi bi-box-arrow-right"></i>
                            Check Out
                        </button>
                    </div>

                    <div class="mt-3">
                        <span id="status" class="fw-semibold"></span>
                    </div>

                </div>
            </div>
        </div>

        <!-- ================= ADMIN CARD ================= -->
        <div class="col-lg-6">
            <div
                class="card shadow-sm"
                id="admin-section"
                style="display:none"
            >
                <div class="card-body">

                    <h5 class="card-title mb-3">
                        <i class="bi bi-shield-lock"></i>
                        Admin – Attendance Records
                    </h5>

                    <div class="mb-3">
                        <label class="form-label">
                            Employee ID
                        </label>
                        <input
                            id="employeeIdInput"
                            class="form-control"
                            placeholder="E123"
                        >
                    </div>

                    <div class="d-grid mb-3">
                        <button
                            id="loadAttendanceBtn"
                            class="btn btn-primary"
                        >
                            Load Attendance
                        </button>
                    </div>

                    <pre
                        id="attendanceResult"
                        class="bg-light p-3 rounded small"
                        style="max-height:300px; overflow:auto"
                    ></pre>

                </div>
            </div>
        </div>

    </div>
</div>

<!-- ================= SCRIPTS ================= -->

<!-- Bootstrap JS -->
<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js">
</script>

<!-- CENTRAL AUTH (REQUIRED ON ALL PAGES) -->
<script src="js/central-auth-api.js"></script>

<script>
/* =====================================================
   STEP 1: PROTECT PAGE (COGNITO)
===================================================== */
CHARLIE.auth.protectPage();

/* =====================================================
   STEP 2: GLOBAL LOGOUT (WORKS ON ALL PAGES)
===================================================== */
CHARLIE.auth.setupLogoutButton("logoutBtn", "index.html");

/* =====================================================
   STEP 3: SHOW ADMIN SECTION IF ADMIN
===================================================== */
if (CHARLIE.isAdmin()) {
    document.getElementById("admin-section").style.display = "block";
}

/* =====================================================
   STEP 4: CHECK-IN
===================================================== */
document.getElementById("checkInBtn").addEventListener("click", async () => {
    try {
        await CHARLIE.api.recordAttendance({
            action: "CHECK_IN",
            time: new Date().toISOString()
        });

        document.getElementById("status").innerText =
            "✅ Checked in successfully";
    } catch {
        document.getElementById("status").innerText =
            "❌ Check-in failed";
    }
});

/* =====================================================
   STEP 5: CHECK-OUT
===================================================== */
document.getElementById("checkOutBtn").addEventListener("click", async () => {
    try {
        await CHARLIE.api.recordAttendance({
            action: "CHECK_OUT",
            time: new Date().toISOString()
        });

        document.getElementById("status").innerText =
            "✅ Checked out successfully";
    } catch {
        document.getElementById("status").innerText =
            "❌ Check-out failed";
    }
});

/* =====================================================
   STEP 6: ADMIN LOAD ATTENDANCE
===================================================== */
document.getElementById("loadAttendanceBtn")
    .addEventListener("click", async () => {

    const empId =
        document.getElementById("employeeIdInput").value.trim();

    if (!empId) {
        alert("Enter Employee ID");
        return;
    }

    try {
        const data = await CHARLIE.api.getAttendance(empId);
        document.getElementById("attendanceResult")
            .innerText = JSON.stringify(data, null, 2);
    } catch {
        alert("Failed to load attendance");
    }
});
</script>

</body>
</html>
```
### FRONTEND — HR ATTENDANCE DASHBOARD (NEW PAGE)

> **📄 File: hr-attendance-dashboard.html**

> **Update Version: 1.1**

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

### ✅ Updated - admin-dashboard.html
> **Update Version: 1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap CSS ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Cognito SDK ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/amazon-cognito-identity-js/6.2.1/amazon-cognito-identity.min.js"></script>

    <!-- ================= jsPDF ================= -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <!-- ================= Café Theme ================= -->
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-attachment: fixed;
            font-family: "Segoe UI", sans-serif;
            display: flex;
            transition: background 0.3s;
        }

        body.light-mode {
            background: #f4efe9;
        }

        /* ===== Sidebar ===== */
        #sidebar {
            width: 230px;
            background-color: #2b1b12;
            color: #fff;
            flex-shrink: 0;
            padding: 20px;
        }

        #sidebar h3 {
            font-family: Georgia, serif;
            color: #f5c16c;
            text-align: center;
        }

        #sidebar .nav-link {
            color: #f1f1f1;
            margin-bottom: 6px;
            border-radius: 6px;
        }

        #sidebar .nav-link:hover {
            background-color: #3d261a;
            color: #f5c16c;
        }

        /* ===== Content ===== */
        #content {
            flex-grow: 1;
            padding: 30px;
        }

        .content-card {
            background-color: rgba(255,255,255,0.97);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 22px rgba(0,0,0,0.45);
        }

        table th {
            background-color: #2b1b12;
            color: #fff;
        }

        .status-badge {
            font-size: 1rem;
        }

        @media (max-width: 768px) {
            body {
                flex-direction: column;
            }
            #sidebar {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<!-- ================= Sidebar (ADMIN ONLY) ================= -->
<nav id="sidebar">
    <h3>☕ Charlie Café</h3>
    <hr>

    <ul class="nav nav-pills flex-column mb-3">
        <li><a class="nav-link active" href="#">Dashboard</a></li>
        <li><a class="nav-link" href="#">Attendance</a></li>
        <li><a class="nav-link" href="#">Employees</a></li>
        <li><a class="nav-link" href="#">Leaves</a></li>
        <li><a class="nav-link" href="#">Reports</a></li>
    </ul>

    <hr>

    <!-- Admin Controls -->
    <div class="d-grid gap-2">
        <button class="btn btn-outline-light btn-sm" onclick="toggleTheme()">🌗 Toggle Theme</button>
        <button class="btn btn-outline-light btn-sm" onclick="downloadPDF()">📄 Download Report</button>
        <button class="btn btn-warning btn-sm" onclick="logout()">🔒 Logout</button>
    </div>
</nav>

<!-- ================= Main Content ================= -->
<div id="content">

    <div class="content-card">
        <h2>Admin Dashboard</h2>
        <p class="text-muted">HR & Attendance Management</p>

        <!-- Status Badge -->
        <span id="today-status" class="badge bg-secondary status-badge">
            Loading today status...
        </span>

        <hr>

        <!-- Attendance Table -->
        <div class="table-responsive mt-3">
            <table class="table table-striped table-bordered" id="attendance-table">
                <thead>
                    <tr>
                        <th>Employee ID</th>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

</div>

<!-- ================= JavaScript ================= -->
<script>
    /* ===== Cognito Config ===== */
    const poolData = {
        UserPoolId: 'us-east-1_XXXXXX',
        ClientId: 'XXXXXXXXXXXX'
    };
    const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    const apiBase = 'https://<API-ID>.execute-api.us-east-1.amazonaws.com/dev';

    async function getJWT() {
        const user = userPool.getCurrentUser();
        return new Promise((resolve, reject) => {
            if (!user) reject("Not logged in");
            user.getSession((err, session) => {
                if (err) reject(err);
                resolve(session.getIdToken().getJwtToken());
            });
        });
    }

    /* ===== Load Attendance (Admin View) ===== */
    async function loadAttendance() {
        const token = await getJWT();
        const res = await fetch(`${apiBase}/attendance/all`, {
            headers: { Authorization: token }
        });
        const records = await res.json();

        const tbody = document.querySelector("#attendance-table tbody");
        tbody.innerHTML = "";

        const today = new Date().toISOString().slice(0,10);
        let countToday = 0;

        records.forEach(r => {
            if (r.attendance_date === today) countToday++;
            tbody.innerHTML += `
                <tr>
                    <td>${r.employee_id}</td>
                    <td>${r.attendance_date}</td>
                    <td>${r.checkin_time || "-"}</td>
                    <td>${r.checkout_time || "-"}</td>
                </tr>
            `;
        });

        updateTodayStatus(countToday);
    }

    function updateTodayStatus(count) {
        const badge = document.getElementById("today-status");
        badge.textContent = `${count} employees checked in today`;
        badge.className = "badge bg-success status-badge";
    }

    /* ===== PDF Export ===== */
    function downloadPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.text("Charlie Café – Attendance Report", 10, 10);
        doc.text(document.getElementById("attendance-table").innerText, 10, 20);
        doc.save("attendance-report.pdf");
    }

    /* ===== Theme Toggle ===== */
    function toggleTheme() {
        document.body.classList.toggle("light-mode");
    }

    /* ===== Logout ===== */
    function logout() {
        const user = userPool.getCurrentUser();
        if (user) user.signOut();
        alert("Logged out successfully");
        window.location.href = "index.html";
    }

    /* ===== Initial Load ===== */
    loadAttendance();
</script>

</body>
</html>
```

### ✅ FINAL: admin-dashboard.html (UPDATED + COMMENTED)
> **Update Version: 1.1**

✅ central-auth-api.js

✅ Phase 6 (single attendance analytics Lambda)

✅ Phase 7 (admin dashboard)

✅ Role-based admin enforcement

✅ Summary cards (Daily / Weekly / Monthly)

✅ Employee filter

✅ Secure API calls

✅ Logout handled centrally

I removed old Cognito SDK logic (VERY IMPORTANT) and replaced it with central-auth-api.js only to avoid conflicts.

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Café | Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- ================= Bootstrap ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= Café Theme ================= -->
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background:
                linear-gradient(rgba(40,25,15,0.85), rgba(40,25,15,0.85)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-attachment: fixed;
            font-family: "Segoe UI", sans-serif;
            display: none; /* 🔐 hidden until auth success */
        }

        body.light-mode {
            background: #f4efe9;
        }

        #sidebar {
            width: 230px;
            background-color: #2b1b12;
            color: #fff;
            padding: 20px;
        }

        #sidebar h3 {
            color: #f5c16c;
            text-align: center;
        }

        #sidebar .nav-link {
            color: #fff;
            margin-bottom: 6px;
        }

        #content {
            flex-grow: 1;
            padding: 30px;
        }

        .content-card {
            background: #fff;
            border-radius: 12px;
            padding: 25px;
        }
    </style>
</head>

<body class="d-flex">

<!-- ================= SIDEBAR ================= -->
<nav id="sidebar">
    <h3>☕ Charlie Café</h3>
    <hr>

    <ul class="nav flex-column">
        <li><a class="nav-link active" href="#">Dashboard</a></li>
        <li><a class="nav-link" href="#">Employees</a></li>
        <li><a class="nav-link" href="#">Attendance</a></li>
    </ul>

    <hr>

    <button class="btn btn-warning btn-sm w-100" id="logoutBtn">🔒 Logout</button>
</nav>

<!-- ================= MAIN CONTENT ================= -->
<div id="content" class="w-100">

    <div class="content-card">

        <h2>Admin Dashboard</h2>
        <p class="text-muted">Attendance Analytics</p>

        <!-- ===== Summary Cards ===== -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card bg-success text-white p-3">
                    <h6>Total Present</h6>
                    <h3 id="card-present">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-danger text-white p-3">
                    <h6>Total Absent</h6>
                    <h3 id="card-absent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-warning text-dark p-3">
                    <h6>Total Leaves</h6>
                    <h3 id="card-leaves">0</h3>
                </div>
            </div>
        </div>

        <!-- ===== Controls ===== -->
        <div class="row mb-3">
            <div class="col-md-4">
                <select id="employeeFilter" class="form-select">
                    <option value="">All Employees</option>
                </select>
            </div>

            <div class="col-md-8 text-end">
                <button class="btn btn-outline-primary" onclick="loadSummary('daily')">Daily</button>
                <button class="btn btn-outline-primary" onclick="loadSummary('weekly')">Weekly</button>
                <button class="btn btn-outline-primary" onclick="loadSummary('monthly')">Monthly</button>
            </div>
        </div>

        <!-- ===== Attendance Table ===== -->
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Date</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                    </tr>
                </thead>
                <tbody id="attendance-body"></tbody>
            </table>
        </div>

        <button class="btn btn-primary mt-3" onclick="exportCSV()">Export CSV</button>

    </div>
</div>

<!-- ================= CENTRAL AUTH ================= -->
<script src="js/central-auth-api.js"></script>

<script>
/* =====================================================
   🔐 AUTH & ROLE ENFORCEMENT
===================================================== */
CHARLIE.auth.protectPage();          // login required
CHARLIE.auth.setupLogoutButton();    // logout button
if (!CHARLIE.isAdmin()) {
    alert("Admin access only");
    CHARLIE.auth.logout();
}

/* =====================================================
   📊 LOAD ATTENDANCE SUMMARY (Phase 6 Lambda)
===================================================== */
async function loadSummary(type) {
    const data = await CHARLIE.secureFetch(
        `${CHARLIE.apiBase}/admin/attendance?type=${type}`
    );

    document.getElementById("card-present").textContent = data.summary.total_present;
    document.getElementById("card-absent").textContent = data.summary.total_absent;
    document.getElementById("card-leaves").textContent = data.summary.total_leaves;

    renderTable(data.attendance);
}

/* =====================================================
   📋 RENDER TABLE
===================================================== */
function renderTable(rows) {
    const tbody = document.getElementById("attendance-body");
    tbody.innerHTML = "";

    rows.forEach(r => {
        tbody.innerHTML += `
            <tr>
                <td>${r.name}</td>
                <td>${r.date}</td>
                <td>${r.checkin_time || "-"}</td>
                <td>${r.checkout_time || "-"}</td>
            </tr>
        `;
    });
}

/* =====================================================
   👥 LOAD EMPLOYEES (FILTER)
===================================================== */
async function loadEmployees() {
    const employees = await CHARLIE.api.getAllEmployees();
    const select = document.getElementById("employeeFilter");

    employees.forEach(e => {
        const opt = document.createElement("option");
        opt.value = e.employee_id;
        opt.textContent = e.name;
        select.appendChild(opt);
    });
}

/* =====================================================
   📤 EXPORT CSV
===================================================== */
function exportCSV() {
    alert("CSV export logic can be plugged here");
}

/* =====================================================
   🚀 INIT
===================================================== */
loadEmployees();
loadSummary("daily");
</script>

</body>
</html>
```

✅ WHAT YOU GAINED (IMPORTANT)

✔ Removed old Cognito JS SDK (no conflict)
✔ 100% central-auth-api.js based
✔ Admin-only enforcement
✔ Phase 6 analytics fully wired
✔ Clean summary cards
✔ Employee filter ready
✔ Secure API calls
✔ Logout works globally

---


