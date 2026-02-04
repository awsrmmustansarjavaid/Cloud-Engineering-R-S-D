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
