import json
import urllib.parse
import urllib.request

COGNITO_DOMAIN = "https://us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com"
CLIENT_ID = "7c5793cnvnbl110ljthmdiohch"
REDIRECT_URI = "https://d2xb54di3chfgj.cloudfront.net/employee-portal.html"

def lambda_handler(event, context):

    body = json.loads(event["body"])
    code = body["code"]

    data = urllib.parse.urlencode({
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "code": code
    }).encode()

    req = urllib.request.Request(
        COGNITO_DOMAIN + "/oauth2/token",
        data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )

    response = urllib.request.urlopen(req)
    result = json.loads(response.read())

    return {
        "statusCode":200,
        "headers":{
            "Access-Control-Allow-Origin":"*"
        },
        "body":json.dumps(result)
    }