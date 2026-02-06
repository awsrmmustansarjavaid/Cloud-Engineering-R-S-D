# Charlie Cafe CENTRAL CAFE STYLE SHEET


### CENTRAL CAFE STYLE SHEET

> **Update Version:1.0**



```
/* ==========================================================
   CENTRAL CAFE STYLE SHEET
   File: central-cafe-style.css
   Purpose:
   - Centralized PRINT & THERMAL PRINT styling
   - Reusable across all Charlie Cafe pages
   - Keeps HTML clean (similar to central-auth-api.js)
   ========================================================== */

/* ==========================================================
   GLOBAL PRINT STYLES (STANDARD A4 / NORMAL PRINTERS)
   Applies automatically when browser print is triggered
   ========================================================== */
@media print {

  /* Force clean white background for printing */
  body {
    background: #ffffff !important;
    color: #000000 !important;
  }

  /* Hide interactive or unnecessary elements */
  button,
  .btn,
  .no-print,
  nav,
  footer,
  .navbar {
    display: none !important;
  }

  /* Make tables printer-friendly */
  table {
    width: 100% !important;
    border-collapse: collapse !important;
    margin-top: 10px;
  }

  th,
  td {
    border: 1px solid #000000 !important;
    padding: 6px !important;
    font-size: 12px !important;
    text-align: left;
  }

  th {
    background: #f0f0f0 !important;
    font-weight: bold;
  }

  /* Headings alignment for printed reports */
  h1, h2, h3 {
    text-align: center !important;
    margin-top: 10px;
  }

  /* Prevent page breaks inside important blocks */
  table,
  .receipt,
  .invoice,
  .print-section {
    page-break-inside: avoid;
  }

  /* Reduce excessive margins added by browsers */
  @page {
    margin: 12mm;
  }
}


/* ==========================================================
   THERMAL PRINTER STYLES (80mm RECEIPT PRINTERS)
   Activate by adding class="thermal-print" to <body>
   Example:
   <body class="thermal-print">
   ========================================================== */
@media print {

  /* Thermal printer page width */
  body.thermal-print {
    width: 80mm;
    margin: 0 auto !important;
    padding: 0 !important;
    font-family: monospace !important;
    font-size: 12px;
  }

  /* Receipt container */
  .receipt {
    width: 72mm;
    margin: auto;
  }

  /* Receipt headings & text */
  .receipt h4,
  .receipt p {
    text-align: center;
    margin: 4px 0;
  }

  /* Receipt table formatting */
  .receipt table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
  }

  .receipt td {
    padding: 2px 0;
    border: none !important; /* thermal printers don't like borders */
  }

  /* Dashed divider for totals */
  .receipt .total {
    border-top: 1px dashed #000000;
    margin-top: 6px;
    padding-top: 6px;
    font-weight: bold;
    text-align: center;
  }

  /* Hide everything except receipt when thermal printing */
  body.thermal-print * {
    visibility: hidden;
  }

  body.thermal-print .receipt,
  body.thermal-print .receipt * {
    visibility: visible;
  }
}

/* ==========================================================
   OPTIONAL UTILITIES (CAN BE USED IN HTML)
   ========================================================== */

/* Force element to print even if others are hidden */
.print-only {
  display: none;
}

@media print {
  .print-only {
    display: block !important;
  }
}
```

### ✅ What I added (new & improved vs your original)

Here’s a clean breakdown of what’s new beyond what you provided, and why it matters 👇

#### 🖨️ Standard Print Enhancements (A4 / normal printers)

Added on top of your original print CSS:

- Hid common UI clutter:

  - .btn, .navbar, nav, footer

- Improved table readability:

  - Header background color

  - Consistent spacing

- Prevented ugly page breaks:

  - page-break-inside: avoid

- Controlled printer margins:

  - @page { margin: 12mm; }

- Forced clean black & white output:

  - Avoids gray / faded prints

#### ✅ Result: professional invoices & reports

#### 🧾 Thermal Printer System (80mm receipt printers)

Upgraded your thermal CSS into a proper system:

- body.thermal-print mode (very important)

- Monospace font (best for thermal printers)

- Receipt-only visibility:

  - Everything hidden except .receipt

- Removed borders (thermal printers hate borders)

- Clean dashed total separator

- Tight spacing for item lists

#### ✅ Result: real POS-style receipts

#### 🧰 Utility Classes (extra power)

