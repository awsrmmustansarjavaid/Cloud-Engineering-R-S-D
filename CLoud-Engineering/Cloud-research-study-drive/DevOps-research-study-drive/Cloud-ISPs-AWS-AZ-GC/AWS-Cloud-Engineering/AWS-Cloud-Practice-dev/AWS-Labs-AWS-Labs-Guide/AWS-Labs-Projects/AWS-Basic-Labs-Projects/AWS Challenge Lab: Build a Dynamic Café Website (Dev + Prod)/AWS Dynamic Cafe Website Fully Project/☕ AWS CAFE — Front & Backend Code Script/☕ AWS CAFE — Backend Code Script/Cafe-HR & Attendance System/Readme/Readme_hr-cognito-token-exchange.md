# Charlie Cafe - hr-cognito-token-exchange

### 🚨 Cognito does NOT allow token exchange from browser JavaScript.

Amazon designed it this way.

Token exchange must be done from:

• Backend
• Lambda
• Server

NOT directly from browser JS.

### ✅ Correct Architecture

```
Browser → API Gateway → Lambda → Cognito /oauth2/token
```

Lambda performs the token exchange and returns the token.

### 🧠 Why AWS does this

Because /oauth2/token requires client authentication and AWS blocks cross-origin calls for security.

So browser JS cannot call it directly.

### 🚀 Correct Flow

```
1️⃣ User clicks login
2️⃣ Cognito Hosted UI login
3️⃣ Cognito redirects:

employee-portal.html?code=XXXX

4️⃣ Browser calls your API:

POST /exchange-token
{
  code: "XXXX"
}

5️⃣ Lambda calls Cognito

/oauth2/token

6️⃣ Lambda returns

{
  id_token: "...",
  access_token: "..."
}

7️⃣ Browser stores token
```

### 🔧 Fix (What You Must Build)

- Create new Lambda: hr-cognito-token-exchange

### Example code:

```
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
```





