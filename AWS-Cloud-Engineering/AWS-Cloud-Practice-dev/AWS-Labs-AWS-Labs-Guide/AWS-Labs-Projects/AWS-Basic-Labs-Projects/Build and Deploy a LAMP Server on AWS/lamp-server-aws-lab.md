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


# 🔐 AWS Hands-On Lab Extension

## Add AWS Secrets Manager to LAMP Server (Based on Existing EC2 LAMP Lab)

---

## 🧠 What You Will Learn

By completing this extension, you will learn:

* Why **AWS Secrets Manager** is needed
* How to store MySQL credentials securely
* How to grant EC2 permission using **IAM Role (Least Privilege)**
* How to fetch secrets from Secrets Manager using **PHP**
* How to remove hardcoded passwords from code

---

## ❗ Why Secrets Manager?

❌ **Bad Practice (What we did earlier)**

```php
$conn = new mysqli("localhost", "root", "password");
```

Problems:

* Password exposed in code
* Hard to rotate credentials
* Security risk

✅ **Good Practice**

* Store secrets in AWS Secrets Manager
* Grant EC2 permission via IAM Role
* Fetch secrets dynamically at runtime

---

## 🧩 Updated Architecture (Concept)

```
User Browser
   |
   | HTTP (80)
   v
EC2 (Apache + PHP)
   |
   | IAM Role (Read Secret)
   v
AWS Secrets Manager
   |
   v
MariaDB (Local DB)
```

---

## 🔐 Step 1: Create Secret in AWS Secrets Manager

1. Open **AWS Console**
2. Search **Secrets Manager**
3. Click **Store a new secret**

### 1.1 Secret Type

* Choose: **Credentials for RDS database**
* Username: `root`
* Password: `YOUR_DB_PASSWORD`

> Even though DB is local, this option is fine

### 1.2 Encryption

* Default KMS key: `aws/secretsmanager`

### 1.3 Secret Name

* Secret name: `lamp/mysql/root`
* Description: `MySQL root password for LAMP EC2`

Click **Next → Next → Store**

---

## 🧑‍💼 Step 2: Create IAM Policy (Least Privilege)

1. Open **IAM → Policies**
2. Click **Create policy**
3. Choose **JSON** tab

Paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:lamp/mysql/root*"
    }
  ]
}
```

4. Policy name: `EC2-Read-LAMP-Secret`
5. Create policy

---

## 🧑‍🚀 Step 3: Create IAM Role for EC2

1. Open **IAM → Roles**
2. Click **Create role**
3. Trusted entity: **AWS service**
4. Use case: **EC2**
5. Attach policy: `EC2-Read-LAMP-Secret`
6. Role name: `EC2-LAMP-Secrets-Role`

---

## 🔗 Step 4: Attach IAM Role to EC2

1. Go to **EC2 → Instances**
2. Select your LAMP instance
3. Actions → Security → Modify IAM role
4. Select: `EC2-LAMP_attach? careful
5. Select: `EC2-LAMP-Secrets-Role`
6. Save

---

## 🧰 Step 5: Install AWS SDK for PHP on EC2

Connect to EC2 via SSH and run:

```bash
sudo dnf install php-cli unzip -y
cd /var/www/html
sudo curl -sS https://getcomposer.org/installer | php
sudo php composer.phar require aws/aws-sdk-php
```

---

## 🐘 Step 6: Create PHP Script to Read Secret

Create file:

```bash
sudo nano /var/www/html/db-secret.php
```

Paste:

```php
<?php
require 'vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;

$client = new SecretsManagerClient([
    'region' => 'YOUR_REGION',
    'version' => 'latest'
]);

$result = $client->getSecretValue([
    'SecretId' => 'lamp/mysql/root'
]);

$secret = json_decode($result['SecretString'], true);

$db_password = $secret['password'];

$conn = new mysqli("localhost", "root", $db_password);

if ($conn->connect_error) {
    die("DB Connection Failed");
}

echo "Database Connected Securely using Secrets Manager";
?>
```

Replace:

* `YOUR_REGION` (example: `us-east-1`)

---

## 🧪 Step 7: Test Secure Connection

Open browser:

```
http://PUBLIC_IP/db-secret.php
```

✅ Output:

```
Database Connected Securely using Secrets Manager
```

---

## 🔁 Step 8: (Optional) Rotate Secret

1. Secrets Manager → Secret
2. Click **Rotate secret**
3. Enable rotation (manual for learning)

Your app will continue working without code changes

---

## 🧹 Step 9: Security Cleanup

* Remove old PHP files with hardcoded passwords
* Restrict SSH to your IP only

---

## 🎯 Final Outcome

You have now:

* Integrated **AWS Secrets Manager** with LAMP
* Applied **IAM Least Privilege**
* Removed plaintext credentials
* Followed real-world AWS security practice

---

## 📁 Save As

```
lamp-secrets-manager-lab.md
```

---

## 🚀 Next Advanced Labs

* Secrets Manager + **RDS**
* Secrets Manager + **Lambda**
* Encrypt secrets with **Customer KMS Key**
* CI/CD with secrets injection

---

✅ This guide is fully based on your existing **LAMP on EC2 lab** and follows production-grade AWS standards.

