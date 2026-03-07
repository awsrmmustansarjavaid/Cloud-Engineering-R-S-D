# Charlie Cafe - FrontEnd Development & Deployment

## 1️⃣ ☕ Charlie Cafe - JS & CSS File 

### 1️⃣ Create config.js (NO LOGIC HERE)
> **This file will be reused across all pages.**

This replaces hardcoded config from your old file.

- 📍 Place this in /js/config.js

#### 1️⃣ Command to create the js directory

```
sudo mkdir -p /var/www/html/js
```

#### 2️⃣ Command to create the .js file

```
sudo nano /var/www/html/js/config.js
```

#### 3️⃣ Copy & Paste Script

[config.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)

### 2️⃣ Create utils.js (Shared Helpers)

Move all generic helpers here.

```
sudo nano /var/www/html/js/utils.js
```

[utils.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)



### 3️⃣ Create central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

```
sudo nano /var/www/html/js/central-auth.js
```

[central-auth.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)



### 4️⃣ Create api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

```
sudo nano /var/www/html/js/api.js
```

[api.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)

### 5️⃣ Create central-printing.js

```
sudo nano /var/www/html/js/central-printing.js
```

[central-printing.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)

### 6️⃣ Create role-guard.js

```
sudo nano /var/www/html/js/role-guard.js
```

[role-guard.js](../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/role-guard.js)


#### ⚠️ Use * to apply it to all files (all extensions) in the directory:

### 6️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/js/*
```
```
sudo chmod 644 /var/www/html/js/*
```

---

### 2️⃣ Create the shared Central-cafe-style (IMPORTANT)

#### 1️⃣ Command to create the css directory

```
sudo mkdir -p /var/www/html/css
```

#### 2️⃣ Create Central-cafe-style

```
sudo nano /var/www/html/css/central_cafe_style.css
```

#### 3️⃣ Copy & Paste CSS

[central_cafe_style.css](../☕%20AWS%20CAFE%20—%20Central%20Style%20Css/central_cafe_style.css)

#### 3️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/css/*
```
```
sudo chmod 644 /var/www/html/css/*
```
## 2️⃣ ☕ Charlie Cafe - FrontEnd Web Pages

### 1️⃣ Charlie Cafe - index.php (IMPORTANT)
> **File Name: index.php**

#### 1️⃣ Create index.php

```
sudo nano /var/www/html/index.php
```

#### 2️⃣ Paste this clean landing page code:

[index.php](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Index.php/Index.php)

**⚠️ Replace S3_IMAGE_URL_HERE later (next phase)**

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---

### 2️⃣ Charlie Cafe Admin Dashboard Page (IMPORTANT)
> **File Name: cafe-admin-dashboard.html**

### 1️⃣ Create index.php

```
sudo nano /var/www/html/cafe-admin-dashboard.html
```

### 2️⃣ Paste this clean landing page code:

[cafe-admin-dashboard.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 3️⃣ Charlie Cafe orders.php (IMPORTANT)
> **File Name: orders.php**

###  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

#### 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)

#### 1️⃣ Create orders.php

```
sudo nano /var/www/html/orders.php
```
#### 2️⃣ MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 4️⃣ Charlie Cafe order-status.html  (IMPORTANT)
> **File Name: order-status.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/order-status.html
```

#### 2️⃣ CODE

#### 🚨 IMPORTANT:

#### Replace this line ONLY:

```
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
```

#### With your real API:

```
fetch("https://abcd1234.execute-api.us-east-1.amazonaws.com/admin/order-status")
```

[order-status.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---
### 5️⃣ Charlie Cafe order-status.php  (IMPORTANT)
> **File Name: order-status.php**

#### ☕ FINAL order-receipt.php with print button (CAFE STYLED - Recommanded)

#### 1️⃣ Create File

```
sudo nano /var/www/html/order-receipt.php
```

#### 2️⃣ code

[order-receipt.php](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 6️⃣ Charlie Cafe admin-orders.html  (IMPORTANT)
> **File Name: admin-orders.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/admin-orders.html
```

#### 2️⃣ code

[admin-orders.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/admin-orders/admin-orders.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 7️⃣ Charlie Cafe payment-status.php  (IMPORTANT)
> **File Name: payment-status.php**

#### 1️⃣ Create File

```
sudo nano /var/www/html/payment-status.php
```

#### 2️⃣ code

[payment-status.php](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 8️⃣ Charlie Cafe Dedicated Printing HTML  (IMPORTANT)
> **File Name: central-print.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/central-print.html
```

#### 2️⃣ code

[central-print.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/☕%20AWS%20CAFE%20—%20Printing%20System/central-print.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---
### 9️⃣ Charlie Cafe analytics.html  (IMPORTANT)
> **File Name: analytics.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/analytics.html
```

#### 2️⃣ code

[analytics.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
### 🔟 login.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/login.html
```

#### 2️⃣ code

[login.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/login.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣1️⃣ price-list.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/price-list.html
```

#### 2️⃣ code

[price-list.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/price-list.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣2️⃣ logout.php


#### 1️⃣ Create File

```
sudo nano /var/www/html/logout.php
```

#### 2️⃣ code

[logout.php](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/logout.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣3️⃣ employee-login.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/employee-login.html
```

#### 2️⃣ code

[employee-login.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-login.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣4️⃣ employee-portal.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/employee-portal.html
```

#### 2️⃣ code

[employee-portal.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-portal.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣5️⃣ hr-attendance.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/hr-attendance.html
```

#### 2️⃣ code

[hr-attendance.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/hr-attendance.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣6️⃣ checkin.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/checkin.html
```

#### 2️⃣ code

[checkin.html](../☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/checkin.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---