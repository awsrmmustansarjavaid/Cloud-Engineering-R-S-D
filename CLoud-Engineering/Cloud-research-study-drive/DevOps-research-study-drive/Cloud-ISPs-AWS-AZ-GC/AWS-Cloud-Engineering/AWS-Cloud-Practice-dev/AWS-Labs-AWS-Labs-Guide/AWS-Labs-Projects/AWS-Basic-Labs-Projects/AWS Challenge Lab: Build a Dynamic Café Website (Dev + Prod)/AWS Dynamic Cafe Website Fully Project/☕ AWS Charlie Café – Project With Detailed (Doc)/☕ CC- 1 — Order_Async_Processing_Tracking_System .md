
# ☕ AWS CAFE — Order Async Processing & Tracking System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

# SECTION 1️⃣ Cafe Order Processor

## PHASE 1️⃣ — AUTOMATION Lambda Cafe-Order (SERVERLESS)

### 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy

---

### 2️⃣ Create Lambda Function

* Name: `CafeOrderProcessor`
* Runtime: Python 3.12
* Role: `Lambda-Cafe-Order-Role`

---

### 3️⃣ Lambda Layer (pymysql)

### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

```
sudo nano upload-pymysql-layer.sh
```

[PyMySQL Lambda Layer](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/upload-pymysql-layer.sh)

```
sudo chmod +x upload-pymysql-layer.sh
```

```
sudo ./upload-pymysql-layer.sh
```

### Method 2️⃣ - PyMySQL Lambda Layer (1-to-1)

#### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```

```
mkdir lambda-layer && cd lambda-layer
```

```
pip3 install pymysql -t python/
```

```
zip -r pymysql-layer.zip python
```

#### 2️⃣ Confirm ZIP exists:

```bash
ls -lh pymysql-layer.zip
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ — S3 Bucket - Upload ZIP

## 1️⃣ S3 Bucket - Upload ZIP to Lambda

### Upload layer → Attach to Lambda.

### 1️⃣ Upload ZIP to S3

#### connect Configure AWS CLI

Run this on your local machine / EC2 / CloudShell:

```
aws configure
```

#### Enter values exactly like this:

```
AWS Access Key ID [None]: AKIA************
AWS Secret Access Key [None]: ********************
Default region name [None]: us-east-1
Default output format [None]: json
```

✔ Press Enter after each input

#### Verify CLI Configuration

```
aws sts get-caller-identity
```

#### Expected output:

```
{
  "UserId": "AIDA************",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/cafe-lab-cli-user"
}
```

✔ This confirms AWS CLI is correctly authenticated.


#### Upload via AWS CLI (Recommended)

```bash
aws s3 cp pymysql-layer.zip s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```

#### Expected output:

```
upload: ./pymysql-layer.zip to s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```


##### Option B: Upload via S3 Console

* Open your S3 bucket
* Click **Upload**
* Add file → select `pymysql-layer.zip`
* Click **Upload**


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## PHASE 3️⃣ — Lambda Layer

### 1️⃣ Create Lambda Layer Using S3

### 1️⃣  Lambda Console

* AWS Console → **Lambda**
* Click **Layers**
* Click **Create layer**

### 2️⃣  Layer Settings

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| Name               | `pymysql-layer`                                                |
| Description        | PyMySQL dependency layer                                       |
| Code entry type    | **Upload a file from Amazon S3**                               |
| S3 URI             | `s3://cafe-lambda-artifacts-<unique>/layers/pymysql-layer.zip` |
| Compatible runtime | Python 3.12                                                    |

Click **Create**

✅ Lambda Layer created from S3

### 2️⃣ Attach Layer to Lambda Function

####  1️⃣ Open Lambda Function

* Lambda → Functions → `CafeOrderProcessor`

#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 4️⃣ — API Gateway


## Objective:

Expose your `CafeOrderProcessor` Lambda function via REST API so your EC2 Café web app can send orders to it.

### 1️⃣ Create a REST API

1. Open **AWS Management Console → API Gateway**.
2. Click **Create API**.
3. Choose **REST API → Build**.
4. **Configuration:**
   - API name: `CafeOrderAPI`
   - Description: `API for processing café orders`
   - Endpoint type: `Regional` (default)
5. Click **Create API**.



### 2️⃣ Create Resource

1. In your API, click **Resources → Actions → Create Resource**.
2. Configure:
   - Resource Name: `orders`
   - Resource Path: `/orders`
3. Click **Create Resource**.



### 3️⃣ Create POST Method

