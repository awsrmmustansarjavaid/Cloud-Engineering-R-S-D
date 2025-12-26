# 🚀 AWS Challenge Lab: Build a Dynamic Café Website (Dev + Prod)

**Objective:**  
Transform a simple café website into a fully functional dynamic online ordering system deployed across two AWS Regions.

---

## AWS Architecture Diagram 

![AWS Architecture Diagram](./AWS%20Challenge%20Lab%20Build%20a%20Dynamic%20Café%20Website%20Dev%20%20Prod.jpg)

## Prerequisites

- AWS account with full EC2, VPC, RDS, IAM, and Secrets Manager access  
- Basic understanding of Linux commands  
- Installed VS Code with AWS Cloud9 or local SSH setup  
- Knowledge of MySQL, PHP, and Apache  

---

## 1️⃣ Create the Development Environment (us-east-1)

### Step 1: Launch a VPC & Networking
1. Go to **VPC Console → Create VPC**  
   - Name: `CafeDevVPC`  
   - CIDR block: `10.0.0.0/16`  
2. Create a **public subnet**  
   - Name: `CafeDevPublicSubnet`  
   - CIDR: `10.0.1.0/24`  
   - Map public IP: Enabled  
3. Create **Internet Gateway → Attach to CafeDevVPC**  
4. Create **Route Table → Associate with public subnet**  
   - Route: `0.0.0.0/0 → Internet Gateway`  

---

### Step 2: Launch EC2 Instance (LAMP Stack)
1. Go to **EC2 Console → Launch Instance**  
2. Select **Amazon Linux 2023 AMI**  
3. Instance type: `t2.micro` (free tier if eligible)  
4. Configure network:  
   - VPC: `CafeDevVPC`  
   - Subnet: `CafeDevPublicSubnet`  
5. Storage: default 8 GB  
6. Tags: `Name = CafeDevWebServer`  
7. Security Group:  
   - Allow SSH (22) from your IP  
   - Allow HTTP (80) from anywhere  
8. Launch → Download key pair `.pem`  

---

### Step 3: Connect to EC2
```bash
chmod 400 CafeDevKey.pem
ssh -i "CafeDevKey.pem" ec2-user@<Public-IP>
```

### Step 4: ✅ LAMP Stack Installation on Amazon Linux 2023

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

#### Recommended Answers

```
Enter current password for root:  (Press Enter)
Set root password?               Y
Remove anonymous users?          Y
Disallow root login remotely?    Y
Remove test database?            Y
Reload privilege tables?         Y
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

##### Install MySQL Client (Optional but Recommended)

```
sudo dnf install -y mariadb105
```


##### Verify Full LAMP Stack

```
httpd -v
php -v
mysql --version
```

### Step 6: Create MySQL Database for Café App

```
CREATE DATABASE cafe_db;
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
FLUSH PRIVILEGES;
```

### Step 7: Store Database Credentials in AWS Secrets Manager

1. Go to Secrets Manager → Store a new secret

2. Type: Other type of secret → Key/Value

```
username: cafe_user
password: StrongPassword123
host: <EC2-Private-IP>
dbname: cafe_db
```

3. Name: CafeDevDBSecret

4. Retrieve Secret ARN for later use in the app

### Step 8: Deploy Café Web Application

1. Upload app files to /var/www/html via SFTP or Git

2. Update config.php to read Secrets Manager:

```
require 'vendor/autoload.php';
use Aws\SecretsManager\SecretsManagerClient;

$client = new SecretsManagerClient([
    'version' => 'latest',
    'region' => 'us-east-1'
]);