New helpers you didn’t have before:

- .no-print → force hide elements

- .print-only → show ONLY in print

- .print-section → prevent page breaks

These give you full control per page without writing new CSS every time.

### 🧩 How to use it in your pages

#### 1️⃣ Include once (replace inline <style> blocks)

```
<link rel="stylesheet" href="/css/central-cafe-style.css">
```

#### 2️⃣ Normal print (nothing special needed)

```
<button class="no-print">Pay Now</button>
```

#### 3️⃣ Thermal receipt print

```
<body class="thermal-print">

<div class="receipt">
  <h4>Charlie Cafe ☕</h4>
  <p>Order #1023</p>
  ...
</div>

</body>
```

### 🧠 Why this is a big architectural win

- No duplicated <style> blocks

- Easy to change print behavior globally

- Works for:

  - invoices

  - order status

  - admin reports

  - thermal receipts

- Matches how you designed:

  - central-auth-api.js

  - future central-api.js

  - future central-ui.js

You’re thinking like a system designer, not just “getting it to work” — that’s solid 💪

---
### CENTRAL CAFE STYLE SHEET

> **Update Version:1.1**

### ✅ What I fixed (very important)

#### ❌ Problem (before)

central-cafe-style.css accidentally contained:

<html>, <head>, <nav>, JS, inline <style>

This would break all pages loading it as CSS

#### ✅ Solution (now)

The file is now PURE CSS ONLY

All:

- navbar styles

- background image styles

- button styles

- print + thermal styles

are centralized correctly

This is now safe to include on every page.

### 📁 Final File Structure (recommended)

```
/var/www/html/
│
├── css/
│   └── central-cafe-style.css   ✅ (THIS FILE)
│
├── js/
│   └── central-auth-api.js
│
├── images/
│   ├── cafe-background.jpg
│   └── charlie-logo.png
│
├── central-print.html
├── order-status.html
├── order.php
└── hr-report.html
```

### 🎨 What was ADDED to central-cafe-style.css

#### 1️⃣ Global UI system (ALL pages)

Base font & colors

.cafe-bg → cafe background image

.cafe-overlay → white readable overlay

Mobile-safe defaults

#### 2️⃣ Shared Navbar (Bootstrap-friendly)

```
<nav class="navbar navbar-expand-lg navbar-dark navbar-cafe">
```

Gradient cafe theme

Logo support

Mobile responsive

One navbar style for all pages

#### 3️⃣ Printing / Export UI buttons

Reusable button classes:

.btn-print 🖨️

.btn-thermal 🔥

.btn-csv 🗄️

.btn-pdf 📄

.print-action-bar (floating bottom bar)

No inline CSS needed anymore.

#### 4️⃣ Print & Thermal (kept + improved)

A4 browser print

Thermal receipt (80mm)

Page-break protection

Auto-hide UI

Receipt-only visibility

### 🧩 How to use this CSS in ANY page

#### 1️⃣ Load once in <head>

```
<link rel="stylesheet" href="/css/central-cafe-style.css">
```

#### 2️⃣ Enable cafe background

```
<body class="cafe-bg">
  <div class="container cafe-overlay">
    ...
  </div>
</body>
```

#### 3️⃣ Standard Navbar (copy ONCE per page)

```
<nav class="navbar navbar-expand-lg navbar-dark navbar-cafe">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">
      <img src="/images/charlie-logo.png"> Charlie Cafe
    </a>
  </div>
</nav>
```

#### 4️⃣ Print / Export Buttons (no custom CSS)

```
<div class="print-action-bar no-print">
  <button class="btn btn-cafe btn-print">🖨️ Print</button>
  <button class="btn btn-cafe btn-thermal">🔥 Thermal</button>
  <button class="btn btn-cafe btn-csv">🗄️ CSV</button>
  <button class="btn btn-cafe btn-pdf">📄 PDF</button>
</div>
```

### 🧠 Architectural Win (big one)

You now have:

✅ ONE CSS file for the entire cafe lab

✅ ZERO inline styles

✅ Mobile-first Bootstrap-friendly

✅ Print-safe

✅ Thermal-safe

✅ Scales to:

admin dashboard

POS

HR reports

finance exports

This is exactly how real production systems are structured.


