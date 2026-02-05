# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

### 🧠 What you’re designing (in real tech terms)

You are creating a:

#### Central Print & Export Gateway (Frontend)

One dedicated HTML page that:

- Loads central CSS (print + thermal)

- Loads central JS

- Accepts data from ANY page

- Can:

    - 🖨️ Print via browser

    - 🧾 Thermal print

    - 📄 Export PDF

    - 📊 Export CSV

- Works for:

    - order.php

    - order-status.html

    - hr.html

    - admin reports

    - future features

This is exactly how enterprise dashboards work.

### 🗂️ Recommended File Structure

```
/print/
│
├── print-hub.html          ✅ THE universal print page
├── central-print.js        ✅ logic (load data, print, export)
├── central-cafe-style.css  ✅ your print + thermal CSS
│
/orders/
│   ├── order.php
│   ├── order-status.html
│
/hr/
│   ├── employee-report.html
```

### 🧾 1️⃣ The Dedicated Printing Page (print-hub.html)

This page:

- Has no business logic

- Only renders + prints what it receives

🔹 How data arrives

We pass data using:

- query params OR

- localStorage OR

- sessionStorage

👉 sessionStorage is best (safe, temporary, clean)

### ✅ print-hub.html (simplified but real)

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Charlie Cafe | Print Hub</title>

  <!-- Central print styles -->
  <link rel="stylesheet" href="/print/central-cafe-style.css">
</head>

<body id="printBody">

  <!-- Print content injected here -->
  <div id="printContainer"></div>

  <!-- Print / Export Controls -->
  <div class="no-print" style="text-align:center; margin-top:20px;">
    <button onclick="window.print()">🖨️ Print</button>
    <button onclick="exportCSV()">📊 Export CSV</button>
    <button onclick="exportPDF()">📄 Export PDF</button>
  </div>

  <!-- Central print logic -->
  <script src="/print/central-print.js"></script>
</body>
</html>
```





