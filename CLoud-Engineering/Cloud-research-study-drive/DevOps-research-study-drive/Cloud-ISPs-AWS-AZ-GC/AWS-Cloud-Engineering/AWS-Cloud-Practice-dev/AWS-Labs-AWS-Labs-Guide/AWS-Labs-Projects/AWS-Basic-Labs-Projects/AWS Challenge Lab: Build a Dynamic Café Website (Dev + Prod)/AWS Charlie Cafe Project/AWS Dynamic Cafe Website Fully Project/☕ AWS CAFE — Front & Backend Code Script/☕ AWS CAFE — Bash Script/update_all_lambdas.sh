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