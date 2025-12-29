# ☕ AWS Café Lab - Build a Dynamic Café Website (Dev + Prod)

#### API Gateway + Lambda + RDS + Secrets Manager

> **Author & Architecture Desinger:** Charlie

---

## 🏗️ Architecture Overview

**Frontend**

* Static `index.html`
* Hosted on **EC2 behind ALB**

**Backend**

* **API Gateway (REST API)**
* **Lambda (PHP via custom runtime OR Node.js)**
* **Amazon RDS MySQL**
* **AWS Secrets Manager**

**Security & Networking**

* VPC with public & private subnets
* ALB in public subnet
* RDS in private subnet
* IAM least-privilege roles

---

## 📌 Region Used

* Primary: **us-east-1**

---

## PHASE 1️⃣ – Networking (VPC Foundation)

### Step 1: Create VPC

* VPC Name: `Cafe-VPC`
* CIDR: `10.0.0.0/16`

### Step 2: Create Subnets

| Name             | Type    | CIDR        | AZ         |
| ---------------- | ------- | ----------- | ---------- |
| Public-Subnet-A  | Public  | 10.0.1.0/24 | us-east-1a |
| Public-Subnet-B  | Public  | 10.0.2.0/24 | us-east-1b |
| Private-Subnet-A | Private | 10.0.3.0/24 | us-east-1a |
| Private-Subnet-B | Private | 10.0.4.0/24 | us-east-1b |

### Step 3: Internet Gateway

* Create IGW: `Cafe-IGW`
* Attach to `Cafe-VPC`

### Step 4: Route Tables

**Public Route Table**

* Route: `0.0.0.0/0 → IGW`
* Associate public subnets

**Private Route Table**

* No internet route
* Associate private subnets

---

## PHASE 2️⃣ – Amazon RDS MySQL

### Step 5: Create DB Subnet Group

* Name: `cafe-db-subnet-group`
* Subnets: Private A & B

### Step 6: Create Secrets Manager Secret

Secret Name: `CafeRDSSecret`

```json
{
  "username": "cafe_user",
  "password": "StrongPassword123!",
  "dbname": "cafe_db",
  "engine": "mysql",
  "port": 3306
}
```

### Step 7: Create RDS MySQL

* Engine: MySQL 8.x
* DB Instance: `cafe-rds`
* Public Access: ❌ No
* Subnet Group: `cafe-db-subnet-group`
* Credentials: **From Secrets Manager**

### Step 8: RDS Security Group

Inbound:

* MySQL (3306)
* Source: Lambda SG

---

## PHASE 3️⃣ – Database Initialization

### Step 9: Connect from Bastion / EC2

```bash
mysql -h <RDS-ENDPOINT> -u cafe_user -p cafe_db
```

### Step 10: Create Table

```sql
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100),
  item VARCHAR(50),
  quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## PHASE 4️⃣ – Backend API (Lambda + API Gateway)

### Step 11: IAM Role for Lambda

Permissions:

* AWSLambdaBasicExecutionRole
* SecretsManagerGetSecretValue

### Step 12: Create Lambda Function

* Name: `CafeOrderAPI`
* Runtime: Node.js 18.x

```js
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');

exports.handler = async (event) => {
  const sm = new AWS.SecretsManager();
  const secret = await sm.getSecretValue({ SecretId: 'CafeRDSSecret' }).promise();
  const creds = JSON.parse(secret.SecretString);

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: creds.username,
    password: creds.password,
    database: creds.dbname
  });

  const body = JSON.parse(event.body);

  await conn.execute(
    'INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)',
    [body.name, body.item, body.quantity]
  );

  return {
    statusCode: 200,
    headers: { 'Access-Control-Allow-Origin': '*' },
    body: JSON.stringify({ message: 'Order placed' })
  };
};
```

Set environment variable:

* `DB_HOST = <RDS-ENDPOINT>`

---

## PHASE 5️⃣ – API Gateway

### Step 13: Create REST API

* Name: `CafeAPI`

### Step 14: Create Resource & Method

* Resource: `/order`
* Method: `POST`
* Integration: Lambda

Enable CORS.

### Step 15: Deploy API

* Stage: `prod`
* Copy Invoke URL

---

## PHASE 6️⃣ – Frontend (index.html)

### Step 16: Create index.html

```html
<!DOCTYPE html>
<html>
<body>
<h2>AWS Café</h2>
<form id="orderForm">
<input name="name" placeholder="Name" />
<input name="item" placeholder="Item" />
<input name="quantity" type="number" />
<button>Order</button>
</form>

