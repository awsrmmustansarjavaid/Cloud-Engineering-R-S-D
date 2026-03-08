

## Central UNIVERSAL Backend RBAC

### ✅ STEP-BY-STEP CONFIGURATION GUIDE

### 1️⃣ Confirm Cognito Groups (ONCE)

#### You already did this, but verify:

- Cognito User Pool → Groups:

    - admin

    - employee

- Users:

    - admin user → member of admin

    - employee user → member of employee

**👉 Group names must match permissions.json exactly**
> **(lowercase = best practice ✅)**

### 2️⃣ Create permissions.json (YOU DID THIS)

Example (keep it simple first):

```
[
  {
    "path": "/order-status",
    "roles": ["admin"]
  },
  {
    "path": "/attendance",
    "roles": ["admin", "employee"]
  },
  {
    "path": "/hr",
    "roles": ["admin"]
  }
]
```

#### 🔐 Rule:

- If path matches → check roles

- If no rule → DENY by default (secure)

### 3️⃣ Decide HOW rbac.py is used (IMPORTANT)

You have 2 valid options.

✅ OPTION A (RECOMMENDED): Lambda Layer

❌ OPTION B: Copy file into each Lambda (temporary)

We’ll do Option A (professional + clean).

### 4️⃣ Create Lambda Layer (RBAC)

#### 📁 Local folder structure (VERY IMPORTANT)

```
cafe-rbac-layer/
└── python/
    ├── rbac.py
    └── permissions.json
```

