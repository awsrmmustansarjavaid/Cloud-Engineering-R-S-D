
### charlie-cafe-verify.html

> **Update Version: 1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Charlie Cafe Lab Verification</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* -------------------
   General Page Styles
   ------------------- */
body {
    background-color: #fff8f0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Page Header */
h1 {
    color: #b22222;
}

/* Table row status colors */
.PASS { color: green; font-weight: bold; }
.FAIL { color: red; font-weight: bold; }
.WARN { color: orange; font-weight: bold; }

/* Logo styles */
#logo {
    font-size: 2.5rem;  /* Coffee cup emoji size */
}

/* Print button spacing */
.print-btn {
    margin-top: 20px;
}
</style>
</head>
<body>
<div class="container">

    <!-- =======================
         Header with Logo
         ======================= -->
    <div class="d-flex align-items-center mt-4 mb-3">
        <!-- Charlie Cafe logo as coffee cup + title -->
        <span id="logo" role="img" aria-label="Coffee Cup">☕</span>
        <h1 class="ms-3">Charlie Cafe Lab Verification</h1>
    </div>

    <!-- =======================
         CSV Input & Load Button
         ======================= -->
    <div class="input-group mb-3">
        <input type="text" id="csvUrl" class="form-control" placeholder="Enter CSV URL from S3" aria-label="CSV URL">
        <button class="btn btn-primary" onclick="loadCSV()">
            <i class="bi bi-arrow-repeat"></i> Load Results
        </button>
    </div>

    <!-- =======================
         Result Table
         ======================= -->
    <div class="table-responsive">
        <table id="resultTable" class="table table-striped table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Test</th>
                    <th>Status</th>
                    <th>Details</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>

    <!-- =======================
         Print Button
         ======================= -->
    <button class="btn btn-success print-btn" onclick="window.print()">
        <i class="bi bi-printer-fill"></i> Print Result
    </button>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* =====================================================
   Function: loadCSV()
   Purpose: Fetch CSV from S3 URL and populate table
   ===================================================== */