$result = $client->getSecretValue([
    'SecretId' => 'CafeDevDBSecret',
]);
$secret = json_decode($result['SecretString'], true);
$db = new mysqli($secret['host'], $secret['username'], $secret['password'], $secret['dbname']);
```

3. Set permissions and restart Apache:

```
sudo chown -R apache:apache /var/www/html
sudo systemctl restart httpd
```

### Step 9: Test the Application

- Access http://<EC2-Public-IP>

- Place orders → Ensure database updates

- Debug PHP/Apache logs: /var/log/httpd/error_log

### Step 🔟 Create Custom AMI

- Go to EC2 Console → Instances → Actions → Create Image

- Name: CafeDevWebAMI

- Wait for AMI creation → This AMI will be used for production deployment

## 2️⃣ Production Environment (us-west-2)

### Step 1: Create VPC & Subnet (same as Dev)

- VPC: CafeProdVPC

- Subnet: CafeProdPublicSubnet

- Internet Gateway & Route Table → configure same as Dev

### Step 2: Launch EC2 from Custom AMI

1. Go to AMIs → Select CafeDevWebAMI → Launch

2. Configure:

    - VPC: CafeProdVPC

    - Subnet: CafeProdPublicSubnet

    - Security Group: allow HTTP/SSH

3. Launch instance

### Step 3: Test Production Site

- Access http://<Prod-EC2-Public-IP>

- Ensure all features work (orders, database, web pages)

- Compare with Dev site

## 3️⃣ Verification & Testing

### ✅ Development

- EC2 running

- Apache serving PHP pages

- MySQL database connection successful

- Secrets Manager credentials working

- Orders can be placed & retrieved

### ✅ Production

- EC2 launched from AMI

- Application functions correctly

- Dev → Prod parity verified

## 4️⃣ Common Issues & Solutions

```
| Issue                     | Solution                                                            |
| ------------------------- | ------------------------------------------------------------------- |
| EC2 not reachable         | Check security group and subnet route table                         |
| PHP page not loading      | Ensure Apache is running and correct permissions on `/var/www/html` |
| Database connection fails | Verify Secrets Manager ARN and MySQL user privileges                |
| Orders not saving         | Check MySQL database & credentials, enable remote access if needed  |
| 403 Forbidden             | Ensure `chown -R apache:apache /var/www/html`                       |
```


# ☑️ AWS Café Website Lab: Test & Verification

**Objective:** Ensure the dynamic café website deployed on AWS is fully functional in both Development (us-east-1) and Production (us-west-2) environments.

---

## 1️⃣ Development Environment (us-east-1)

### EC2 & LAMP Stack Verification

* Navigate to **EC2 Console → Instances**
* Ensure `CafeDevWebServer` is running
* Check Public IPv4 is assigned
* Verify Apache is running:

```bash
sudo systemctl status httpd
```

* Verify PHP is working:

```bash
php -v
```

### Database Verification

* Connect to MariaDB:

```bash
mysql -u cafe_user -p -h <EC2-Private-IP> cafe_db
```

* Ensure database contains tables required by the café app
* Test inserting and retrieving a sample record:

```sql
INSERT INTO orders (customer_name, item, quantity) VALUES ('Test', 'Coffee', 1);
SELECT * FROM orders;
```

### Secrets Manager Verification

* Navigate to **Secrets Manager → CafeDevDBSecret**
* Ensure secret contains:

```
username: cafe_user
password: <your_password>
host: <EC2-Private-IP>
dbname: cafe_db
```

* Test app can retrieve secret and connect to DB using PHP script

### Web Application Verification

* Open browser → `http://<Dev-EC2-Public-IP>`
* Verify website loads correctly
* Place a test order → Ensure it is recorded in the database
* Check Apache logs for errors:

```bash
sudo tail -f /var/log/httpd/error_log
```

### Security Verification

* Security group allows HTTP/SSH traffic
* MySQL root access is restricted
* Secrets are not hardcoded in web app

---

## 2️⃣ Production Environment (us-west-2)

### EC2 Instance Verification

* Navigate to **EC2 Console → Instances**
* Ensure `ProdWebServer` launched from `CafeDevWebAMI` is running
* Check Public IPv4 is assigned
* Verify Apache and PHP:

```bash
sudo systemctl status httpd
php -v
```

### Application Verification

* Open browser → `http://<Prod-EC2-Public-IP>`
* Test all website pages load correctly
* Place a test order → Verify order appears in the database
* Ensure session persistence and app functionality match development environment

### Multi-Region Verification

* Dev site accessible: `http://<Dev-EC2-IP>`
* Prod site accessible: `http://<Prod-EC2-IP>`
* Check that custom AMI deployment works (Prod instance mirrors Dev app)

---

## 3️⃣ Common Bugs & Solutions

| Issue                       | Solution                                                                      |
| --------------------------- | ----------------------------------------------------------------------------- |
| EC2 not reachable           | Verify security group inbound rules & subnet routing                          |
| PHP page blank              | Ensure `index.php` exists, Apache running, correct permissions                |
| Database connection fails   | Verify secret ARN, DB credentials, and MySQL user privileges                  |
| Orders not saving           | Ensure DB connection string is correct and user has INSERT privileges         |
| 403 Forbidden               | Check `/var/www/html` ownership: `sudo chown -R apache:apache /var/www/html`  |
| Secrets Manager not working | Check IAM role attached to EC2 has `secretsmanager:GetSecretValue` permission |

---

## 4️⃣ Final Verification Checklist

* [ ] Development EC2 running & Apache/PHP working
* [ ] MySQL database operational & connected via Secrets Manager
* [ ] Website fully functional in Dev
* [ ] Custom AMI created successfully
* [ ] Production EC2 launched from AMI
* [ ] Production site fully functional
* [ ] Multi-region deployment verified

✅ **Result:** Once all checks pass, the café website is fully deployed and verified in both Dev and Prod environments.





