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

