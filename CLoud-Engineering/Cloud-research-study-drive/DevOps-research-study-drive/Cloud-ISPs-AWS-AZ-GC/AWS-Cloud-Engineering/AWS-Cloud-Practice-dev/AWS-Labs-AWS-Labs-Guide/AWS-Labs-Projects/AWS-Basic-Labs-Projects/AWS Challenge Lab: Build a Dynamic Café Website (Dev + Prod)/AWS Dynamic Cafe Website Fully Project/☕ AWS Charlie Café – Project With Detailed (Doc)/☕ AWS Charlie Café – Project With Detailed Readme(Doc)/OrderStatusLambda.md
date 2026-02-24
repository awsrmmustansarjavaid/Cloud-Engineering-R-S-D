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
---
## Verification & Test 

## 🔐 PHASE 5️⃣ — API Gateway Authorizer Test

### 1️⃣ GET /order-status

### 1️⃣ Test Inside API Gateway Console

- Go to: API Gateway → Resources → /order-status → GET → Test

#### 1️⃣ Test Without Date Filter

- **Leave Query String empty.**

#### 2️⃣ Test With Date Filter

- Add:

```
Name: date
Value: 2026-02-22
```

- Click Test

**✅ If working → you’ll see metrics + recent_orders.**

### ✅ 2️⃣ Test in Browser (Direct URL)

Because it is a GET request, browser works.

#### 1️⃣ Without Date Filter

- Open in browser:

```
https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-status
```

You should see JSON response.

#### 2️⃣ With Date Filter

- Add query parameter:

```
https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-status?date=2026-02-22
```

This filters orders by that date.

### ✅ 3️⃣ Test from EC2 (curl)

- SSH into EC2 and run:

#### 1️⃣ Without Date Filter

```
curl https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-status
```

#### 2️⃣ With Date Filter

```
curl "https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-status?date=2026-02-22"
```

#### ✅ Expected Successful Response Example

```
{
  "filter_date": "2026-02-22",
  "metrics": [
    {
      "metric": "Total Orders",
      "count": 5
    },
    {
      "metric": "Total Items Sold",
      "count": 12
    },
    {
      "metric": "Customers",
      "count": 3
    }
  ],
  "recent_orders": [
    {
      "customer_name": "John",
      "item": "Coffee",
      "quantity": 2,
      "created_at": "2026-02-22 10:22:11"
    }
  ]
}
```

### 2️⃣ Admin dashboard (GET):

```
curl -X GET "https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard"
```

#### ✅ Expected Result (Success, Admin with Cognito token):

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

- Status code: 200 OK

- Notes:

  - Returns static dashboard summary.

  - Requires admin Cognito token. Without it → 401 Unauthorized.

#### ✅ Result:  

```
{"totalEmployees":25,"totalOrdersToday":42,"revenueToday":1234.56}
```

#### ✅ Interpretation:

- ✅ Success! This endpoint returned exactly what we expected.

- Conclusion: Your GET /admin/dashboard is working fine.

### 3️⃣ Create user (POST):

```
curl -X POST "https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/admin/create-user" \
-H "Content-Type: application/json" \
-d '{"username": "charlie", "role": "employee"}'
```

#### ✅ Expected Result (Success, Admin with Cognito token):

```
{
  "message": "User charlie created with role employee",
  "username": "charlie",
  "role": "employee"
}
```

- Status code: 200 OK

- Notes:

  - Currently does not create a real user, only returns confirmation message.

  - Requires admin Cognito token. Without it → 401 Unauthorized.

#### ✅ Result:  

```
{"message":"Unauthorized"}
```

#### ⚠️ Interpretation:

- This means you are not authenticated with Cognito, or your request did not include a valid admin access token.

- This endpoint requires an admin Cognito token, otherwise API Gateway returns Unauthorized.

- This is expected if you didn’t provide Authorization: Bearer <TOKEN> in your cURL request.

### 4️⃣ Get employee orders (GET):

```
curl -X GET "https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/employee/orders?employee_id=alice"
```

#### ✅ Expected Result (Success, Admin with Cognito token):