async function loadCSV() {
    const url = document.getElementById('csvUrl').value.trim();

    if (!url) {
        alert('Please enter a CSV URL.');
        return;
    }

    try {
        const response = await fetch(url); // Fetch CSV from S3
        if (!response.ok) throw new Error('Cannot fetch CSV. Check URL or permissions.');
        const text = await response.text();

        const rows = text.split('\n').slice(1); // skip header row
        const tbody = document.querySelector('#resultTable tbody');
        tbody.innerHTML = ''; // Clear previous results

        rows.forEach(row => {
            if (!row.trim()) return; // Skip empty lines
            const cols = row.split(',');
            const tr = document.createElement('tr');

            // Determine status color class
            const status = cols[1]?.replace(/"/g,'') || '';
            tr.innerHTML = `
                <td>${cols[0]?.replace(/"/g,'')}</td>
                <td class="${status}">${status}</td>
                <td>${cols[2]?.replace(/"/g,'')}</td>
                <td>${cols[3]?.replace(/"/g,'')}</td>
            `;
            tbody.appendChild(tr);
        });
    } catch (err) {
        alert('Error loading CSV: ' + err.message);
    }
}
</script>
</body>
</html>
```

---
### charlie-cafe-verify.html

> **Update Version: 1.1**

#### Features included:

Coffee cup logo ☕

CSV upload or optional S3 URL input

Table with PASS 🎉, FAIL 😢, WARN ⚠️ icons

Analytics summary card with total tests, passed, failed, warnings, and success %

Responsive Bootstrap 5 layout

Print button

Color-coded table and summary

Comments for clarity

#### Here’s the full updated code:


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Charlie Cafe Lab Verification</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* -------------------
   General Page Styles
   ------------------- */
body {
    background-color: #fff8f0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Header Styles */
h1 {
    color: #b22222;
}

/* Table row status colors */
.PASS { color: green; font-weight: bold; }
.FAIL { color: red; font-weight: bold; }
.WARN { color: orange; font-weight: bold; }

/* Logo styles */
#logo {
    font-size: 2.5rem;  /* Coffee cup emoji size */
}

/* Print button spacing */
.print-btn {
    margin-top: 20px;
}

/* Summary card styles */
.summary-card {
    margin-top: 20px;
}
.summary-card h5 {
    font-weight: bold;
}
.summary-card .value {
    font-size: 1.5rem;
}
</style>
</head>
<body>
<div class="container">

    <!-- =======================
         Header with Logo
         ======================= -->
    <div class="d-flex align-items-center mt-4 mb-3">
        <span id="logo" role="img" aria-label="Coffee Cup">☕</span>
        <h1 class="ms-3">Charlie Cafe Lab Verification</h1>
    </div>

    <!-- =======================
         CSV URL Input & Load Button
         ======================= -->
    <div class="input-group mb-3">
        <input type="text" id="csvUrl" class="form-control" placeholder="Enter CSV URL from S3 (optional)" aria-label="CSV URL">
        <button class="btn btn-primary" onclick="loadCSV()">
            <i class="bi bi-arrow-repeat"></i> Load Results
        </button>
    </div>

    <!-- =======================
         File Upload Option
         ======================= -->
    <div class="mb-3">
        <label for="csvFile" class="form-label">Or Upload CSV/TXT file:</label>
        <input class="form-control" type="file" id="csvFile" accept=".csv,.txt" onchange="loadFile(this)">
    </div>

    <!-- =======================
         Summary Analytics Card
         ======================= -->
    <div class="row summary-card">
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Total Tests</h5>
                <div id="totalTests" class="value">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Passed</h5>
                <div id="passedTests" class="value text-success">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Failed</h5>
                <div id="failedTests" class="value text-danger">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Warnings</h5>
                <div id="warnTests" class="value text-warning">0</div>
            </div>
        </div>
        <div class="col-12 mt-2">
            <div class="card text-center bg-light p-2">
                <h5>Success Percentage</h5>
                <div id="successPercent" class="value text-success">0%</div>
            </div>
        </div>
    </div>

    <!-- =======================
         Result Table
         ======================= -->
    <div class="table-responsive mt-3">
        <table id="resultTable" class="table table-striped table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Test</th>
                    <th>Status</th>
                    <th>Details</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>

    <!-- =======================
         Print Button
         ======================= -->
    <button class="btn btn-success print-btn" onclick="window.print()">
        <i class="bi bi-printer-fill"></i> Print Result
    </button>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* =====================================================
   Load CSV from URL (if public/pre-signed)
   ===================================================== */
async function loadCSV() {
    const url = document.getElementById('csvUrl').value.trim();
    if (!url) return alert('Enter CSV URL or upload a file.');

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Cannot fetch CSV. Check URL or permissions.');
        const text = await response.text();
        displayTable(text);
    } catch (err) {
        alert('Error loading CSV from URL: ' + err.message);
    }
}

/* =====================================================
   Load CSV/TXT from local file
   ===================================================== */
function loadFile(input) {
    const file = input.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
        const text = e.target.result;
        displayTable(text);
    };
    reader.readAsText(file);
}

/* =====================================================
   Display CSV data in table and calculate analytics
   ===================================================== */
function displayTable(csvText) {
    const rows = csvText.split('\n').slice(1); // skip header
    const tbody = document.querySelector('#resultTable tbody');
    tbody.innerHTML = ''; // Clear previous results

    let total = 0, passed = 0, failed = 0, warn = 0;

    rows.forEach(row => {
        if (!row.trim()) return;
        const cols = row.split(',');
        const status = cols[1]?.replace(/"/g,'') || '';
        total++;

        // Count status for analytics
        if (status === "PASS") passed++;
        else if (status === "FAIL") failed++;
        else if (status === "WARN") warn++;

        // Add emoji icon to status
        let icon = '';
        if (status === "PASS") icon = '🎉';
        else if (status === "FAIL") icon = '😢';
        else if (status === "WARN") icon = '⚠️';

        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${cols[0]?.replace(/"/g,'')}</td>
            <td class="${status}">${status} ${icon}</td>
            <td>${cols[2]?.replace(/"/g,'')}</td>
            <td>${cols[3]?.replace(/"/g,'')}</td>
        `;
        tbody.appendChild(tr);
    });

    // Update analytics cards
    document.getElementById('totalTests').textContent = total;
    document.getElementById('passedTests').textContent = passed;
    document.getElementById('failedTests').textContent = failed;
    document.getElementById('warnTests').textContent = warn;
    document.getElementById('successPercent').textContent = total > 0 ? ((passed/total)*100).toFixed(2) + '%' : '0%';
}
</script>
</body>
</html>
```

#### ✅ New Features Implemented

Pass/Fail/Warn emojis in table: 🎉 😢 ⚠️

Analytics summary card with total tests, passed, failed, warnings, success %

File upload + optional S3 URL support

Bootstrap 5 responsive layout

Professional dashboard look with cards and color-coded values

Print button

Comments explaining each section

---

### charlie-cafe-verify.html

> **Update Version: 1.2**


a fully professional dashboard with all the requested features:

Chart.js Pie Chart for Pass/Fail/Warn visualization

Auto-detect CSV headers (works if lab adds/removes columns)

Download CSV button (download current table data)

Dark/Light theme toggle for a professional feel

Bootstrap 5 responsive design, print button, coffee cup logo

Pass/Fail/Warn emojis in table

Analytics summary cards

#### Here’s the complete working code with detailed comments:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Charlie Cafe Lab Verification Dashboard</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* -------------------
   General Page Styles
   ------------------- */
body {
    background-color: #fff8f0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    transition: background-color 0.3s, color 0.3s;
}

body.dark-mode {
    background-color: #1e1e1e;
    color: #f5f5f5;
}

body.dark-mode h1 {
    color: #ffb347;
}

/* Header Styles */
h1 {
    color: #b22222;
}

/* Table row status colors */
.PASS { color: green; font-weight: bold; }
.FAIL { color: red; font-weight: bold; }
.WARN { color: orange; font-weight: bold; }

/* Logo styles */
#logo {
    font-size: 2.5rem;  /* Coffee cup emoji size */
}

/* Buttons spacing */
.print-btn, .download-btn, .theme-btn {
    margin-top: 20px;
    margin-right: 10px;
}

/* Summary card styles */
.summary-card {
    margin-top: 20px;
}
.summary-card h5 {
    font-weight: bold;
}
.summary-card .value {
    font-size: 1.5rem;
}

/* Chart container styles for professional size */
.chart-card {
    max-width: 400px; /* Limit width for professional UX */
    margin: 20px auto; /* Center horizontally */
    padding: 15px;
    background-color: #fdf2e9;
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1);
}

body.dark-mode .chart-card {
    background-color: #2c2c2c;
}
</style>
</head>
<body>
<div class="container">

    <!-- =======================
         Header with Logo
         ======================= -->
    <div class="d-flex align-items-center mt-4 mb-3 justify-content-between">
        <div class="d-flex align-items-center">
            <span id="logo" role="img" aria-label="Coffee Cup">☕</span>
            <h1 class="ms-3">Charlie Cafe Lab Verification</h1>
        </div>
        <button class="btn btn-secondary theme-btn" onclick="toggleTheme()">
            <i class="bi bi-moon-fill"></i> Toggle Dark/Light
        </button>
    </div>

    <!-- =======================
         CSV URL Input & Load Button
         ======================= -->
    <div class="input-group mb-3">
        <input type="text" id="csvUrl" class="form-control" placeholder="Enter CSV URL from S3 (optional)" aria-label="CSV URL">
        <button class="btn btn-primary" onclick="loadCSV()">
            <i class="bi bi-arrow-repeat"></i> Load Results
        </button>
    </div>

    <!-- =======================
         File Upload Option
         ======================= -->
    <div class="mb-3">
        <label for="csvFile" class="form-label">Or Upload CSV/TXT file:</label>
        <input class="form-control" type="file" id="csvFile" accept=".csv,.txt" onchange="loadFile(this)">
    </div>

    <!-- =======================
         Summary Analytics Cards
         ======================= -->
    <div class="row summary-card">
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Total Tests</h5>
                <div id="totalTests" class="value">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Passed</h5>
                <div id="passedTests" class="value text-success">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Failed</h5>
                <div id="failedTests" class="value text-danger">0</div>
            </div>
        </div>
        <div class="col-md-3 col-6 mb-2">
            <div class="card text-center bg-light p-2">
                <h5>Warnings</h5>
                <div id="warnTests" class="value text-warning">0</div>
            </div>
        </div>
        <div class="col-12 mt-2">
            <div class="card text-center bg-light p-2">
                <h5>Success Percentage</h5>
                <div id="successPercent" class="value text-success">0%</div>
            </div>
        </div>
    </div>

    <!-- =======================
         Pie Chart (Professional size)
         ======================= -->
    <div class="chart-card">
        <canvas id="statusChart" height="300"></canvas>
    </div>

    <!-- =======================
         Result Table
         ======================= -->
    <div class="table-responsive mt-3">
        <table id="resultTable" class="table table-striped table-bordered align-middle">
            <thead class="table-dark" id="tableHead">
                <tr>
                    <th>Test</th>
                    <th>Status</th>
                    <th>Details</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>

    <!-- =======================
         Buttons: Print & Download CSV
         ======================= -->
    <div class="mb-4">
        <button class="btn btn-success print-btn" onclick="window.print()">
            <i class="bi bi-printer-fill"></i> Print Result
        </button>
        <button class="btn btn-info download-btn" onclick="downloadCSV()">
            <i class="bi bi-download"></i> Download CSV
        </button>
    </div>

</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
let chart; // Chart.js instance

/* ============================
   Toggle Dark/Light Theme
   ============================ */
function toggleTheme() {
    document.body.classList.toggle('dark-mode');
}

/* ============================
   Load CSV from URL
   ============================ */
async function loadCSV() {
    const url = document.getElementById('csvUrl').value.trim();
    if (!url) return alert('Enter CSV URL or upload a file.');

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Cannot fetch CSV. Check URL or permissions.');
        const text = await response.text();
        displayTable(text);
    } catch (err) {
        alert('Error loading CSV from URL: ' + err.message);
    }
}

/* ============================
   Load CSV/TXT from local file
   ============================ */
function loadFile(input) {
    const file = input.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
        const text = e.target.result;
        displayTable(text);
    };
    reader.readAsText(file);
}

/* ============================
   Display CSV data in table
   ============================ */
function displayTable(csvText) {
    const lines = csvText.split('\n').filter(l => l.trim() !== '');
    if (lines.length === 0) return;

    // Auto-detect CSV headers
    const headers = lines[0].split(',').map(h => h.replace(/"/g,''));
    const tbody = document.querySelector('#resultTable tbody');
    tbody.innerHTML = '';

    // Update table header dynamically
    const tableHead = document.getElementById('tableHead');
    tableHead.innerHTML = '';
    const trHead = document.createElement('tr');
    headers.forEach(h => {
        const th = document.createElement('th');
        th.textContent = h;
        trHead.appendChild(th);
    });
    tableHead.appendChild(trHead);

    // Initialize analytics
    let total=0, passed=0, failed=0, warn=0;

    // Process each CSV row
    lines.slice(1).forEach(row => {
        const cols = row.split(',');
        if (cols.length === 0) return;
        total++;

        let status = cols[1]?.replace(/"/g,'') || '';
        if (status === "PASS") passed++;
        else if (status === "FAIL") failed++;
        else if (status === "WARN") warn++;

        let icon = '';
        if (status === "PASS") icon = '🎉';
        else if (status === "FAIL") icon = '😢';
        else if (status === "WARN") icon = '⚠️';

        const tr = document.createElement('tr');
        tr.innerHTML = cols.map((c,i) => i===1 ? `<td class="${status}">${status} ${icon}</td>` : `<td>${c.replace(/"/g,'')}</td>`).join('');
        tbody.appendChild(tr);
    });

    // Update analytics cards
    document.getElementById('totalTests').textContent = total;
    document.getElementById('passedTests').textContent = passed;
    document.getElementById('failedTests').textContent = failed;
    document.getElementById('warnTests').textContent = warn;
    document.getElementById('successPercent').textContent = total > 0 ? ((passed/total)*100).toFixed(2) + '%' : '0%';

    // Update Chart.js pie chart
    const ctx = document.getElementById('statusChart').getContext('2d');
    if(chart) chart.destroy();
    chart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['PASS', 'FAIL', 'WARN'],
            datasets: [{
                data: [passed, failed, warn],
                backgroundColor: ['#28a745','#dc3545','#ffc107']
            }]
        },
        options: {
            responsive:true,
            maintainAspectRatio:true, // keep professional aspect
            plugins: { legend: { position: 'bottom' } }
        }
    });
}

/* ============================
   Download current table as CSV
   ============================ */
function downloadCSV() {
    const table = document.getElementById('resultTable');
    const rows = Array.from(table.rows).map(r => Array.from(r.cells).map(c => `"${c.textContent.replace(/"/g,'""')}"`).join(','));
    const csvContent = rows.join('\n');
    const blob = new Blob([csvContent], {type:'text/csv;charset=utf-8;'});
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'CharlieCafe_Verification.csv';
    link.click();
}
</script>
</body>
</html>
```

#### ✅ Features in this final professional dashboard

CSV upload / S3 URL support

Dynamic table with emojis for PASS 🎉, FAIL 😢, WARN ⚠️

Analytics summary cards

Pie chart with Chart.js

Auto-detect CSV headers

Download updated CSV

Dark/Light theme toggle

Fully responsive Bootstrap 5 layout

Print button and coffee cup logo

---

