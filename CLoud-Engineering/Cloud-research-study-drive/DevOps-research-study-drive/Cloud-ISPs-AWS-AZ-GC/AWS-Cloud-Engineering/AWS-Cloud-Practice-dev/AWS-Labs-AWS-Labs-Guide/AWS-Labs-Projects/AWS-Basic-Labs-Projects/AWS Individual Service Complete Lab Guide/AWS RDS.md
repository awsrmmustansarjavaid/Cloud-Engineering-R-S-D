# AWS RDS/ Aurora Lab Complete Guide 

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)

## 💻 Section 1 - Install and Configure AWS RDS/ Aurora on EC2

### 1.1 Install and Configure MariaDB (MySQL) Server and Client

```
sudo dnf install mariadb105-server mariadb105 -y
```

**🎙️ Explanation:**

>This command uses the DNF package manager (common on modern Linux distributions like Fedora/RHEL/CentOS) to install the MariaDB server (the database engine) and the client utility (to interact with the server). The -y flag automatically confirms the installation.

### 1.2 Start the MariaDB Service

```
sudo systemctl start mariadb
```
**🎙️ Explanation:**

>This command uses systemctl to initiate and run the installed MariaDB database service in the background, making it ready to accept connections.

### 1.3 Configure MariaDB to Start on Boot

```
sudo systemctl enable mariadb
```

**🎙️ Explanation:**

>This command ensures that the MariaDB service will automatically start every time the system is rebooted, making the database persistent and available.

### 1.4 Verify MariaDB/MySQL Client Version

```
mysql --version
```

**🎙️ Explanation:**

> This command executes the mysql client utility and prints its version number to confirm that the client software has been correctly installed and is accessible from the command line.

### 1.5 Secure the Local MariaDB Installation

#### Run secure installation:

```
sudo mysql_secure_installation
```

**🎙️ Explanation:**

> This is a critical script that runs a series of prompts to harden the default installation of MariaDB/MySQL. It prompts for security settings like setting the root password, removing anonymous users, and disabling remote root logins.

#### Use the following answers:

```
| Prompt                 | Answer                    |
| ---------------------- | ------------------------- |
| Switch to unix_socket  | n                         |
| Set root password      | y → Enter strong password |
| Remove anonymous       | y                         |
| Disallow remote root   | y                         |
| Remove test DB         | y                         |
| Reload privilege table | y                         |
```

### 1.6 Connect to the AWS RDS/Aurora Instance

```
mysql -h <RDS-ENDPOINT> -u <username> -p
```

**🎙️ Explanation:**

> This command uses the MySQL client to connect to the remote AWS RDS/Aurora database instance. The -h specifies the database endpoint (hostname), -u specifies the user, and -p prompts for the user's password.


### 1.7 Create a New Database

```
CREATE DATABASE <databasename>;
```

#### 💡 Example;

```
CREATE DATABASE wordpress;
```

**🎙️ Explanation:**

> This SQL command creates a new, empty database named wordpress on the connected server. Applications like WordPress will store all their data within this database.


### 1.8 Create a Dedicated Database User

```
CREATE USER '<username>'@'%' IDENTIFIED BY '<userpassword>';
```

#### 💡 Example;

```
CREATE USER 'wordpressuser'@'%' IDENTIFIED BY 'StrongPassword123!';
```

**🎙️ Explanation:**

> This SQL command creates a new user named wordpressuser. The '@'% indicates that this user can connect from any host. It assigns the specified strong password to the user.


### 1.9 Grant User Permissions on the Database

```
GRANT ALL PRIVILEGES ON <databasename>.* TO '<username>'@'%';
```

#### 💡 Example;

```
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'%';
```

**🎙️ Explanation:**

> This crucial SQL command grants the wordpressuser all permissions (ALL PRIVILEGES) on all tables (*) within the wordpress database. This gives the application user full read/write access to its designated database.


### 1.10 Apply New Security and Permission Changes

```
FLUSH PRIVILEGES;
```

**🎙️ Explanation:**

> This command instructs the database server to reload the grant tables immediately. This makes the new user and permission changes (from step 1.8 and 1.9) active without needing to restart the database server.


