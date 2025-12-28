# ☕ AWS Café Lab - Build a Dynamic Café Website (Dev + Prod)

#### API Gateway + Lambda + RDS + Secrets Manager

> **Author & Architecture Desinger:** Charlie

---

## Goal

Frontend (index.html) → API Gateway → Lambda → RDS MySQL
Credentials fetched securely from Secrets Manager

---

## 🧠 FINAL FLOW (Understand First)

Browser (index.html)
↓ HTTP POST / GET
API Gateway
↓
Lambda Function (Node.js / PHP)
↓
Secrets Manager (DB creds)
↓
RDS MySQL (orders table)

---

## PHASE 0️⃣ – PREREQUISITES (DO NOT SKIP)

* ✅ RDS MySQL instance exists
* ✅ Database `cafe_db` exists
* ✅ `orders` table exists
* ✅ Secrets Manager secret exists
* ✅ Lambda execution role exists

---

## PHASE 1️⃣ – IAM ROLE FOR LAMBDA

### 1️⃣ Create IAM Role

Path: **IAM → Roles → Create role**

* Trusted entity: AWS service
* Use case: Lambda

### 2️⃣ Attach policies

* `AWSLambdaBasicExecutionRole`
* `SecretsManagerReadWrite` (or custom with `secretsmanager:GetSecretValue`)

### 3️⃣ Name role

* Role name: **CafeLambdaRole**

---

## PHASE 2️⃣ – CREATE LAMBDA FUNCTION (Node.js)

### 2️⃣ Create Lambda

Path: **Lambda → Create function**

* Author from scratch
* Name: `CafeOrderFunction`
* Runtime: Node.js 18.x
* Architecture: x86_64
* Execution role: CafeLambdaRole

### 3️⃣ Configure VPC

Lambda → Configuration → VPC

* VPC: Cafe VPC
* Subnets: Private Subnet A & B
* Security group: lambda-sg

⚠️ Lambda must be in same VPC as RDS

### 4️⃣ Environment Variables

| Key        | Value          |
| ---------- | -------------- |
| DB_SECRET  | CafeRDSSecret  |
| DB_HOST    | <RDS-ENDPOINT> |
| AWS_REGION | us-east-1      |

---

## PHASE 3️⃣ – LAMBDA CODE (Node.js)

```js
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);

    const sm = new AWS.SecretsManager({ region: process.env.AWS_REGION });
    const secret = await sm.getSecretValue({ SecretId: process.env.DB_SECRET }).promise();
    const creds = JSON.parse(secret.SecretString);

    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: creds.username,
      password: creds.password,
      database: creds.dbname
    });

    await conn.execute(
      'INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)',
      [body.name, body.item, body.quantity]
    );

    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Order placed successfully' })
    };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
  }
};
```

### Add MySQL Dependency

```bash
mkdir lambda-package && cd lambda-package
npm init -y
npm install mysql2
zip -r cafe-lambda.zip .
```

Upload ZIP → Lambda

---

## PHASE 4️⃣ – API GATEWAY (REST API)

### Create API

* API Gateway → Create API
* REST API → Build
* Name: CafeAPI
* Endpoint: Regional

### Create Resource & Method

* Resource: `/order`
* Method: POST
* Integration: Lambda → CafeOrderFunction

### Enable CORS

* Enable POST + OPTIONS

### Deploy

* Stage: prod

Endpoint:

```
https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order
```

---

## PHASE 5️⃣ – TEST API

```bash
curl -X POST \
https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order \
-H "Content-Type: application/json" \
-d '{"name":"Ali","item":"Coffee","quantity":1}'
```

---

## PHASE 6️⃣ – FRONTEND INTEGRATION

```html
<script>
document.getElementById("orderForm").addEventListener("submit", async e => {
  e.preventDefault();
  const data = { name: name.value, item: item.value, quantity: quantity.value };
  await fetch("https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  alert("Order placed!");
});
</script>
```

---

## ☕ PHP Lambda Conversion (Custom Runtime)

### Runtime: `provided.al2`

Structure:

```
php-lambda/
├── bootstrap
├── index.php
└── vendor/
```

### bootstrap

```sh
#!/bin/sh
set -e
while true; do
  EVENT=$(curl -sS http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/next)
  RESPONSE=$(echo "$EVENT" | php index.php)
  REQUEST_ID=$(echo "$EVENT" | jq -r '.requestContext.requestId')
  curl -X POST http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/$REQUEST_ID/response -d "$RESPONSE"
done
```

### index.php (POST + GET)

```php
<?php
require 'vendor/autoload.php';
use Aws\SecretsManager\SecretsManagerClient;
$event = json_decode(stream_get_contents(STDIN), true);
$method = $event['requestContext']['http']['method'] ?? 'GET';
$sm = new SecretsManagerClient(['version'=>'latest','region'=>getenv('AWS_REGION')]);
$secret = $sm->getSecretValue(['SecretId'=>getenv('DB_SECRET')]);
$creds = json_decode($secret['SecretString'], true);
$db = new mysqli(getenv('DB_HOST'), $creds['username'], $creds['password'], $creds['dbname']);
if ($method === 'GET') {
  $res = $db->query("SELECT * FROM orders ORDER BY created_at DESC");
  echo json_encode(['statusCode'=>200,'body'=>json_encode($res->fetch_all(MYSQLI_ASSOC))]);
  exit;
}
$body = json_decode($event['body'], true);
$stmt = $db->prepare("INSERT INTO orders (customer_name,item,quantity) VALUES (?,?,?)");
$stmt->bind_param("ssi", $body['name'],$body['item'],$body['quantity']);
$stmt->execute();
echo json_encode(['statusCode'=>200,'body'=>json_encode(['message'=>'Order placed'])]);
```

---

## ☁️ CloudWatch Debugging

* Logs: `/aws/lambda/CafeOrderFunction`
* Check for:

  * DB errors
  * Secrets permission
  * Timeout

---

## ✅ FINAL CHECKLIST

* ✔ API Gateway responds
* ✔ Lambda logs visible
* ✔ Secrets Manager used
* ✔ RDS updated
* ✔ GET /orders works

🎓 **You built a real-world, serverless AWS architecture** 💪
