

## Central UNIVERSAL Backend RBAC

### 🧠 First: Correct Mental Model (VERY IMPORTANT)

You already have this on frontend:

```
central-auth-api.js
  ├─ getToken()
  ├─ checkRole()
  ├─ attach Authorization header
```

Now we do the same idea in backend, but cleaner and safer.

#### Backend equivalent options (best → acceptable)

1️⃣ Shared RBAC helper file (recommended)

2️⃣ Lambda Layer (advanced, optional)

3️⃣ Copy-paste RBAC block into every Lambda (last option)

We’ll do Option 1 because:

Fast

Clear

No over-engineering

Perfect for your current project timeline

### ✅ FINAL DESIGN YOU SHOULD USE

```
backend/
├── rbac.py              👈 UNIVERSAL RBAC (new)
├── order_status.py      👈 existing lambda (unchanged logic)
├── hr.py
├── attendance.py
├── sales.py
```

#### Each Lambda:

Imports rbac.py

Calls ONE function

Business logic stays untouched

👉 No giant merged Lambda

👉 No rewrite

👉 Very professional

#### 1️⃣ Create UNIVERSAL backend RBAC file
> **📄 rbac.py (THIS IS YOUR BACKEND central-auth-api)**

```
# rbac.py
# =====================================================
# UNIVERSAL ROLE-BASED ACCESS CONTROL (RBAC)
# =====================================================

def get_user_context(event):
    """
    Extract user identity from Cognito Authorizer
    API Gateway already validated the JWT
    """

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
    except KeyError:
        # No authorizer → unauthenticated
        return None

    username = claims.get("cognito:username")
    groups = claims.get("cognito:groups", "")

    if isinstance(groups, str):
        groups = groups.split(",")

    return {
        "username": username,
        "groups": groups,
        "is_admin": "admin" in groups,
        "is_employee": "employee" in groups
    }


def require_role(user, allowed_roles):
    """
    Check if user has required role
    allowed_roles example: ["admin"] or ["admin", "employee"]
    """

    if not user:
        return False

    user_roles = user["groups"]
    return any(role in user_roles for role in allowed_roles)
```


Why this is powerful

🔁 Reusable everywhere

🧠 Single source of truth

🛡 Same security logic for all APIs

2️⃣ Use RBAC in ANY existing Lambda (short & clean)

Now your order-status Lambda stays mostly the same.

📄 order_status.py

```
import json
import os
import pymysql
from rbac import get_user_context, require_role

# ================= CONFIG =================
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# ================= DB CONNECTION =================
def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# ================= LAMBDA HANDLER =================
def lambda_handler(event, context):

    # -------------------------------------------------
    # 1️⃣ GET USER CONTEXT (CENTRAL RBAC)
    # -------------------------------------------------
    user = get_user_context(event)

    # -------------------------------------------------
    # 2️⃣ AUTHORIZE ACCESS
    # order-status → ADMIN ONLY
    # -------------------------------------------------
    if not require_role(user, ["admin"]):
        return forbidden("Admin access only")

    # -------------------------------------------------
    # 3️⃣ BUSINESS LOGIC (UNCHANGED)
    # -------------------------------------------------
    conn = None
    cursor = None

    try:
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")

        conn = get_connection()
        cursor = conn.cursor()

        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"
        cursor.execute(sql, values)

        return success_response({
            "user": user["username"],
            "recent_orders": cursor.fetchall()
        })

    except Exception as e:
        return error_response(str(e))

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ================= RESPONSES =================
def success_response(data):
    return {
        "statusCode": 200,
        "headers": cors_headers(),
        "body": json.dumps(data, default=str)
    }

def forbidden(message):
    return {
        "statusCode": 403,
        "headers": cors_headers(),
        "body": json.dumps({"error": message})
    }

def error_response(error):
    return {
        "statusCode": 500,
        "headers": cors_headers(),
        "body": json.dumps({"error": error})
    }

def cors_headers():
    return {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Authorization",
        "Access-Control-Allow-Methods": "GET"
    }
```

3️⃣ How HR / Attendance / Sales APIs will look
HR (admin only)

```
if not require_role(user, ["admin"]):
    return forbidden("Admin only")
```

Attendance (admin + employee)

```
if not require_role(user, ["admin", "employee"]):
    return forbidden("Employee access only")
```

Sales report (admin only)

```
if not require_role(user, ["admin"]):
    return forbidden("Admin only")
```

👉 Same RBAC file
👉 Same pattern everywhere

4️⃣ API Gateway configuration (NO CHANGE)

You already did this correctly:

✅ Cognito Authorizer
✅ Attached to routes
✅ JWT validated before Lambda

RBAC = Lambda responsibility only

5️⃣ Testing & Verification (VERY IMPORTANT)
🧪 Lambda Test — Admin (PASS)

```
{
  "path": "/order-status",
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "admin_user",
        "cognito:groups": "admin"
      }
    }
  }
}
```

✅ Expected:

```
200 OK
```

🧪 Lambda Test — Employee (FAIL)

```
{
  "path": "/order-status",
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "emp_user",
        "cognito:groups": "employee"
      }
    }
  }
}
```

❌ Expected:

```
403 Admin access only
```

🧪 Lambda Test — No Token

```
{}
```

❌ Expected:

```
403 Admin access only
```

🌐 Real browser test

1️⃣ Login via Cognito
2️⃣ Token in localStorage
3️⃣ Frontend sends:

```
Authorization: Bearer eyJ...
```

4️⃣ API Gateway validates
5️⃣ Lambda RBAC checks role
6️⃣ Data returns

✔ Production behavior

🟢 FINAL VERDICT (READ THIS TWICE)

✅ YES — you can keep separate Lambdas
✅ YES — you should use central RBAC helper
✅ NO — you do NOT need to merge everything
✅ YES — this is exactly how senior engineers do it
✅ YES — this matches your frontend central-auth-api.js thinking

You are thinking architecturally now, not just coding.

---
