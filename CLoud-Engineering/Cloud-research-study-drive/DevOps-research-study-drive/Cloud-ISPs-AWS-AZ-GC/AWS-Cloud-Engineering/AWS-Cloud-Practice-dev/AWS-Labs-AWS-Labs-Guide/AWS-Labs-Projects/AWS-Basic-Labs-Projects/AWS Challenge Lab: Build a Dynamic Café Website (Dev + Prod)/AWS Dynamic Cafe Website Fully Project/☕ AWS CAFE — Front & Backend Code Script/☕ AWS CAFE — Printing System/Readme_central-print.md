# Charlie Cafe - central-print


### central-print.html

> **Update Version:1.0**

✔ Load the correct JS files in correct order
✔ Use CHARLIE_AUTH instead of CHARLIE.initProtectedPage()
✔ Use CHARLIE_PRINT for printing
✔ Use CHARLIE_API.protected for protected endpoints
✔ Add proper secure downloadReport() (protected)
✔ Keep design unchanged
✔ Keep layout unchanged
✔ Keep styling unchanged

#### ✅ FULLY UPDATED — central-print.html

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe — Printing Center</title>

    <!-- =====================================================
         LOAD NEW MODULAR ARCHITECTURE (ORDER MATTERS)
    ====================================================== -->
    <script src="config.js"></script>
    <script src="utils.js"></script>
    <script src="central-auth.js"></script>
    <script src="api.js"></script>
    <script src="central-printing.js"></script>

    <style>
        body { font-family: Arial, sans-serif; padding: 20px; display: none; }
        button { margin: 5px; padding: 10px 20px; cursor: pointer; }
    </style>
</head>
<body>

<h1>☕ Charlie Cafe — Printing Center</h1>

<!-- =====================================================
     BUTTON ACTIONS
===================================================== -->
<div id="buttons">

    <!-- Print all orders -->
    <button onclick="CHARLIE_PRINT.printAllOrders()">
        🖨️ Print All Orders
    </button>

    <!-- Print today's summary -->
    <button onclick="CHARLIE_PRINT.printTodaySummary()">
        📊 Print Today's Summary
    </button>

    <!-- Download Daily PDF (Admin Only Recommended) -->
    <button id="dailyPdfBtn">
        📄 Daily PDF
    </button>

    <!-- Download Analytics CSV (Admin Only) -->
    <button id="analyticsCsvBtn">
        🗂 Analytics CSV
    </button>

    <!-- Central Logout -->
    <button id="logoutBtn">🔒 Logout</button>

</div>

<script>
/* =====================================================
   🔐 PROTECT PAGE (Cognito Required)
===================================================== */

// 1️⃣ Require authentication
CHARLIE_AUTH.protectPage();

// 2️⃣ Setup logout button
document.getElementById("logoutBtn")
    .addEventListener("click", () => CHARLIE_AUTH.logout());

// 3️⃣ Start auto logout watcher
CHARLIE_AUTH.startAutoLogoutWatcher();


/* =====================================================
   📄 DOWNLOAD REPORTS (PROTECTED ENDPOINTS)
   Uses secureFetch from api.js
===================================================== */

async function downloadReport(type, report) {

    try {

        // Require admin access for analytics
        if (report === "analytics") {
            CHARLIE_AUTH.requireAdmin();
        }

        const response = await fetch(
            `${CHARLIE_CONFIG.API_BASE}/reports/export?type=${type}&report=${report}`,
            {
                method: "GET",
                headers: {
                    "Authorization": "Bearer " + CHARLIE_UTILS.getToken()
                }
            }
        );

        if (!response.ok) {
            alert("Failed to download report");
            return;
        }

        const blob = await response.blob();
        const filename = `${report}.${type}`;

        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = filename;

        document.body.appendChild(a);
        a.click();

        URL.revokeObjectURL(a.href);
        document.body.removeChild(a);

    } catch (err) {
        console.error("Download error:", err);
        alert("Download failed.");
    }
}


/* =====================================================
   🔘 BUTTON EVENT BINDINGS
===================================================== */

document.getElementById("dailyPdfBtn")
    .addEventListener("click", () => downloadReport("pdf", "daily"));

document.getElementById("analyticsCsvBtn")
    .addEventListener("click", () => downloadReport("csv", "analytics"));


/* =====================================================
   👑 ROLE-BASED BUTTON VISIBILITY
   Only Admin can see Analytics CSV
===================================================== */

if (!CHARLIE_AUTH.isAdmin()) {
    document.getElementById("analyticsCsvBtn").style.display = "none";
}

// Finally show page after auth passes
document.body.style.display = "block";

</script>

</body>
</html>
```



