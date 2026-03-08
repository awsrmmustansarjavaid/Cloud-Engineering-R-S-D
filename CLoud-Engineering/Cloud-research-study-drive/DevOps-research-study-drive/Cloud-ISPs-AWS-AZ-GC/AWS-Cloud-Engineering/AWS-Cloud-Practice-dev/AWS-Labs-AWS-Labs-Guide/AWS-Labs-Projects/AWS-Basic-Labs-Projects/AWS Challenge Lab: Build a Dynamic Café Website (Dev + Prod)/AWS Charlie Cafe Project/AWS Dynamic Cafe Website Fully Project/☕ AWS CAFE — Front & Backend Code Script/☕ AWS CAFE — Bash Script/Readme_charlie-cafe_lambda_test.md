# Charlie Cafe Lambda Test 


### charlie-cafe_lambda_test.sh

> **Update Version: 1.0**


```
#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Cafe Lambda Batch Tester - FIXED VERSION 2025
# Uses only REAL function names from your account
# Region hardcoded to us-east-1 (change if needed)
# ------------------------------------------------------------------------------

set -u

REGION="us-east-1"

# ──────────────────────────────────────────────────────────────────────────────
# 1. List Lambda functions (just for confirmation)
# ──────────────────────────────────────────────────────────────────────────────

echo "=============================================================="
echo "Listing Lambda functions (${REGION}) ..."
echo "=============================================================="

FUNCTIONS=$(aws lambda list-functions --region "${REGION}" --query 'Functions[].FunctionName' --output text 2>/dev/null)

if [[ -z "$FUNCTIONS" ]]; then
  echo "ERROR: Cannot list functions. Check credentials / region."
  exit 1
fi

echo "$FUNCTIONS" | tr '\t' '\n' | sort
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 2. Test cases - using REAL function names only
# ──────────────────────────────────────────────────────────────────────────────

declare -a tests=(

  # Order creation / placement related
  "Test_CafeOrderProcessor     | CafeOrderProcessor    | {\"body\": \"{\\\"customer_name\\\":\\\"LambdaTest\\\",\\\"item\\\":\\\"Coffee\\\",\\\"quantity\\\":2}\"}"

  "Test_ApiOrderTest           | CafeOrderApiLambda    | {\"body\": \"{\\\"table_number\\\":1,\\\"customer_name\\\":\\\"ConsoleTest\\\",\\\"item\\\":\\\"Latte\\\",\\\"quantity\\\":2}\"}"

  "Test_SqsProducerTest        | CafeOrderApiLambda    | {\"body\": \"{\\\"customer_name\\\":\\\"ConsoleTest\\\",\\\"item\\\":\\\"Latte\\\",\\\"quantity\\\":2}\"}"

  "Test_CreateOrderLambda      | CreateOrderLambda     | {\"body\": \"{\\\"table_number\\\":1,\\\"customer_name\\\":\\\"Test User\\\",\\\"item\\\":\\\"Coffee\\\",\\\"quantity\\\":3}\"}"

  # Order status / tracking
  "Test-GetOrderStatusLambda   | GetOrderStatusLambda  | {\"queryStringParameters\": {\"order_id\": \"ORD-TEST-123\"}}"

  "Test_Customer_Order_Tracking| CafeOrderStatusLambda | {\"queryStringParameters\": {\"order_id\": \"ORD-TEST-123\"}}"

  # Order status updates (PREPARING / COMPLETED etc.)
  "Test_RECEIVED-PREPARING     | CafeOrderApiLambda    | {\"body\": \"{\\\"order_id\\\": \\\"ORD-20260131-1234\\\", \\\"status\\\": \\\"PREPARING\\\"}\", \"httpMethod\": \"POST\", \"path\": \"/order-update\", \"isBase64Encoded\": false}"

  "Test_PREPARING-READY        | CafeOrderApiLambda    | {\"body\": \"{\\\"order_id\\\": \\\"ORD-20260131-1234\\\", \\\"status\\\": \\\"COMPLETED\\\"}\", \"httpMethod\": \"POST\", \"path\": \"/order-update\", \"isBase64Encoded\": false}"

  "Test_READY-COMPLETED        | CafeOrderApiLambda    | {\"body\": \"{\\\"order_id\\\": \\\"ORD-20260131-1234\\\", \\\"status\\\": \\\"COMPLETED\\\"}\", \"httpMethod\": \"POST\", \"path\": \"/order-update\", \"isBase64Encoded\": false}"

  # Payment related
  "TestCashPayment_full        | CashPaymentLambda     | {\"body\": \"{\\\"order_id\\\": \\\"ORD-20260131-1234\\\"}\", \"httpMethod\": \"POST\", \"path\": \"/orders/cash-payment\", \"requestContext\": {\"stage\": \"dev\", \"requestId\": \"test-1234-abcd\"}, \"headers\": {\"Content-Type\": \"application/json\"}, \"isBase64Encoded\": false}"

  "TestCashPayment_minimal     | CashPaymentLambda     | {\"body\": \"{\\\"order_id\\\": \\\"ORD-20260131-5678\\\"}\"}"

  "TestMarkPaid_full           | AdminMarkPaidLambda   | {\"body\": \"{\\\"order_id\\\": \\\"ORD-1738333333-456\\\"}\", \"httpMethod\": \"POST\", \"path\": \"/orders/cash-payment\", \"resource\": \"/orders/cash-payment\", \"requestContext\": {\"resourceId\": \"abc123\", \"resourcePath\": \"/orders/cash-payment\", \"httpMethod\": \"POST\", \"stage\": \"dev\", \"requestId\": \"test-request-id-1234\", \"identity\": {\"sourceIp\": \"127.0.0.1\"}}, \"headers\": {\"Content-Type\": \"application/json\"}, \"isBase64Encoded\": false}"

  "TestMarkPaid_minimal        | AdminMarkPaidLambda   | {\"body\": \"{\\\"order_id\\\": \\\"ORD-999999999-999\\\"}\"}"

  # Worker (SQS triggered style)
  "Test_CafeOrderWorker        | CafeOrderWorker       | {\"Records\": [{\"body\": \"{\\\"table_number\\\": 1, \\\"customer_name\\\": \\\"WorkerTest\\\", \\\"item\\\": \\\"Coffee\\\", \\\"quantity\\\": 2}\"}]}"
)

# ──────────────────────────────────────────────────────────────────────────────
# 3. Run tests
# ──────────────────────────────────────────────────────────────────────────────

echo "=============================================================="
echo "Starting Lambda tests (${REGION}) ..."
echo "=============================================================="

SUCCESS=0
FAIL=0
TOTAL=${#tests[@]}

RESULTS=()

for entry in "${tests[@]}"; do
  IFS='|' read -r test_name func_name payload <<< "$entry"
  test_name=$(echo "$test_name" | xargs)
  func_name=$(echo "$func_name" | xargs)

  echo "→ ${test_name} (${func_name})"

  output_file="resp_${test_name// /_}.json"

  # Invoke
  aws lambda invoke \
    --function-name "${func_name}" \
    --region "${REGION}" \
    --payload "${payload}" \
    --cli-binary-format raw-in-base64-out \
    "${output_file}" > invoke_result.json 2> error.txt

  if [[ $? -ne 0 ]]; then
    echo "   → CLI FAILED"
    cat error.txt | head -n 3
    FAIL=$((FAIL+1))
    RESULTS+=("${test_name} | FAIL | CLI error")
    continue
  fi

  # Check for function-level error
  func_error=$(jq -r '.FunctionError // empty' "${output_file}" 2>/dev/null)

  if [[ -n "${func_error}" ]]; then
    echo "   → FAILED (FunctionError: ${func_error})"
    FAIL=$((FAIL+1))
    RESULTS+=("${test_name} | FAIL | ${func_error}")
    continue
  fi

  # Try to get statusCode
  status=$(jq -r '.statusCode // "NO_STATUS"' "${output_file}" 2>/dev/null)

  if [[ "${status}" == "200" || "${status}" == "NO_STATUS" ]]; then
    echo "   → OK (${status})"
    SUCCESS=$((SUCCESS+1))
    RESULTS+=("${test_name} | PASS | ${status}")
  else
    echo "   → FAILED (status ${status})"
    FAIL=$((FAIL+1))
    RESULTS+=("${test_name} | FAIL | status ${status}")
  fi
done

# ──────────────────────────────────────────────────────────────────────────────
# 4. Summary
# ──────────────────────────────────────────────────────────────────────────────

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                     TEST RESULTS SUMMARY                   ║"
echo "╠════════════════════════════════════════════════════════════╣"
printf "║  Total tests  : %-43s ║\n" "${TOTAL}"
printf "║  Passed       : %-43s ║\n" "${SUCCESS}"
printf "║  Failed       : %-43s ║\n" "${FAIL}"
echo "╠════════════════════════════════════════════════════════════╣"

for res in "${RESULTS[@]}"; do
  IFS='|' read -r tname outcome msg <<< "$res"
  printf "║  %-35s | %-8s | %-30s ║\n" "$(echo "$tname" | cut -c1-33)" "$outcome" "$(echo "$msg" | cut -c1-28)"
done

echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [[ ${FAIL} -eq 0 ]]; then
  echo "🎉 ALL TESTS PASSED"
else
  echo "⚠️  Some tests failed"
  echo "Most common next step: check CloudWatch Logs"
  echo "Example command:"
  echo "aws logs tail /aws/lambda/CafeOrderProcessor --region us-east-1 --since 30m"
fi
```



---


