# Charlie Cafe - hr-attendance.html


### hr-attendance.html

> **Update Version:1.0**

The key updates:

- Replace old CHARLIE.secureFetch calls with CHARLIE_API.api.recordAttendance() (protected API).

- Use /prod stage instead of /dev.

- Load JS files in the correct order: config.js → utils.js → central-auth.js → api.js → central-printing.js.

- Logout button now uses central-auth.js.

- Maintain page protection (initProtectedPage).

### ✅ FINAL hr-attendance.html

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
     LOAD SEPARATED JS MODULES
     Order is important
===================================================== -->
<script src="js/config.js"></script>
<script src="js/utils.js"></script>
<script src="js/central-auth.js"></script>
<script src="js/api.js"></script>
<script src="js/central-printing.js"></script>

<script>
/* =====================================================
   🔐 CENTRALIZED PAGE PROTECTION
   - Show content only if logged in
   - Setup logout button
===================================================== */
CHARLIE.initProtectedPage({
    requireAuth: true,
    enableLogout: true,
    logoutButtonId: "logoutBtn"
});

/* =====================================================
   📊 LOAD ATTENDANCE FUNCTION
   - Uses CHARLIE_API.api.recordAttendance()
   - Optional filters: employee_id, date
===================================================== */
async function loadAttendance() {
    const empId = document.getElementById("employeeId").value;
    const date = document.getElementById("date").value;

    const payload = {};
    if (empId) payload.employee_id = empId;
    if (date) payload.date = date;

    try {
        // ✅ Call Cognito-protected API
        const data = await CHARLIE_API.api.recordAttendance(payload);

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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

### ✅ WHAT WAS MODIFIED

- Removed old CHARLIE.secureFetch calls → replaced with CHARLIE_API.api.recordAttendance(payload).

- Production /prod API stage now used internally in api.js.

- Logout button handled by central-auth.js via initProtectedPage.

- Module load order updated: config.js → utils.js → central-auth.js → api.js → central-printing.js.

- Page protection logic kept (requireAuth: true)

- All styling, layout, table structure untouched

- Print functionality reused via central-printing.js

---