1. Select `/orders` resource.
2. Click **Actions → Create Method → POST**.
3. Integration type: **Lambda Function**
   - Check **Use Lambda Proxy integration**
   - Lambda Region: `us-east-1`
   - Lambda Function: `CafeOrderProcessor`
4. Click **Save** → **OK** to give permissions to API Gateway to invoke Lambda.



### 4️⃣ Enable CORS (Cross-Origin Resource Sharing)

1. Select `/orders` resource.
2. Click **Actions → Enable CORS**.
3. Configure:
   - Allowed Methods: `POST`
   - Allowed Headers: `Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token`
   - Allow Credentials: unchecked
4. Click **Enable CORS and replace existing CORS headers**.
5. Click **Yes, replace existing values** if prompted.



### 5️⃣ Deploy API

1. Click **Actions → Deploy API**.
2. Configure:
   - Deployment stage: `dev`
   - Stage description: `Development stage`
   - Deployment description: `Initial deployment`
3. Click **Deploy**.

### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an **Invoke URL** at the top of the Stage page, e.g.:

```
https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders
```

> This URL will be used in your EC2 PHP web app `curl` requests.

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## PHASE 5️⃣ — Frontend Development Code

##  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

## 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)

### 1️⃣ Create the shared auth-api.js file

#### Command to create the js directory

```
sudo mkdir -p /var/www/js
```

```
sudo nano /var/www/js/auth-api.js
```

[auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/auth-api.js)

### 2️⃣ Update EC2 PHP App to Use API Gateway

```
sudo nano /var/www/html/orders.php
```
#### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

### 3️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣ — Backend Development Code

### 1️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️

[CafeOrderProcessor.py](..//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderProcessor/CafeOrderProcessor.py)

Save Lambda

Click Deploy (top right)
---- 

### 2️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 3️⃣ Create VPC Endpoint

- **AWS Console → VPC → Endpoints → Create endpoint**

- **Endpoint Name:** secretsmanager-INT-EP

- **Service category:** AWS services

- **Service name:** com.amazonaws.us-east-1.secretsmanager

- **Type:** Interface

- **VPC:** Select VPC 

- **Subnets:**

**✔ Select the SAME private subnets used by Lambda**

- **Security Group:**

**Allow HTTPS (443) inbound from Lambda SG**

Create endpoint ✅

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## PHASE 7️⃣ — Test & Verification ( Must)

_ **Please refer to the Test & Verification documentation for detailed procedures.**

# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# SECTION 2️⃣ — AWS Cafe Menu + Cache Layer

## PHASE 1 — AMAZON DYNAMODB (Menu + Cache Layer)

### 1️⃣ Create DynamoDB Table

- **DynamoDB → Create table**

### 1️⃣ Basic Table Settings

| Field         | Value      |
| ------------- | ---------- |
| Table name    | `CafeMenu` |
| Partition key | `item`     |
| Type          | `String`   |

##### ⚠️ Do NOT add Sort key

##### ⚠️ Partition key name must be exactly item

### 2️⃣ Table Settings (Capacity)

Scroll down to Table settings

- Capacity mode:

    ✅ On-demand

#### Why?

- No capacity planning

- Free-tier friendly

- Ideal for learning & small apps

### 3️⃣ Additional Settings (Keep Default)

Leave ALL of these as default:

- Encryption at rest: AWS owned key

- Table class: Standard

- Deletion protection: Disabled

- Tags: Optional (skip)

### 4️⃣ Create Table

- Click Create table

#### Wait until:

```
Status = ACTIVE
```

##### ⏳ This may take 20–60 seconds

### 2️⃣ Insert Menu Items

- **DynamoDB → CafeMenu → Explore table → Create item**

### 1️⃣ Method 1 JSON EDitor

#### 1️⃣ Create First Item (Coffee)

You will see a JSON editor.

Replace everything with:

```
{
  "item": {
    "S": "Coffee"
  },
  "price": {
    "N": "3"
  }
}
```

- ✅ Click Create item

#### 2️⃣ Create Second Item (Latte)

Click Create item again:

```
{
  "item": {
    "S": "Latte"
  },
  "price": {
    "N": "5"
  }
}
```

- ✅ Click Create item

#### 3️⃣ Create Third Item (Tea)

Click Create item again:

```
{
  "item": {
    "S": "Tea"
  },
  "price": {
    "N": "2"
  }
}
```

- ✅ Click Create item

---

#### 4️⃣ Create Third Item (Cappuccino)

```
{
  "item": {
    "S": "Cappuccino"
  },
  "price": {
    "N": "8"
  }
}
```

- ✅ Click Create item

---

#### 5️⃣ Create Third Item (Fresh Juice)

```
{
  "item": {
    "S": "Fresh Juice"
  },
  "price": {
    "N": "6"
  }
}
```

- ✅ Click Create item

---

### 2️⃣ Method 2 Item editor screen


#### 1️⃣ Create First Item (Coffee)

1. Partition key:

- item → Coffee

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 3

- ✅ Click Create item

#### 2️⃣ Create Second Item (Latte)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 5

- ✅ Click Create item

#### 3️⃣ Create Third Item (Tea)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 2

- ✅ Click Create item

#### 4️⃣ Create First Item (Cappuccino)

1. Partition key:

- item → Cappuccino

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 8

- ✅ Click Create item

#### 5️⃣ Create First Item (Fresh Juice)

1. Partition key:

- item → Fresh Juice

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 6

- ✅ Click Create item

---
### 3️⃣ Verify Items

You should now see 5 items in the table. You should now see:

| item   | price |
| ------ | ----- |
| Coffee | 3     |
| Latte  | 5     |
| Cappuccino    | 8     |
| Fresh Juice    | 6     |

✅ DynamoDB table is ready


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — CafeMenuLambda
### 1️⃣ Attach Policy to Lambda Role

You likely have two Lambdas:

    API Lambda

    Worker Lambda

👉 Attach this policy to API Lambda role

- **Go to IAM → Roles → Search for your Lambda role**

Example:

```
CafeAPILambdaRole
```

- Attach Policy to API Lambda role **CafeLambdaExecutionRole**

```
CafeMenuDynamoDBReadPolicy
```
✅ IAM is now correctly configured

✅ Lambda now has DynamoDB access


### 2️⃣ CREATE NEW LAMBDA (MENU API)

- Open AWS Lambda

- **Function details:**

| Field          | Value                     |
| -------------- | ------------------------- |
| Function name  | `CafeMenuLambda`          |
| Runtime        | Python 3.12               |
| Architecture   | x86_64                    |
| Execution role | Use existing role         |
| Role           | `CafeLambdaExecutionRole` |

**✔️ Click Create function**

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeMenuLambda.py)

