import json
import os
from urllib import parse, request, error

def lambda_handler(event, context):
    print("Received event:", event)
    
    try:
        body = json.loads(event.get("body", "{}"))
        code = body.get("code")
        print("Authorization code:", code)

        token_url = f"https://{os.environ['COGNITO_DOMAIN']}/oauth2/token"
        data = {
            "grant_type": "authorization_code",
            "client_id": os.environ["CLIENT_ID"],
            "redirect_uri": os.environ["COGNITO_REDIRECT_URI"],
            "code": code
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        encoded_data = parse.urlencode(data).encode()
        req = request.Request(token_url, data=encoded_data, headers=headers)
        
        with request.urlopen(req) as resp:
            response_text = resp.read().decode()
            print("Cognito response:", response_text)

        return {
            "statusCode": 200,
            "body": response_text,
            "headers": {"Content-Type": "application/json"}
        }

    except error.HTTPError as e:
        err_msg = e.read().decode()
        print("HTTPError:", err_msg)
        return {
            "statusCode": e.code,
            "body": json.dumps({"error": err_msg})
        }
    except Exception as e:
        print("Lambda error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }