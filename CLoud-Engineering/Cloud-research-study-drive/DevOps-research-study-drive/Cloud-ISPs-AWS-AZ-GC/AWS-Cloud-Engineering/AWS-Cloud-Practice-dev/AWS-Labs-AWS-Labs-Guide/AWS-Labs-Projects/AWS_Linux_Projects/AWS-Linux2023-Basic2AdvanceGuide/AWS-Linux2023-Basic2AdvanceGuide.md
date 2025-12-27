# AWS Linux 2023 Basic to Advance CLI Guide 

> **Author & Architecture Designer:** Charlie 


# 🐧 Amazon Linux 2023 – Basic to Advanced CLI Command Guide (AWS Focused)

This guide is designed for **AWS learners, Cloud Engineers, SysAdmins, and DevOps beginners** using **Amazon Linux 2023** on EC2.

It covers **daily-use, real-world commands** from **basic Linux operations → services → networking → security → web servers → troubleshooting → AWS-friendly tasks**.

---

---

# Content 

### 1. [System Basics & Information](#1-system-basics--information)

### 2. [Package Management (DNF – Daily Use)](#Package-Management)

### 3. [File & Directory Management](#File-&-Directory-Management)

### 4. [User & Permission Management](#User-&-Permission-Management)

### 5. [Service Management](#Service-Management)

### 6. [Networking Commands](#Networking-Commands)

### 7. [System Basics & Information](#System-Basics-&-Information)

### 8. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

### 9. [System Basics & Information](#System-Basics-&-Information)

---

## 📌 1. System Basics & Information

### Check OS Version

```bash
cat /etc/os-release
```

### Kernel Version

```bash
uname -r
```

### System Uptime

```bash
uptime
```

### CPU Information

```bash
lscpu
```

### Memory Usage

```bash
free -h
```

### Disk Usage

```bash
df -h
```

### Mounted Filesystems

```bash
lsblk
```

---

## 📌 2. Package Management 

##### (DNF – Daily Use)

### Update System (MOST COMMON)

```bash
sudo dnf update -y
```

### Search a Package

```bash
dnf search httpd
```

### Install a Package

```bash
sudo dnf install -y httpd
```

### Remove a Package

```bash
sudo dnf remove httpd
```

### List Installed Packages

```bash
dnf list installed
```

### Package Information

```bash
dnf info php
```

---

## 📌 3. File & Directory Management 

##### (Daily Admin Tasks)

### List Files

```bash
ls
ls -l
ls -la
```

### Create Directory

```bash
mkdir project
```

### Create File

```bash
touch index.html
```

### Copy Files

```bash
cp file1 file2
```

### Move / Rename

```bash
mv oldname newname
```

### Delete Files & Directories

```bash
rm file.txt
rm -rf folder
```

### File Permissions

```bash
chmod 755 script.sh
```

### Change Ownership

```bash
sudo chown ec2-user:ec2-user file.txt
```

---

## 📌 4. User & Permission Management

##### (AWS EC2 Admin)

### Current User

```bash
whoami
```

### Add User

```bash
sudo useradd devuser
```

### Set Password

```bash
sudo passwd devuser
```

### Switch User

```bash
su - devuser
```

### Add User to sudo

```bash
sudo usermod -aG wheel devuser
```

---

## 📌 5. Service Management 

##### (systemctl – VERY IMPORTANT)

### Start Service

```bash
sudo systemctl start httpd
```

### Stop Service

```bash
sudo systemctl stop httpd
```

### Restart Service

```bash
sudo systemctl restart httpd
```

### Enable on Boot

```bash
sudo systemctl enable httpd
```

### Disable on Boot

```bash
sudo systemctl disable httpd
```

### Service Status

```bash
sudo systemctl status httpd
```

### List Running Services

```bash
systemctl list-units --type=service
```

---

## 📌 6. Networking Commands 

##### (AWS Troubleshooting)

### IP Address

```bash
ip a
```

### Routing Table

```bash
ip route
```

### Test Connectivity

```bash
ping google.com
```

### Check Open Ports

```bash
ss -tuln
```

### DNS Check

```bash
nslookup google.com
```

### Curl (API & Web Test)

```bash
curl http://localhost
```