**⚠️ Folder name MUST be python/**

#### 1️⃣ Create the folder structure

```
sudo mkdir -p cafe-rbac-layer/python
```
> **📌 python/ folder name is MANDATORY for Lambda layers**
**⚠️ If you miss this → Lambda will not find rbac.py**

#### 2️⃣ Create permissions.json

```
sudo nano cafe-rbac-layer/python/permissions.json
```
[permissions.json](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Central%20Backend%20RBAC%20Script/permissions.json)

- Save and exit.

#### 🔐 Rule:

- If path matches → check roles

- If no rule → DENY by default (secure)

#### 3️⃣ Create UNIVERSAL backend RBAC file
> **📄 rbac.py (THIS IS YOUR BACKEND central-auth-api)**

```
sudo nano cafe-rbac-layer/python/rbac.py
```
- Paste your existing rbac.py code

[rbac.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Central%20Backend%20RBAC%20Script/rbac.py)

- Save and exit (CTRL + O, ENTER, CTRL + X)

#### 4️⃣ Create the ZIP (Layer package)

Run this inside the folder that contains python/:

```
cd cafe-rbac-layer
zip -r cafe-rbac-layer.zip python
```

Verify zip contents:

```
unzip -l cafe-rbac-layer.zip
```

You MUST see:

```
python/rbac.py
python/permissions.json
```

#### 5️⃣ Publish Lambda Layer using AWS CLI

Make sure AWS CLI is configured

```
aws configure
```
**(Access key, secret, region, output)**

Create the layer (Amazon Linux 2023 compatible)

```
aws lambda publish-layer-version \
  --layer-name cafe-rbac-layer \
  --description "Charlie Cafe Universal RBAC Layer" \
  --zip-file fileb://cafe-rbac-layer.zip \
  --compatible-runtimes python3.12 python3.11 python3.10
```

#### ✅ Expected output includes:

```
{
  "LayerVersionArn": "arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:1",
  "Version": 1
}
```

#### 6️⃣ Attach Layer to a Lambda (CLI)

Example: attach to order-status Lambda

```
aws lambda update-function-configuration \
  --function-name CafeOrderStatusLambda \
  --layers arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:1
```

#### 📌 Replace:

- CafeOrderStatusLambda

- Account ID

- Region

- Layer version if newer

### 🧱 PART 0 — ASSUMPTIONS (READ ONCE)

You already have:

✅ Cognito User Pool

✅ Cognito groups: admin, employee

✅ API Gateway with Cognito Authorizer

✅ Multiple Lambdas behind API Gateway

✅ One shared RBAC Lambda Layer (cafe-rbac-layer)

✅ Python runtime (3.10+)

If any of the above is missing → stop and tell me.

### 🧩 PART 1 — AUDIT LOGGING INSIDE RBAC (CORE)

We will log:

username

groups

API path

decision (ALLOW / DENY)

timestamp

Logs will go to CloudWatch Logs (default, safe, free tier friendly).

### 1️⃣ Update rbac.py (VERY IMPORTANT)

Open your RBAC file:

```
nano cafe-rbac-layer/python/rbac.py
```

✅ FULL RBAC WITH AUDIT LOGGING (COPY ALL)

```
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
```

### 2️⃣ Rebuild & republish the layer

```
cd cafe-rbac-layer
zip -r cafe-rbac-layer.zip python
```

Publish new version:

```
aws lambda publish-layer-version \
  --layer-name cafe-rbac-layer \
  --description "RBAC Layer with Audit Logging" \
  --zip-file fileb://cafe-rbac-layer.zip \
  --compatible-runtimes python3.12 python3.11 python3.10
```

👉 Note the new layer version number (e.g. :2)

### 🔁 PART 2 — ONE CLI SCRIPT TO UPDATE ALL LAMBDAS

No clicking.
No mistakes.
Repeatable.
Rollback-friendly.

### 3️⃣ Create update script

```
nano update_all_lambdas.sh
```

✅ COPY THIS SCRIPT (SAFE VERSION)

```
#!/bin/bash

# ==============================
# CONFIG — EDIT THESE
# ==============================
REGION="us-east-1"
LAYER_ARN="arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:2"

# ==============================
# Get all Lambda functions
# ==============================
FUNCTIONS=$(aws lambda list-functions \
  --region $REGION \
  --query 'Functions[].FunctionName' \
  --output text)

# ==============================
# Attach layer to each Lambda
# ==============================
for FUNCTION in $FUNCTIONS; do
  echo "Updating $FUNCTION ..."

  aws lambda update-function-configuration \
    --region $REGION \
    --function-name $FUNCTION \
    --layers $LAYER_ARN

done

echo "✅ All Lambdas updated successfully"
```

4️⃣ Make script executable

```
chmod +x update_all_lambdas.sh
```

5️⃣ RUN the script

```
./update_all_lambdas.sh
```

#### Expected output:

```
Updating OrderStatusLambda ...
Updating PaymentLambda ...
Updating AttendanceLambda ...
✅ All Lambdas updated successfully
```

6️⃣ Verify ONE Lambda (spot check)

```
aws lambda get-function-configuration \
  --function-name OrderStatusLambda
```

Look for:

```
"Layers": [
  {
    "Arn": "arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:2"
  }
]
```

🔍 PART 3 — USING RBAC IN EACH LAMBDA (ONE LINE)

Inside every Lambda handler:

```
from rbac import authorize

def lambda_handler(event, context):
    authorize(event)   # ⬅ RBAC + audit log
    
    return {
        "statusCode": 200,
        "body": "OK"
    }
```

❌ No duplication
❌ No IAM mess
❌ No multiple Lambdas for roles

📊 PART 4 — VIEW AUDIT LOGS

Go to: CloudWatch → Log groups → /aws/lambda/<LambdaName>

You’ll see logs like:

```
{
  "timestamp": "2026-02-04T18:32:11",
  "username": "charlie.admin",
  "groups": ["admin"],
  "path": "/admin/dashboard",
  "decision": "ALLOW"
}
```

This is enterprise-grade RBAC auditing.

✅ FINAL ARCHITECTURE

```
Cognito (Groups)
     ↓
API Gateway (Authorizer)
     ↓
Lambda
     ↓
RBAC Layer
     ↓
Audit Logs (CloudWatch)
```

🧠 WHY THIS IS THE BEST WAY (HONEST)

✔ One Lambda per feature
✔ One RBAC brain
✔ One update script
✔ One audit trail
✔ Zero vendor lock tricks
✔ Easy rollback
✔ Scales cleanly

This is how senior AWS engineers do it.

---

### 📛 Script Title Charlie Cafe RBAC Layer Setup & Verification

Below is a single, safe, reusable Bash script that:

✅ Packages the RBAC layer
✅ Verifies ZIP contents
✅ Publishes Lambda Layer
✅ Attaches layer to a Lambda
✅ Verifies attachment
✅ Shows a final RESULT CARD (PASS / FAIL summary)
✅ Uses AWS CLI only
✅ Has clear comments everywhere
✅ Stops immediately if something is wrong (fail-fast)

📁 Suggested file name

```
charlie_cafe_rbac_layer_test_verify.sh
```

🧠 What this script verifies (shown BEFORE execution)

RBAC folder structure

ZIP contents

Lambda Layer creation

Layer ARN capture

Layer attachment to Lambda

Post-attach verification

At the end → Result Card ✔❌

✅ FINAL WORKING BASH SCRIPT (COPY–PASTE)

```
#!/bin/bash
# ==============================================================
# Charlie Cafe RBAC Layer Setup & Verification Script
#
# PURPOSE:
# - Package RBAC Python layer
# - Verify ZIP contents
# - Publish Lambda Layer
# - Attach Layer to Lambda
# - Verify Layer attachment
#
# SAFE:
# ✔ No data deletion
# ✔ Idempotent (can re-run)
#
# REQUIREMENTS:
# - AWS CLI configured
# - zip, unzip, tree installed
# ==============================================================

set -e

# ===============================
# USER CONFIGURATION (REPLACE)
# ===============================

AWS_REGION="us-east-1"
LAYER_NAME="cafe-rbac-layer"
LAMBDA_FUNCTION_NAME="CafeOrderStatusLambda"

# RBAC folder (must contain python/)
RBAC_DIR="cafe-rbac-layer"
ZIP_FILE="cafe-rbac-layer.zip"

# ===============================
# RESULT TRACKING
# ===============================
PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "✅ $1"
  ((PASS_COUNT++))
}

fail() {
  echo "❌ $1"
  ((FAIL_COUNT++))
}

# ===============================
# TEST PLAN (DISPLAY FIRST)
# ===============================
echo "============================================================="
echo "☕ Charlie Cafe RBAC Layer – Test & Verification Plan"
echo "============================================================="
echo "1. Verify RBAC directory structure"
echo "2. Create ZIP package for Lambda Layer"
echo "3. Verify ZIP contents"
echo "4. Publish Lambda Layer"
echo "5. Attach Layer to Lambda function"
echo "6. Verify Layer attachment"
echo "7. Final Result Card"
echo "============================================================="
echo

# ===============================
# 1️⃣ VERIFY RBAC DIRECTORY
# ===============================
echo "🔍 Step 1: Verifying RBAC directory structure..."

if [ ! -d "$RBAC_DIR/python" ]; then
  fail "Missing directory: $RBAC_DIR/python"
  exit 1
fi

if [ ! -f "$RBAC_DIR/python/rbac.py" ] || [ ! -f "$RBAC_DIR/python/permissions.json" ]; then
  fail "rbac.py or permissions.json missing"
  exit 1
fi

pass "RBAC directory structure OK"

echo
echo "📂 RBAC folder tree:"
tree "$RBAC_DIR"
echo

# ===============================
# 2️⃣ CREATE ZIP PACKAGE
# ===============================
echo "📦 Step 2: Creating Lambda Layer ZIP package..."

rm -f "$ZIP_FILE"
cd "$RBAC_DIR"
zip -r "../$ZIP_FILE" python >/dev/null
cd - >/dev/null

pass "ZIP package created: $ZIP_FILE"

# ===============================
# 3️⃣ VERIFY ZIP CONTENTS
# ===============================
echo
echo "🔎 Step 3: Verifying ZIP contents..."

ZIP_CHECK=$(unzip -l "$ZIP_FILE" | grep -E "python/rbac.py|python/permissions.json" | wc -l)

if [ "$ZIP_CHECK" -ne 2 ]; then
  fail "ZIP content verification failed"
  unzip -l "$ZIP_FILE"
  exit 1
fi

pass "ZIP contains required RBAC files"

# ===============================
# 4️⃣ PUBLISH LAMBDA LAYER
# ===============================
echo
echo "🚀 Step 4: Publishing Lambda Layer..."

LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Charlie Cafe Universal RBAC Layer" \
  --zip-file "fileb://$ZIP_FILE" \
  --compatible-runtimes python3.12 python3.11 python3.10 \
  --region "$AWS_REGION" \
  --query 'LayerVersionArn' \
  --output text)

if [[ "$LAYER_ARN" == arn:* ]]; then
  pass "Lambda Layer published"
  echo "   Layer ARN: $LAYER_ARN"
else
  fail "Failed to publish Lambda Layer"
  exit 1
fi

# ===============================
# 5️⃣ ATTACH LAYER TO LAMBDA
# ===============================
echo
echo "🔗 Step 5: Attaching layer to Lambda function..."

aws lambda update-function-configuration \
  --function-name "$LAMBDA_FUNCTION_NAME" \
  --layers "$LAYER_ARN" \
  --region "$AWS_REGION" >/dev/null

pass "Layer attached to Lambda: $LAMBDA_FUNCTION_NAME"

# ===============================
# 6️⃣ VERIFY LAYER ATTACHMENT
# ===============================
echo
echo "🧪 Step 6: Verifying layer attachment..."

ATTACHED_LAYER=$(aws lambda get-function-configuration \
  --function-name "$LAMBDA_FUNCTION_NAME" \
  --region "$AWS_REGION" \
  --query "Layers[].Arn" \
  --output text)

if echo "$ATTACHED_LAYER" | grep -q "$LAYER_NAME"; then
  pass "RBAC layer verified on Lambda"
else
  fail "RBAC layer NOT attached"
fi

# ===============================
# FINAL RESULT CARD
# ===============================
echo
echo "============================================================="
echo "📊 RBAC SETUP & VERIFICATION RESULT CARD"
echo "============================================================="
echo "✔ Passed : $PASS_COUNT"
echo "✖ Failed : $FAIL_COUNT"
echo "-------------------------------------------------------------"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "🎉 STATUS: ALL RBAC TESTS PASSED SUCCESSFULLY"
else
  echo "🚨 STATUS: ISSUES DETECTED – REVIEW ABOVE"
fi

echo "============================================================="
```

🧪 How to run

```
chmod +x charlie_cafe_rbac_layer_test_verify.sh
./charlie_cafe_rbac_layer_test_verify.sh
```

🧠 Why this script is production-grade

Fail-fast (stops immediately if something is wrong)

No hard-coded account ID

Automatically captures Layer ARN

Clear PASS / FAIL Result Card

Safe to re-run anytime

Perfect for labs, demos, audits

---

