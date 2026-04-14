# Charlie Cafe - Web Development


---
## Health Check Endpoint /health.php

👉 A health check endpoint (like /health.php) is:

A simple URL that tells whether your application is running and healthy

Example:

```
http://localhost:8080/health.php
```

### 🎯 2. Why You Need It (In YOUR Project)

In your Charlie Cafe DevOps setup, it helps:

### ✅ 1. CI/CD validation (GitHub Actions)

#### Instead of just:

```
curl http://localhost:8080
```

#### 👉 You check:

```
curl http://localhost:8080/health.php
```

✔ More reliable

### ✅ 2. Docker container monitoring

- Detect if Apache/PHP is working

- Detect DB connectivity

### ✅ 3. Production readiness (VERY IMPORTANT)

#### Later when you use:

- Load balancer

- ECS / Kubernetes

👉 They use health checks to restart broken containers

### ✅ 4. Debugging

#### Instead of guessing:

“Why site not working?”

#### 👉 You instantly know:

- Web OK?

- DB OK?

### ⚙️ 3. Types of Health Checks

| Type     | Meaning          |
| -------- | ---------------- |
| Basic    | App is running   |
| Advanced | App + DB working |

### 🚀 4. FINAL health.php (Production Ready)

#### Create:

```
app/frontend/health.php
```

#### ✅ FULL CODE

```
<?php
// ==========================================================
// ☕ Charlie Cafe - Health Check Endpoint
// ==========================================================

// Set response type
header('Content-Type: application/json');

// -----------------------------
// BASIC CHECK (App running)
// -----------------------------
$status = [
    "status" => "OK",
    "service" => "Charlie Cafe",
    "timestamp" => date("Y-m-d H:i:s"),
];

// -----------------------------
// DATABASE CHECK (Optional but recommended)
// -----------------------------
$db_host = "charlie_db"; // Docker service name
$db_user = "root";
$db_pass = "rootpassword";
$db_name = "cafe_db";

try {
    $conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

    if ($conn->connect_error) {
        throw new Exception("DB connection failed");
    }

    $status["database"] = "connected";

} catch (Exception $e) {
    $status["status"] = "ERROR";
    $status["database"] = "failed";
    http_response_code(500);
}

// -----------------------------
// OUTPUT JSON
// -----------------------------
echo json_encode($status, JSON_PRETTY_PRINT);
```

### 🔍 5. How It Works

#### When you open:

```
http://localhost:8080/health.php
```

#### ✅ If everything is OK:

```
{
  "status": "OK",
  "service": "Charlie Cafe",
  "timestamp": "2026-03-26 12:00:00",
  "database": "connected"
}
```

#### ❌ If DB fails:

```
{
  "status": "ERROR",
  "database": "failed"
}
```

### 🐳 6. Docker Integration (VERY IMPORTANT)

#### Because in your docker-compose.yml:

```
db:
  container_name: charlie_db
```

#### 👉 So PHP connects using:

```
charlie_db
```

✔ Not localhost

✔ Not RDS endpoint

### 🔄 7. Update GitHub CI/CD (IMPORTANT)

#### Replace your test step:

```
- name: 🌐 Test Web Server
  run: |
    sleep 10
    curl -I http://localhost:8080 || exit 1
```

### ✅ With THIS:

```
- name: ❤️ Health Check
  run: |
    sleep 10
    curl -f http://localhost:8080/health.php || exit 1
```

✔ -f fails pipeline if error

✔ Real validation

### ☁️ 8. Production Use (Future)

Later when you deploy:

#### AWS Load Balancer:

```
Health check path: /health.php
```

#### Docker (optional):

You can even add:

```
HEALTHCHECK CMD curl --fail http://localhost/health.php || exit 1
```

### 💡 9. Advanced Version (Optional)

#### You can also check:

- API Gateway

- Lambda response

- Redis (future)

### 📁 10. Final Placement in Your Project

```
app/
└── frontend/
    ├── index.php
    ├── order.php
    └── health.php   ✅ (NEW FILE)
```

### 🎯 Final Benefits (Your Project)

You now get:

✅ Real-time app status

✅ CI/CD validation

✅ Docker health monitoring

✅ Production readiness

✅ Debugging tool

----

