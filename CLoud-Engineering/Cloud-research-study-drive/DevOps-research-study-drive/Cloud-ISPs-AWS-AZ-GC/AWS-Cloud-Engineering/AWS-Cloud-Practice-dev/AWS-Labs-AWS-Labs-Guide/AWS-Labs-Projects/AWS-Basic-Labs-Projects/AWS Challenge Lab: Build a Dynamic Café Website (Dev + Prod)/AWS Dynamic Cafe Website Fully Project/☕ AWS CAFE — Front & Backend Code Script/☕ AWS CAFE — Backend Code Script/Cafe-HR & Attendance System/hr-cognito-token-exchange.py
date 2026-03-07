import json
import urllib.parse
import urllib.request
import os

def lambda_handler(event, context):

    body = json.loads(event.get("body", "{}"))
    code = body.get("code")

    data = urllib.parse.urlencode({
        "grant_type": "authorization_code",
        "client_id": os.environ["CLIENT_ID"],
        "redirect_uri": os.environ["COGNITO_REDIRECT_URI"],
        "code": code
    }).encode()

    url = "https://" + os.environ["COGNITO_DOMAIN"] + "/oauth2/token"

    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )

    try:
        response = urllib.request.urlopen(req)
        result = response.read().decode()

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": result
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(str(e))
        }