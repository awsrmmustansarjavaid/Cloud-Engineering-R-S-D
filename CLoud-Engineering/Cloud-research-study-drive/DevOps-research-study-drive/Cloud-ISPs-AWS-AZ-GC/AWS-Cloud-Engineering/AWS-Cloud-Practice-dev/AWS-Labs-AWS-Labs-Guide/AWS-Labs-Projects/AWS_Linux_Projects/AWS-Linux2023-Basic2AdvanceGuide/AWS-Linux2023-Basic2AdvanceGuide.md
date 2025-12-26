# AWS Linux 2023 Basic to Advance CLI Guide 

> **Author & Architecture Designer:** Charlie 



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