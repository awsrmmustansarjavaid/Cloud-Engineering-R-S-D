#!/bin/bash
# =============================================================
# Exporting Bash Script Output to S3
#
# This script runs any specified bash script, captures its
# output (stdout + stderr), saves it to a text file, converts
# it to CSV and PDF, and uploads all three to an S3 bucket.
#
# Requirements:
# - AWS CLI configured (Access Key + Secret Key)
# - pandoc (installed automatically if missing)
# =============================================================

set -euo pipefail

# ===============================
# ASK USER INPUTS
# ===============================
read -p "Enter the full path of the bash script to run: " SCRIPT_PATH
if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "❌ File not found: $SCRIPT_PATH"
  exit 1
fi

read -p "Enter AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "Enter AWS Region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

read -p "Enter S3 Bucket name: " S3_BUCKET
read -p "Enter S3 folder/prefix (default: Bash Script Output): " S3_PREFIX
S3_PREFIX=${S3_PREFIX:-Bash Script Output}

# ===============================
# EXPORT AWS CREDENTIALS
# ===============================
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="$AWS_REGION"

# ===============================
# TIMESTAMP & OUTPUT FILES
# ===============================
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BASENAME=$(basename "$SCRIPT_PATH" .sh)
TXT_FILE="${BASENAME}_Output_${TIMESTAMP}.txt"
CSV_FILE="${BASENAME}_Output_${TIMESTAMP}.csv"
PDF_FILE="${BASENAME}_Output_${TIMESTAMP}.pdf"

# ===============================
# CHECK PANDOC AND INSTALL IF NEEDED
# ===============================
if ! command -v pandoc >/dev/null 2>&1; then
    echo "⚠️ pandoc not found. Installing..."
    sudo yum install -y pandoc || { echo "❌ Failed to install pandoc"; exit 1; }
    ok="✅"
    echo "$ok pandoc installed"
fi

# ===============================
# RUN THE SCRIPT AND CAPTURE OUTPUT
# ===============================
echo "🔹 Running script: $SCRIPT_PATH"
echo "-------------------------------------------------------------"
bash "$SCRIPT_PATH" >"$TXT_FILE" 2>&1
echo "✅ Script output saved to $TXT_FILE"

# ===============================
# CONVERT TXT TO CSV (simple)
# ===============================
# Each line becomes a CSV row (text only)
awk '{gsub(/"/,"\"\""); print "\"" $0 "\"" }' "$TXT_FILE" >"$CSV_FILE"
echo "✅ Converted output to CSV: $CSV_FILE"

# ===============================
# CONVERT TXT TO PDF USING PANDOC
# ===============================
pandoc "$TXT_FILE" -o "$PDF_FILE" --pdf-engine=xelatex || { echo "❌ PDF conversion failed"; exit 1; }
echo "✅ Converted output to PDF: $PDF_FILE"

# ===============================
# UPLOAD FILES TO S3
# ===============================
echo "☁️ Uploading files to S3..."
aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE"
aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE"
echo "✅ Files uploaded to S3:"
echo "   - s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE"
echo "   - s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE"
echo "   - s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE"

# ===============================
# FINAL STATUS
# ===============================
echo "============================================================="
echo "🎉 Bash script output export completed successfully!"
echo "All files are available in S3 with timestamp $TIMESTAMP"
echo "============================================================="