### 1.11 Select and Use the Target Database

```
USE <databasename>;
```

#### 💡 Example;

```
USE wordpress;
```

**🎙️ Explanation:**

> This SQL command sets the active database context to wordpress. All subsequent SQL commands (like CREATE TABLE or INSERT) will be executed against this specific database until a different one is selected or the connection is closed.


### 1.12 Create a Sample Table (Products)

```
CREATE TABLE actual_table_name (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  price DECIMAL(10,2),
  description TEXT
);
```

#### 💡 Example;

```
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  price DECIMAL(10,2),
  description TEXT
);
```

**🎙️ Explanation:**

> This SQL command creates a new table named products within the active database. It defines the structure with four columns: an auto-incrementing ID, product name, price (with decimal places), and a text description.


### 1.12 Insert Sample Data into Table:

```
INSERT INTO <table_name> (column1, column2, column3) VALUES
  (value1_row1, value2_row1, value3_row1),
  (value1_row2, value2_row2, value3_row2);
```

#### 💡 Example;

```
INSERT INTO products (name, price, description) VALUES
 ('Laptop', 1200.00, 'Good laptop'),
 ('Phone', 800.00, 'Smartphone');

INSERT INTO products (name, price, description) VALUES
 ('PC', 30000, 'Good PC'),
 ('Samsung', 8000.00, 'Smartphone');

INSERT INTO products (name, price, description) VALUES
 ('Gaming PC', 6000.00, 'Good Gaming PC'),
 ('IPhone', 8700.00, 'Smartphone');

INSERT INTO products (name, price, description) VALUES
 ('Smart LED', 5400.00, 'A1 LED'),
 ('LCD', 700.00, 'LCD');

INSERT INTO products (name, price, description) VALUES
 ('Mouse', 600, 'Branded Mouse'),
 ('Headpne', 8700, 'Headphone');
 ```

 **🎙️ Explanation:**

> These SQL commands add new rows of data into the products table. Each INSERT INTO statement specifies the columns to populate and the corresponding values for two product entries.


### 1.13 List Tables in the Current Database:

 ```
 SHOW TABLES;
 ```

 **🎙️ Explanation:**

> This command displays a list of all tables that exist within the currently selected database (wordpress), allowing you to confirm the successful creation of the products table.


 ### 1.14 Retrieve and Display All Table Data:

 ```
SELECT * FROM products;
```

#### 💡 Example;

 ```
 SELECT * FROM <table_name>;
 ```

 **🎙️ Explanation:**

> This is a fundamental SQL command that retrieves and displays all columns (*) and all rows of data from the products table. This confirms that the data insertion was successful.


 ### 1.15 Disconnect from the Database Server:

```
exit
```

**🎙️ Explanation:**

> This command terminates the current session with the MySQL client, disconnecting you from the AWS RDS/Aurora database server and returning control to your operating system's command prompt.


---

## 💻 Section 2️⃣ - Charlie Cafe RDS 

### 2️⃣ — Basic RDS CONFIGURATIONS

## Method 1 - ☕ AWS Café — RDS MySQL Setup Bash Script

### 📄 File name (recommended)

```
sudo nano setup_cafe_rds.sh
```

### ✅ FULL BASH SCRIPT (100% COMPLETE)

