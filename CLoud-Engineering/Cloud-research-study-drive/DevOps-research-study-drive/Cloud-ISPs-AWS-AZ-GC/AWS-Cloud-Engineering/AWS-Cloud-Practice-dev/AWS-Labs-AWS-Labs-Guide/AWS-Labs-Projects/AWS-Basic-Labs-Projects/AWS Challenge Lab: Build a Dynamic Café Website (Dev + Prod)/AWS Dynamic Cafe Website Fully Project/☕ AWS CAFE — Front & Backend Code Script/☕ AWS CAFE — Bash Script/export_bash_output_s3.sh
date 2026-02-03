#!/bin/bash
# =============================================================
# Exporting Bash Script Output to S3
#
# DESCRIPTION:
# This script runs any specified Bash script, captures its output,
# and exports the results to AWS S3 in CSV and PDF formats.
# Adds timestamp to files, ensures Pandoc is installed, creates
# a folder in S3, and uploads the output files.
#
# SAFE: Read-only, does not modify the target script.
# =============================================================

set -euo pipefail

# ===============================
# USER CONFIGURATION (REPLACE)
# ===============================

# Replace with your AWS credentials
AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
AWS_REGION="us-east-1"

# Replace with your S3 bucket name
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

# ===============================
# SPECIFY THE BASH SCRIPT TO RUN
# ===============================
# Only one path should be active at a time

# Example 1: Script in same folder as exporter
#TARGET_BASH_SCRIPT="./connect_rds.sh"

# Example 2: Script one folder above exporter
#TARGET_BASH_SCRIPT="../connect_rds.sh"

# Example 3: Script in subfolder relative to exporter
#TARGET_BASH_SCRIPT="./subfolder/connect_rds.sh"

# Example 4: Absolute path anywhere
#TARGET_BASH_SCRIPT="/var/www/html/bash_script/connect_rds.sh"

# Example 5: Script in home directory
#TARGET_BASH_SCRIPT="$HOME/connect_rds.sh"

# Example 6: Script in /tmp folder
#TARGET_BASH_SCRIPT="/tmp/connect_rds.sh"

# ✅ Uncomment the one you want to run:
TARGET_BASH_SCRIPT="./charlie_cafe_lab_test_verify.sh"

# ===============================
# CHECK TARGET SCRIPT EXISTS
# ===============================
if [ ! -f "$TARGET_BASH_SCRIPT" ]; then
  echo "❌ Target bash script not found: $TARGET_BASH_SCRIPT"
  exit 1
fi

# ===============================
# TIMESTAMP & FILE NAMES
# ===============================
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
OUTPUT_TEXT="Basic_Script_Output_${TIMESTAMP}.txt"
OUTPUT_CSV="Basic_Script_Output_${TIMESTAMP}.csv"
OUTPUT_PDF="Basic_Script_Output_${TIMESTAMP}.pdf"

# ===============================
# EXPORT AWS CREDENTIALS
# ===============================
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="$AWS_REGION"

# ===============================
# CHECK & INSTALL PANDOC
# ===============================
if ! command -v pandoc >/dev/null 2>&1; then
    echo "📦 Pandoc not found. Installing..."
    if ! rpm -q epel-release >/dev/null 2>&1; then
        echo "   → Installing epel-release..."
        sudo amazon-linux-extras install epel -y || sudo yum install epel-release -y
    fi
    sudo yum install pandoc -y || {
        echo "❌ Pandoc installation failed. Please install manually."
        exit 1
    }
    echo "✅ Pandoc installed successfully"
fi

# ===============================
# RUN TARGET BASH SCRIPT
# ===============================
echo "🧪 Running target bash script: $TARGET_BASH_SCRIPT"
echo "-------------------------------------------------------------"

# Capture output into text file
bash "$TARGET_BASH_SCRIPT" 2>&1 | tee "$OUTPUT_TEXT"

# ===============================
# CONVERT TEXT TO CSV
# ===============================
echo "🔄 Converting output to CSV..."
awk '{gsub(/"/,"\"\""); print "\"" $0 "\""}' "$OUTPUT_TEXT" > "$OUTPUT_CSV"
echo "✅ CSV created: $OUTPUT_CSV"

# ===============================
# CONVERT TEXT TO PDF
# ===============================
echo "🔄 Converting output to PDF using Pandoc..."
pandoc "$OUTPUT_TEXT" -o "$OUTPUT_PDF"
echo "✅ PDF created: $OUTPUT_PDF"

# ===============================
# UPLOAD FILES TO S3
# ===============================
echo "☁️ Uploading files to S3 bucket: $S3_BUCKET"
aws s3 cp "$OUTPUT_TEXT" "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_TEXT"
aws s3 cp "$OUTPUT_CSV"  "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_CSV"
aws s3 cp "$OUTPUT_PDF"  "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_PDF"

echo "✅ Files uploaded to S3 successfully:"
echo "   • s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_TEXT"
echo "   • s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_CSV"
echo "   • s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_PDF"

# ===============================
# FINAL MESSAGE
# ===============================
echo "============================================================="
echo "🎉 Bash script output successfully exported to S3"
echo "Files include timestamp: $TIMESTAMP"
echo "============================================================="