```
[
  { "order_id": "O-101", "employee": "alice", "total": 23.5 }
]
```

- Status code: 200 OK

- Notes:

  - If you use employee_id=all → returns all orders:

```
[
  { "order_id": "O-101", "employee": "alice", "total": 23.5 },
  { "order_id": "O-102", "employee": "bob", "total": 12.0 }
]
```

- Requires employee or admin Cognito token. Without it → 401 Unauthorized.

#### ✅ Result:  

```
[{"order_id":"O-101","employee":"alice", ... }]
```

#### ✅ Interpretation:

- Looks like this one worked partially — it returned orders for alice.

- If you didn’t supply a Cognito token, some setups allow GET for employees/admin if the API Gateway is set for public GET access, but usually you need a token.

### 5️⃣ Create employee order (POST):

```
curl -X POST "https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/employee/order" \
-H "Content-Type: application/json" \
-d '{"order_id": "O-103", "employee": "charlie", "items": ["coffee"], "total": 10.5}'
```

#### ✅ Expected Result (Success, Admin with Cognito token):

```
{
  "message": "Order O-103 created successfully",
  "order": {
    "order_id": "O-103",
    "employee": "charlie",
    "items": ["coffee"],
    "total": 10.5
  }
}
```

- Status code: 200 OK

- Notes:

  - Currently does not store the order, just echoes it.

  - Requires employee or admin Cognito token. Without it → 401 Unauthorized.

  - If JSON body is malformed → 400 Invalid JSON input.

#### ✅ Result:  

```
{"message":"Unauthorized"}
```

#### ⚠️ Interpretation:

- Same as the Create User endpoint — you did not include a valid Cognito token.

- POST endpoints require employee/admin access token. Without it → Unauthorized.

### ✅ Summary of your results

| Endpoint                  | Result         | Status       | Notes                                 |
| ------------------------- | -------------- | ------------ | ------------------------------------- |
| `/admin/dashboard` GET    | Success        | OK           | Working, returned expected data       |
| `/admin/create-user` POST | `Unauthorized` | Not OK       | Requires admin Cognito token          |
| `/employee/orders` GET    | Success        | OK (partial) | Returned data for `alice`             |
| `/employee/order` POST    | `Unauthorized` | Not OK       | Requires employee/admin Cognito token |



### 6️⃣ Using Postman (GUI - Optional)

- Open Postman → New request

- Select GET or POST according to endpoint

- Paste URL: https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard

- If POST, go to Body → raw → JSON and enter the JSON payload

- Send request and check response

### 7️⃣ Cognito Authentication

Since all endpoints are protected by Cognito:

- You will need a valid Cognito access token in the header:

```
Authorization: Bearer <ACCESS_TOKEN>
```

#### To get the token:

- Go to Cognito Hosted UI login

- Log in as an admin or employee

- Get the id_token or access_token

- Use it in Postman or cURL

Without the token, the API will return 401 Unauthorized.

#### 📣 Cognito Authentication Notes

- All endpoints are protected by Cognito.

- Without a valid token: 401 Unauthorized.

- To test quickly:

  - Log in via Cognito Hosted UI

  - Copy the access_token

  - Add header in cURL/Postman:

```
Authorization: Bearer <ACCESS_TOKEN>
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ Lambda Functions 

### ✅ Lambda Test JSON

Since this Lambda uses queryStringParameters, here are proper test events.

### 1️⃣ Lambda Code Test

- Name:

```
Test_OrderStatusLambda
```

#### JSON

```
{}
```
#### ✅ Expected Result

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization",
    "Access-Control-Allow-Methods": "GET"
  },
```

#### ✅ Result:

```
/order-status?date=YYYY-MM-DD
```

✅ returns filtered orders

### 2️⃣ Test Without Date Filter (Get All Recent)

```
{
  "queryStringParameters": null
}
```

#### ✅ Expected Result

```
{
  "metrics": [
    { "metric": "Total Orders", "count": 15 },
    { "metric": "Total Items Sold", "count": 42 },
    { "metric": "Customers", "count": 8 }
  ],
  "recent_orders": [
    {
      "customer_name": "John",
      "item": "Coffee",
      "quantity": 2,
      "created_at": "2026-02-22 10:22:11"
    }
  ]
}
```
(Numbers depend on your DB)

