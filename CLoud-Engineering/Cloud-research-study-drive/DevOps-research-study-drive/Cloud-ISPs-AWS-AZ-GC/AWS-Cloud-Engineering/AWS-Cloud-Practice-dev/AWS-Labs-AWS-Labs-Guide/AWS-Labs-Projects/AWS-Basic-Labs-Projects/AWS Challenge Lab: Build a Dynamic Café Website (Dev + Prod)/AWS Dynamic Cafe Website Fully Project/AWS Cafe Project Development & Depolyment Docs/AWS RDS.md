# AWS RDS

## 1️⃣ Create DB Subnet Group
AWS Console → RDS → Subnet groups → Create
- Name: CafeRDSSubnetGroup
- VPC: CafeDevVPC
- Subnets: **PRIVATE subnets (2 AZs)**

Create

## 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create
- Name: CafeRDS-SG
- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

Create

## 3️⃣ Create RDS Instance
RDS → Databases → Create database
- Engine: MySQL (or MariaDB)
- Template: Free tier
- DB identifier: cafedb
- Username: cafe_user
- Password: StrongPassword123
- VPC: CafeDevVPC
- Subnet group: CafeRDSSubnetGroup
- Public access: ❌ No
- Security group: CafeRDS-SG
- Backup: Enabled

Create database ⏳

## 4️⃣ Create Schema in RDS
Connect from EC2:

## 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

### Verify mysql

```
mysql --version
```

### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```
---

## 2️⃣ Create Café Database

```sql
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

## 3️⃣ Use the correct database

```
USE cafe_db;
```

## 4️⃣ Orders Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

## 6️⃣ Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```

## 7️⃣ Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
```