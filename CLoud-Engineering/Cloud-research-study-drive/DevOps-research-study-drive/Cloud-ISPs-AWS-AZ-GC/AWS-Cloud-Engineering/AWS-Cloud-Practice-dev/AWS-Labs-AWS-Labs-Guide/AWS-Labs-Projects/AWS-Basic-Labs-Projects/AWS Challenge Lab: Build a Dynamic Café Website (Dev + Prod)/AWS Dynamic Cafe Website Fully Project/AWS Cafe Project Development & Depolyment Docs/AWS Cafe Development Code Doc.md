

# AWS Cafe Development Code

## PHASE 1 - Frontend Development Code

### 1️⃣ Update EC2 PHP App to Use API Gateway

```
sudo nano /var/www/html/orders.php
```

#### In your `orders.php`:

You can copy-paste this entire file safely 👇

```php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_encode([
        "name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => $_POST['quantity']
    ]);

    $ch = curl_init("https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

    $response = curl_exec($ch);
    curl_close($ch);

    echo "<p>✅ Order sent to serverless backend!</p>";
}
```


#### FULL UPDATED orders.php (FINAL VERSION)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }
        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }
        button:hover {
            background-color: #219150;
        }
        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

    $payload = json_encode([
        "customer_name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => (int)$_POST['quantity']
    ]);

    $ch = curl_init($apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Content-Type: application/json"
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

    $response = curl_exec($ch);

    if ($response === false) {
        echo "<p style='color:red'>❌ CURL Error: " . curl_error($ch) . "</p>";
    } else {
        echo "<p style='color:green'>✅ Order sent successfully</p>";
        echo "<pre>$response</pre>";
    }

    curl_close($ch);
}
?>

</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```

#### ❌ (Do not use this in production; it is for research and study purposes only.)


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }
        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }
        button:hover {
            background-color: #219150;
        }
        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] === "POST") {

        $payload = [
            "customer_name" => $_POST["name"],
            "item"          => $_POST["item"],
            "quantity"      => (int) $_POST["quantity"]
        ];

        $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

        $ch = curl_init($apiUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode === 200) {
            echo "<p>✅ Order sent successfully!</p>";
        } else {
            echo "<p>❌ Error sending order</p>";
            echo "<pre>$response</pre>";
        }
    }
    ?>
</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```


---

## PHASE 2 - Backend Development Code

### 1️⃣ Lambda Code — AUTOMATION Lambda Cafe-Order (SERVERLESS)

#### ❌ (Do not use this in production; it is for research and study purposes only.)

##### Your Lambda must expect proxy format:

```
import json

def lambda_handler(event, context):
    body = json.loads(event["body"])

    customer_name = body["customer_name"]
    item = body["item"]
    quantity = body["quantity"]

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": "Order saved"})
    }
```


---

### 2️⃣ Lambda Code — AUTOMATION SQS (Async Order Processing)

#### 📣 CafeOrderApiLambda — Code Evolution & Purpose

In this lab, the CafeOrderApiLambda is responsible for:

✅ Receiving orders from API Gateway

✅ Validating input

✅ Sending orders to Amazon SQS

❌ NOT interacting with RDS directly

> **This section documents all versions of the Lambda code used during learning, including their purpose, limitations, and why improvements were needed.**

#### 🧪 Version 1 — Strict Input Validation (Initial Learning Version)

#### 📌 Purpose

- Learn basic API → Lambda → SQS flow

- Enforce strict input requirements

- Understand how missing fields cause failures

#### 🧠 Key Behavior

- Requires customer_name, item, and quantity

- Fails if any field is missing

- Explicitly converts quantity to integer

- Returns HTTP 400 for client errors

#### ⚠️ Limitation

- No default values

- No CORS header on error

- Not user-friendly for real APIs

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        message = {
            "customer_name": body["customer_name"],
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        return {
            "statusCode": 202,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }
```        

#### 🧪 Version 2 — Safer Defaults (Improved Usability Version)

#### 📌 Purpose

- Allow optional customer_name

- Avoid breaking API if field is missing

- Improve user experience

#### 🧠 Key Behavior

- Defaults customer_name to "Guest"

- Keeps API functional even if field missing

- Always returns CORS headers

#### ⚠️ Limitation

- Does NOT convert quantity to integer

- Incorrect use of HTTP 500 for client errors

- Still lacks full validation

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": body["quantity"]
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

#### ✅ Version 3 — Final Merged & Production-Ready (Recommended)

#### 📌 Purpose

- Combine strict validation + safe defaults

- Follow real-world serverless best practices

- Clean separation between API Lambda and Worker Lambda

- Suitable for interviews, demos, and production labs

#### 🧠 Key Improvements

✔ Input validation

✔ Default values

✔ Type safety

✔ Correct HTTP status codes

✔ Proper CORS handling

✔ Clean SQS message format

#### 💻 Final Code (Recommended for This Lab)

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))

        # Validate required fields
        if "item" not in body or "quantity" not in body:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Missing required fields: item, quantity"})
            }

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        # Send message to SQS
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order accepted",
                "order": order
            })
        }

    except ValueError:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Quantity must be a number"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```
#### 🧠 Learning Summary (Why This Matters)

| Version | What You Learned             |
| ------- | ---------------------------- |
| v1      | Strict validation & failures |
| v2      | Defaults & API safety        |
| v3      | Real-world production design |


> **API Lambda validates and enqueues.**
> **Worker Lambda processes and writes to RDS.**

**✅ This separation is core serverless architecture.**

---



