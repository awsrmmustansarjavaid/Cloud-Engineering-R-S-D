# ☕ AWS Café Lab – Automation Extension (Lambda + API Gateway)

> **Purpose**: Modify the existing EC2-based café app so **order placement is automated via API Gateway + Lambda** (serverless), while the website remains on EC2. This introduces modern automation, separation of concerns, and prepares you for full serverless later.

---

## 🎯 What Changes From Original Lab

| Component        | Before                 | After                                     |
| ---------------- | ---------------------- | ----------------------------------------- |
| Order submission | PHP → MariaDB directly | PHP → API Gateway → Lambda → DB           |
| Business logic   | On EC2                 | In Lambda (serverless)                    |
| Security         | DB creds on EC2        | DB creds only in Secrets Manager (Lambda) |
| Automation       | Manual                 | Fully automated order processing          |

---

## 🧠 Final Architecture (Automation Added)

```
Browser
  ↓
EC2 (Apache + PHP)
  ↓ HTTP POST
API Gateway (REST API)
  ↓
Lambda (OrderProcessor)
  ↓
Secrets Manager → DB Credentials
  ↓
MariaDB (Dev) / RDS (Optional upgrade)
```

---

## 🔐 Prerequisites (Already Done)

✔ EC2 Café website running
✔ MariaDB working
✔ Secrets Manager secret exists (`CafeDevDBSecret`)
✔ IAM basics understood

---

# 1️⃣ Create IAM Role for Lambda

## Step 1: IAM → Roles → Create Role

* Trusted entity: **AWS Service**
* Use case: **Lambda**



## Step 2: Add Custom Policy for Secrets Manager

**IAM → Policies → Create policy → JSON**

```json
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

Policy name:

```
LambdaCafeSecretsAccess
```

## Step 3: Attach Permissions

Attach **AWS managed policies**:

```
AWSLambdaBasicExecutionRole
```

```
LambdaCafeSecretsAccess
```

Attach this policy to the Lambda role.

Role name:

```
Lambda-Cafe-Order-Role
```

---

# 2️⃣ Create Lambda Function (Order Processor)

## Step 1: Lambda → Create Function

* Function name:

```
CafeOrderProcessor
```

* Runtime:

```
Python 3.12
```

* Execution role:

```
Use existing role → Lambda-Cafe-Order-Role
```

---

## Step 2: Lambda Function Code

> This Lambda **receives order JSON**, reads DB credentials from Secrets Manager, and inserts into MariaDB.

### Paste **EXACT** code:

```python
import json
import pymysql
import boto3

secrets_client = boto3.client('secretsmanager', region_name='us-east-1')

SECRET_NAME = "CafeDevDBSecret"

def get_db_credentials():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response['SecretString'])


