# Charlie Cafe - Central Auth API 

### 🧠 BIG PICTURE (READ THIS FIRST)

You now have TWO central auth systems, each with a clear job:

### 🖥️ Frontend — central-auth-api.js

Responsible for:

Login / Logout

Storing token

Attaching token to API calls

Hiding pages from wrong users (UX)

#### ❌ Frontend does NOT enforce security
#### ✅ It only helps user experience

### ☁️ Backend — rbac.py

Responsible for:

Reading Cognito claims (from API Gateway)

Deciding who can access which API

Blocking access (REAL security)

#### ✅ Backend is the final authority

### 🔒 API Gateway (THE BRIDGE)

Validates JWT with Cognito

Passes user info to Lambda

Calls your Lambda

### 🧩 FINAL FLOW (THIS IS THE KEY)

```
Browser
  ↓
central-auth-api.js
  ↓ Authorization: Bearer <JWT>
API Gateway
  ↓ (Cognito Authorizer validates token)
Lambda
  ↓
rbac.py → ALLOW or DENY
```

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

1️⃣ Convert rbac.py into a Lambda Layer
2️⃣ Add permission matrix (JSON-based)
3️⃣ Add route → role mapping
4️⃣ Show how Lambdas use it
5️⃣ Show how to test & verify

### 🧠 FINAL ARCHITECTURE

```
Lambda Layer: cafe-rbac-layer
│
├── rbac.py              ← logic
├── permissions.json     ← who can access what
```
Every Lambda:

Imports RBAC from the layer

Calls ONE function

No duplication

No merge hell

### 1️⃣ Convert rbac.py into a Lambda Layer

Step 1: Create local folder structure (VERY IMPORTANT)

Lambda Layers require exact folder names.

```
cafe-rbac-layer/
└── python/
    ├── rbac.py
    └── permissions.json
```

👉 python/ folder name is MANDATORY

Step 2: Final rbac.py (Layer version)

📄 python/rbac.py

```
# =====================================================
# CENTRAL RBAC ENGINE (LAMBDA LAYER)
# =====================================================

import json
import os

# Load permission matrix ONCE (cold start)
PERMISSIONS_FILE = os.path.join(os.path.dirname(__file__), "permissions.json")

with open(PERMISSIONS_FILE) as f:
    PERMISSIONS = json.load(f)


def get_user_context(event):
    """
    Extract user info from Cognito Authorizer
    JWT already validated by API Gateway
    """

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
    except KeyError:
        return None

    groups = claims.get("cognito:groups", "")
    if isinstance(groups, str):
        groups = groups.split(",")

    return {
        "username": claims.get("cognito:username"),
        "groups": groups
    }


def authorize(event):
    """
    Universal authorization function
    - Reads API path
    - Matches permission matrix
    - Validates role
    """

    user = get_user_context(event)
    if not user:
        return False, "Unauthenticated"

    path = event.get("path", "")

    for rule in PERMISSIONS:
        if path.startswith(rule["path"]):
            allowed_roles = rule["roles"]

            if any(role in user["groups"] for role in allowed_roles):
                return True, user

            return False, "Access denied"

    # No matching rule → deny by default
    return False, "Access denied"
```

📌 Important rule:

❌ No rule = ❌ No access
This is secure by default.

2️⃣ Permission Matrix (JSON-based)

This replaces hardcoded if/else forever.

📄 python/permissions.json

```
[
  {
    "path": "/order-status",
    "roles": ["admin"]
  },
  {
    "path": "/employee",
    "roles": ["admin", "employee"]
  },
  {
    "path": "/attendance",
    "roles": ["admin", "employee"]
  },
  {
    "path": "/hr",
    "roles": ["admin"]
  },
  {
    "path": "/sales",
    "roles": ["admin"]
  }
]
```

Why this is powerful

Add new API → no code change

Change permission → edit JSON

Easy to audit

Easy to explain to team

3️⃣ Create the Lambda Layer in AWS
Step-by-step (NO SKIPS)
Step 1: Zip the layer

From inside cafe-rbac-layer folder:

```
zip -r cafe-rbac-layer.zip python
```

Step 2: Create Layer

AWS Console → Lambda → Layers → Create layer

| Field   | Value                 |
| ------- | --------------------- |
| Name    | `cafe-rbac-layer`     |
| Upload  | `cafe-rbac-layer.zip` |
| Runtime | Python 3.12           |

