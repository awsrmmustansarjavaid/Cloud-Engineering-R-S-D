# 🛒 AWS Five-Tier E-Commerce Hands-On Lab (Beginner → Realistic)

> **Author & Architecture Designer:** Charlie


> **Goal:** Build a realistic but safe AWS e-commerce lab using Free Tier–friendly services.
> **Focus:** Learning by doing (networking, security, APIs, scripting, databases).

---

## 1. LAB REQUIREMENTS & DESIGN

### 📌 LAB OBJECTIVE

Build a **basic but realistic e-commerce platform** on AWS using a **five-tier architecture** with:

* Static frontend
* Secure APIs
* Backend application
* Hybrid databases
* Basic automation & security

This lab is **AWS Free Tier–friendly** and designed for **learning by doing**.

---

### Functional Requirements

* Public static e-commerce website
* Secure backend APIs
* Structured + unstructured data storage
* Authentication-ready architecture
* Monitoring and logging

### Non‑Functional Requirements

* AWS Free Tier compatible
* Step-by-step manual configuration
* No advanced CI/CD or heavy automation

---

## 2. FIVE-TIER ARCHITECTURE OVERVIEW

### Tier 1 – Network Tier

* VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups

### Tier 2 – Web Tier

* S3 (Static Website)
* CloudFront (CDN)
* Route 53 (DNS)
* AWS WAF
* AWS KMS

### Tier 3 – App Tier

* Application Load Balancer (ALB)
* EC2 (Flask App)
* EFS (Shared Storage)
* API Gateway

### Tier 4 – Database Tier

* DynamoDB (Products)
* RDS MySQL (Orders)
* AWS Secrets Manager

### Tier 5 – Automation & Security Tier

* IAM Roles & Policies
* CloudWatch Logs & Metrics
* Cognito (Auth-ready)


### 🔧 AWS SERVICES USED

* VPC, Subnets, Route Tables
* Internet Gateway, NAT Gateway
* EC2, Application Load Balancer (ALB)
* S3, CloudFront
* Route 53
* API Gateway
* RDS MySQL
* DynamoDB
* EFS
* IAM
* Secrets Manager
* Cognito
* WAF
* CloudWatch
* Bash & Python

---

# 🧩 TIER 1: NETWORK TIER

## 1️⃣ Create VPC

**Console → VPC → Create VPC**

* Name: `ecom-vpc`
* IPv4 CIDR: `10.0.0.0/16`

---

## 2️⃣ Create Subnets

### Public Subnets

* `public-subnet-1` → `10.0.1.0/24`
* `public-subnet-2` → `10.0.2.0/24`

### Private Subnets

* `private-subnet-app` → `10.0.11.0/24`
* `private-subnet-db` → `10.0.12.0/24`

---

## 3️⃣ Internet Gateway

* Create Internet Gateway
* Attach to `ecom-vpc`

---

## 4️⃣ NAT Gateway

* Create NAT Gateway in `public-subnet-1`
* Allocate Elastic IP

---

## 5️⃣ Route Tables

### Public Route Table

* Route: `0.0.0.0/0 → Internet Gateway`
* Associate public subnets

### Private Route Table

* Route: `0.0.0.0/0 → NAT Gateway`
* Associate private subnets

---

# 🌐 TIER 2: WEB TIER (STATIC FRONTEND)

## 6️⃣ Create S3 Bucket

**S3 → Create Bucket**

* Name: `ecom-static-site-<unique>`
* Block public access: ❌ Disable
* Enable versioning
* Default encryption: **SSE-KMS**

---

## 7️⃣ Upload Frontend Files

### FRONTEND – SINGLE FILE (HTML + CSS + JS)