**✔️ Click Deploy**

### 6️⃣ TEST LAMBDA (MANDATORY)

- Click Test

- Test name: MenuTest

- Event JSON:

```
{}
```

**✔️ Click Test**

#### ✅ Expected Output:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "[{\"price\": 5, \"item\": \"Latte\"}, {\"price\": 8, \"item\": \"Cappuccino\"}, {\"price\": 6, \"item\": \"Fresh Juice\"}, {\"price\": 2, \"item\": \"Tea\"}, {\"price\": 3, \"item\": \"Coffee\"}]"
}
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 2️⃣ COMPLETE & VERIFIED
---
# SECTION 3️⃣ — AWS CAFE SQS (Async Order Processing)

## PHASE 1️⃣ — SQS/LAMBDA (Producer)


## 1️⃣ Create SQS Queue

- **SQS → Create queue**

- **Queue Type:** Standard

    ⚠️ Do NOT select FIFO

- **Name:** CafeOrdersQueue

**Configuration:**

- **Visibility timeout:** 60

> **💡 Why: Worker Lambda must finish DB insert within this time**

- **Message retention:** 4 days **(Leave default)**

- **Maximum message size:** 256 KB **(Leave default)**

- **Delivery delay:** 0 seconds **(Leave default)**

- **Receive message wait time:** 0 seconds **(Leave default)**

- **Dead-letter queue:** ❌ Disable for now **(we’ll add later)**

- **Encryption:** Select: Disabled **(Free tier friendly)**

- **Access Policy:** Leave Basic **(Do NOT change)**

**✔️ Click Create queue**

### ✅ Verify

- Queue status should be Available

- Copy Queue ARN

- Copy Queue URL (IMPORTANT — save it)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ CREATE API Lambda Function (Producer)
> **(ORDER API → SQS)**

### 1️⃣ Create Lambda Function

- Open Lambda Console

- Click Functions

- Click Create function

#### 1️⃣ Basic Information:

| Field         | Value                          |
| ------------- | --------------------           |
| Function name | `CafeOrderApiLambda`           |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |

Click Create function

⏳ Wait until status shows Active

### 2️⃣ Update API Lambda (Producer)

#### 1️⃣ Open Order API Lambda