✅ Create

Step 3: Attach Layer to ALL Lambdas

For each Lambda (order, HR, attendance, sales):

Lambda → Layers → Add layer
✔ Custom layers
✔ cafe-rbac-layer
✔ Latest version
✔ Save

4️⃣ Use RBAC in ANY Lambda (SUPER SHORT)

Now your Lambda code becomes tiny and clean.

Example: order_status.py

```
from rbac import authorize
import json

def lambda_handler(event, context):

    allowed, result = authorize(event)

    if not allowed:
        return {
            "statusCode": 403,
            "body": json.dumps({"error": result})
        }

    user = result  # contains username & groups

    # ---- BUSINESS LOGIC ONLY ----
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Order status data",
            "user": user["username"]
        })
    }
```

👉 No role logic
👉 No Cognito parsing
👉 No duplication

5️⃣ How Route → Role Mapping Works (Clear Explanation)

| API Path        | Who decides? | Where            |
| --------------- | ------------ | ---------------- |
| `/order-status` | RBAC Layer   | permissions.json |
| `/hr/*`         | RBAC Layer   | permissions.json |
| `/attendance/*` | RBAC Layer   | permissions.json |
| `/sales/*`      | RBAC Layer   | permissions.json |

API Gateway:

Validates JWT

Calls Lambda

Lambda:

Calls authorize(event)

RBAC layer decides

6️⃣ Testing & Verification (MANDATORY)
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

✅ 200 OK

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

❌ 403 Access denied

🧪 Attendance API — Employee (PASS)

```
{
  "path": "/attendance/checkin",
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

✅ 200 OK

🌐 Real-world test

1️⃣ Login via Cognito
2️⃣ Frontend sends token
3️⃣ API Gateway validates
4️⃣ RBAC layer authorizes
5️⃣ Lambda executes

✔ Exactly like production systems

🟢 FINAL VERDICT (VERY IMPORTANT)

✅ This is enterprise-grade RBAC
✅ One RBAC system for ALL APIs
✅ Zero duplication
✅ Easy to extend
✅ Easy to audit
✅ Fast to maintain

You are now designing systems, not just Lambdas.
---

## New & Updated RBAC with Central-auth-api.js

✅ WHAT WE WILL DELIVER (CLEAR SCOPE)

1️⃣ Updated rbac.py (backend, Lambda Layer ready)
– With clear comments
– Path → role mapping
– Secure-by-default

2️⃣ Updated central-auth-api.js (same file, improved)
– No new JS file
– Roles normalized (important fix)
– Matches backend RBAC logic

3️⃣ Step-by-step configuration guide (NO jumps)
– Cognito
– API Gateway
– Lambda
– Layer
– Testing

1️⃣ UPDATED BACKEND RBAC (rbac.py)

This version is production-grade, easy to read, and safe by default.

📄 rbac.py (Lambda Layer or shared file)

```
# =====================================================
# CHARLIE CAFE — CENTRAL UNIVERSAL RBAC ENGINE
# =====================================================
# • Used by ALL Lambdas
# • Reads Cognito claims (already verified by API Gateway)
# • Applies role-based access using permission matrix
# • Secure-by-default (no rule = no access)
# =====================================================

import json
import os

# -----------------------------------------------------
# Load permissions.json ONCE (cold start optimization)
# -----------------------------------------------------
PERMISSIONS_FILE = os.path.join(os.path.dirname(__file__), "permissions.json")

with open(PERMISSIONS_FILE, "r") as f:
    PERMISSIONS = json.load(f)


def get_user_context(event):
    """
    Extract user identity and roles from Cognito Authorizer.

    API Gateway already:
    ✔ Validated JWT
    ✔ Verified signature
    ✔ Checked expiration
    """

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
    except KeyError:
        # No Cognito authorizer attached
        return None

    groups = claims.get("cognito:groups", [])

    # Cognito sometimes returns groups as comma-separated string
    if isinstance(groups, str):
        groups = groups.split(",")

    return {
        "username": claims.get("cognito:username"),
        "groups": groups
    }


def authorize(event):
    """
    Universal authorization function.

    Steps:
    1️⃣ Get user context
    2️⃣ Identify API path
    3️⃣ Match against permission matrix
    4️⃣ Allow or deny
    """

    user = get_user_context(event)
    if not user:
        return False, "Unauthenticated"

    path = event.get("path", "")

    # Check permission rules
    for rule in PERMISSIONS:
        if path.startswith(rule["path"]):
            allowed_roles = rule["roles"]

            # Role match
            if any(role in user["groups"] for role in allowed_roles):
                return True, user

            return False, "Access denied"

    # 🔐 No matching rule → DENY
    return False, "Access denied"
