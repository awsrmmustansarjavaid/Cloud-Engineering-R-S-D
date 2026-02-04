# Charlie Cafe - Central Backend RBAC
> **This version is production-grade, easy to read, and safe by default.**


### Central Backend RBAC
> **Update Version:1.0**

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

---

### Central Backend RBAC
> **Update Version:1.01**

✔️ Added central-auth-api.js

✔️ permissions.json


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
