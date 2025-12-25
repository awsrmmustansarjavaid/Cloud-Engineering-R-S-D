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


