# Charile Cafe Printing System


### central-print.html

> **Updated Version:1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Charlie Cafe — Central Print / Export</title>

  <!-- ==========================================
       Central CSS for all printing (A4 + Thermal)
       ========================================== -->
  <link rel="stylesheet" href="/css/central-cafe-style.css">

  <!-- Optional Bootstrap for better UX -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

  <!-- Optional icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body class="print-page">

  <!-- ==========================================
       Main Print Container
       Inject content dynamically from other pages
       ========================================== -->
  <div class="container mt-3" id="printContainer">
    <div class="text-center mb-3">
      <h3>☕ Charlie Cafe — Print & Export</h3>
      <hr>
    </div>
    <!-- Table or content will be loaded here -->
  </div>

  <!-- ==========================================
       Central JS — Printing / CSV / PDF
       ========================================== -->
  <script src="/js/central-auth-api.js"></script>

  <!-- jsPDF library for PDF export -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

  <script>
    // ==========================================
    // CENTRAL PRINT / EXPORT MODULE
    // Reusable for any page
    // ==========================================
    const centralPrint = {
      // Load HTML content (table, daily summary, receipt, etc.)
      loadContent: function(htmlContent) {
        document.getElementById('printContainer').innerHTML = htmlContent;
      },

      // Browser Print (A4 / standard)
      printPage: function() {
        window.print();
      },

      // Thermal Print — 80mm receipt style
      thermalPrint: function() {
        document.body.classList.add('thermal-print');
        window.print();
      },

      // Daily summary report
      dailySummary: function(tableSelector) {
        const table = document.querySelector(tableSelector);
        if (!table) {
          alert("❌ Table not found for daily summary.");
          return;
        }

        const rows = table.querySelectorAll('tbody tr');
        const today = new Date().toISOString().split("T")[0];

        let totalOrders = 0;
        let totalAmount = 0;

        rows.forEach(row => {
          const orderDate = row.dataset.date;
          const amount = parseFloat(row.dataset.total || 0);
          if (orderDate === today) {
            totalOrders++;
            totalAmount += amount;
          }
        });

        const summaryHTML = `
          <div style="padding:20px; font-family: Arial, sans-serif;">
            <h3 style="text-align:center">☕ Charlie Cafe — Daily Summary</h3>
            <hr>
            <p><strong>Date:</strong> ${today}</p>
            <p><strong>Total Orders:</strong> ${totalOrders}</p>
            <p><strong>Total Sales:</strong> $${totalAmount.toFixed(2)}</p>
          </div>
        `;

        centralPrint.loadContent(summaryHTML);
        centralPrint.printPage();
      },

      // Export CSV from table
      exportCSV: function(filename='data.csv') {
        const container = document.getElementById('printContainer');
        const rows = container.querySelectorAll('table tr');
        if(rows.length === 0) {
          alert("❌ No table found to export CSV.");
          return;
        }

        let csv = [];
        rows.forEach(tr => {
          let cols = tr.querySelectorAll('td, th');
          let row = [];
          cols.forEach(col => row.push('"' + col.innerText.replace(/"/g,'""') + '"'));
          csv.push(row.join(','));
        });

        const blob = new Blob([csv.join("\n")], {type: 'text/csv'});
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = filename;
        a.click();
        URL.revokeObjectURL(a.href);
      },

      // Export PDF using jsPDF
      exportPDF: function(filename='document.pdf') {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('p', 'pt', 'a4');
        const container = document.getElementById('printContainer');

        doc.html(container, {
          callback: function (doc) {
            doc.save(filename);
          },
          margin: [20,20,20,20],
          autoPaging: 'text',
          x: 10,
          y: 10
        });
      }
    };

    // Optional: Add keyboard shortcuts
    document.addEventListener('keydown', function(e) {
      if(e.ctrlKey && e.key === 'p') centralPrint.printPage();
      if(e.ctrlKey && e.key === 't') centralPrint.thermalPrint();
      if(e.ctrlKey && e.key === 'c') centralPrint.exportCSV();
      if(e.ctrlKey && e.key === 'd') centralPrint.exportPDF();
    });
  </script>

  <!-- ==========================================
       UI Buttons for testing / UX
       Can be removed in production
       ========================================== -->
  <div class="fixed-bottom mb-3 ms-3 no-print">
    <button class="btn btn-primary me-2" onclick="centralPrint.printPage()">
      🖨️ Print A4
    </button>
    <button class="btn btn-warning me-2" onclick="centralPrint.thermalPrint()">
      🔥 Thermal Print
    </button>
    <button class="btn btn-success me-2" onclick="centralPrint.exportCSV('orders.csv')">
      🗄️ Export CSV
    </button>
    <button class="btn btn-danger me-2" onclick="centralPrint.exportPDF('orders.pdf')">
      📄 Export PDF
    </button>
  </div>

</body>
</html>
```


---
### central-print.html

> **Updated Version:1.1**


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe — Printing Center</title>
    <script src="path/to/charlie-central-auth.js"></script>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; display: none; }
        button { margin: 5px; padding: 10px 20px; cursor: pointer; }
    </style>
</head>
<body>

    <h1>☕ Charlie Cafe — Printing Center</h1>

    <div id="buttons">
        <button onclick="CHARLIE.printAllOrders()">🖨️ Print All Orders</button>
        <button onclick="CHARLIE.printTodaySummary()">📊 Print Today's Summary</button>
        <button onclick="CHARLIE.downloadReport('pdf', 'daily')">📄 Download PDF Report</button>
        <button onclick="CHARLIE.downloadReport('csv')">📑 Download CSV Export</button>
        <button id="logoutBtn">🔒 Logout</button>
    </div>

</body>

<script>
    // Initialize page with auth protection + logout button
    CHARLIE.initProtectedPage({ requireAuth: true, enableLogout: true, logoutButtonId: "logoutBtn" });
</script>

</html>
```

### 1️⃣ How It Works

1. Auth protection

```
CHARLIE.initProtectedPage()
```

Ensures only logged-in users see the page. Auto-redirects to Cognito login if not logged in.

2. Logout button
- Central logout works via your CHARLIE.auth.logout().

3. Printing & Reports

- CHARLIE.printAllOrders() → prints all orders (uses current DOM table)

- CHARLIE.printTodaySummary() → prints daily summary

- CHARLIE.downloadReport("pdf") → downloads PDF

- CHARLIE.downloadReport("csv") → downloads CSV

4. Roles respected

- If an endpoint requires admin, your secureFetch + requireAdmin() ensures unauthorized users cannot perform actions.

### 2️⃣ Optional Improvements

- Dynamic orders table: fetch from CHARLIE.api.getOrderStatus() or CHARLIE.api.getCafeOrderStatus() and render in the table.

- Conditional buttons for roles:

```
if(!CHARLIE.isAdmin()) {
    document.querySelector("#buttons button:nth-child(3)").style.display = "none";
}
```

- Styling for print: you can add a @media print { ... } CSS block to make it look professional on paper.

---



