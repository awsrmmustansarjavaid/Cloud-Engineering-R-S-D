#!/bin/bash

# ================================
# CONFIGURATION
# ================================
AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"

DB_HOST="your-rds-endpoint.amazonaws.com"
DB_PORT="3306"
DB_NAME="cafedb"
DB_USERNAME="admin"
DB_PASSWORD="StrongPasswordHere"

# ================================
# CREATE SECRET JSON
# ================================
SECRET_STRING=$(cat <<EOF
{
  "host": "$DB_HOST",
  "port": "$DB_PORT",
  "dbname": "$DB_NAME",
  "username": "$DB_USERNAME",
  "password": "$DB_PASSWORD"
}
EOF
)

# ================================
# CREATE OR UPDATE SECRET
# ================================
aws secretsmanager create-secret \
  --region "$AWS_REGION" \
  --name "$SECRET_NAME" \
  --secret-string "$SECRET_STRING" \
  2>/dev/null || \
aws secretsmanager put-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --secret-string "$SECRET_STRING"

# ================================
# CONFIRMATION
# ================================
echo "✅ RDS credentials securely stored in AWS Secrets Manager"
echo "🔐 Secret Name: $SECRET_NAME"
