# Charlie Cafe - OrderStatusLambda

### ✅ 1️⃣ Difference Between the Two Lambda Functions

🔹 CafeOrderStatusLambda

🔹 OrderStatusLambda

👉 Code Comparison

After reviewing both code blocks carefully:

They are 100% identical.

There is:

No logic difference

No SQL difference

No response difference

Same secret name (CafeDevDBSM)

Same query handling

Same output format

The only difference is the Lambda function name:

CafeOrderStatusLambda

OrderStatusLambda

Functionally, they do the exact same thing.

### ✅ 2️⃣ Difference Between Their API Gateway Endpoints

You created two different API routes:

🔹 API 1

```
GET /cafe-order-status
→ CafeOrderStatusLambda
```

Example:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status
```

🔹 API 2

```
GET /order-status
→ OrderStatusLambda
```

### 🔎 So What’s the Real Difference?

| Feature     | CafeOrderStatus       | OrderStatus       |
| ----------- | --------------------- | ----------------- |
| Lambda Name | CafeOrderStatusLambda | OrderStatusLambda |
| API Route   | `/cafe-order-status`  | `/order-status`   |
| Logic       | Same                  | Same              |
| Database    | Same                  | Same              |
| Output      | Same                  | Same              |

The difference is purely:

Different endpoint path
Different Lambda name
But identical backend logic

### ✅ 3️⃣ Can We Merge These Two Lambda Functions?

✔ YES — and you absolutely should.

Because:

Same logic

Same database

Same response format

No reason to maintain duplicate code

Easier maintenance

Lower AWS Lambda management overhead

### 🎯 Best Practice Solution

#### ✅ Option 1 (Recommended)

Keep one Lambda function (e.g., OrderStatusLambda)

Then attach BOTH API routes to the SAME Lambda.

In API Gateway:

```
GET /order-status
GET /cafe-order-status
```

Both → OrderStatusLambda

This way:

One codebase

Two URLs (if needed for backward compatibility)

Clean architecture

#### ✅ Option 2 (Even Cleaner)

Remove one endpoint completely and standardize on:

```
GET /order-status
```

Simpler. Cleaner. Professional.

### 🏗 Architecture Recommendation (Production Level)

Instead of:

```
Lambda 1 → /cafe-order-status
Lambda 2 → /order-status
```

Use:

```
One Lambda → Multiple Routes (if needed)
```

This follows proper microservice design inside:

AWS Lambda

Amazon API Gateway

### ⚠ Important Note

Having two identical Lambdas means:

Double deployments

Double debugging effort

Risk of future inconsistency

More maintenance cost

This is not recommended in production systems.

### 🧠 Final Answer Summary

✔ There is NO difference in code
✔ The only difference is endpoint path and Lambda name
✔ Yes, you can merge them
✔ Best practice: Use one Lambda for both routes

### 🎯 What You Should Do

Since both:

CafeOrderStatusLambda

OrderStatusLambda

have identical code
and both API endpoints do the same thing,

👉 Keep only one Lambda and one API route.

### ✅ Recommended Cleanup Plan
Step 1 — Decide Which Name To Keep

Between:

/cafe-order-status

/order-status

### 🔥 Best practice:

Keep:

```
/order-status
```

It’s:

Shorter

Cleaner

More REST-like

More scalable

Step 2 — Delete the Duplicate Resources

Remove:

The duplicate Lambda function

The duplicate API resource in API Gateway

Any unused permissions

Inside:

AWS Lambda

Amazon API Gateway

### ⚠ Important Before Deleting

Before deleting anything:

Make sure no frontend / Postman / mobile app is using the old endpoint.

Test the one you're keeping.

Confirm production traffic isn’t hitting the one you plan to delete.

If this is just a dev project → you’re safe to remove immediately.

### 🧠 Why This Is Good Practice

Keeping duplicate Lambdas causes:

Confusion

Double maintenance

Future bugs when one gets updated and the other doesn’t

Higher cognitive load

Production systems should always follow:

One responsibility → One function

### 🚀 Final Answer

Yes.
If they are 100% identical:

✅ Delete one Lambda
✅ Delete its API Gateway resource
✅ Keep only one clean endpoint

That’s the correct architectural decision.

----

## OrderStatusLambda Configurations


### 1️⃣ API Gateway – SECURE Cognito AUTH Authorizer (MOST IMPORTANT) 

- **AWS Console → API Gateway → REST API → /order-status**

### 1️⃣ Resource & Method

- Go to Resources → /order-status

- If GET method does not exist → click Actions → Create Method → GET

```
GET /order-status
```

- Select Lambda Proxy Integration



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


**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ Lambda Functions 

### 1️⃣ CREATE New Lambda Functions 

### 1️⃣ CREATE OrderStatusLambda

- **AWS Console → Lambda → Create Function → Author from scratch**

- **Function name:** OrderStatusLambda

- **Runtime:** Python 3.12

- **Permissions:** Create new role with basic Lambda permissions

### 1️⃣ ✅ FINAL LAMBDA CODE (Python 3.12)

> 🔁 This is a drop-in replacement
> Nothing else needs to change

[OrderStatusLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda/CafeOrderStatusLambda.py)

### 2️⃣ 🔐 Attach Lambda Layer

- Same 

### 3️⃣ 🔐 Edit VPC

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



**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---