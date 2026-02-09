# Charlie Cafe FINAL-single-order-status-with-print-button


### FINAL-single-order-status-with-print-button

> **Update Version: 1.0**


```
<?php
/* ===============================
   CONFIGURATION SECTION
   👉 REPLACE API URL WITH YOUR OWN
   =============================== */

$orderId = $_GET['order_id'] ?? '';

/* 🔴 REPLACE this API URL */
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=$orderId";

$response = @file_get_contents($apiUrl);
$data = json_decode($response, true);
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ===============================
     BOOTSTRAP CSS
     =============================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===============================
     GOOGLE FONT (CAFE STYLE)
     =============================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<!-- ===============================
     CUSTOM CAFE CSS
     =============================== -->
<style>
body {
  font-family: 'Poppins', sans-serif;
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

.cafe-card {
  background: #fff;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 10px 25px rgba(0,0,0,.25);
}

.cafe-title {
  color: #5a2d0c;
  font-weight: 700;
}

.badge-status {
  font-size: 1rem;
  padding: 8px 14px;
}

.print-btn {
  position: absolute;
  top: 20px;
  right: 20px;
}

footer {
  margin-top: 30px;
  font-size: 0.85rem;
  color: #777;
  text-align: center;
}
</style>
</head>

<body>

<!-- ===============================
     PRINT BUTTON (TOP RIGHT)
     =============================== -->
<button onclick="printPage()" class="btn btn-dark print-btn">
  🖨 Print Receipt
</button>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
  <div class="col-md-6">

    <div class="cafe-card position-relative">

      <h3 class="cafe-title mb-3 text-center">☕ Charlie Cafe</h3>
      <p class="text-center text-muted mb-4">Order Status Details</p>

      <?php if (!$data || isset($data['error'])): ?>

        <!-- ❌ ERROR STATE -->
        <div class="alert alert-danger text-center">
          ❌ Order not found or invalid order ID
        </div>

      <?php else: ?>

        <!-- ✅ ORDER DETAILS -->
        <p><strong>Order ID:</strong> <?= htmlspecialchars($orderId) ?></p>

        <p>
          <strong>Status:</strong>
          <span class="badge bg-success badge-status">
            <?= htmlspecialchars($data['status']) ?>
          </span>
        </p>

        <hr>

        <p><strong>Item:</strong> <?= htmlspecialchars($data['order']['item']) ?></p>
        <p><strong>Quantity:</strong> <?= htmlspecialchars($data['order']['quantity']) ?></p>
        <p><strong>Date:</strong> <?= htmlspecialchars($data['order']['created_at']) ?></p>

        <hr>

        <div class="text-center fw-bold text-success">
          ☕ Thank you for ordering with Charlie Cafe!
        </div>

      <?php endif; ?>

    </div>

    <footer>
      © <?= date("Y") ?> Charlie Cafe · Fresh Coffee & Tea
    </footer>

  </div>
</div>

<!-- ===============================
     JAVASCRIPT
     =============================== -->
<script>
/* 🔹 PRINT FUNCTION */
function printPage() {
  window.print();
}
</script>

</body>
</html>
```


---
### FINAL-single-order-status-with-print-button

> **Update Version: 1.1**

```
<?php
/* =====================================================
   CHARLIE CAFE – SINGLE ORDER STATUS WITH CENTRAL PRINT
   FILE: FINAL-single-order-status-with-print-button.php
   ===================================================== */

/* -------------------------------
   1️⃣ BASIC CONFIG
-------------------------------- */
$orderId = $_GET['order_id'] ?? '';

/* 🔴 REPLACE WITH YOUR REAL API */
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=" . urlencode($orderId);

/* -------------------------------
   2️⃣ FETCH API DATA (SAFE)
-------------------------------- */
$data = null;

if ($orderId) {
    $response = @file_get_contents($apiUrl);
    if ($response !== false) {
        $data = json_decode($response, true);
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ===============================
     BOOTSTRAP CSS
================================ -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===============================
     GOOGLE FONT
================================ -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<!-- ===============================
     CUSTOM STYLE
================================ -->
<style>
body {
  font-family: 'Poppins', sans-serif;
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

.cafe-card {
  background: #fff;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 10px 25px rgba(0,0,0,.25);
}

.cafe-title {
  color: #5a2d0c;
  font-weight: 700;
}

.badge-status {
  font-size: 1rem;
  padding: 8px 14px;
}

/* 🔹 BUTTON NOW FIXED BELOW THANK-YOU MESSAGE */
.print-btn {
  display: block;
  margin: 20px auto 0 auto;
}

footer {
  margin-top: 30px;
  font-size: 0.85rem;
  color: #777;
  text-align: center;
}
</style>
</head>

<body>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
  <div class="col-md-6">

    <!-- ===============================
         ORDER CARD (PRINT TARGET)
    ================================ -->
    <div class="cafe-card position-relative" id="orderPrintArea">

      <h3 class="cafe-title mb-3 text-center">☕ Charlie Cafe</h3>
      <p class="text-center text-muted mb-4">Order Status Details</p>

      <?php if (!$orderId || !$data || isset($data['error'])): ?>

        <!-- ❌ ERROR STATE -->
        <div class="alert alert-danger text-center">
          ❌ Order not found or invalid Order ID
        </div>

      <?php else: ?>

        <!-- ✅ ORDER DETAILS -->
        <p><strong>Order ID:</strong> <?= htmlspecialchars($orderId) ?></p>

        <p>
          <strong>Status:</strong>
          <span class="badge bg-success badge-status">
            <?= htmlspecialchars($data['status'] ?? 'N/A') ?>
          </span>
        </p>

        <hr>

        <p><strong>Item:</strong> <?= htmlspecialchars($data['order']['item'] ?? '-') ?></p>
        <p><strong>Quantity:</strong> <?= htmlspecialchars($data['order']['quantity'] ?? '-') ?></p>
        <p><strong>Date:</strong> <?= htmlspecialchars($data['order']['created_at'] ?? '-') ?></p>

        <hr>

        <div class="text-center fw-bold text-success mb-3">
          ☕ Thank you for ordering with Charlie Cafe!
        </div>

        <!-- 🔹 PRINT BUTTON BELOW THANK-YOU MESSAGE -->
        <button class="btn btn-dark print-btn"
                onclick="openCentralPrint('#orderPrintArea')">
          🖨 Print / Export
        </button>

      <?php endif; ?>

    </div>

    <footer>
      © <?= date("Y") ?> Charlie Cafe · Fresh Coffee & Tea
    </footer>

  </div>
</div>

<!-- ===============================
     CENTRAL PRINT SCRIPT
================================ -->
<script>
/*
|--------------------------------------------------------------------------
| CENTRAL PRINT HANDLER (BUG-FREE)
|--------------------------------------------------------------------------
| • Works for ANY section
| • No race conditions
| • Safe window handling
|--------------------------------------------------------------------------
*/
function openCentralPrint(selector) {

  const target = document.querySelector(selector);
  if (!target) {
    alert('Print section not found!');
    return;
  }

  const content = target.outerHTML;

  const printWindow = window.open('/central-print.html', '_blank');

  /* Ensure content loads AFTER window is ready */
  const timer = setInterval(() => {
    if (printWindow && printWindow.centralPrint) {
      printWindow.centralPrint.loadContent(content);
      clearInterval(timer);
    }
  }, 100);
}
</script>

</body>
</html>
```