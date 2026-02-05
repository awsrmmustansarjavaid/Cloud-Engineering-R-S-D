# Charlie Cafe - pymysql-layer

## PHASE 1️⃣ Basic pymysql-layer Configurations

### Verify prerequisites (Optional)

```
aws --version
```

```
python3 --version
```

```
pip3 --version
```

#### 👁‍🗨 You should see:

```
aws-cli/2.x

Python 3.x
```

#### ❗️ If pip3 missing:

### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```

### 2️⃣ — Create clean working directory

```
sudo mkdir lambda-layer && cd lambda-layer
```

### 3️⃣ — Create required Lambda layer folder structure

⚠️ Lambda REQUIRES this exact structure

```
mkdir python
```

#### 👁‍🗨 You should see:

```
pymysql-layer/
└── python/
```

### 4️⃣ — Install PyMySQL INTO python folder

```
pip3 install pymysql -t python/
```

### 5️⃣ Verify install:

```
ls python/
```

#### 👁‍🗨 You should see:

```
pymysql/
pymysql-*.dist-info/
```

### 6️⃣ — Create ZIP file (VERY IMPORTANT)

```
zip -r pymysql-layer.zip python
```

### 7️⃣ Confirm ZIP exists:

```
ls -lh pymysql-layer.zip
```

#### 👁‍🗨 You should see:

```
pymysql-layer.zip   (few MB)
```


### 8️⃣ — Publish Lambda Layer USING AWS CLI (NO S3)

🔥 This is what you want instead of S3

```
aws lambda publish-layer-version \
  --layer-name pymysql-layer \
  --description "PyMySQL Lambda Layer" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.9 python3.10 python3.11
```

### 9️⃣ — Confirm Layer was created

```
aws lambda list-layer-versions \
  --layer-name pymysql-layer
```

#### 👁‍🗨 You should see:

```
{
  "LayerVersions": [
    {
      "Version": 1,
      "LayerVersionArn": "arn:aws:lambda:us-east-1:123456789012:layer:pymysql-layer:1"
    }
  ]
}
```

#### ✅ Copy the LayerVersionArn

### 🔟 — Attach Layer to Lambda (CLI way)

#### 1️⃣ Get current layers (IMPORTANT – don’t overwrite)

```
aws lambda get-function-configuration \
  --function-name YOUR_LAMBDA_NAME
```

Check "Layers" section.

#### 2️⃣ Update Lambda with PyMySQL layer

⚠️ Replace ARN + function name

```
aws lambda update-function-configuration \
  --function-name YOUR_LAMBDA_NAME \
  --layers arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:1
```

If you already have layers, include ALL layer ARNs together.

### 1️⃣1️⃣ — Test inside Lambda (MANDATORY)

In your Lambda code:

```
import pymysql

def lambda_handler(event, context):
    return {
        "status": "ok",
        "pymysql_version": pymysql.__version__
    }
```

Invoke test → expect no import error.

#### 🔹 — Common mistakes (READ THIS)

❌ Installing pymysql globally
❌ Zipping wrong folder
❌ Missing python/ root directory
❌ Using --zip-file file:// instead of fileb://
❌ Wrong Python runtime

#### 🔹 OPTIONAL — Cleanup local files

```
cd ..
rm -rf pymysql-layer
```

#### ✅ FINAL RESULT

You now have:

✔ PyMySQL Lambda Layer

✔ Created entirely via AWS CLI

✔ No S3 bucket involved

✔ Reusable across all Lambdas


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ Auto-update ALL Lambdas with a Layer

> **Goal: Attach pymysql-layer to every Lambda (or filtered ones) automatically.**

### 1️⃣ — Get Layer ARN

```
aws lambda list-layer-versions --layer-name pymysql-layer
```

#### Copy:

```
arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:VERSION
```

### 2️⃣ — List all Lambda names

```
aws lambda list-functions \
  --query 'Functions[].FunctionName' \
  --output text
```

### 3️⃣ — Auto-attach layer to ALL Lambdas

```
for fn in $(aws lambda list-functions --query 'Functions[].FunctionName' --output text); do
  aws lambda update-function-configuration \
    --function-name $fn \
    --layers arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:1
done
```

✅ All Lambdas updated
⚠️ If Lambdas already have layers → include ALL ARNs in --layers

### 2️⃣ 🧪 DB Connection Test Lambda (REAL MySQL Test)

#### 1️⃣ — Lambda code (db_test.py)

