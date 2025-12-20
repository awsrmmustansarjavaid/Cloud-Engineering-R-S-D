# 🧪 AWS Hands-On Lab

> **Author & Architecture Designer:** Charlie

## Build and Deploy a LAMP Server on AWS (Beginner – No Steps Skipped)

---

## 🧠 What You Will Learn

By completing this lab, you will practically learn:

* What the LAMP stack is (Linux, Apache, MySQL, PHP)
* How to launch an EC2 instance
* How to configure Security Groups
* How to connect to EC2 using SSH
* How to install Apache, MySQL (MariaDB), and PHP
* How to deploy and test a PHP application

---

## 🧱 LAMP Stack Overview

| Component       | Purpose                              |
| --------------- | ------------------------------------ |
| Linux           | Operating System (Amazon Linux 2023) |
| Apache          | Web Server                           |
| MySQL (MariaDB) | Database Server                      |
| PHP             | Server-side scripting language       |

---

## 📌 Prerequisites

* AWS Free Tier Account
* Laptop/Desktop with Internet
* Basic command-line access

---

## 🧩 Architecture

```
User Browser
     |
     | HTTP (Port 80)
     v
EC2 Instance (Amazon Linux)
     |
     | Apache + PHP
     |
MariaDB (Local Database)
```

## 🧩 Architecture Diagram

![AWS Architecture Diagram](./LAMP%20architecture%20on%20AWS%20cloud%20diagram.png)
---

## 🔐 Step 1: Login to AWS Console

1. Go to [https://aws.amazon.com](https://aws.amazon.com)
2. Click **Sign In → Console**
3. Login using your AWS credentials

---

## 🌍 Step 2: Select AWS Region

Choose a nearby region (example: `us-east-1` or `ap-south-1`).

> ⚠️ Use the same region throughout the lab

---

## 🖥️ Step 3: Launch EC2 Instance

### 3.1 Open EC2 Service

* Search **EC2** → Click **Launch Instance**

### 3.2 Configure Instance

* Name: `LAMP-Server`
* AMI: Amazon Linux 2023
* Instance Type: `t2.micro`

### 3.3 Create Key Pair

* Name: `lamp-key`
* Type: RSA
* Download `.pem` file

### 3.4 Network Settings

* Auto-assign Public IP: Enable

### 3.5 Security Group Rules

| Type  | Port | Source   |
| ----- | ---- | -------- |
| SSH   | 22   | My IP    |
| HTTP  | 80   | Anywhere |
| HTTPS | 443  | Anywhere |

### 3.6 Storage

* Default 8GB (gp3)

### 3.7 Launch Instance

Click **Launch Instance**

---

## 🔗 Step 4: Connect to EC2 via SSH

```bash
chmod 400 lamp-key.pem
ssh -i lamp-key.pem ec2-user@PUBLIC_IP
```

---

## 🐧 Step 5: Update Linux

```bash
sudo dnf update -y
```

---

## 🌐 Step 6: Install Apache

```bash
sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Test in browser:

```
http://PUBLIC_IP
```

---

## 🛢️ Step 7: Install MySQL (MariaDB)

```bash
sudo dnf install mariadb105-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
```

---

## 🐘 Step 8: Install PHP

```bash
sudo dnf install php php-mysqlnd php-fpm -y
sudo systemctl restart httpd
```

---

## 🧪 Step 9: Test PHP

```bash
sudo nano /var/www/html/info.php
```

```php
<?php phpinfo(); ?>
```

Browser:

```
http://PUBLIC_IP/info.php
```

---

## 🗃️ Step 10: Test Database Connection

```bash
sudo nano /var/www/html/dbtest.php
```

```php
<?php
$conn = new mysqli("localhost", "root", "YOUR_PASSWORD");
if ($conn->connect_error) {
  die("Connection failed");
}
echo "Database Connected Successfully";
?>
```

---

## 🔐 Step 11: Fix Permissions

```bash
sudo chown -R apache:apache /var/www
sudo chmod -R 755 /var/www
```

---

## 🎉 Lab Completed

You have successfully built and deployed a **LAMP Server on AWS**.

---

## 🧹 Cleanup

Terminate the EC2 instance to avoid charges.

---

## 📁 Save As

```
lamp-server-aws-lab.md
```