```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS First-Time Setup..."

# ================= CONFIG =================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"   # ← CHANGE TO YOUR REAL SECRET ARN

DB_NAME="cafe_db"   # Hard-coded for your new cafe setup

# ================= INSTALL REQUIRED PACKAGES =================
echo "📦 Installing MariaDB client & jq if missing..."
sudo dnf install -y mariadb105 jq

# AWS CLI v2 is pre-installed on Amazon Linux 2023 – verify it
if ! command -v aws >/dev/null 2>&1; then
    echo "⚠️ AWS CLI not found (unusual on AL2023) – installing official v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --update
    rm -rf aws awscliv2.zip
fi

aws --version || { echo "❌ AWS CLI failed to run – check installation"; exit 1; }
mysql --version
echo ""

# ================= FETCH SECRET FROM SECRETS MANAGER =================
echo "🔐 Fetching RDS credentials from Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ ERROR: Missing required fields in secret (host/username/password)"
    exit 1
fi

echo "✅ Secret loaded"
echo "🔗 RDS Endpoint: $DB_HOST"
echo "   Port:       $DB_PORT"
echo "👤 DB User:     $DB_USER"
echo "🗄 Database:     $DB_NAME (creating if not exists)"
echo ""

# ================= CREATE TEMP CREDENTIALS FILE =================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# ================= TEST CONNECTION =================
echo "🔌 Testing RDS connection..."
if ! mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ Connection failed. Check:"
    echo "   • Security Group allows 3306 from this EC2"
    echo "   • RDS is in same VPC/subnet or properly peered"
    echo "   • Credentials & endpoint in secret are correct"
    exit 1
fi
echo "✅ Connection OK"
echo ""

# ================= CREATE DATABASE =================
echo "🗄 Creating database '$DB_NAME'..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo ""

# ================= CREATE ORDERS TABLE =================
echo "📋 Creating orders table..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    table_number  INT NOT NULL,
    customer_name VARCHAR(100),
    item          VARCHAR(100),
    quantity      INT NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at   (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF
echo ""

# ================= VERIFY =================
echo "🔍 Verifying setup..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
    SHOW TABLES;
    SELECT 'Cafe database ready' AS message;
"
echo ""

echo "✅ Cafe RDS setup completed successfully ☕"
echo "Next steps:"
echo "  - Use database: $DB_NAME"
echo "  - Endpoint:    $DB_HOST"
echo "  - User:        $DB_USER"
```

#### ⚠️ Important Configuration Values NOTE (Before Running This Cafe RDS Setup Script)

> **You MUST replace the placeholder values below with your own AWS RDS credentials before executing this script.**

#### 🔧 Required Changes

> **Update the following variables in the script according to your AWS environment:**

#### AWS Region:

```bash
AWS_REGION="us-east-1"
```
- **Current value:** us-east-1

- **Action:** Replace with your actual AWS region

**👉 Replace with your actual AWS Region**

**Examples: eu-west-1, ap-south-1, us-west-2, sa-east-1**

- **Why:** Secrets Manager and RDS are region-specific

#### Secrets Manager ARN:

```
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"
```

- **Current value:** arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV

- **Action:** Replace with the real ARN of your target secret
- **How to find it:**
    - AWS Console → Secrets Manager → select your secret → copy the ARN

    - Must match the secret that contains host, username, password

- **Most critical value – wrong ARN = script cannot get credentials**


#### Database Name:

```
DB_NAME="cafe_db"
```

- **Current value:** cafe_db

- **Action:** Usually keep as-is for this project

- **When to change:**

    - Different environments: cafe_dev, cafe_staging, cafe_prod

    - Company naming convention: app_cafe_2026, cafe_v1

- **Note:** Script uses CREATE DATABASE IF NOT EXISTS → safe to re-run

### 🔐 HOW TO USE THIS SCRIPT

#### 1️⃣ Make it executable

```
sudo chmod +x setup_cafe_rds.sh
```

#### 2️⃣ Run the script

```
sudo ./setup_cafe_rds.sh
```

**You’ll be prompted once for the admin RDS password (master user).**

### ✅ FINAL SUCCESS CHECKLIST

#### If everything is correct, you will see:

✅ MySQL client installed

✅ cafe_db created

✅ cafe_user created

✅ orders table exists

✅ Test rows displayed via SELECT * FROM orders;

---

## Method 2 - ☕ AWS Café — RDS MySQL Setup 1-To-1

### 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

#### Verify mysql

```
mysql --version
```

#### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```
---

### 2️⃣ Create Café Database

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

### 3️⃣ Use the correct database

```
USE cafe_db;
```

