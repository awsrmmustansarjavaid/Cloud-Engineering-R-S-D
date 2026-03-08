#!/bin/bash
# =============================================================
# Charlie Cafe Basic Lab Configuration Test and Verification
#
# TASK: Runs any bash script, captures output, converts to CSV & PDF,
#       and uploads results to S3 with timestamped filenames.
# =============================================================

set -euo pipefail

# ===============================
# AWS CONFIGURATION (REPLACE WITH YOUR KEYS)
# ===============================
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# ===============================
# INPUT: Script to run
# ===============================
SCRIPT_TO_RUN="$1"   # e.g., ./charlie_cafe_lab_verify.sh
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

if [[ -z "$SCRIPT_TO_RUN" || ! -f "$SCRIPT_TO_RUN" ]]; then
  echo "❌ Usage: $0 <script-to-run>"
  exit 1
fi

# ===============================
# TIMESTAMP
# ===============================
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
OUTPUT_DIR="output_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# ===============================
# FILE PATHS
# ===============================
BASE_NAME=$(basename "$SCRIPT_TO_RUN" .sh)
TXT_FILE="$OUTPUT_DIR/${BASE_NAME}_Result_${TIMESTAMP}.txt"
CSV_FILE="$OUTPUT_DIR/${BASE_NAME}_Result_${TIMESTAMP}.csv"
PDF_FILE="$OUTPUT_DIR/${BASE_NAME}_Result_${TIMESTAMP}.pdf"

# ===============================
# SHOW TASK INFO
# ===============================
echo "===================================================="
echo "Charlie Cafe Basic Lab Configuration Test and Verification"
echo "Script: $SCRIPT_TO_RUN"
echo "Timestamp: $TIMESTAMP"
echo "Results TXT: $TXT_FILE"
echo "Results CSV: $CSV_FILE"
echo "Results PDF: $PDF_FILE"
echo "S3 Bucket: $S3_BUCKET/$S3_PREFIX"
echo "===================================================="
echo
echo "List of Tests / Verification tasks that will run:"
echo "  1. Apache & PHP check (LAMP stack)"
echo "  2. MySQL client verification"
echo "  3. Directory permissions check"
echo "  4. AWS RDS database connection"
echo "  5. Database existence"
echo "  6. Required tables verification"
echo "  7. Table structure (DESCRIBE)"
echo "  8. Critical columns check"
echo "  9. Indexes and constraints verification"
echo " 10. Row counts and sample data check"
echo "===================================================="
echo

# ===============================
# INSTALL PANDOC IF MISSING
# ===============================
if ! command -v pandoc >/dev/null 2>&1; then
    echo "📦 pandoc not found. Installing..."
    sudo yum install -y pandoc
else
    echo "✅ pandoc already installed"
fi

# ===============================
# RUN SCRIPT AND CAPTURE OUTPUT
# ===============================
echo "▶️ Running script: $SCRIPT_TO_RUN ..."
bash "$SCRIPT_TO_RUN" 2>&1 | tee "$TXT_FILE"

# ===============================
# CONVERT TXT TO CSV
# ===============================
echo "📄 Converting TXT to CSV..."
awk '{ print strftime("%Y-%m-%d %H:%M:%S"), ",", $0 }' "$TXT_FILE" > "$CSV_FILE"

# ===============================
# CONVERT TXT TO PDF
# ===============================
echo "📑 Converting TXT to PDF..."
pandoc "$TXT_FILE" -o "$PDF_FILE"

# ===============================
# UPLOAD TO S3
# ===============================
echo "☁️ Uploading results to S3..."
aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$TXT_FILE")"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$CSV_FILE")"
aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$PDF_FILE")"

echo
echo "✅ Files successfully uploaded to S3:"
echo " - s3://$S3_BUCKET/$S3_PREFIX/$(basename "$TXT_FILE")"
echo " - s3://$S3_BUCKET/$S3_PREFIX/$(basename "$CSV_FILE")"
echo " - s3://$S3_BUCKET/$S3_PREFIX/$(basename "$PDF_FILE")"
echo
echo "🎉 Charlie Cafe Basic Lab Configuration Test and Verification COMPLETED!"