---

## 📌 7. Firewall (firewalld – Optional in AL2023)

### Check Firewall Status

```bash
sudo systemctl status firewalld
```

### Start Firewall

```bash
sudo systemctl start firewalld
```

### Allow HTTP

```bash
sudo firewall-cmd --permanent --add-service=http
```

### Reload Firewall

```bash
sudo firewall-cmd --reload
```

⚠️ *In AWS, Security Groups are PRIMARY — firewall is secondary.*

---

## 📌 8. ✅ LAMP Stack Installation on Amazon Linux 2023

#### Update the System

```
sudo dnf update -y
```

#### Install Apache (httpd)

```
sudo dnf install -y httpd
```

#### Start & Enable Apache

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### Verify Apache

```
sudo systemctl status httpd
```

#### Allow Apache Through Firewall (if enabled)

```
sudo firewall-cmd --permanent --add-service=http
```

```
sudo firewall-cmd --reload
```

##### ⚠️ If firewalld is not installed, you can ignore this step.


#### Install PHP 8.x (Amazon Linux 2023 Default)

```
sudo dnf install -y php php-cli php-common php-mysqlnd php-gd php-xml php-mbstring
```

#### Verify PHP

```
php -v
```

#### Test PHP with Apache

```
sudo nano /var/www/html/info.php
```

##### Paste:

```
<?php
phpinfo();
?>
```

#### Restart Apache:

```
sudo systemctl restart httpd
```

##### Open in browser:

```
http://<EC2-Public-IP>/info.php
```

##### ✅ If PHP info page appears → PHP is working correctly

##### Fix Permissions (Very Important)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

##### Verify Full LAMP Stack

```
httpd -v
```

```
php -v
```

`#### `Apache is NOT configured to use PHP-FPM

##### Check this file:

```
sudo nano /etc/httpd/conf.d/php.conf
```

##### It must contain this (default usually does):

```
<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
</FilesMatch>
```

If missing → PHP files will cause 500 error

## 📌 9. 🔁 Install AWS SDK for PHP properly (BEST PRACTICE)

##### This keeps your Secrets Manager integration secure and correct.

#### Install Composer

```
sudo dnf install -y composer
```

#### Go to your web root

```
cd /var/www/html
```

#### Initialize composer

```
sudo composer init
```

##### (Press ENTER for all prompts)

#### Install AWS SDK for PHP

```
sudo composer require aws/aws-sdk-php
```

##### This creates:

```
/var/www/html/vendor/
└── autoload.php
```

#### Set permissions and restart Apache:

```
sudo chown -R apache:apache /var/www/html
```

```
sudo systemctl restart httpd
```

#### 🔄 Restart Apache

```
sudo systemctl restart php-fpm
```

```
sudo systemctl restart httpd
```

####  Verify 

```
php -v
```

```
systemctl status php-fpm
```

```
systemctl status httpd
```

#### 🌐 Test in EC2 CLI

```
curl -I http://localhost/
```

#### 🌐 Test in Browser

```
http://<EC2-Public-IP>
```

##### ✅ You should see the AWS Café homepage


---

## 📌 10. Logs & Monitoring (Production Troubleshooting)

### View System Logs

```bash
journalctl -xe
```

### Service Logs

```bash
journalctl -u httpd
```

### Apache Logs

```bash
/var/log/httpd/access_log
/var/log/httpd/error_log
```

### Check PHP-FPM log:

```
sudo tail -n 50 /var/log/php-fpm/www-error.log
```

#### If file doesn’t exist:

```
sudo journalctl -u php-fpm --no-pager -n 50
```

#### 👉 You WILL see something like:

- mysqli_sql_exception

- Access denied for user

- Call to a member function prepare() on bool



### Disk Usage by Folder

```bash
du -sh *
```

---

## 📌 11. Process Management

### Running Processes

```bash
ps aux
```

### Top (Live Monitoring)

```bash
top
```

### Kill Process

```bash
kill -9 PID
```

---

## 📌 12. Compression & Backup (AWS Admin Work)

### Create Archive

```bash
tar -czvf backup.tar.gz folder/
```

### Extract Archive

```bash
tar -xzvf backup.tar.gz
```