- AWS Console → Lambda

- Click your Order API Lambda

#### 2️⃣ Add Environment Variable:

- Configuration → Environment variables

- Click Edit

- Add:

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |

#### 📍 How to get Queue URL:

- Open SQS

- Click CafeOrdersQueue

- Copy Queue URL

**✔️ Click Save**

### 3️⃣ Update Lambda Code (FULL)

#### 1️⃣ Replace your order insert logic with this:

#### 📣 CafeOrderApiLambda  — Production-Ready (Recommended for This Lab)

#### 💻 Code (Recommended for This Lab)

[CafeOrderApiLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderApiLambda.py)

**✔️ Click Deploy**
---

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

---
## PHASE 3️⃣ — Verification SQS/LAMBDA (Producer - Must)

- **Please refer to the Test & Verification documentation for detailed procedures.**

## PHASE 4️⃣ — SQS/Worker LAMBDA (Consumer)

### 1️⃣ Create Worker Lambda (Consumer)

### 1️⃣ Create Lambda Function

- **Lambda → Create function**

- **Select Author from scratch**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Function name  | `CafeOrderWorker`             |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |


**✔️ Click Create function**

### 2️⃣ Add SQS Trigger (VERY IMPORTANT)

- Scroll to Function overview

- Click Add trigger

- Select SQS

```
your SQS arn url
```


#### Trigger settings:

| Field                      | Value         |
| -------------------------- | ------------- |
| Activate trigger           | ✅ Checked     |
| Batch size                 | 1             |
| Batch window               | 0             |
| Maximum concurrency        | (leave empty) |
| Report batch item failures | ❌ unchecked   |


**✔️ Click Add**

#### ⚠️ CRITICAL:

- AWS automatically:

- Creates event source mapping

- Adds ReceiveMessage permissions

### 3️⃣ WORKER LAMBDA CODE Production Safe (Recommended)

#### 💻 Code:

[CafeOrderWorker.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderWorker.py)

**Click Deploy**

### 4️⃣ Attach Layer to Worker Lambda

- Lambda → CafeOrderWorker

> **Scroll to Layers**

- Click Add a layer

- Choose:

    - ☑ Custom layers

    - Select PyMySQLLayer

    - Version: latest

- Click Add

### 5️⃣ Attach Lambda to VPC (MANDATORY)

#### 1️⃣ Attach Lambda to VPC

- **AWS Console → Lambda → CafeOrderWorker**

1️⃣ Click Configuration

2️⃣ Click VPC

3️⃣ Click Edit

Set EXACTLY like this:

| Field           | Value                                 |
| --------------- | ------------------------------------- |
| VPC             | **Same VPC as RDS**                   |
| Subnets         | **Private subnets (same AZs as RDS)** |
| Security groups | **Lambda-SG (or create new)**         |

4️⃣ Click Save

⏳ Wait 1–2 minutes

#### 2️⃣ Fix Security Groups (MANDATORY)

**A) RDS Security Group**

#### Inbound rule:

| Type         | Port | Source        |
| ------------ | ---- | ------------- |
| MySQL/Aurora | 3306 | **Lambda-SG** |


❌ NOT 0.0.0.0/0

✅ MUST be Lambda SG

**B) Lambda Security Group**

#### Outbound rule (default usually OK):

| Type        | Destination |
| ----------- | ----------- |
| All traffic | 0.0.0.0/0   |


#### 3️⃣ Increase Lambda Timeout

**Lambda → Configuration → General configuration → Edit**

| Setting | Value          |
| ------- | -------------- |
| Timeout | **30 seconds** |
| Memory  | **512 MB**     |


👉 Why:

- ENI creation

- Cold start

- DB connection

- Memory also improves network performance.

Click Save

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — VPC ENDPOINTS (THIS IS WHERE MOST FAIL)

You already have Secrets Manager endpoint ✅

Now add the remaining REQUIRED endpoints.

### 1️⃣ Create SQS Interface Endpoint

**VPC → Endpoints → Create endpoint**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Name           | sqs-INT-EP                    |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Same private subnets          |
| Security group | Lambda-SG                     |
| Private DNS    | ✅ ENABLE                      |

### 2️⃣ Create CloudWatch Logs Interface Endpoint

- **Name:**

```
cloudwatch-INT-EP 
```

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅

### 3️⃣ Create DynamoDB Gateway Endpoint (VERY IMPORTANT)

- **Name:**

```
dynamodb-GW-EP 
```


- **Service:**

