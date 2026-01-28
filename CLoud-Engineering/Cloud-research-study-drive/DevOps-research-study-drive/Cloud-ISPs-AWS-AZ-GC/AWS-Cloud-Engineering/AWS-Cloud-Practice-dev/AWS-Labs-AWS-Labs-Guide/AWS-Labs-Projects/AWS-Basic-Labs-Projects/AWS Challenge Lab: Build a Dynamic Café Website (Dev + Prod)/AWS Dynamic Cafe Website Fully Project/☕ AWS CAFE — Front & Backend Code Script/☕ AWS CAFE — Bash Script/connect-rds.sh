#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================

# Use Secret Name OR Secret ARN
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"

# Choose DB engine: mysql | postgres
DB_ENGINE="mysql"

# ==========================================
# FETCH SECRET FROM AWS SECRETS MANAGER
# ==========================================

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

if [ -z "$SECRET_JSON" ]; then
  echo "❌ Failed to retrieve secret"
  exit 1
fi

# ==========================================
# PARSE SECRET VALUES
# ==========================================

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

# ==========================================
# CONNECT TO RDS
# ==========================================

if [ "$DB_ENGINE" = "mysql" ]; then
  echo "🔐 Connecting to MySQL RDS..."
  mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"

elif [ "$DB_ENGINE" = "postgres" ]; then
  echo "🔐 Connecting to PostgreSQL RDS..."
  PGPASSWORD="$DB_PASS" psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME"

else
  echo "❌ Unsupported DB engine"
  exit 1
fi
