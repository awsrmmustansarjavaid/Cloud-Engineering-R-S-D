# ☕ AWS Café Lab - Build a Dynamic Café Website (Dev + Prod)

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

### Step 4: Deploy Café Web Application


#### ✅ index.php (Static Café Website – Lab Ready)

#### 📂 Where to Save This File on EC2

```
sudo nano /var/www/html/index.php
```

##### 👉 Copy & paste exactly as it is

- Paste the code → Save → Exit

```
<?php
require 'config.php';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #333;
        }

        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }

        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }

        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }

        button:hover {
            background-color: #219150;
        }

        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label for="name">Customer Name</label>
        <input type="text" id="name" name="name" placeholder="Enter your name" required>

        <label for="item">Select Item</label>
        <select id="item" name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label for="quantity">Quantity</label>
        <input type="number" id="quantity" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Prepare and execute statement safely
        $stmt = $db->prepare("INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)");
        $stmt->bind_param("ssi", $_POST['name'], $_POST['item'], $_POST['quantity']);
        $stmt->execute();
        echo "<p>✅ Order placed successfully!</p>";
    }
    ?>
</div>

<footer>
    <p>© 2025 AWS Café | Built on Amazon EC2 (LAMP Stack)</p>
</footer>

</body>
</html>
```

### 🔁 Create config.php (Secrets Manager + MariaDB)

#### 📂 Where to Save This File on EC2

```
sudo nano /var/www/html/config.php
```

```
<?php
require __DIR__ . '/vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

$region = "us-east-1";   // change for prod if needed
$secretName = "CafeDevDBSecret";

try {
    $client = new SecretsManagerClient([
        'version' => 'latest',
        'region'  => $region
    ]);

    $result = $client->getSecretValue([
        'SecretId' => $secretName
    ]);

    $secret = json_decode($result['SecretString'], true);

    $db = new mysqli(
        $secret['host'],
        $secret['username'],
        $secret['password'],
        $secret['dbname']
    );

    if ($db->connect_error) {
        die("Database connection failed: " . $db->connect_error);
    }

} catch (AwsException $e) {
    die("Secrets Manager error: " . $e->getMessage());
}
?>
```

### Step 5: ✅ LAMP Stack Installation on Amazon Linux 2023

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

### Step 6: 🔁 Install AWS SDK for PHP properly (BEST PRACTICE)

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


### Step 7: ✅ install and configure MariaDB Server on Amazon Linux 2023

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

#### Verify mysql

```
mysql --version
```

##### Install MySQL Client (Optional but Recommended)

```
sudo dnf install -y mariadb105
```

### Step 6: Create MySQL Database for Café App

#### Login to MariaDB:

```
sudo mysql -u root -p
```

#### Create MySQL Database

##### Run:

```
CREATE DATABASE cafe_db;
```

```
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
```

```
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
```

```
FLUSH PRIVILEGES;
```

#### Verify 

```
mysql -u cafe_user -p cafe_db
```

#### Use the correct database

```
USE cafe_db;
```

#### Create the orders table (REQUIRED)

##### Run this exact SQL:

```
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    item VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

#### Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```

#### Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
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
mysql -u cafe_user -p -h 127.0.0.1 cafe_db
```

##### From another machine (if remote enabled):

```
mysql -u cafe_user -p -h <EC2-Public-IP> cafedevdatabase
```

#### Connect from PHP App

##### Your PHP config.php will use these credentials:

```
$db = new mysqli(
    '<EC2-Private-IP-or-127.0.0.1>',
    'cafe_user',
    'YourStrongPassword',
    'cafedevdatabase'
);
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

---

### Step 8: 🔐 Create IAM Role for EC2 (Secrets Manager Access)

#### 🎯 Goal: Allow your EC2 instance to call

```
secretsmanager:GetSecretValue
```

#### for:

```
CafeDevDBSecret
```

### 🟢 PART 1: Create IAM Role (AWS Console)

#### Step 1: Open IAM Console

- Go to AWS Console

- Search IAM

- Click Roles

- Click Create role

#### Step 2: Select Trusted Entity

- Trusted entity type → AWS service

- Use case → EC2

- Click Next

##### ✅ This step allows EC2 to assume the role

#### Step 3: Create Custom Permission Policy

- Click Create policy (opens new tab)

- Choose: JSON tab

- Paste this exact policy (replace region if needed):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
    }
  ]
}
```

- Click Next

#### Step 4: Name the Policy

- Policy name:

```
CafeSecretsManagerAccess
```

##### Description (optional):

```
Allow EC2 to read Cafe DB secrets
```

- Click Create policy

##### ✅ Policy created successfully

#### Step 5: Attach Policy to Role

- Go back to the Create role tab.

- Click Refresh

- Search policy:

```
CafeSecretsManagerAccess
```

- Select it

- Click Next

#### Step 6: Name the IAM Role

- Role name:

```
EC2-Cafe-Secrets-Role
```

- Description:

```
IAM role for Cafe EC2 to access Secrets Manager
```

- Click Create role

##### ✅ IAM Role is now ready

### 🟢 PART 2: Attach IAM Role to EC2 Instance

#### Step 7: Attach Role to Running EC2

- Open EC2 Console

- Go to Instances

- Select your instance

```
CafeDevWebServer
```

- Click Actions

- Security

- Modify IAM role

#### Step 8: Select IAM Role

- Choose:

```
EC2-Cafe-Secrets-Role
```

- Click Update IAM role

##### ✅ Role attached instantly (NO reboot required)

### 🟢 PART 3: Verify from EC2 (VERY IMPORTANT)

#### Step 9: Verify IAM Role is Attached

##### Run this on EC2:

```
curl http://169.254.169.254/latest/meta-data/iam/info
```

###### ✅ If role is attached, you will see JSON output.

#### Step 10: Test Secrets Manager Access from EC2

##### Install AWS CLI if not present:

```
sudo dnf install -y awscli
```

##### Run:

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSecret \
  --region us-east-1
```

##### ✅ If secret value is returned → IAM role works

For example !

```
{
    "ARN": "arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSecret-OgLDg9",
    "Name": "CafeDevDBSecret",
    "VersionId": "bbdf3ecb-5d93-46ae-8049-5e4d4164fc10",
    "SecretString": "{\"username\":\"cafe_user\",\"password\":\"StrongPassword123\",\"host\":\"10.0.0.130\",\"dbname\":\"cafe_db\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2025-12-27T10:25:34.199000+00:00"
}
```

##### ❌ If AccessDenied → policy or role is wrong

#### 🧠 Common Mistakes (READ THIS)

```
| Mistake                  | Result             |
| ------------------------ | ------------------ |
| Role not attached        | PHP fails silently |
| Wrong region             | Secret not found   |
| Using IAM User keys      | ❌ Bad practice     |
| Hardcoding credentials   | ❌ Security risk    |
| Missing `GetSecretValue` | AccessDenied       |
```

#### ✅ FINAL CHECKLIST

✔ IAM role created

✔ Policy attached

✔ Role attached to EC2

✔ Secret accessible via AWS CLI

✔ PHP app can read Secrets Manager

#### 🏁 Final Architecture

```
EC2
 └── IAM Role
      └── SecretsManager:GetSecretValue
           └── CafeDevDBSecret
```

---

### Step 9: Test the Application

- Access http://<EC2-Public-IP>

- Place orders → Ensure database updates

- Debug PHP/Apache logs: /var/log/httpd/error_log

### Step 10 Create Custom AMI

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

























