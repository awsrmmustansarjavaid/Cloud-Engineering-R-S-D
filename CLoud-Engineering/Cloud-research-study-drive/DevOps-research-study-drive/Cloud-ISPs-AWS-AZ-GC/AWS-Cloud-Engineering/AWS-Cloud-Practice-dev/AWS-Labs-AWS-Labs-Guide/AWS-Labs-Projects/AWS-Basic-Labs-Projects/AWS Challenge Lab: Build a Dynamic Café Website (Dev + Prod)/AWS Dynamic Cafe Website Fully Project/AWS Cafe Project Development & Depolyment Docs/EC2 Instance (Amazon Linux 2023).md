# 🌐 Launch EC2 Instance (Amazon Linux 2023)

### ✅ EC2 USER DATA — LAMP + MySQL CLIENT (Amazon Linux 2023) 

> **You can copy-paste directly into EC2 → Advanced details → User data.**

```
#!/bin/bash
# --------------------------------------------
# EC2 User Data Script
# Amazon Linux 2023
# Installs LAMP Stack + MySQL Client
# --------------------------------------------

# 1️⃣ Update OS (MANDATORY FIRST)
dnf update -y

# 2️⃣ Install Apache (httpd)
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# 3️⃣ Install PHP + MySQL Support
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# 4️⃣ Fix Web Directory Permissions (MANDATORY)
chown -R apache:apache /var/www
chmod -R 755 /var/www

# 5️⃣ Install MySQL Client (MariaDB)
dnf install -y mariadb105

# 6️⃣ Create a PHP Info Page (Optional Verification)
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 7️⃣ Restart Apache to Apply PHP
systemctl restart httpd

# --------------------------------------------
# END OF USER DATA
# --------------------------------------------
```

#### ✅ WHAT THIS USER DATA DOES AUTOMATICALLY

| Task                   | Status |
| ---------------------- | ------ |
| OS update              | ✅      |
| Apache install & start | ✅      |
| PHP install            | ✅      |
| PHP–MySQL driver       | ✅      |
| Correct permissions    | ✅      |
| MySQL client           | ✅      |
| Apache restart         | ✅      |


## 3️⃣ Connect to EC2

```bash
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```

## 4️⃣ 🧪 HOW TO VERIFY AFTER EC2 IS RUNNING

### 1️⃣ Apache Test

#### Open browser:

```
http://<EC2-PUBLIC-IP>/
```

#### You should see:

```
It works!
```

### 2️⃣ PHP Test

#### Open:

```
http://<EC2-PUBLIC-IP>/info.php
```

#### You should see:

- PHP version

- mysqlnd enabled

### 3️⃣ MySQL Client Test (SSH)

```
mysql --version
```

### 4️⃣ VERIFY APACHE (httpd) (CLI)

#### 1️⃣ Check Apache Service Status

```
sudo systemctl status httpd
```

#### ✅ Expected:

```
Active: active (running)
```

#### 2️⃣ Verify Apache Version

```
httpd -v
```

#### ✅ Expected:

```
Server version: Apache/2.4.xx (Amazon Linux)
```

#### 3️⃣ Test Apache Locally (CLI)

```
curl http://localhost
```

#### ✅ Expected:

```
It works!
```

⚠️ If not installed correctly, you’ll get connection refused.

### 5️⃣ VERIFY PHP (CLI)

#### 1️⃣ Check PHP Version

```
php -v
```

#### ✅ Expected:

```
PHP 8.x.x (cli)
```

#### 2️⃣ Create PHP Test File (CLI)

```
sudo nano /var/www/html/test.php
```

##### Paste:

```
<?php
echo "PHP is working";
phpinfo();
?>
```

**Save and exit.**

#### 3️⃣ Test PHP via Apache (LOCAL)

```
curl http://localhost/test.php
```

#### ✅ Expected:

- Text: PHP is working

- PHP info output (HTML text)

**This confirms:**

✔ Apache → PHP module works

✔ PHP interpreter works

### 6️⃣ VERIFY FILE PERMISSIONS (IMPORTANT)

```
ls -ld /var/www /var/www/html
```

#### ✅ Expected:

```
drwxr-xr-x apache apache ...
```

#### ✅ If not:

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

### 7️⃣ VERIFY PHP ↔ MYSQL EXTENSION

```
php -m | grep mysql
```

#### ✅ Expected:

```
mysqlnd
```

**This confirms PHP can talk to MySQL/RDS.**

### 8️⃣ OPTIONAL: CHECK APACHE LOGS

#### 1️⃣ Access Log

```
sudo tail -f /var/log/httpd/access_log
```

#### 2️⃣ Error Log

```
sudo tail -f /var/log/httpd/error_log
```

#### Open another terminal and run:

```
curl http://localhost/test.php
```

You should see logs updating.

### 9️⃣ COMMON ERRORS & FIXES

#### ❌ Apache not running

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### ❌ PHP file downloads instead of executing

> **Cause: PHP module missing**

#### Fix:

```
sudo dnf install -y php php-mysqlnd
```

```
sudo systemctl restart httpd
```

#### ❌ curl returns empty or 403

#### Check permissions:

```
sudo chmod -R 755 /var/www
```

### 🧠 REAL ENGINEER CHECKLIST (FINAL)

| Check           | Command                   |
| --------------- | ------------------------- |
| Apache running  | `systemctl status httpd`  |
| Apache responds | `curl localhost`          |
| PHP CLI works   | `php -v`                  |
| PHP via Apache  | `curl localhost/test.php` |
| MySQL extension | `php -m \| grep mysql`    |


### 🏁 YOU ARE DONE

Your EC2 is now LAMP-ready and verified from:

- CLI ✅

- Apache ✅

- PHP ✅

---

# PHASE 2 — OPERATING SYSTEM & RUNTIME

## 1️⃣  Install LAMP Stack (ORDER MATTERS)

### ⚠️ VERY IMPORTANT NOTE (DO NOT IGNORE)

**If you forget to add user data at instance launch, then follow this:**

### Update OS

```bash
sudo dnf update -y
```

### Install Apache

```
sudo dnf install -y httpd
```

```
sudo systemctl enable --now httpd
```

### Install PHP

```bash
sudo dnf install -y php php-mysqlnd php-cli php-common php-mbstring php-xml
```

### Verify

```bash
php -v
```

```
httpd -v
```

---

## 2️⃣ Fix Permissions (MANDATORY)

```bash
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

---

# PHASE 3 — APPLICATION CODE

## 1️⃣ Install AWS SDK for PHP

##### (Press ENTER for all prompts)

```bash
cd /var/www/html
```

```
sudo dnf install -y composer
```

```
sudo composer require aws/aws-sdk-php
```



## 2️⃣ Fix Permissions (Very Important)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

---

## 3️⃣ Restart

```bash
sudo systemctl restart httpd
```

---