```
com.amazonaws.us-east-1.dynamodb
```

- **Type:** Gateway

- **Attach to:**

  - ALL private route tables

Click Create

### 4️⃣ Verify Secrets Manager Keys (VERY IMPORTANT)

Your secret must contain EXACT keys:

```
{
  "host": "your-rds-endpoint",
  "username": "cafe_user",
  "password": "********",
  "dbname": "cafe_db"
}
```

❌ If even ONE key name differs → connection fails silently

### 5️⃣ Add DEBUG LOGS (TEMPORARY - Optional)

Update your Lambda code temporarily:

```
print("DEBUG: Lambda invoked")
print("DEBUG: Event =", event)

secret = get_db_secret()
print("DEBUG: Secret fetched")

connection = pymysql.connect(
    host=secret["host"],
    user=secret["username"],
    password=secret["password"],
    database=secret["dbname"],
    connect_timeout=5
)

print("DEBUG: RDS connected")
```

This lets us see exactly where it stops.

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣ — Update Lambda Function Cafe Order Processor

### 1️⃣ Updated Code 

[CafeOrderProcessor](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderProcessor/CafeOrderProcessor.py)

#### 2️⃣ Add Environment Variable:

- **Configuration → Environment variables**

- Click Edit

#### Add:

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |

#### 📍 How to get Queue URL:

- Open SQS

- Click CafeOrdersQueue

- Copy Queue URL

**✔️ Click Save**


#### 3️⃣ Test Lambda Code:

#### Event name: 

```
test-new order processing SQS
```

#### Paste JSON

```
{
      "body": "{\"table_number\": 1, \"customer_name\": \"WorkerTest\", \"item\": \"Tea\", \"quantity\": 2}"
}
```


**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

## PHASE 7️⃣ — Verification SQS/Worker LAMBDA (Consumer - Must)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

# 🟢 SECTION 3️⃣ COMPLETE & VERIFIED
---

# SECTION 4️⃣ — ORDER STATUS DASHBOARD

## PHASE 1️⃣ — DYNAMODB METRICS TABLE (FULL)

### 1️⃣ Open DynamoDB Console

#### AWS Console → DynamoDB → Tables → Create table

### 2️⃣ CREATE DYNAMODB METRICS TABLE

#### 1️⃣ Table configuration

| Field         | Value              |
| ------------- | ------------------ |
| Table name    | `CafeOrderMetrics` |
| Partition key | `metric` (String)  |
| Sort key      | ❌ None             |
| Table class   | Standard           |
| Capacity      | On-demand          |
| Encryption    | Default            |

#### Sample items:

```
{ "metric": "TOTAL_ORDERS", "count": 120 }
{ "metric": "TODAY_ORDERS", "count": 25 }
```

Click Create table

**🕐 WAIT until status = ACTIVE**

### 3️⃣ Insert initial items (VERY IMPORTANT)

**Click table → Explore table → Create item**

#### Item 1

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item

