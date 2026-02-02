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