#### File: `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>CloudMart – AWS E-Commerce</title>
  <style>
    body { font-family: Arial; background:#f5f5f5; margin:0 }
    header { background:#232f3e; color:white; padding:15px; text-align:center }
    .container { padding:20px; display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:15px }
    .product { background:white; padding:15px; border-radius:6px; box-shadow:0 0 5px rgba(0,0,0,0.1) }
    button { background:#ff9900; border:none; padding:8px; cursor:pointer }
  </style>
</head>
<body>
<header><h1>CloudMart</h1><p>AWS Five-Tier Lab</p></header>
<div class="container" id="products">Loading...</div>
<script>
const API_BASE = "https://YOUR_API_GATEWAY_URL";
async function loadProducts(){
 const res = await fetch(`${API_BASE}/products`);
 const data = await res.json();
 const div = document.getElementById('products'); div.innerHTML='';
 data.forEach(p=>{
  div.innerHTML += `<div class='product'><h3>${p.name}</h3><p>$${p.price}</p><button onclick="order('${p.product_id}')">Buy</button></div>`;
 });
}
async function order(id){
 await fetch(`${API_BASE}/orders`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({product_id:id,quantity:1})});
 alert('Order placed');
}
loadProducts();
</script>
</body>
</html>
```

---

## 8️⃣ CloudFront Distribution

* Origin: S3 bucket
* Viewer protocol: Redirect HTTP → HTTPS
* Default root object: `index.html`

---

## 9️⃣ Route 53

* Create Hosted Zone
* Add **A Record** → CloudFront distribution

---

# 🧠 TIER 3: APPLICATION TIER

## 🔟 IAM Role for EC2

Attach permissions:

* AmazonS3ReadOnlyAccess
* AmazonDynamoDBFullAccess
* SecretsManagerReadWrite
* CloudWatchAgentServerPolicy
* AmazonElasticFileSystemClientReadWriteAccess

---

## 1️⃣1️⃣ Security Groups

### ALB Security Group

* Inbound: 80, 443 from `0.0.0.0/0`

### App Security Group

* Inbound: 80 from ALB SG
* Outbound: All

---

## 1️⃣2️⃣ Launch EC2 (App Server)

* Amazon Linux 2
* Subnet: `private-subnet-app`
* IAM Role: Attach

### EC2 User Data (Bash)

```bash
#!/bin/bash
yum update -y
yum install python3 mysql -y
pip3 install flask boto3 pymysql
mkdir /app
```

---

## 1️⃣3️⃣ Application Load Balancer

* Type: Public ALB
* Target Group: EC2
* Health Check Path: `/health`

---

## 1️⃣4️⃣ Python App API

### `/app/app.py`

```python
from flask import Flask, jsonify
import boto3

app = Flask(__name__)
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('products')

@app.route("/health")
def health():
    return "OK"

@app.route("/products")
def products():
    res = table.scan()
    return jsonify(res['Items'])

app.run(host='0.0.0.0', port=80)
```

---

# 🗄️ TIER 4: DATABASE TIER

## 1️⃣5️⃣ RDS MySQL

* Subnet group: `private-subnet-db`
* Public access: ❌ Disabled
* Engine: MySQL
* Store credentials in **Secrets Manager**

---

## 1️⃣6️⃣ DynamoDB Table

* Table name: `products`
* Partition key: `product_id`

---

## 1️⃣7️⃣ EFS

* Create EFS
* Mount target in app subnet

### EFS Mount Script

```bash
yum install amazon-efs-utils -y
mkdir /mnt/efs
mount -t efs fs-xxxx:/ /mnt/efs
```

---

# 🔐 TIER 5: SECURITY & AUTOMATION

## 1️⃣8️⃣ API Gateway

* REST API
* Resource: `/products`
* Method: GET
* Integration: ALB

---

## 1️⃣9️⃣ Cognito

* Create User Pool
* Create App Client
* Configure JWT Authorizer in API Gateway

---

## 2️⃣0️⃣ AWS WAF

* Create Web ACL
* Attach to CloudFront
* Add AWS Managed Rules

---

## 2️⃣1️⃣ CloudWatch

Enable logging for:

* EC2
* ALB
* API Gateway

---

# 🔁 API SUMMARY

| API       | Method | Backend  |
| --------- | ------ | -------- |
| /health   | GET    | App      |
| /products | GET    | DynamoDB |
| /orders   | POST   | RDS      |
| /login    | POST   | Cognito  |

---

## ✅ FINAL RESULT

You now have:

✔ Five-tier AWS architecture
✔ Static frontend
✔ Secure APIs
✔ Hybrid databases
✔ Cognito authentication
✔ WAF protection
✔ Bash & Python automation
✔ AWS Free Tier–safe lab

---

🎯 **This file is ready to copy-paste as a `.md` file into GitHub.**


## 3. FRONTEND – SINGLE FILE (HTML + CSS + JS)

### File: `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>CloudMart – AWS E-Commerce</title>
  <style>
    body { font-family: Arial; background:#f5f5f5; margin:0 }
    header { background:#232f3e; color:white; padding:15px; text-align:center }
    .container { padding:20px; display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:15px }
    .product { background:white; padding:15px; border-radius:6px; box-shadow:0 0 5px rgba(0,0,0,0.1) }
    button { background:#ff9900; border:none; padding:8px; cursor:pointer }
  </style>
</head>
<body>
<header><h1>CloudMart</h1><p>AWS Five-Tier Lab</p></header>
<div class="container" id="products">Loading...</div>
<script>
const API_BASE = "https://YOUR_API_GATEWAY_URL";
async function loadProducts(){
 const res = await fetch(`${API_BASE}/products`);
 const data = await res.json();
 const div = document.getElementById('products'); div.innerHTML='';
 data.forEach(p=>{
  div.innerHTML += `<div class='product'><h3>${p.name}</h3><p>$${p.price}</p><button onclick="order('${p.product_id}')">Buy</button></div>`;
 });
}
async function order(id){
 await fetch(`${API_BASE}/orders`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({product_id:id,quantity:1})});
 alert('Order placed');
}
loadProducts();
</script>
</body>
</html>
```

---

## 4. BACKEND – PYTHON APIs (FLASK)

### Folder Structure

```
app/
 ├── app.py
 ├── db.py
 ├── dynamo.py
 └── requirements.txt
```

### `requirements.txt`

```txt
flask
boto3
pymysql
```

### `db.py` – RDS via Secrets Manager

```python
import boto3, json, pymysql

def get_db():
 client=boto3.client('secretsmanager','us-east-1')
 sec=json.loads(client.get_secret_value(SecretId='ecom-rds-secret')['SecretString'])
 return pymysql.connect(host=sec['host'],user=sec['username'],password=sec['password'],database=sec['dbname'])
```

### `dynamo.py` – DynamoDB Products

```python
import boto3

table=boto3.resource('dynamodb').Table('products')

def get_products():
 return table.scan().get('Items',[])
```

### `app.py` – Main API

```python
from flask import Flask,request,jsonify
from dynamo import get_products
from db import get_db

app=Flask(__name__)

@app.route('/health')
def health(): return 'OK'

@app.route('/products')
def products(): return jsonify(get_products())

@app.route('/orders',methods=['POST'])
def order():
 d=request.json
 db=get_db(); c=db.cursor()
 c.execute("INSERT INTO orders(product_id,quantity) VALUES(%s,%s)",(d['product_id'],d['quantity']))
 db.commit(); c.close(); db.close()
 return {'message':'order created'}

app.run(host='0.0.0.0',port=80)
```

---

## 5. API SUMMARY

| API       | Method | Purpose      | Data Source |
| --------- | ------ | ------------ | ----------- |
| /health   | GET    | ALB health   | App         |
| /products | GET    | Product list | DynamoDB    |
| /orders   | POST   | Create order | RDS         |

---

## 6. BASH SCRIPTS (BASIC)

### Mount EFS

```bash
sudo yum install -y amazon-efs-utils
sudo mkdir /mnt/efs
sudo mount -t efs fs-xxxx:/ /mnt/efs
```

### RDS Test

```bash
mysql -h RDS_ENDPOINT -u admin -p
```

---

## 7. TESTING & VERIFICATION

### Frontend

* CloudFront URL loads page
* Browser dev tools → Network → APIs return 200

### Backend

```bash
curl http://ALB_DNS/health
```

### Databases

* DynamoDB Scan shows products
* RDS `SELECT * FROM orders;`

---

## 8. COMMON ISSUES & SOLUTIONS

| Issue                 | Cause            | Fix                    |
| --------------------- | ---------------- | ---------------------- |
| 403 CloudFront        | OAC/OAI missing  | Attach correct policy  |
| API timeout           | SG blocked       | Allow ALB → EC2        |
| RDS connection error  | Wrong secret     | Verify Secrets Manager |
| DynamoDB AccessDenied | IAM role missing | Attach policy          |
| JS CORS error         | API Gateway      | Enable CORS            |

---

## 9. WHAT YOU LEARNED

* Five-tier AWS architecture
* Secure API-driven frontend
* DynamoDB vs RDS usage
* IAM least privilege
* Cloud monitoring basics

---

## 10. NEXT SMALL LAB IDEAS

* Add Cognito login
* Convert API to Lambda
* Add image upload to S3

---

**🎯 This document is ready for GitHub & LinkedIn showcase.**