### 4️⃣ Orders Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 📢 Recommended Final CREATE TABLE with table_number

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,                    -- ← Added: table number (1, 2, 3, ...)
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),           -- optional: faster queries by table
    INDEX idx_created_at (created_at)                -- optional: good for time-based reports
);
```

#### ✅ FINAL orders TABLE with table_number (WITH CLEAR COMMENTS)

```
CREATE TABLE orders (

    -- Primary unique identifier for each order
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Cafe table number where customer is seated (1, 2, 3, ...)
    table_number INT NOT NULL,

    -- Optional customer name (can be NULL for walk-in customers)
    customer_name VARCHAR(100),

    -- Ordered item name (must match CafeMenu.item_name)
    item VARCHAR(50),

    -- Quantity of the ordered item
    quantity INT NOT NULL,

    -- Date & time when order was created (auto-filled by MySQL)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Index to speed up queries by table number (useful for waiter dashboards)
    INDEX idx_table_number (table_number),

    -- Index to speed up date-based queries (daily, weekly, monthly reports)
    INDEX idx_created_at (created_at)

);
```

#### 📢 Most common real-world version

#### Many cafes/restaurants also like to track status and total amount, so here’s a more complete modern version you might consider:


```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100) DEFAULT NULL,       -- optional, sometimes anonymous orders
    item            VARCHAR(100) NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(10,2) NOT NULL,          -- important for billing
    total_amount    DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    status          ENUM('pending', 'preparing', 'served', 'cancelled') DEFAULT 'pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

#### ☕ orders TABLE — FULLY COMMENTED (PRODUCTION-READY)

```
CREATE TABLE orders (

    -- Unique ID for each order (auto increases)
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Cafe table number (e.g., table 1, table 5)
    table_number INT NOT NULL,

    -- Customer name (optional: walk-in or anonymous allowed)
    customer_name VARCHAR(100) DEFAULT NULL,

    -- Item name ordered (must match CafeMenu.item_name)
    item VARCHAR(100) NOT NULL,

    -- Quantity of the item ordered
    quantity INT NOT NULL DEFAULT 1,

    -- Selling price per single item (charged to customer)
    unit_price DECIMAL(10,2) NOT NULL,

    -- Auto-calculated total amount = quantity × unit_price
    -- STORED means value is physically saved (faster reports)
    total_amount DECIMAL(10,2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,

    -- Order status used by kitchen + order-status dashboard
    status ENUM('pending', 'preparing', 'served', 'cancelled')
        DEFAULT 'pending',

    -- Time when order was created
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Time when order was last updated (status change, etc.)
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Index for quickly finding orders by table number
    INDEX idx_table_number (table_number),

    -- Index for fast filtering by order status
    INDEX idx_status (status),

    -- Index for analytics & reports by date/time
    INDEX idx_created_at (created_at)

);
```

#### 📢 Remove (Delete) the Table

#### Option A: Normal delete (most common)

```
DROP TABLE orders;
```

#### Option B: Delete only if it exists (safer - no error if table doesn't exist)

```
DROP TABLE IF EXISTS orders;
```

#### Option C: Very aggressive - delete even if there are foreign keys pointing to it (usually not recommended unless you really know what you're doing)

```
SET FOREIGN_KEY_CHECKS = 0;
```

```
DROP TABLE orders;
```

```
SET FOREIGN_KEY_CHECKS = 1;
```

####  Also fine - mixed style

```
SET FOREIGN_KEY_CHECKS = 0;
```

```
DROP TABLE IF EXISTS orders;
```

```
SET FOREIGN_KEY_CHECKS = 1;
```

#### 📢 Modify Existing Table (ALTER TABLE)

#### A. Add new column

```
ALTER TABLE orders
    ADD COLUMN table_number INT NOT NULL AFTER id;
```

#### B. Add column with default value

```
ALTER TABLE orders
    ADD COLUMN status ENUM('pending','preparing','served','cancelled') 
    DEFAULT 'pending' AFTER quantity;
```

#### C. Change column type (example: make customer_name longer)

```
ALTER TABLE orders
    MODIFY COLUMN customer_name VARCHAR(150) NOT NULL;
```

#### D. Rename column

```
ALTER TABLE orders
    CHANGE COLUMN item product_name VARCHAR(100);
```

#### E. Drop (remove) column you no longer need

```
ALTER TABLE orders
    DROP COLUMN customer_name;
```

#### F. Add index (very important for performance)

```
ALTER TABLE orders
    ADD INDEX idx_table_number (table_number);
```