```

📄 permissions.json (NO code changes needed later)

```
[
  { "path": "/order-status", "roles": ["admin"] },
  { "path": "/attendance",   "roles": ["admin", "employee"] },
  { "path": "/employee",     "roles": ["admin", "employee"] },
  { "path": "/hr",           "roles": ["admin"] },
  { "path": "/sales",        "roles": ["admin"] }
]
```

🔥 Why this is powerful

Add new API → edit JSON only

Security team friendly

Auditable

No hardcoded if/else mess

2️⃣ UPDATED central-auth-api.js (SAME FILE, FIXED)
⚠️ IMPORTANT FIX YOU NEED

Your backend uses:

```
admin
employee
```

But your JS checks:

```
Admin
Employee
```

❌ That will BREAK RBAC.

✅ Updated & corrected version (key parts only)

```
/* =====================================================
   5️⃣ ROLE & ACCESS CONTROL (FIXED + NORMALIZED)
===================================================== */

function getUserRoles() {
    const token = getToken();
    if (!token) return [];

    const payload = parseJwt(token);
    const groups = payload["cognito:groups"] || [];

    // Normalize to lowercase for safety
    return Array.isArray(groups)
        ? groups.map(r => r.toLowerCase())
        : [groups.toLowerCase()];
}

function isAdmin() {
    return getUserRoles().includes("admin");
}

function isEmployee() {
    return getUserRoles().includes("employee");
}

function requireAdmin() {
    if (!isAdmin()) {
        alert("❌ Admin access only");
        auth.logout();
        throw new Error("Admin access required");
    }
}

function requireEmployee() {
    if (!isEmployee() && !isAdmin()) {
        alert("❌ Employee access only");
        auth.logout();
        throw new Error("Employee access required");
    }
}
```

✅ Result

Frontend roles === Backend roles

No mismatch bugs

Same mental model on both sides

3️⃣ HOW A LAMBDA USES RBAC (SUPER SHORT)
Example: order_status.py

```
from rbac import authorize
import json

def lambda_handler(event, context):

    allowed, result = authorize(event)

    if not allowed:
        return {
            "statusCode": 403,
            "body": json.dumps({ "error": result })
        }

    user = result  # username + groups

    # -------------------------------
    # BUSINESS LOGIC ONLY
    # -------------------------------
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Order status data",
            "user": user["username"]
        })
    }
```

👉 No Cognito parsing
👉 No role logic
👉 Clean & readable

4️⃣ STEP-BY-STEP CONFIGURATION (NO SKIPS)
Step 1️⃣ Cognito

Create User Pool

Create groups:

admin

employee

Assign users to groups

Enable Hosted UI

Step 2️⃣ API Gateway

REST API (keep your existing one)

Create routes:

/order-status

/attendance

/hr

Attach Cognito Authorizer

Authorization header: Authorization

Step 3️⃣ Lambda Layer

```
cafe-rbac-layer/
└── python/
    ├── rbac.py
    └── permissions.json
```
```
zip -r cafe-rbac-layer.zip python
```

Upload:

Lambda → Layers → Create layer

Runtime: Python 3.12

Attach to ALL Lambdas

Step 4️⃣ Lambdas

Import authorize

Call it once

Keep business logic unchanged

Step 5️⃣ Frontend

Use same central-auth-api.js

Call:

```
CHARLIE.initProtectedPage();
```

Use:

```
CHARLIE.requireAdmin();
```

5️⃣ TESTING & VERIFICATION
🧪 Admin → order-status (PASS)

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

✅ 200 OK

🧪 Employee → order-status (FAIL)

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

❌ 403 Access denied

🌍 Real world

Login via Hosted UI

Token auto attached

API Gateway validates

RBAC layer authorizes

Lambda runs

🟢 FINAL VERDICT (IMPORTANT)

✅ You DO NOT need new JS files
✅ You DO NOT need merged Lambdas
✅ You DO have universal RBAC
✅ This matches frontend & backend perfectly
✅ This is enterprise-grade architecture

You are no longer “just coding” —
you are designing systems now 👏

---

