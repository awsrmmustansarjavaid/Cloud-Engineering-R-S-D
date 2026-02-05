# Charile Cafe Printing System


### central-print.html

> **Updated Version:1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Charlie Cafe — Print / Export</title>
  <!-- Central CSS for printing -->
  <link rel="stylesheet" href="/css/central-cafe-style.css">

  <!-- Optional: Bootstrap for styling in print preview -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

</head>
<body>
  <div id="printContainer" class="container mt-3">
    <!-- Content will be injected dynamically from other pages -->
  </div>

  <!-- Central JS for printing -->
  <script src="/js/central-auth-api.js"></script>
  
  <!-- Central Print & Export JS -->
  <script>
    // ==============================================
    // 🖨️ CENTRAL PRINT & EXPORT HANDLER
    // Universal for all pages
    // ==============================================

    const centralPrint = {
      loadContent: function(htmlContent) {
        // Inject content into the container
        document.getElementById('printContainer').innerHTML = htmlContent;
      },

      printPage: function() {
        window.print();
      },

      exportCSV: function(filename='data.csv') {
        const container = document.getElementById('printContainer');
        const rows = container.querySelectorAll('table tr');
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

      exportPDF: function() {
        // Simple PDF export via browser print dialog
        // Can later integrate jsPDF for advanced PDF
        window.print();
      }
    };

    // Optional: Automatically print if loaded with content
    // centralPrint.printPage();
  </script>
</body>
</html>
```


---
