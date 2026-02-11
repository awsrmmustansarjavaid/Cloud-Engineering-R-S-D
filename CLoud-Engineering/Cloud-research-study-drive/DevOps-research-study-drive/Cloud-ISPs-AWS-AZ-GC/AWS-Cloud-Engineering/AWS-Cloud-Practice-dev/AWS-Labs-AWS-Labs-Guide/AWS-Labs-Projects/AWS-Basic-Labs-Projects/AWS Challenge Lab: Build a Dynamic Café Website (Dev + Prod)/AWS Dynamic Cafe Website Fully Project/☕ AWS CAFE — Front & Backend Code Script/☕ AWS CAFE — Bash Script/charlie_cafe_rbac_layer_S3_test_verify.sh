#!/bin/bash
# ============================================================== 
# Charlie Cafe RBAC Layer Setup & Verification Script (S3 Upload Version)
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

# S3 bucket to store the Lambda layer ZIP
S3_BUCKET="your-s3-bucket-name"   # <-- CHANGE THIS
S3_KEY="lambda-layers/$ZIP_FILE"

# ===============================
# RESULT TRACKING
# ===============================
PASS_COUNT=0
FAIL_COUNT=0

pass() { echo "✅ $1"; ((PASS_COUNT++)); }
fail() { echo "❌ $1"; ((FAIL_COUNT++)); }

# ===============================
# TEST PLAN
# ===============================
echo "============================================================="
echo "☕ Charlie Cafe RBAC Layer – Test & Verification Plan"
echo "============================================================="
echo "1. Verify RBAC directory structure"
echo "2. Create ZIP package for Lambda Layer"
echo "3. Verify ZIP contents"
echo "4. Upload ZIP to S3"
echo "5. Publish Lambda Layer from S3"
echo "6. Attach Layer to Lambda function"
echo "7. Verify Layer attachment"
echo "8. Final Result Card"
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
# 4️⃣ UPLOAD ZIP TO S3
# ===============================
echo
echo "☁ Step 4: Uploading ZIP to S3: s3://$S3_BUCKET/$S3_KEY ..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_REGION" >/dev/null
if [ $? -eq 0 ]; then
  pass "ZIP uploaded to S3 successfully"
else
  fail "S3 upload failed"
  exit 1
fi

# ===============================
# 5️⃣ PUBLISH LAMBDA LAYER FROM S3
# ===============================
echo
echo "🚀 Step 5: Publishing Lambda Layer from S3..."
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Charlie Cafe Universal RBAC Layer" \
  --content "S3Bucket=$S3_BUCKET,S3Key=$S3_KEY" \
  --compatible-runtimes python3.12 python3.11 python3.10 \
  --region "$AWS_REGION" \
  --query 'LayerVersionArn' \
  --output text)

if [[ "$LAYER_ARN" == arn:* ]]; then
  pass "Lambda Layer published from S3"
  echo "   Layer ARN: $LAYER_ARN"
else
  fail "Failed to publish Lambda Layer"
  exit 1
fi

# ===============================
# 6️⃣ ATTACH LAYER TO LAMBDA
# ===============================
echo
echo "🔗 Step 6: Attaching layer to Lambda function..."
aws lambda update-function-configuration \
  --function-name "$LAMBDA_FUNCTION_NAME" \
  --layers "$LAYER_ARN" \
  --region "$AWS_REGION" >/dev/null
pass "Layer attached to Lambda: $LAMBDA_FUNCTION_NAME"

# ===============================
# 7️⃣ VERIFY LAYER ATTACHMENT
# ===============================
echo
echo "🧪 Step 7: Verifying layer attachment..."
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
