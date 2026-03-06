import json
import os
import urllib.parse
import urllib.request

COGNITO_DOMAIN = os.environ["COGNITO_DOMAIN"]
CLIENT_ID = os.environ["COGNITO_CLIENT_ID"]
REDIRECT_URI = os.environ["COGNITO_REDIRECT_URI"]

def lambda_handler(event, context):

    try:

        body = json.loads(event["body"])
        code = body["code"]

        data = urllib.parse.urlencode({
            "grant_type": "authorization_code",
            "client_id": CLIENT_ID,
            "redirect_uri": REDIRECT_URI,
            "code": code
        }).encode()

        url = f"{COGNITO_DOMAIN}/oauth2/token"

        req = urllib.request.Request(
            url,
            data=data,
            headers={"Content-Type":"application/x-www-form-urlencoded"},
            method="POST"
        )

        response = urllib.request.urlopen(req)
        result = json.loads(response.read())

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS"
            },
            "body": json.dumps(result)
        }

    except Exception as e:

        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": str(e)
            })
        }