#### Item 2

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — VERIFICATION (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

## PHASE 3️⃣ — UPDATE WORKER LAMBDA (SAFE & EXACT)
> **⚠️ This step is inside existing Worker Lambda, NOT API Lambda.**

###  1️⃣ Open Worker Lambda

### AWS Console → Lambda → CafeOrderWorker

###  2️⃣ UPDATE WORKER LAMBDA (SAFE ADDITION)

### 1️⃣ Add this code at the TOP

```
metrics_table = dynamodb.Table("CafeOrderMetrics")
```

### 2️⃣ Add this AFTER successful RDS insert

⚠️ Place it AFTER cursor.execute(...) and commit()

#### Inside your SQS Worker Lambda, after DB insert:

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

### 3️⃣ ✅ FINAL WORKER LAMBDA CODE

#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

[CafeOrderMetrics.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderMetrics.py)

**Click Deploy**

✔️ RDS remains main source

✔️ DynamoDB gives fast counters

### 3️⃣ IAM ROLE CHECK (DO THIS FIRST)

Make sure Worker Lambda Role has:

### 4️⃣ VERIFY THIS STEP

1️⃣ Place one new order

2️⃣ Go to DynamoDB → CafeOrderMetrics

3️⃣ Open TOTAL_ORDERS

✔ Count increased by 1


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — CREATE ORDER STATUS LAMBDA (NEW)
> **📢 This Lambda ONLY READS DATA.**

### 1️⃣ Create Lambda

#### AWS Console → Lambda → Create function

| Setting        | Value                                   |
| -------------- | --------------------------------------- |
| Name           | `GetOrderStatusLambda`                  |
| Runtime        | Python 3.12                             |
| Execution role | Use existing role                       |
| Role           | Same role as Worker (read-only is fine) |


- **✔️ Click Create function**

### 2️⃣ Lambda Status Order Code

[GetOrderStatusLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/GetOrderStatusLambda.py)

### 3️⃣ Attach Layer to Lambda Function

####  1️⃣ Open Lambda Function

* Lambda → Functions → `CafeOrderProcessor`

#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**

### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**

### 5️⃣ Test Lambda

#### Test event:

```
{}
```

#### Expected:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"metrics\": [{\"metric\": \"TOTAL_ORDERS\", \"count\": \"2\"}], \"recent_orders\": ..........."
}
```

✔ Status code: 200

✔ JSON returned

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — API GATEWAY ENDPOINT

👉 Use your EXISTING API

👉 Create a NEW METHOD (GET /order-status) on it

❌ Do NOT create a new API

### 🧠 WHY YOU SHOULD USE THE EXISTING API

#### You already have something like:

```
CafeOrdersAPI
https://xxxxx.execute-api.us-east-1.amazonaws.com/dev
```

#### And inside it you probably have:

```
POST /orders        → CreateOrderLambda
```

#### ✔️ This is CORRECT architecture

One API = One backend system
Multiple resources/methods inside it

**Creating multiple APIs would be:**

❌ Hard to manage

❌ Bad practice

❌ Confusing for frontend

### STRUCTURE (VISUAL)

```
CafeOrdersAPI
│
├── POST /orders
│     └── CreateOrderLambda
│
└── GET /order-status
      └── GetOrderStatusLambda
```

✔️ SAME API

✔️ SAME stage (/dev)

✔️ DIFFERENT Lambda functions

### 1️⃣ Open API Gateway

#### API Gateway → Open Your Existing API (example: CafeOrdersAPI) → Resources

### 2️⃣ Create Resource

```
Resource name: order-status
Resource path: /order-status
```

Click Create resource

### 3️⃣ Create NEW METHOD

Select /order-status

Click Create Method

```
GET /order-status
```

- **Method:** GET

- **Integration:** Lambda

- **Select GetOrderStatusLambda**

- **Lambda name:** GetOrderStatusLambda

✔️ Enable Lambda proxy integration

Click Create method


### 4️⃣ Enable CORS (VERY IMPORTANT)

Select /order-status

Actions → Enable CORS

✔️ GET

✔️ OPTIONS

Click Enable CORS and replace existing CORS headers

### 5️⃣ Deploy API (MOST MISSED STEP 🚨)

API Gateway → Actions → Deploy API

| Field            | Value                 |
| ---------------- | --------------------- |
| Deployment stage | New stage             |
| Stage name       | status                |
| Description      | Order status endpoint |

Click Deploy

### 6️⃣ VERIFY API

#### 🌐 FINAL API URL

```
GET https://xxxxx.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### 🧪 TEST IT (MUST WORK)

```
curl https://xxxxx.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### ✅ You MUST see JSON like:

```
{
  "metrics": [
    {"metric":"Total Orders","count":15}
  ],
  "recent_orders": [
    {
      "customer_name":"Ali",
      "item":"Coffee",
      "quantity":2,
      "created_at":"2026-01-09 12:30:00"
    }
  ]
}
```

❌ If this does not work → STOP. Fix backend first.

#### Open browser:

```
https://API_ID.execute-api.region.amazonaws.com/status/order-status
```

✔ JSON visible

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE

### 1️⃣ Create File

```
sudo nano /var/www/html/order-status.html
```

### 1️⃣ CODE

#### 🚨 IMPORTANT:

#### Replace this line ONLY:

```
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
```

#### With your real API:

```
fetch("https://abcd1234.execute-api.us-east-1.amazonaws.com/admin/order-status")
```

#### 1️⃣ Simple order-status.html 

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 2️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 2️⃣ SECURITY & PERMISSIONS

✅ 2.1 Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```
```
sudo chmod 644 /var/www/html/order-status.html
```

### 3️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

### 4️⃣ Open page in browser

✔ Orders visible

✔ Counts visible

✔ Date/time visible


**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

## PHASE 7️⃣ — FEATURE VERIFICATION (IMPORTANT)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---
# ☕ SECTION 5️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

## 🔔 PHASE 1️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧑‍💻 1️⃣ — BACKUP YOUR EXISTING FILE (MANDATORY)

