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