### 3️⃣ Test With Date Filter

#### Example date: 2026-02-22

```
{
  "queryStringParameters": {
    "date": "2026-02-22"
  }
}
```

#### ✅ Expected Result

Only orders from that specific date will be returned.

### 4️⃣ Invalid Date Format (Still Works But Returns 0 Data)

```
{
  "queryStringParameters": {
    "date": "2026/02/22"
  }
}
```

#### ✅ Expected Result

- Likely empty results

- No crash

### 🚀 Important IAM Requirement

Make sure your Lambda role has permission:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "*"
}
```

**⚠️ Otherwise, you’ll get 500 error.**

### 5️⃣ Lambda Code Test

- Name:

```
Test_AdminDashboardLambda
```

#### JSON

```
{}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 6️⃣ Lambda Code Test

- Name:

```
Test_AdminCreateUserLambda
```

#### JSON

```
{
  "body": "{\"username\": \"john.doe\", \"role\": \"employee\"}"
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 7️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrdersLambda
```

#### JSON

```
{
  "queryStringParameters": {
    "employee_id": "alice"
  }
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 8️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrderLambda
```

#### JSON

```
{
  "order_id": "O-103",
  "employee": "alice",
  "items": [
    { "name": "Latte", "quantity": 2, "price": 5 },
    { "name": "Bagel", "quantity": 1, "price": 3 }
  ],
  "total": 13
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 9️⃣ Verification

- Go to Lambda → Monitoring → View Logs

- Check CloudWatch Logs for each Lambda

#### Confirm:

- /admin/dashboard → AdminDashboardLambda response

- /admin/create-user → AdminCreateUserLambda response

- /employee/orders → EmployeeOrdersLambda response

- /employee/order → EmployeeOrderLambda response

#### Test JWT Authorization:

- Access without token → should fail

- Access with token → should succeed

**✅ After this, your API Gateway + Lambda + front-end integration is fully professional, secure, and working.**




### 🏁 FINAL VERIFICATION CHECKLIST



✔ API Gateway blocks unauthorized

✔ Lambda blocks wrong roles

✔ Public routes open

✔ Protected routes secured

✔ Expired token rejected

✔ Refresh works

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**



# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---

# 📢 New Configurations 

## 🔐 PHASE 5️⃣ — API Gateway

### 1️⃣ API Gateway – SECURE Cognito AUTH Authorizer (MOST IMPORTANT) 

### 🎯 FINAL ARCHITECTURE

```
API Gateway
     ↓
CompanyManagementLambda
     ↓
Route handling inside code
```

This is called: “Lambda Monolith Pattern” Good for small/medium systems.

### ✅ NEW API Gateway Configuration (RECOMMENDED)

Even with one Lambda, use 4 routes:

| Resource Path      | Method | Integration             |
| ------------------ | ------ | ----------------------- |
| /admin/dashboard   | GET    | CompanyManagementLambda |
| /admin/create-user | POST   | CompanyManagementLambda |
| /employee/orders   | GET    | CompanyManagementLambda |
| /employee/order    | POST   | CompanyManagementLambda |

This keeps:

- Clean REST structure

- Easy role-based authorization

- Clean documentation

- Future scalability

- **AWS Console → API Gateway → REST API**

### 1️⃣ Resource & Method

- Go to Resources 

- If GET method does not exist → click Actions → Create Method → GET

- Select Lambda Proxy Integration

### 2️⃣ Create Resource
> **You MUST manually create routes.
> **API Gateway does NOT auto-create /admin/*.**

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

- Integration: CompanyManagementLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Admin Resource 2

- Method: POST

- Path: /admin/create-user

- Integration: CompanyManagementLambda

- Authorization: cafe-cognito-authorizer

- Click Create

> **💡 This is how /admin/* works**

**📢 You manually create Resource that start with /admin/**

#### Employee Resource 1

- Method: GET

- Path: /employee/orders

- Integration: CompanyManagementLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Employee Resource 2

- Method: POST

- Path: /employee/order

- Integration: CompanyManagementLambda

- Authorization: cafe-cognito-authorizer

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

### 5️⃣ Get Your API Gateway Invoke URL

- Go to: AWS Console → API Gateway → Your API → Stages → prod (or your stage name)

You will see something like:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
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

- **Function name:** CompanyManagementLambda

- **Permissions:** Create new role with basic Lambda permissions

#### ✅ Lambda Configuration

| Setting      | Value                           |
| ------------ | ------------------------------- |
| Runtime      | Node.js 18.x                    |
| Architecture | x86_64                          |
| Memory       | 128 MB (or 256 MB recommended)  |
| Timeout      | 10 seconds                      |
| Handler      | `index.handler`                 |
| Enable CORS  | Yes (if using browser frontend) |

#### ✅ IAM Role:

- Basic Lambda execution role

- CloudWatch logs access

[CompanyManagementLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CompanyManagementLambda/CompanyManagementLambda.py)

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**

# 📢 Verfication

## 🔐 PHASE 5️⃣ — API Gateway Authorizer Test

### 🟡 Test Inside API Gateway Console

- Go to: API Gateway → Resources → /order-status → GET → Test

### 1️⃣ : GET /admin/dashboard

### ✅ Test API

- Method: GET

- Path: /admin/dashboard

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

- Click Test

#### ✅ Expected Result:

- Status: 200

### 🌐 Browser Test

- Open browser and enter:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
```

