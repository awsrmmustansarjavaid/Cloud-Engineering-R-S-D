import json
import urllib.parse
import urllib.request
import os

# ==========================================================
# CHARLIE CAFÉ ☕
# HR — COGNITO TOKEN EXCHANGE LAMBDA
# ----------------------------------------------------------
# Purpose:
# Exchanges Cognito OAuth Authorization Code for ID Token
#
# Flow:
# Employee Portal → API Gateway → Lambda → Cognito Token API
#
# The ID token returned contains user attributes including:
# custom:employee_id
#
# Required Environment Variables:
# CLIENT_ID
# COGNITO_DOMAIN
# COGNITO_REDIRECT_URI
# ==========================================================


# ==========================================================
# STANDARD RESPONSE FUNCTION
# Ensures every response includes CORS headers
# ==========================================================

def response(status, body):

    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",

            # Allow CloudFront / browser requests
            "Access-Control-Allow-Origin": "*",

            # Allow frontend headers
            "Access-Control-Allow-Headers": "Content-Type",

            # Allow POST + OPTIONS (CORS preflight)
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps(body)
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    try:

        # ==================================================
        # HANDLE CORS PREFLIGHT REQUEST
        # Browser sends OPTIONS before POST
        # ==================================================
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})


        # ==================================================
        # PARSE REQUEST BODY
        # Expect JSON:
        # { "code": "authorization_code_from_cognito" }
        # ==================================================
        body = json.loads(event.get("body", "{}"))

        code = body.get("code")

        if not code:
            return response(400, {"error": "Authorization code missing"})


        # ==================================================
        # PREPARE REQUEST TO COGNITO TOKEN ENDPOINT
        # ==================================================

        payload = urllib.parse.urlencode({
            "grant_type": "authorization_code",
            "client_id": os.environ["CLIENT_ID"],
            "redirect_uri": os.environ["COGNITO_REDIRECT_URI"],
            "code": code
        }).encode()


        # Cognito OAuth2 token endpoint
        token_url = "https://" + os.environ["COGNITO_DOMAIN"] + "/oauth2/token"


        # ==================================================
        # CREATE HTTP REQUEST
        # ==================================================
        request = urllib.request.Request(
            token_url,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded"
            }
        )


        # ==================================================
        # SEND REQUEST TO COGNITO
        # ==================================================
        with urllib.request.urlopen(request) as cognito_response:

            result = cognito_response.read().decode()

            token_data = json.loads(result)


        # ==================================================
        # SUCCESS RESPONSE
        # Return tokens back to frontend
        # ==================================================
        return response(200, token_data)


    except urllib.error.HTTPError as e:

        # Cognito returned error
        error_body = e.read().decode()

        return response(500, {
            "error": "Cognito token exchange failed",
            "details": error_body
        })


    except Exception as e:

        # Generic failure
        return response(500, {
            "error": "Token exchange error",
            "details": str(e)
        })