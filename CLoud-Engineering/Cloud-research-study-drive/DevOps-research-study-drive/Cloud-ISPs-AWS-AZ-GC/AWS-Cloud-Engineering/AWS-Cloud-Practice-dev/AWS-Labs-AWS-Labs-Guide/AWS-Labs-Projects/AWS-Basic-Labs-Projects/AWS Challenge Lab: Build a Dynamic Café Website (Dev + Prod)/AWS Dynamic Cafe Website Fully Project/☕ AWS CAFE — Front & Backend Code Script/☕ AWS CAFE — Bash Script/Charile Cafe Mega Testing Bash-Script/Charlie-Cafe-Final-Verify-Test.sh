#!/bin/bash
# ============================================================
# Charlie Cafe ☕
# FINAL COMPLETE LAB TEST & VERIFICATION SCRIPT (PROD API + LAMBDA)
# ============================================================

set -euo pipefail

echo "============================================================"
echo "☕ CHARLIE CAFE – FULL SYSTEM TEST STARTED"
echo "============================================================"

# =========================
# 1️⃣ CONFIGURATION
# =========================
REGION="us-east-1"
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"

# API Gateway Production Endpoints
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"

# ALB & CloudFront
ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

# Secrets Manager
SECRET_ID="cafe-rds-secret"

# =========================
# 2️⃣ LOCAL HOST + STATIC FILE CHECK
# =========================
echo "🔹 Testing local JS file"
curl -I http://localhost/js/central-auth-api.js || true
curl http://localhost/js/central-auth-api.js | head -5 || true

echo "🔹 Local IP info"
ip addr | grep inet || true

# =========================
# 3️⃣ ALB + CLOUDFRONT STATIC FILE TEST
# =========================
echo "🔹 ALB static file test"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js || true

echo "🔹 CloudFront static file test"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js || true

# =========================
# 4️⃣ SECRETS MANAGER VERIFICATION
# =========================
echo "🔹 Verifying Secrets Manager keys"
aws secretsmanager get-secret-value \
  --secret-id ${SECRET_ID} \
  --region ${REGION} \
  --query SecretString \
  --output text | jq .

# =========================
# 5️⃣ API GATEWAY TESTS (PROD)
# =========================
echo "🔹 API TESTS USING PROD ENDPOINT"

# 1️⃣ POST /orders → CafeOrderProcessor Lambda
curl -X POST ${API_PROD}/orders \
-H "Content-Type: application/json" \
-d '{"table_number":5,"customer_name":"John","item":"Coffee","quantity":2}'

# 2️⃣ GET /get-order-status → GetOrderStatusLambda
curl ${API_PROD}/get-order-status

# 3️⃣ GET /cafe-order-status → CafeOrderStatusLambda
curl ${API_PROD}/cafe-order-status

# 4️⃣ POST /order-update → CafeOrderWorkerLambda
curl -X POST ${API_PROD}/order-update \
-H "Content-Type: application/json" \
-d '{"order_id": "ORD-20260222-4821", "status": "PREPARING"}'

# 5️⃣ POST /admin/mark-paid → AdminMarkPaidLambda
curl -X POST ${API_PROD}/admin/mark-paid \
-H "Content-Type: application/json" \
-d '{"body": "{\"order_id\": \"ORD-123456\"}"}'

# 6️⃣ GET /analytics → CafeAnalyticsLambda
curl ${API_PROD}/analytics?period=today

# =========================
# 6️⃣ SQS CHECK
# =========================
echo "🔹 Checking SQS Queue"
aws sqs get-queue-attributes \
  --queue-url https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} \
  --attribute-names ApproximateNumberOfMessages

# =========================
# 7️⃣ LAMBDA INVOKE TESTS
# =========================
invoke_lambda () {
  NAME=$1
  PAYLOAD=$2

  echo "▶ Invoking Lambda: ${NAME}"
  aws lambda invoke \
    --function-name ${NAME} \
    --payload "${PAYLOAD}" \
    --region ${REGION} \
    /tmp/${NAME}.json

  cat /tmp/${NAME}.json
  echo
}

# ──────────────────────────────
# Lambda Functions & Payloads
# ──────────────────────────────

# 1️⃣ CafeOrderProcessor
invoke_lambda CafeOrderProcessor \
'{"body":"{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2}"}'

# 2️⃣ CafeMenuLambda
invoke_lambda CafeMenuLambda '{}'

# 3️⃣ GetOrderStatusLambda
invoke_lambda GetOrderStatusLambda '{}'

# 4️⃣ CafeOrderStatusLambda
invoke_lambda CafeOrderStatusLambda '{}'

# 5️⃣ CafeOrderWorkerLambda
invoke_lambda CafeOrderWorkerLambda \
'{"body":"{\"order_id\":\"ORD-20260222-1234\",\"status\":\"PREPARING\"}"}'

# 6️⃣ AdminMarkPaidLambda
invoke_lambda AdminMarkPaidLambda \
'{"body":"{\"order_id\": \"ORD-123456\"}"}'

# 7️⃣ CafeAnalyticsLambda
invoke_lambda CafeAnalyticsLambda \
'{"queryStringParameters":{"period":"today"}}'

# 8️⃣ HR / Attendance & Employee Lambdas
invoke_lambda hr-checkin \
'{"resource":"/hr/attendance/checkin","path":"/hr/attendance/checkin","httpMethod":"POST","requestContext":{"authorizer":{"claims":{"sub":"cognito-user-123","cognito:groups":["Employee"]}}}}'

invoke_lambda hr-checkout \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-employee-profile \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-attendance-history \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-leaves-holidays \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

# =========================
# ✅ DONE
# =========================
echo "============================================================"
echo "✅ CHARLIE CAFE FULL LAB TEST COMPLETED SUCCESSFULLY"
echo "============================================================"