```
import pymysql
import os

def lambda_handler(event, context):
    conn = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        connect_timeout=5
    )

    with conn.cursor() as cursor:
        cursor.execute("SELECT 1")
        result = cursor.fetchone()

    conn.close()
    return {"db_test": "SUCCESS", "result": result}
```

#### 2️⃣ — Set env vars (CLI)

```
aws lambda update-function-configuration \
  --function-name db-test-lambda \
  --environment Variables="{DB_HOST=xxx,DB_USER=xxx,DB_PASS=xxx,DB_NAME=xxx}"
```

#### 3️⃣ — Invoke test

```
aws lambda invoke \
  --function-name db-test-lambda \
  response.json && cat response.json
```

### 3️⃣ 🐳 Build Lambda Layers Using Docker (AWS-Perfect)

Why: avoids “works locally but fails in Lambda”

#### 1️⃣ — Dockerfile

```
FROM public.ecr.aws/lambda/python:3.10

RUN pip install pymysql -t /layer/python

CMD ["bash"]
```

#### 2️⃣ Build image

```
docker build -t pymysql-layer .
```

#### 3️⃣ Copy layer files out

```
docker run --rm -v $(pwd):/out pymysql-layer \
  cp -r /layer /out
```

#### 4️⃣ Zip and publish

```
zip -r pymysql-layer.zip layer/python

aws lambda publish-layer-version \
  --layer-name pymysql-layer \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
```

### 4️⃣ Move DB Credentials to Secrets Manager

#### 1️⃣ — Create secret

```
aws secretsmanager create-secret \
  --name cafe-db-credentials \
  --secret-string '{
    "host":"db-endpoint",
    "user":"admin",
    "password":"secret",
    "dbname":"cafe"
  }'
```

#### 2️⃣ IAM permission (Lambda role)

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:*:*:secret:cafe-db-credentials*"
}
```

#### 3️⃣ Lambda code usage

```
import boto3, json

def get_db_creds():
    sm = boto3.client("secretsmanager")
    secret = sm.get_secret_value(SecretId="cafe-db-credentials")
    return json.loads(secret["SecretString"])
```

### 5️⃣ CloudWatch Structured Logging (JSON)

#### 1️⃣ — Logging utility

```
import json, logging, time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def log(event, level="INFO", **data):
    logger.info(json.dumps({
        "level": level,
        "event": event,
        "timestamp": int(time.time()),
        **data
    }))
```

#### 2️⃣ — Usage

```
log("DB_CONNECTED", lambda="order-service", status="ok")
```

#### Result in CloudWatch:

```
{"event":"DB_CONNECTED","lambda":"order-service","status":"ok"}
```

### 6️⃣ Shared DB Utility Lambda Layer

#### 1️⃣ — Folder structure

```
db-layer/
└── python/
    └── db.py
```

#### 2️⃣ db.py

```
import pymysql, boto3, json

def get_conn():
    sm = boto3.client("secretsmanager")
    secret = json.loads(
        sm.get_secret_value(SecretId="cafe-db-credentials")["SecretString"]
    )

    return pymysql.connect(
        host=secret["host"],
        user=secret["user"],
        password=secret["password"],
        database=secret["dbname"]
    )
```

#### 3️⃣ Publish layer

```
zip -r db-utils-layer.zip python

aws lambda publish-layer-version \
  --layer-name db-utils-layer \
  --zip-file fileb://db-utils-layer.zip
```

#### 4️⃣ Use in Lambda

```
from db import get_conn
```

### 7️⃣ CI/CD Script to Auto-Publish Layers

#### 1️⃣ — Bash script (deploy-layer.sh)

```
#!/bin/bash
set -e

LAYER_NAME="pymysql-layer"

rm -rf python pymysql-layer.zip
mkdir python

pip install pymysql -t python/
zip -r pymysql-layer.zip python

aws lambda publish-layer-version \
  --layer-name $LAYER_NAME \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
```

#### 2️⃣ Make executable

```
sudo chmod +x deploy-layer.sh
```

#### 3️⃣ Run anytime

```
sudo ./deploy-layer.sh
```

### ✅ FINAL ARCHITECTURE YOU NOW HAVE

✔ Central DB logic
✔ Secure Secrets Manager creds
✔ Structured CloudWatch logs
✔ Docker-built AWS-native layers
✔ One-command CI/CD deployment
✔ Mass Lambda updates

This is real AWS production setup, not tutorial junk.

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---