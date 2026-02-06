# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

### READ Me About

[Charile Cafe Printing System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕%20CC-%201%20—%20Order_Async_Processing_Tracking_System.md)

### ☕ AWS Charlie Café – Test & Verifications

[Charile Cafe Printing System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—%20Order_Async_Processing_Tracking_System%20.md)


---
# SECTION 1️⃣ Charlie Cafe - PRINTING System

## 🔐 PHASE 1️⃣ Charlie Cafe - PRINTING (FRONTEND ONLY)

### 1️⃣ Create a Dedicated Printing HTML (central-print.html)

Path: /var/www/html/central-print.html

This will be the universal printing & export hub.

This file will:

- Include central-cafe-style.css for all print styles

- Include central-auth-api.js for browser printing functions

- Include optional export functionality (CSV/PDF)

- Be reusable for any page: order.php, order-status.html, HR reports, etc.

- Allow printing or exporting without duplicating code

### 1️⃣ Create File

```
sudo nano /var/www/html/central-print.html
```

### 2️⃣ Add Full HTML Template

Paste this code into central-print.html. It is fully commented, contains thermal print, daily summary, CSV export, PDF export, and UX/UI features.

[central-print.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Printing%20System/central-print.html)

#### Save File

```
CTRL + O → ENTER
CTRL + X
```

#### Permissions

```
sudo chown apache:apache /var/www/html/central-print.html
```
```
sudo chmod 644 /var/www/html/central-print.html
```

### 3️⃣ Using this Central Print File in Other Pages

- Include a print button on any page, e.g., order-status.html:

```
<button class="btn btn-outline-dark" onclick="openCentralPrint('#ordersTable')">
  🖨️ Print / Export
</button>

<script>
function openCentralPrint(selector) {
  const content = document.querySelector(selector).outerHTML;
  const printWindow = window.open('/central-print.html', '_blank');
  printWindow.onload = function() {
    printWindow.centralPrint.loadContent(content);
  }
}
</script>
```

#### ✅ Works for any table or section.

### 4️⃣ UX / UI Features Added

✔️ Fixed-bottom action buttons for testing (Print, Thermal, CSV, PDF)

✔️ Keyboard shortcuts:

✔️ Ctrl+P → Print A4

✔️ Ctrl+T → Thermal print

✔️ Ctrl+C → CSV export

✔️ Ctrl+D → PDF export

✔️ Alerts if no table found

✔️ Fully responsive using Bootstrap

✔️ Thermal print layout uses central-cafe-style.css

a




**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 1️⃣  COMPLETE ✅
---
# SECTION 2️⃣ Central PDF Reporting Lambda (optional)













**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 2️⃣  COMPLETE ✅
---