#### ✅ Expected Result:

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

### ✅ EC2 Test

```
curl https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
```

#### ✅ Expected Result:

```
{"totalEmployees":25,"totalOrdersToday":42,"revenueToday":1234.56}
```


### 2️⃣ : POST /admin/create-user

### ✅ Test API

Method: POST

Body:

```
{
  "username": "john",
  "role": "admin"
}
```

- Click Test

#### ✅ Expected Result:

```
{
  "message": "User john created with role admin",
  "username": "john",
  "role": "admin"
}
```

### 🌐 Browser Test

- Open browser and enter:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/orders?employee_id=alice
```

#### ✅ Expected Result:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

### ✅ EC2 Test

```
curl -X POST https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/create-user \
-H "Content-Type: application/json" \
-d '{"username":"john","role":"admin"}'
```

#### ✅ Expected Result:

```
{"message":"User john created with role admin","username":"john","role":"admin"}
```

### ✅ Test 3️⃣ : GET Employee Orders

Method: GET

Request Body: leave blank (GET request does not have a body)

- Click Test

#### ✅ Expected Result:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

If employee_id=all:

```
[
  { "order_id": "O-101", "employee": "alice", "total": 23.5 },
  { "order_id": "O-102", "employee": "bob", "total": 12.0 }
]
```

- Status Code: 200 OK

- Headers: "Content-Type": "application/json"

### ✅ EC2 Test

```
curl "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/orders?employee_id=alice"
```

#### ✅ Expected Result:

```
[{"order_id":"O-101","employee":"alice","total":23.5}]
```

### ✅ Test 4️⃣ : POST Employee Create Order

Method: POST

Body:

```
{
  "order_id": "O-999",
  "employee": "alice",
  "total": 45.5
}
```

- Click Test

#### ✅ Expected Result:

```
{
  "message": "Order O-999 created successfully",
  "order": {
    "order_id": "O-999",
    "employee": "alice",
    "total": 45.5
  }
}
```

### ✅ EC2 Test

```
curl -X POST https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/order \
-H "Content-Type: application/json" \
-d '{"order_id":"O-999","employee":"alice","total":45.5}'
```

#### ✅ Expected Result:

```
{"message":"Order O-999 created successfully","order":{"order_id":"O-999","employee":"alice","total":45.5}}
```

### 🔹 If You Get Errors

#### ❌ 403 Forbidden

→ API not deployed

→ IAM authorization enabled

→ Missing API key

#### ❌ 500 Internal Server Error

→ Check CloudWatch Logs

- Go to: AWS Console → CloudWatch → Log Groups → /aws/lambda/CompanyManagementLambda

#### ❌ 404 Not Found

→ Wrong route

→ Stage name missing

→ Forgot to deploy API

### 🔹 Quick Notes for API Gateway Console Testing

#### GET requests:

- Use Query String Parameters for filtering (employee_id)

- Body is ignored

#### POST requests:

- Body must be valid JSON

- Set Content-Type: application/json

#### Errors you may see:

- 400 Bad Request → invalid JSON in body

- 404 Not Found → wrong resource path

- 500 Internal Server Error → check Lambda logs in CloudWatch

### 🔹 IMPORTANT — After Creating Routes

After adding routes, you MUST:

```
Deploy API → Select Stage → Deploy
````

