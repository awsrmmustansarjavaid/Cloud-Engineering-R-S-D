# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System



### ☕ AWS Charlie Café – Test & Verifications

[Secure Charlie Cafe Dashboard System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)


---

## 🔐 PHASE 2️⃣ — API Gateway

### 1️⃣ API Gateway – SECURE Cognito AUTH Authorizer (MOST IMPORTANT) 

- **AWS Console → API Gateway → REST API → /order-status**

### 1️⃣ Resource & Method

- Go to Resources → /order-status

- If GET method does not exist → click Actions → Create Method → GET

```
GET /order-status
```

- Select Lambda Proxy Integration

- Lambda function → OrderStatusLambda

### 2️⃣ Create Resource
> **You MUST manually create routes.
> **API Gateway does NOT auto-create /admin/*.**

#### Overview of your resources and Lambda mapping

| Resource Path        | Method | Lambda Function        | Notes               |
| -------------------- | ------ | ---------------------- | ------------------- |
| `/admin/dashboard`   | GET    | AdminDashboardLambda*  | Admin only          |
| `/admin/create-user` | POST   | AdminCreateUserLambda* | Admin only          |
| `/employee/orders`   | GET    | EmployeeOrdersLambda*  | Employee + Admin    |
| `/employee/order`    | POST   | EmployeeOrderLambda*   | Employee + Admin    |
| `/order-status`      | GET    | OrderStatusLambda      | Order status checks |

**You’ll need to create separate Lambdas for admin/employee if not already done.**

- Go to: API Gateway → Resource → Click Create

| Resource               | Method | Auth    |
| -------------------- | ------ | ------- |
| `/order-status`      | GET    | No Cognito |
| `/admin/dashboard`   | GET    | Cognito |
| `/admin/create-user` | POST   | Cognito |
| `/employee/orders`   | GET    | Cognito |
| `/employee/order`    | POST   | Cognito |

> **✔ Attach CafeCognitoAuthorizer to ALL protected Resource**

#### Admin Resource 1

- Method: GET

- Path: /admin/dashboard

- Integration: AdminDashboardLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Admin Resource 2

- Method: POST

- Path: /admin/create-user

- Integration: AdminCreateUserLambda

- Authorization: cafe-cognito-authorizer

- Click Create

> **💡 This is how /admin/* works**

**📢 You manually create Resource that start with /admin/**

#### Employee Resource 1

- Method: GET

- Path: /employee/orders

- Integration: EmployeeOrdersLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Employee Resource 2

- Method: POST

- Path: /employee/order

- Integration: EmployeeOrderLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### order-status Resource 1

- Method: GET

- Path: /order-status

- Integration: OrderStatusLambda

- Authorization: no need because its public

- Click Create


#### Attach this authorizer to your Resource

/admin/*

/employee/*

or /api/*

**✔ Now API Gateway blocks unauthenticated users**

### 3️⃣ Create Authorizer in API Gateway

- Go to: API Gateway → CafeOrdersAPI

- Authorizers → Create Authorizer

- Configure:

  - Type → Cognito

  - Name → CafeCognitoAuthorizer

  - User Pool → select your pool

  - Token source → Authorization

- Save.

### 4️⃣ Attach Cognito Authorizer in API Gateway

- Now attach this authorizer ONLY to:

```
/admin/*
/employee/*
```

- ❌ Do NOT attach to:

```
/public/*
```

### 🔥 FINAL ARCHITECTURE RESULT

```
/public/orders                → No authorizer
/public/order-status          → No authorizer

/admin/dashboard              → Cognito authorizer
/admin/orders                 → Cognito authorizer
/admin/mark-paid              → Cognito authorizer

/employee/orders              → Cognito authorizer
/employee/order               → Cognito authorizer
```

Then inside Lambda:

- Validate group

- Enforce authorization

### ❓ IMPORTANT CHANGE FROM YOUR OLD SETUP

OLD:

```
response_type=token
Implicit grant
```

NEW (recommended):

```
response_type=code
Authorization code grant
```

#### ⚠️ You must update your central-auth-api.js accordingly.

### 5️⃣ Enable CORS (Cross-Origin Resource Sharing)

> **These are two separate things — enabling CORS is for frontend browser calls.**

- Click GET → Actions → Enable CORS

- A popup appears:

  - Check “Replace existing CORS headers” ✅

- Click Enable CORS

- Confirm popup: “Yes, replace existing headers” ✅

> **This allows your frontend JS (from CloudFront) to call API Gateway without CORS errors.**

✔ Enable CORS on each method

✔ Especially for GET /order-status

### 6️⃣ Deploy API

- **Click Actions → Deploy API**

- **Stage: prod**

- **Save Invoke URL**

✔ Deploy after every change

✔ Stage can be prod

✔ Frontend URL must match stage

#### 📌 Copy new endpoint API URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status
```

#### 👉 Paste this into frontend once

#### 🔁 Update frontend:

```
API_URL = ".../prod/order-status"
```

#### ✅ Result:

- ❌ No login → 401


- ✅ Login → data loads


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 3️⃣ Lambda Functions 

### 1️⃣ CREATE New Lambda Functions 

### 1️⃣ CREATE OrderStatusLambda

- **AWS Console → Lambda → Create Function → Author from scratch**

- **Function name:** OrderStatusLambda

- **Runtime:** Python 3.12

- **Permissions:** Create new role with basic Lambda permissions

#### 1️⃣ ✅ FINAL LAMBDA CODE (Python 3.12)

> 🔁 This is a drop-in replacement
> Nothing else needs to change

[OrderStatusLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/OrderStatusLambda.py)

#### 3️⃣ 🔐 Add Environment Variables

```
DB_HOST = <your-rds-endpoint>
DB_USER = cafe_user
DB_PASS = <your-db-password>
DB_NAME = cafe_db
```

#### 4️⃣ 🔐 Attach Lambda Layer

- Same 

#### 5️⃣ 🔐 Edit VPC

- Same 

> **⚠️ Make sure DB_HOST points to your RDS MySQL/MariaDB instance.**

### 2️⃣ CREATE AdminDashboardLambda

- **Function name:** AdminDashboardLambda

- **Runtime:** Node.js 18.x

[AdminDashboardLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminDashboardLambda.js)

### 3️⃣ CREATE AdminCreateUserLambda

- **Function name:** AdminCreateUserLambda

- **Runtime:** Node.js 18.x

[AdminCreateUserLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminCreateUserLambda.js)

### 4️⃣ CREATE EmployeeOrdersLambda

- **Function name:** EmployeeOrdersLambda

- **Runtime:** Node.js 18.x

[EmployeeOrdersLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/EmployeeOrdersLambda.js)


### 5️⃣ CREATE EmployeeOrderLambda

- **Function name:** EmployeeOrderLambda

- **Runtime:** Node.js 18.x

[EmployeeOrderLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/EmployeeOrderLambda.js)



**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 4️⃣ 