#### G. Add auto-increment if you forgot it (very rare case)

```
ALTER TABLE orders
    MODIFY id INT AUTO_INCREMENT PRIMARY KEY;
```

#### H. Change default value for existing column

```
ALTER TABLE orders
    ALTER COLUMN quantity SET DEFAULT 1;
```

### 5️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

### 6️⃣ Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```
#### 📢 Multi Values (with table_number)


```
-- For your first (simpler) table
INSERT INTO orders (table_number, customer_name, item, quantity) 
VALUES 
    (1, 'Ali Khan', 'Espresso', 2),
    (1, 'Sara Ahmed', 'Cappuccino', 1),
    (2, 'CLI-Test', 'Coffee', 1),
    (3, NULL, 'Latte', 3),
    (5, 'Ahmed Raza', 'Croissant + Tea', 1);
``` 

#### Most common quick test inserts (good for development):

```
-- Quick test inserts - very useful for checking
INSERT INTO orders (table_number, customer_name, item, quantity) VALUES
    (1, 'Test User', 'Black Coffee', 1),
    (2, NULL, 'Green Tea', 2),
    (4, 'CLI-Test', 'Coffee', 1);
```

#### 📢 Complete/Production Version (table NUMBER – with price, status, total_amount)

```
-- For your second (more complete) table
INSERT INTO orders (
    table_number, 
    customer_name, 
    item, 
    quantity, 
    unit_price, 
    status
) VALUES 
    (1, 'Ali Khan', 'Espresso', 2, 450.00, 'served'),
    (1, 'Sara Ahmed', 'Cappuccino', 1, 520.00, 'preparing'),
    (2, 'CLI-Test', 'Coffee', 1, 300.00, 'pending'),
    (3, NULL, 'Latte + Croissant', 1, 780.00, 'pending'),
    (5, 'Ahmed Raza', 'Caramel Macchiato', 2, 650.00, 'served'),
    (4, 'Fatima Noor', 'Iced Americano', 3, 400.00, 'cancelled');
```

#### Quick development/test version (minimal required fields):

```
-- Minimal insert for testing (uses defaults for the rest)
INSERT INTO orders (table_number, item, quantity, unit_price) VALUES
    (1, 'Black Coffee', 1, 300.00),
    (2, 'Green Tea', 2, 250.00),
    (4, 'CLI-Test Coffee', 1, 300.00);
```

### 7️⃣ Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
```

### 📢 Quick Reference Table - What do you want to do?

| Action                              | Command Example                                   | Risk   |
|-------------------------------------|---------------------------------------------------|--------|
| Delete table (force)                | `DROP TABLE orders;`                              | High   |
| Delete table (safe)                 | `DROP TABLE IF EXISTS orders;`                    | Low    |
| Add new column                      | `ALTER TABLE orders ADD COLUMN table_number INT;` | Low    |
| Change column type/size             | `ALTER TABLE orders MODIFY COLUMN name VARCHAR(200);` | Medium |
| Rename column                       | `ALTER TABLE orders CHANGE COLUMN old_name new_name VARCHAR(100);` | Low    |
| Delete column                       | `ALTER TABLE orders DROP COLUMN customer_name;`   | Medium |
| Add index                           | `ALTER TABLE orders ADD INDEX idx_table (table_number);` | Low    |
| Set/change default value            | `ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'pending';` | Low    |


##  PHASE 1️⃣ — RDS DATABASE

### 1️⃣ ADD DATE & TIME TO RDS (NO SKIP)

#### 1️⃣ Connect to RDS

#### From EC2 or local MySQL client:

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

#### You should see:

```
mysql>
```
#### 2️⃣ Check current table

```
DESCRIBE orders;
```

#### ❗ Look carefully

- If you do NOT see created_at → continue
- If you already see it → skip to Step 2



#### 3️⃣ Add created_at column

```
ALTER TABLE orders
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

✔️ No breaking change

✔️ Automatically tracks date & time

#### 4️⃣ VERIFY (MANDATORY)

```
DESCRIBE orders;
```

#### You MUST see:

```
created_at | timestamp | DEFAULT CURRENT_TIMESTAMP
```

✅ Phase 1 complete

---

---