---

## 📌 13. AWS EC2-Specific Daily Commands

### Instance Metadata (VERY IMPORTANT)

```bash
curl http://169.254.169.254/latest/meta-data/
```

### Public IP

```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### Instance ID

```bash
curl http://169.254.169.254/latest/meta-data/instance-id
```

---

## 📌 14. Security Best Practices

### Disable Root Login (SSH)

```bash
sudo vi /etc/ssh/sshd_config
```

Set:

```
PermitRootLogin no
```

Restart SSH:

```bash
sudo systemctl restart sshd
```

---

## 📌 15. Useful Aliases (Productivity)

```bash
alias ll='ls -lah'
alias cls='clear'
```

---

## 📌 16. install and configure MariaDB Server on Amazon Linux 2023


##### Update Your System

```
sudo dnf update -y
```

#### Install MariaDB Server (MySQL Compatible)

```
sudo dnf install -y mariadb105-server
```

#### Start & Enable MariaDB

```
sudo systemctl start mariadb
```

```
sudo systemctl enable mariadb
```

#### Verify MariaDB

```
sudo systemctl status mariadb
```

#### Secure MariaDB

```
sudo mysql_secure_installation
```
##### Set root password, remove test DB, disable remote root login

##### Recommended Answers


```
Enter current password for root:  (Press Enter)
Set root password?               Y
Remove anonymous users?          Y
Disallow root login remotely?    Y
Remove test database?            Y
Reload privilege tables?         Y
```

- Set root password

- Remove anonymous users

- Disallow root login remotely (optional for security)

- Remove test database

- Reload privilege tables → yes



##### Install MySQL Client (Optional but Recommended)

```
sudo dnf install -y mariadb105
```

### Step 6: Create MySQL Database for Café App

#### Login to MariaDB:

```
sudo mysql
```

##### If root password is required:

```
sudo mysql -u root -p
```

#### Verify Database Exists

```
SHOW DATABASES;
```

##### ✅ Check if you see:

```
cafedevdatabase
```

#### Create MySQL Database

##### Run:

```
CREATE DATABASE cafe_db;
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
FLUSH PRIVILEGES;
```


#### Verify User Exists

```
SELECT user, host FROM mysql.user WHERE user='cafe_user';
```

##### Expected output:

```
cafe_user | %
```

#### Confirm Privileges

```
SHOW GRANTS FOR 'cafe_user'@'%';
```

##### You MUST see something like:

```
GRANT ALL PRIVILEGES ON `cafedevdatabase`.* TO 'cafe_user'@'%'
```

#### Exit MySQL

```
EXIT;
```

#### Test Table Access

```
SHOW TABLES;
```

#### Create test table:

```
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100),
  item VARCHAR(100),
  quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Insert test data:

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('TestUser', 'Coffee', 1);
```

#### Verify Table & Table's Data:

```
SELECT * FROM orders;
```


#### Configure MariaDB to Allow Remote Connections (Optional)

##### Edit:

```
sudo nano /etc/my.cnf.d/mariadb-server.cnf
```

##### Find bind-address and set:

```
bind-address = 0.0.0.0
```

#### Restart MariaDB:

```
sudo systemctl restart mariadb
```

#### Configure EC2 Security Group

- **Go to EC2 Console → Security Groups → Inbound rules**

- **Add rule:**

   - **Type: MySQL/Aurora**

   - **Port: 3306**

   - **Source: your IP (or anywhere 0.0.0.0/0 for lab/testing)**

#### Test Connection

##### From EC2 itself:

```
mysql -u cafe_user -p -h 127.0.0.1 cafedevdatabase
```

##### From another machine (if remote enabled):

```
mysql -u cafe_user -p -h <EC2-Public-IP> cafedevdatabase
```


---

## ✅ Final Notes

✔ Designed for **AWS EC2 + Amazon Linux 2023**
✔ Covers **real interview + job tasks**
✔ Perfect for **Cloud, SysAdmin, DevOps beginners**

---

If you want next:

* 🔹 **DevOps-focused Linux guide**
* 🔹 **Linux commands mapped to AWS interviews**
* 🔹 **Downloadable `.md` or `.pdf`**

Just tell me 👍



