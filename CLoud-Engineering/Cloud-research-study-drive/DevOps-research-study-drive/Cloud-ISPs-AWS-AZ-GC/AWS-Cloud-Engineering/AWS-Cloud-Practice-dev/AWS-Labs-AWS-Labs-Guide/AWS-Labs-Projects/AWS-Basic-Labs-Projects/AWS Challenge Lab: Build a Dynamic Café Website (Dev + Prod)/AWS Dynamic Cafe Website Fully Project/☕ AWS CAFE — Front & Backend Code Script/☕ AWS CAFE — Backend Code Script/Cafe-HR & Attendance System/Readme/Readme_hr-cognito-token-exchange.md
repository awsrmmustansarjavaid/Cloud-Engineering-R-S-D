# Charlie Cafe - hr-cognito-token-exchange

Your frontend code is actually correct now 👍.
The problem is not employee-portal.html anymore. The issue is happening in the Cognito → token exchange step.

From the network data you posted, the key problem is:

#### ⚠️ Your browser never successfully receives the id_token.

So this line later fails:

```
const employeeId =
decoded["custom:employee_id"] ||
decoded["employee_id"] ||
decoded["cognito:username"];
```

Because decoded is never created → token exchange failed.

### 🔎 Root Cause (Very Important)

Your request to Cognito:

```
POST
https://us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com/oauth2/token
```

But there is NO response shown.

This means the request is being blocked by CORS.

And this is expected behaviour.

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

### Then Update Frontend

Change this:

```
fetch(`${CHARLIE_CONFIG.COGNITO_DOMAIN}/oauth2/token`)
```

to

```
fetch(`${CHARLIE_CONFIG.API_BASE}/exchange-token`)
```

### ⚠️ Another Small Issue I Saw

Your Lambda APIs allow only:

```
Access-Control-Allow-Methods: POST,OPTIONS
```

But your frontend likely uses:

```
GET
```

This will break requests.

Better change to:

```
"Access-Control-Allow-Methods": "GET,POST,OPTIONS"
```

### 📊 Current System Status

| Component          | Status              |
| ------------------ | ------------------- |
| Cognito login      | ✅ working           |
| Redirect with code | ✅ working           |
| Token exchange     | ❌ blocked           |
| Employee portal    | ❌ waiting for token |
| Lambda APIs        | ✅ good              |


### 🧑‍💻 Good News

Your architecture is 90% correct already.

You built correctly:

✅ CloudFront

✅ Cognito Hosted UI

✅ Lambda APIs

✅ RDS

✅ Secrets Manager

Only 1 Lambda missing.

----
## hr-cognito-token-exchange



### hr-cognito-token-exchange.py

> **Update Version:1.0**


```