#### Before changing anything:

1️⃣ Go to your server / EC2

2️⃣ Navigate to your web directory

3️⃣ File Name

```
orders.php
```

4️⃣ Rename your file:

```
orders.php  →  order_old.php
```

**✅ This guarantees rollback safety**

### 🧑‍💻 STEP 2 — CREATE UPDATED ORDER FILE

#### Create a new file:

```
place-order.php
```

Paste the FULL code below

⚠️ Do NOT remove anything

⚠️ Do NOT partially copy

### ✅ FINAL UPDATED ORDER FRONTEND CODE

#### 📌 Copy-paste exactly as is

[orders.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

### 🧪 STEP 3 — TESTING (DO NOT SKIP)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## 🔔 PHASE 2️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

### 🧑‍💻 STEP 1 — CREATE NEW LAMBDA (READ-ONLY)

#### 1️⃣ Open AWS Lambda

AWS Console → Lambda → Create function

#### 2️⃣ Function Settings

| Field         | Value                         |
| ------------- | ----------------------------- |
| Function name | `CafeOrderStatusLambda`       |
| Runtime       | Python 3.12                   |
| Architecture  | x86_64                        |
| Role          | Same role used for RDS access |

Click Create function

Wait until status = Active

### 🧑‍💻 STEP 2 — ADD DB ENV VARIABLES

Lambda → Configuration → Environment variables → Edit

#### Add:

```
DB_HOST = your-rds-endpoint
DB_USER = cafe_user
DB_PASS = password
DB_NAME = cafe_db
```

Click Save

### 🧑‍💻 STEP 3 — ADD PyMySQL LAYER

- Lambda → Layers → Add layer

- Custom layers

- Select PyMySQLLayer

- Latest version

- Click Add

### 🧑‍💻 STEP 4 — FINAL LAMBDA CODE (READ-ONLY)

> **⚠️ COPY EXACTLY — do NOT modify**

[CafeOrderStatusLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda.py)

Click Deploy

### 🧪 STEP 5 — TEST LAMBDA (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 🌐 STEP 6 — CREATE API GATEWAY (READ-ONLY)

#### 1️⃣ Open API Gateway

Create → REST API → New API

##### Name:

```
CafeOrderStatusAPI
```

#### 2️⃣ Create Resource

```
/order-status
```

#### 3️⃣ Create GET Method

#### Integration:

    - Lambda Function

    - CafeOrderStatusLambda

Enable Lambda Proxy Integration

#### 4️⃣ Enable CORS

- **Allow Origin:** *

- **Allow Methods:** GET

- **Allow Headers:** *

#### 5️⃣ Deploy API

#### Stage name:

```
prod
```

**Copy Invoke URL**

#### Example:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/prod/order-status
```

### 🧪 STEP 7 — TEST API (CRITICAL)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 🧑‍💻 STEP 8 — CREATE order-status.php

This file is frontend-only and SAFE

#### ☕ FINAL order-status.php with print button (CAFE STYLED - Recommanded)

[order-receipt.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

#### ✅ WHAT YOU NEED TO REPLACE (VERY CLEAR)

Inside the PHP file, ONLY replace this line:

```
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=$orderId";
```

**🔁 Replace with your real API Gateway URL**

### 🧪 STEP 9 — END-TO-END TEST

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

### 🧑‍💻 STEP 1 — MODIFY DATABASE (ONE TIME)

#### 1️⃣ Open RDS → Query Editor (or MySQL client)

Connect to your cafe database.

#### 2️⃣ Add Required Columns

#### Run exactly this SQL:

```
ALTER TABLE orders
ADD COLUMN order_id VARCHAR(50),
ADD COLUMN status VARCHAR(20) DEFAULT 'RECEIVED',
ADD COLUMN total_amount DECIMAL(10,2),
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

#### 3️⃣ Verify Columns

```
DESCRIBE orders;
```

#### You MUST see:

- order_id

- status

- total_amount

- updated_at

### 🧠 ORDER ID FORMAT (STANDARD)

```
ORD-YYYYMMDD-XXXX
```

#### Example:

```
ORD-20260114-8392
```

### 🧑‍💻 STEP 2 — UPDATE CREATE ORDER LAMBDA

⚠️ This does not break existing flow

#### 1️⃣ Open Lambda

Function: CreateOrderLambda

#### 2️⃣ Replace Code (100% COPY)

[CreateOrderLambda.py](..//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CreateOrderLambda.py)

#### 3️⃣ Deploy Lambda

Click Deploy

### 🧪 STEP 3 — TEST ORDER CREATION

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 🧑‍💻 STEP 4 — CREATE WORKER (KITCHEN) LAMBDA

#### This simulates:

- Barista

- Kitchen staff

- Admin panel

#### 1️⃣ Create Lambda

| Setting | Value                   |
| ------- | ----------------------- |
| Name    | `CafeOrderWorkerLambda` |
| Runtime | Python 3.12             |
| Role    | Same RDS role           |


### 2️⃣ Lambda Code (STRICT COPY)

[CafeOrderWorkerLambda.py](/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderWorkerLambda.py)

### 🌐 STEP 5 — CREATE API GATEWAY FOR WORKER

#### Endpoint

```
POST /order-update
```

- Integration: CafeOrderWorkerLambda

- Enable CORS

- Deploy stage: prod

### 🧪 STEP 6 — TEST STATUS FLOW (MANDATORY)

#### 1️⃣ RECEIVED → PREPARING

```
{
  "order_id": "ORD-XXXX",
  "status": "PREPARING"
}
```

#### 2️⃣ PREPARING → READY

#### 3️⃣ READY → COMPLETED

❌ Try skipping → must fail

### 🧑‍💻 STEP 7 — UPDATE ORDER STATUS LAMBDA (READ REAL STATUS)

#### Replace SELECT query:

```
SELECT order_id, table_number, item, quantity, total_amount, status, created_at
FROM orders
WHERE order_id=%s
```

### 🧑‍💻 STEP 8 — order-receipt.php

#### Add billing & live status:

#### 📌 Requirement: Your backend must expose a GET order status API like:

```
GET https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=ORD-XXXX
```

#### 📁 WHERE THIS FILE BELONGS

```
/web
 ├── order.php
 ├── order-receipt.php   ✅ (THIS FILE)
 └── index.html
```

#### Code order-receipt.php

```
<p><strong>Total:</strong> $<?= $data['order']['total_amount'] ?></p>
<p><strong>Status:</strong>
<span class="badge bg-success"><?= $data['order']['status'] ?></span>
</p>
```

**Print button already exists ✅**

[order-receipt.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

### 🧪 FINAL TEST

1️⃣ Place order

2️⃣ Backend returns order_id

3️⃣ Open:

```
order-receipt.php?order_id=ORD-XXXX
```

4️⃣ Status updates automatically

5️⃣ Scan QR → same page

6️⃣ Print → receipt only


**☕ You now have a REAL SaaS-LEVEL CUSTOMER ORDER TRACKING SYSTEM**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔔 PHASE 4️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧩 STEP 1 — DATABASE (VERIFY ONLY)

❌ Do NOT drop or modify existing columns

✅ Only verify these exist

#### Required columns in orders table

```
order_id        VARCHAR(40) PRIMARY KEY
customer_name  VARCHAR(100)
table_number   INT
item            VARCHAR(50)
quantity        INT
total_amount   DECIMAL(10,2)
status          VARCHAR(20)
created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

✔ If these already exist → DO NOTHING

✔ If order_id exists → must be unique

### 🧩 STEP 2 — BACKEND API (READ-ONLY)

#### Endpoint

```
GET /order-receipt.php?order_id=ORD-XXXX
```

#### Lambda responsibility

- Fetch order by order_id

- Return JSON

- No updates

- No auth

#### Expected JSON response (MANDATORY)

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "customer_name": "John",
    "table_number": 4,
    "item": "Latte",
    "quantity": 2,
    "total_amount": 8.00,
    "status": "PREPARING",
    "created_at": "2026-01-14 10:42:00"
  }
}
```

✔ If this API already exists → DO NOTHING

✔ If not → create a new Lambda (read-only)

### 🧩 STEP 3 — ORDER PAGE (MINIMAL CHANGE)

#### File: order.php

After successful order placement, backend already returns order_id.

#### Add this line ONLY (no other change):

```
echo "<a class='btn btn-success mt-2'
      href='order-status.php?order_id={$order_id}'>
      📦 Track Your Order
      </a>";
```

✔ Existing order logic untouched

✔ This only adds a link

### 🧩 STEP 4 — CREATE CUSTOMER TRACKING PAGE

#### File name (NEW)

```
order-receipt.php
```

#### Location

```
/web/order-receipt.php
```

### 🧩 STEP 5 — FINAL order-receipt.php (LATEST VERSION)

[order-receipt.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT%20(single%20order))/order-receipt.php)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---