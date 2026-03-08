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

---
### Central Backend RBAC
> **Update Version:1.2**

✔️ ONE CLI script to attach RBAC layer to ALL Lambdas

✔️ Audit logging inside RBAC (CloudWatch + optional S3 later)

#### 🧩 PART 1 — AUDIT LOGGING INSIDE RBAC (CORE)

We will log:

- username

- groups

- API path

- decision (ALLOW / DENY)

- timestamp

Logs will go to CloudWatch Logs (default, safe, free tier friendly).

```
import json
import logging
from datetime import datetime

# ---------------------------
# Logger configuration
# ---------------------------
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------
# Load permissions file
# ---------------------------
with open("/opt/python/permissions.json") as f:
    PERMISSIONS = json.load(f)


def authorize(event):
    """
    Central RBAC authorization function
    Used by ALL Lambdas
    """

    # ---------------------------
    # Extract Cognito claims
    # ---------------------------
    claims = event["requestContext"]["authorizer"]["claims"]

    username = claims.get("cognito:username", "unknown")
    groups = claims.get("cognito:groups", "")

    if isinstance(groups, str):
        groups = groups.split(",")

    path = event.get("rawPath", "unknown")

    # ---------------------------
    # Default decision
    # ---------------------------
    decision = "DENY"

    # ---------------------------
    # Check permissions
    # ---------------------------
    for rule in PERMISSIONS:
        if path.startswith(rule["path"]):
            if any(role in groups for role in rule["roles"]):
                decision = "ALLOW"
                break

    # ---------------------------
    # AUDIT LOG (THIS IS THE KEY)
    # ---------------------------
    audit_log = {
        "timestamp": datetime.utcnow().isoformat(),
        "username": username,
        "groups": groups,
        "path": path,
        "decision": decision
    }

    logger.info(json.dumps(audit_log))

    # ---------------------------
    # Final decision
    # ---------------------------
    if decision == "DENY":
        raise PermissionError("Access denied")

    return True
```

####  🔍 What this does 

- Logs EVERY request

- Logs WHO, FROM WHICH ROLE, TO WHICH API

- Logs ALLOW or DENY

- Automatically appears in CloudWatch Logs

---