def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        creds = get_db_credentials()

        connection = pymysql.connect(
            host=creds['host'],
            user=creds['username'],
            password=creds['password'],
            database=creds['dbname'],
            cursorclass=pymysql.cursors.DictCursor
        )

        with connection.cursor() as cursor:
            sql = "INSERT INTO orders (customer_name, item, quantity) VALUES (%s, %s, %s)"
            cursor.execute(sql, (
                body['name'],
                body['item'],
                body['quantity']
            ))
        connection.commit()
        connection.close()

        return {
            'statusCode': 200,
            'headers': {"Access-Control-Allow-Origin": "*"},
            'body': json.dumps({'message': 'Order placed successfully'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {"Access-Control-Allow-Origin": "*"},
            'body': json.dumps({'error': str(e)})
        }
```

---

## Step 3: Add Lambda Layer (pymysql)

Lambda does **not include pymysql by default**.

### From EC2 or CloudShell:

```bash
mkdir lambda-layer
cd lambda-layer
sudo dnf install -y python3 python3-pip
python3 --version
pip3 --version
pip install pymysql -t python/
zip -r pymysql-layer.zip python
```

### Upload Zip

###### Uploading a Lambda layer from EC2 via S3

#### 1️⃣ Verify ZIP Exists on EC2

##### On EC2, run:

```
ls -lh
```
##### You must see:

```
pymysql-layer.zip
```

##### If not, recreate it:

```
zip -r pymysql-layer.zip python
```

#### 2️⃣ Install & Configure AWS CLI on EC2

```
sudo dnf install -y awscli
```

##### Verify:

```
aws --version
```

#### 3️⃣ Verify IAM Role Has S3 Permissions

###### Your EC2 must have an IAM role attached.

##### Required permission:

```
s3:PutObject
```

##### Quick Test (run this):

```
aws sts get-caller-identity
```

✅ If JSON output appears → role is attached

❌ If error → IAM role missing

#### 4️⃣ Add S3 Permission (If Needed)

- **IAM → Roles → Your EC2 role**

##### Attach this AWS managed policy:

```
AmazonS3FullAccess
```

###### (For lab only — in production, use least privilege)

#### 5️⃣ Create Bucket (Same Region as Lambda)

- **From AWS Console → S3:**

###### Bucket name (must be globally unique):

```
cafe-lambda-layers-<your-name>
```

##### Region:

```
us-east-1
```

- **Block public access → ON**

- **Encryption → Default (ON)**

✅ Click Create bucket

#### 6️⃣ Upload ZIP from EC2 to S3

From EC2 (inside directory with ZIP):

```
aws s3 cp pymysql-layer.zip s3://cafe-lambda-layers-<your-name>/
```

##### Verify upload:

```
aws s3 ls s3://cafe-lambda-layers-<your-name>/
```

##### You should see:

```
pymysql-layer.zip
```

✅ Upload complete


### Lambda layer

#### 1️⃣ Create Layer

* AWS Console → Lambda → Layers → Create layer

#### 2️⃣ Layer Configuration

##### Fill exactly:

```
| Field               | Value                                                   |
| ------------------- | ------------------------------------------------------- |
| Name                | `pymysql-layer`                                         |
| Description         | `PyMySQL library for Cafe Order Lambda`                 |
| Code source         | **Upload a file from Amazon S3**                        |
| S3 URI              | `s3://cafe-lambda-layers-<your-name>/pymysql-layer.zip` |
| Compatible runtimes | ✅ Python 3.12                                           |
```

* Click Create

#### 3️⃣ Attach Layer to Lambda Function

* Lambda → Functions

* Open:

```
CafeOrderProcessor
```

* Scroll to Layers

* Click Add a layer

* Choose:

```
Custom layers
```

* Select:

```
pymysql-layer
```

* Version: 1

* Click Add

#### 4️⃣ Verify Layer Is Working

##### Check Lambda Test Event

* Create Test Event

```
{
  "body": "{\"name\":\"LayerTest\",\"item\":\"Coffee\",\"quantity\":1}"
}
```

* Click Test

##### Expected Result ✅

```
{
  "statusCode": 200,
  "body": "{\"message\":\"Order placed successfully\"}"
}
```

#### 4️⃣ Check CloudWatch Logs

* **Lambda → Monitor → View logs**

##### You should NOT see:

```
ModuleNotFoundError: No module named 'pymysql'
```

**⛔️ If you do → ZIP structure is wrong.**

#### 🚨 Common Mistakes

```
| Mistake                              | Result                    |
| ------------------------------------ | ------------------------- |
| Zipped contents instead of `python/` | Import error              |
| Used Windows to build layer          | Binary mismatch           |
| Wrong runtime selected               | Layer ignored             |
| Uploaded wrong ZIP                   | Lambda can't find pymysql |
```



---

# 3️⃣ Create API Gateway (REST API)

## Step 1: API Gateway → Create API

* Type: **REST API**
* Name:

```
CafeOrderAPI
```

---

## Step 2: Create Resource

```
/orders
```

---

## Step 3: Create POST Method

* Integration type: **Lambda Function**
* Lambda:

```
CafeOrderProcessor
```

* Enable **Lambda proxy integration**

---

## Step 4: Enable CORS

* Resource: `/orders`
* Actions → Enable CORS
* Allow:

```
POST
```

---

## Step 5: Deploy API

* Actions → Deploy API
* Stage name:

```
dev
```

### Copy Invoke URL

```
https://xxxxx.execute-api.us-east-1.amazonaws.com/dev/orders
```

---

# 4️⃣ Modify EC2 PHP App (Automation Enabled)

## Replace Order Insert Logic in `index.php`

### 🔁 REMOVE this block:

```php
$stmt = $db->prepare("INSERT INTO orders...");
```

### ✅ ADD this instead:

```php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_encode([
        "name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => $_POST['quantity']
    ]);

    $ch = curl_init("https://xxxxx.execute-api.us-east-1.amazonaws.com/dev/orders");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

    $response = curl_exec($ch);
    curl_close($ch);

    echo "<p>✅ Order sent to serverless backend!</p>";
}
```

---

# 5️⃣ Automation Testing

## Test via CURL

```bash
curl -X POST \
https://xxxxx.execute-api.us-east-1.amazonaws.com/dev/orders \
-H "Content-Type: application/json" \
-d '{"name":"API-Test","item":"Latte","quantity":2}'
```

## Verify DB

```sql
SELECT * FROM orders ORDER BY id DESC;
```

---

# 6️⃣ Production Upgrade (Optional Automation)

✔ Same Lambda code
✔ New API stage: `prod`
✔ New secret: `CafeProdDBSecret`
✔ Point EC2 Prod site to **prod API URL**

---

# ✅ Final Automation Checklist

✔ Lambda processes orders
✔ API Gateway exposes endpoint
✔ PHP no longer touches DB
✔ Secrets Manager only accessed by Lambda
✔ Fully automated order pipeline

---

## 🚀 Next Enhancements (Tell me when ready)

1. Replace MariaDB with **Amazon RDS**
2. Use **DynamoDB (fully serverless)**
3. Add **SQS queue** for async orders
4. Add **CloudWatch dashboards**
5. Add **WAF + rate limiting**

---

**You now have a REAL production-grade AWS automation architecture.**