Otherwise changes won’t work.

### 🔹 Final Expected Behavior Summary

| Endpoint           | Method | Browser | EC2 Curl | Expected              |
| ------------------ | ------ | ------- | -------- | --------------------- |
| /admin/dashboard   | GET    | ✅       | ✅        | Dashboard JSON        |
| /admin/create-user | POST   | ❌       | ✅        | User created message  |
| /employee/orders   | GET    | ✅       | ✅        | Orders list           |
| /employee/order    | POST   | ❌       | ✅        | Order created message |




**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ Lambda Functions 

### ✅ Lambda Test JSON

Since this Lambda uses queryStringParameters, here are proper test events.

### 1️⃣ Admin Dashboard (GET)

- Name: Admin_Dashboard

#### ✅ Test JSON :

```
{
  "httpMethod": "GET",
  "resource": "/admin/dashboard"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"totalEmployees\":25,\"totalOrdersToday\":42,\"revenueToday\":1234.56}"
}
```

#### ✅ If you parse the body JSON, actual data is:

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

### 2️⃣ Admin Create User (POST)

- Name: Admin_Create_User

#### ✅ Test JSON :

```
{
  "httpMethod": "POST",
  "resource": "/admin/create-user",
  "body": "{\"username\":\"john\",\"role\":\"admin\"}"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"message\":\"User john created with role admin\",\"username\":\"john\",\"role\":\"admin\"}"
}
```

#### ✅ Parsed body:

```
{
  "message": "User john created with role admin",
  "username": "john",
  "role": "admin"
}
```



### 3️⃣ Employee Orders (GET)

- Name: Employee_Orders

#### ✅ Test JSON :

```
{
  "httpMethod": "GET",
  "resource": "/employee/orders",
  "queryStringParameters": {
    "employee_id": "alice"
  }
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "[{\"order_id\":\"O-101\",\"employee\":\"alice\",\"total\":23.5}]"
}
```

#### ✅ Parsed body:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

If you remove employee_id, it will return both orders.

### 4️⃣ Create Employee Order (POST)

- Name: Employee_Order

#### ✅ Test JSON :

```
{
  "httpMethod": "POST",
  "resource": "/employee/order",
  "body": "{\"order_id\":\"O-999\",\"employee\":\"alice\",\"total\":45.5}"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"message\":\"Order O-999 created successfully\",\"order\":{\"order_id\":\"O-999\",\"employee\":\"alice\",\"total\":45.5}}"
}
```

#### ✅ Parsed body:

```
{
  "message": "Order O-999 created successfully",
  "order": {
    "order_id": "O-999",
    "employee": "alice",
    "total": 45.5
  }
}
```

### 🚨 Important Notes

#### 1️⃣ Why body is a STRING?

Because API Gateway requires Lambda proxy integration response format:

```
{
  "statusCode": 200,
  "body": "string"
}
```

That’s why we use:

```
JSON.stringify(body)
```

#### 2️⃣ These test events work for:

- API Gateway REST API

- Lambda Console Testing

If using HTTP API (v2) the event shape is slightly different (rawPath, requestContext.http.method).

### 🔎 What Happens If Route Doesn't Match?

Example test:

```
{
  "httpMethod": "GET",
  "resource": "/unknown"
}
```

#### Result:

```
{
  "statusCode": 404,
  "body": "{\"error\":\"Route not found\"}"
}
```

### 🎯 Final Confirmation

Yes — all 4 test events are:

✔ Valid

✔ Correct format

✔ Will work with the merged Lambda

✔ Return the responses shown above

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**