<script>
document.getElementById('orderForm').onsubmit = async e => {
 e.preventDefault();
 const data = Object.fromEntries(new FormData(e.target));
 await fetch('API_GATEWAY_URL/order', {
   method:'POST',
   body: JSON.stringify(data)
 });
 alert('Order placed');
}
</script>
</body>
</html>
```

---

## PHASE 7️⃣ – EC2 + ALB

### Step 17: Launch EC2

* Amazon Linux 2023
* Install Apache

```bash
sudo dnf install -y httpd
sudo systemctl enable --now httpd
```

Upload `index.html` to `/var/www/html`

---

### Step 18: Create ALB

#### 1️⃣ Create ALB Security Group

##### Console Path:

```
EC2 → Security Groups → Create security group
```

#### Settings:

- Name: alb-sg

- Description: ALB public access

- VPC: Your Cafe VPC

#### Inbound rules:

```
| Type | Protocol | Port | Source    |
| ---- | -------- | ---- | --------- |
| HTTP | TCP      | 80   | 0.0.0.0/0 |
```

❌ Do NOT add SSH

❌ Do NOT restrict IPs yet

#### Outbound rules:

- Allow all (default)

- Click Create security group

#### 2️⃣Update EC2 Security Group (VERY IMPORTANT)

##### Your EC2 must allow traffic FROM ALB, not from internet.

- **Go to: EC2 → Security Groups → EC2-SG**


#### Inbound rules:

```
| Type | Port | Source |
| ---- | ---- | ------ |
| HTTP | 80   | alb-sg |
```

❌ Remove 0.0.0.0/0 for HTTP

✔ ALB → EC2 only (secure)

- Save rules.

#### 3️⃣ Create Target Group

Console Path:

```
EC2 → Load Balancing → Target Groups → Create target group
```
#### Basic configuration

- Target type: Instances

- Target group name: cafe-tg

- Protocol: HTTP

- Port: 80

- VPC: Your Cafe VPC

- Protocol version: HTTP1

- Click Next

#### Health checks (DO NOT SKIP)

- Set:

  - Health check protocol: HTTP

  - Health check path:

```
 /
```

#### Advanced health check:

- Healthy threshold: 2

- Unhealthy threshold: 2

- Timeout: 5

- Interval: 10

- Success codes: 200

- Click Next

#### Register targets

✔ Select your EC2 instance

✔ Port: 80

- Click Include as pending below

- Click Create target group

#### VERIFY TARGET HEALTH (IMPORTANT)

- Open cafe-tg

- Go to Targets tab

You MUST see:

```
EC2-ID     | Port | Status
-----------|------|--------
i-xxxxxxx  | 80   | healthy
```

#### ❌ If status = unhealthy:

- Apache not running

- Security group issue

- Wrong health check path


#### CREATE APPLICATION LOAD BALANCER

- Console Path:

```
EC2 → Load Balancers → Create load balancer
```
- Choose: Application Load Balancer

#### Basic configuration

- Load balancer name: cafe-alb

- Scheme: Internet-facing

- IP address type: IPv4

#### Network mapping

- VPC: Cafe VPC

- Mappings:

  ✔ Public Subnet AZ-a

  ✔ Public Subnet AZ-b

⚠️ MUST be public subnets

#### Security groups

- Remove default SG

- Select: alb-sg

#### Listeners & routing

- Listener:

  - Protocol: HTTP

  - Port: 80

- Default action:

  - Forward to: cafe-tg

Click Create load balancer

**⏳ Wait 1–2 minutes until:**

```
State: Active
```

## PHASE 8️⃣ – Testing & Verification

### Test via ALB DNS

#### Go to:

```
EC2 → Load Balancers → cafe-alb
```

Copy:

```
DNS name
```

Example:

```
http://cafe-alb-123456.us-east-1.elb.amazonaws.com
```

Paste into browser.

✅ EXPECTED RESULT

You should see:

```
☕ AWS Café
Place Your Order
```

❌ If it fails:

Check target group health

Check EC2 SG

Check Apache

### CLI VERIFICATION

#### On EC2:

```
curl http://localhost
```

#### From your laptop:

```
curl http://ALB-DNS-NAME
```

**✅ Both should return HTML.**

### API Test

```bash
curl -X POST API_URL/order -d '{"name":"Ali","item":"Coffee","quantity":1}'
```

### DB Verification

```sql
SELECT * FROM orders;
```

### Browser Test

* Open ALB DNS
* Place order
* Verify DB

---

## ✅ FINAL RESULT

✔ Static frontend

✔ Serverless backend

✔ Secure RDS

✔ Secrets Manager

✔ ALB

✔ Production-ready

## 🧠 COMMON ALB FAILURES

```
| Problem                     | Cause                   |
| --------------------------- | ----------------------- |
| 503 error                   | Target unhealthy        |
| Infinite loading            | Wrong subnets           |
| Works on EC2 IP but not ALB | SG misconfigured        |
| Health check fails          | index missing           |
| ALB created but no traffic  | Listener not forwarding |
```


---

## 🎯 Interview Talking Points

* Why ALB + API Gateway?
* Why private RDS?
* Why Secrets Manager?
* How scaling works?

---

☕ **You have now built a REAL AWS production system.**
