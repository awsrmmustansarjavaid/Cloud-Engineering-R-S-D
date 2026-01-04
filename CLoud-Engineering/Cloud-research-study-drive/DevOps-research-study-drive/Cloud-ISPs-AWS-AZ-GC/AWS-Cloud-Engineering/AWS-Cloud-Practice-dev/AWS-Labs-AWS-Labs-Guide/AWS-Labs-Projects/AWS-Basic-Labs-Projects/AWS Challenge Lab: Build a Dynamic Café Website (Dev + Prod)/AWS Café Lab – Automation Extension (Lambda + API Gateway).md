# ☕ AWS Café Lab – Automation Extension (Lambda + API Gateway)

> **Author & Architecture Designer:** Charlie
>
> 
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
pip install pymysql -t python/
zip -r pymysql-layer.zip python
```

### Upload Layer

* Lambda → Layers → Create layer
* Name:

```
pymysql-layer
```

* Upload `pymysql-layer.zip`
* Runtime: Python 3.12

Attach layer to Lambda.

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