```
/* ==========================================================
   CENTRAL CAFE STYLE SHEET
   File: central-cafe-style.css
   Project: Charlie Cafe Lab (Frontend + Printing + Export)
   Purpose:
   - Global UI/UX styling for ALL cafe pages
   - Centralized PRINT & THERMAL PRINT styles
   - Responsive Bootstrap-friendly layout helpers
   - Avoid CSS duplication across pages
   ========================================================== */

/* ==========================================================
   1️⃣ GLOBAL BASE STYLES (ALL PAGES)
   ========================================================== */

/* Default body styling */
body {
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f8f9fa;
  color: #212529;
}

/* Cafe background (used on dashboards & print hub) */
body.cafe-bg {
  background-image: url('/images/cafe-background.jpg'); /* Cafe theme image */
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* Overlay for readability on background images */
.cafe-overlay {
  background: rgba(255, 255, 255, 0.92);
  border-radius: 12px;
  padding: 20px;
}

/* ==========================================================
   2️⃣ NAVBAR (SHARED ACROSS ALL PAGES)
   ========================================================== */

.navbar-cafe {
  background: linear-gradient(90deg, #2b2b2b, #000000);
}

.navbar-cafe .navbar-brand {
  font-weight: bold;
  color: #ffffff !important;
}

.navbar-cafe .navbar-brand img {
  height: 40px;
  margin-right: 8px;
}

.navbar-cafe .nav-link {
  color: #e0e0e0 !important;
}

.navbar-cafe .nav-link:hover {
  color: #ffc107 !important; /* cafe accent */
}

/* Mobile navbar spacing */
@media (max-width: 768px) {
  .navbar-cafe .navbar-brand {
    font-size: 16px;
  }
}

/* ==========================================================
   3️⃣ BUTTONS & ACTION UI (PRINT / EXPORT)
   ========================================================== */

.btn-cafe {
  border-radius: 50px;
  padding: 10px 18px;
  font-size: 14px;
}

.btn-print {
  background-color: #343a40;
  color: #ffffff;
}

.btn-thermal {
  background-color: #fd7e14;
  color: #ffffff;
}

.btn-csv {
  background-color: #198754;
  color: #ffffff;
}

.btn-pdf {
  background-color: #dc3545;
  color: #ffffff;
}

/* Floating action bar (bottom) */
.print-action-bar {
  position: fixed;
  bottom: 15px;
  left: 15px;
  z-index: 9999;
}

/* ==========================================================
   4️⃣ GLOBAL PRINT STYLES (A4 / NORMAL PRINTERS)
   ========================================================== */
@media print {

  body {
    background: #ffffff !important;
    color: #000000 !important;
  }

  /* Hide UI-only elements */
  button,
  .btn,
  .no-print,
  nav,
  footer,
  .navbar {
    display: none !important;
  }

  table {
    width: 100% !important;
    border-collapse: collapse !important;
    margin-top: 10px;
  }

  th,
  td {
    border: 1px solid #000000 !important;
    padding: 6px !important;
    font-size: 12px !important;
  }

  th {
    background: #f0f0f0 !important;
    font-weight: bold;
  }

  h1, h2, h3 {
    text-align: center !important;
  }

  table,
  .receipt,
  .invoice,
  .print-section {
    page-break-inside: avoid;
  }

  @page {
    margin: 12mm;
  }
}

/* ==========================================================
   5️⃣ THERMAL PRINTER STYLES (80mm RECEIPTS)
   ========================================================== */
@media print {

  body.thermal-print {
    width: 80mm;
    margin: 0 auto !important;
    padding: 0 !important;
    font-family: monospace !important;
    font-size: 12px;
  }

  .receipt {
    width: 72mm;
    margin: auto;
  }

  .receipt h4,
  .receipt p {
    text-align: center;
    margin: 4px 0;
  }

  .receipt table {
    width: 100%;
    font-size: 11px;
  }

  .receipt td {
    padding: 2px 0;
    border: none !important;
  }

  .receipt .total {
    border-top: 1px dashed #000000;
    margin-top: 6px;
    padding-top: 6px;
    font-weight: bold;
    text-align: center;
  }

  body.thermal-print * {
    visibility: hidden;
  }

  body.thermal-print .receipt,
  body.thermal-print .receipt * {
    visibility: visible;
  }
}

/* ==========================================================
   6️⃣ PRINT UTILITIES
   ========================================================== */

.print-only {
  display: none;
}

@media print {
  .print-only {
    display: block !important;
  }
}
```
