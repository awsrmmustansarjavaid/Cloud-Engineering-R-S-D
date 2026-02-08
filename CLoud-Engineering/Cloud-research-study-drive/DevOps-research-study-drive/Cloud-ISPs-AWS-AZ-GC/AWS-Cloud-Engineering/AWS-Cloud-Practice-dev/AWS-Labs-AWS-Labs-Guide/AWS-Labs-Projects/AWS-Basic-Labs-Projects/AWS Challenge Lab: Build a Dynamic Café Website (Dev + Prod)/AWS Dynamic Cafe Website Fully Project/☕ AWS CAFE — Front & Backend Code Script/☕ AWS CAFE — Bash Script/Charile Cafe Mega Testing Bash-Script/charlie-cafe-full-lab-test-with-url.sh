#!/bin/bash
# ============================================================
# Charlie Cafe ☕
# FINAL COMPLETE LAB TEST & VERIFICATION SCRIPT (WITH FULL URL)
# ============================================================

set -e

echo "============================================================"
echo "☕ CHARLIE CAFE – FULL SYSTEM TEST STARTED"
echo "============================================================"

# =========================
# 1️⃣ DEFINE API GATEWAY ENDPOINTS
# =========================
API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

REGION="us-east-1"
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"

# ============================================================
# 2️⃣ LOCAL HOST + STATIC FILE CHECK
# ============================================================
echo "🔹 Testing local JS file"
curl -I http://localhost/js/central-auth-api.js || true
curl http://localhost/js/central-auth-api.js | head -5 || true

echo "🔹 Local IP info"
ip addr | grep inet || true

# ============================================================
# 3️⃣ ALB + CLOUDFRONT STATIC FILE TEST
# ============================================================
echo "🔹 ALB static file test"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js || true

echo "🔹 CloudFront static file test"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js || true

# ============================================================
# 4️⃣ SECRETS MANAGER VERIFICATION
# ============================================================
echo "🔹 Verifying Secrets Manager keys"
aws secretsmanager get-secret-value \
  --secret-id cafe-rds-secret \
  --region ${REGION} \
  --query SecretString \
  --output text | jq .

# ============================================================
# 5️⃣ API GATEWAY TESTS USING FULL URL
# ============================================================
echo "🔹 Create Order (POST /dev/orders)"
curl -X POST \
  ${API_DEV}/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'

echo "🔹 Get Orders"
curl ${API_DEV}/orders

echo "🔹 Cash Payment"
curl -X POST \
  ${API_DEV}/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{"order_id":"ORD-123"}'

echo "🔹 Mark Paid (Admin)"
curl ${API_DEV}/admin/mark-paid

echo "🔹 Order Status"
curl ${API_STATUS}/order-status
curl ${API_PROD}/order-status/order-status

# ============================================================
# 6️⃣ Analytics & Reports
# ============================================================
curl ${API_PROD}/analytics?period=today
curl ${API_PROD}/analytics?period=month
curl ${API_PROD}/analytics/csv

curl ${API_PROD}/report/pdf?page=analytics
curl ${API_PROD}/report/pdf?page=order-status

# ============================================================
# 7️⃣ SQS CHECK
# ============================================================
echo "🔹 Checking SQS Queue"
aws sqs get-queue-attributes \
  --queue-url https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} \
  --attribute-names ApproximateNumberOfMessages

# ============================================================
# 8️⃣ LAMBDA INVOKE TESTS
# ============================================================
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
# All your Lambda tests
# ──────────────────────────────
invoke_lambda CafeOrderProcessor \
'{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'

invoke_lambda CafeMenuLambda '{}'

invoke_lambda CafeOrderApiLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda Test_SqsProducerTest \
'{"body":"{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda CafeOrderWorker \
'{"Records":[{"body":"{\"table_number\":1,\"customer_name\":\"WorkerTest\",\"item\":\"Coffee\",\"quantity\":2}"}]}'

invoke_lambda GetOrderStatusLambda '{}'

invoke_lambda CreateOrderLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"Test User\",\"item\":\"Coffee\",\"quantity\":3}"}'

invoke_lambda CashPayment \
'{"body":"{\"order_id\":\"ORD-20260131-1234\"}"}'

invoke_lambda MarkPaid \
'{"body":"{\"order_id\":\"ORD-999999999-999\"}"}'

invoke_lambda CafeDynamoTestLambda '{}'

invoke_lambda CafeAnalyticsLambda \
'{"queryStringParameters":{"period":"today"}}'

invoke_lambda CafeAnalyticsCSVLambda '{}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"analytics"}}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"order-status"}}'

invoke_lambda CafeDailyPDFLambda '{}'

invoke_lambda hr-checkin \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-checkout \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-employee-profile \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-attendance-history \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-leaves-holidays \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

# ============================================================
# ✅ DONE
# ============================================================
echo "============================================================"
echo "✅ CHARLIE CAFE FULL LAB TEST COMPLETED SUCCESSFULLY"
echo "============================================================"
