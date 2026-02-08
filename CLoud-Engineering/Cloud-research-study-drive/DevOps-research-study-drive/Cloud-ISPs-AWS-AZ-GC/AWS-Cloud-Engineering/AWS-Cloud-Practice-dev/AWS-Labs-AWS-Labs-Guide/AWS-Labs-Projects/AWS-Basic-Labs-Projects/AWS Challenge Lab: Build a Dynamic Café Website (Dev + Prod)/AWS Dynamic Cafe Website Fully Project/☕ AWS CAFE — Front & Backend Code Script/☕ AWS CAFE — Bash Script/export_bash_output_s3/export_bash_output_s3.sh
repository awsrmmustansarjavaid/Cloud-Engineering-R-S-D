#!/bin/bash
# ============================================================================
# ☕ Charlie Café — Bash Output → TXT / CSV / PDF → S3
#
# PLATFORM : Amazon Linux 2023
# PDF MODE : enscript + ghostscript (NO pandoc / NO latex / NO weasyprint)
# SAFE     : Read-only execution of target script
# ============================================================================

set -Eeuo pipefail

# ----------------------------------------------------------------------------
# USER CONFIGURATION
# ----------------------------------------------------------------------------
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie-Cafe/Test-Verification"
AWS_REGION="us-east-1"

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

# ----------------------------------------------------------------------------
# VALIDATION
# ----------------------------------------------------------------------------
if [[ ! -f "$TARGET_BASH_SCRIPT" ]]; then
  echo "❌ Target script not found: $TARGET_BASH_SCRIPT"
  exit 1
fi

# ----------------------------------------------------------------------------
# TIMESTAMP & FILES
# ----------------------------------------------------------------------------
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

WORKDIR="/tmp/bash-report-$TIMESTAMP"
mkdir -p "$WORKDIR"

OUTPUT_TXT="$WORKDIR/output_$TIMESTAMP.txt"
OUTPUT_CSV="$WORKDIR/output_$TIMESTAMP.csv"
OUTPUT_PS="$WORKDIR/output_$TIMESTAMP.ps"
OUTPUT_PDF="$WORKDIR/output_$TIMESTAMP.pdf"

# ----------------------------------------------------------------------------
# INSTALL PREREQUISITES (Amazon Linux 2023)
# ----------------------------------------------------------------------------
echo "📦 Installing required packages..."

sudo dnf install -y \
  awscli \
  enscript \
  ghostscript \
  util-linux \
  coreutils

echo "✅ Packages installed"

# ----------------------------------------------------------------------------
# AWS REGION (IAM ROLE OR ENV CREDS EXPECTED)
# ----------------------------------------------------------------------------
export AWS_DEFAULT_REGION="$AWS_REGION"

# ----------------------------------------------------------------------------
# RUN TARGET SCRIPT & CAPTURE OUTPUT
# ----------------------------------------------------------------------------
{
  echo "===================================================="
  echo "☕ Charlie Café — Test & Verification Report"
  echo "Script     : $TARGET_BASH_SCRIPT"
  echo "Executed   : $(date)"
  echo "EC2 Host   : $(hostname)"
  echo "===================================================="
  echo
  bash "$TARGET_BASH_SCRIPT"
} 2>&1 | tee "$OUTPUT_TXT"

# ----------------------------------------------------------------------------
# TXT → CSV (1 line per row, Excel-safe)
# ----------------------------------------------------------------------------
awk '{ gsub(/"/,"\"\""); print "\"" $0 "\"" }' "$OUTPUT_TXT" > "$OUTPUT_CSV"

# ----------------------------------------------------------------------------
# TXT → PDF (ROCK-SOLID METHOD)
# ----------------------------------------------------------------------------
echo "📄 Generating PDF..."

enscript "$OUTPUT_TXT" \
  --font=Courier10 \
  --margins=72:72:72:72 \
  --word-wrap \
  --no-header \
  -p "$OUTPUT_PS"

ps2pdf "$OUTPUT_PS" "$OUTPUT_PDF"

if [[ ! -f "$OUTPUT_PDF" ]]; then
  echo "❌ PDF generation failed"
  exit 1
fi

echo "✅ PDF generated successfully"

# ----------------------------------------------------------------------------
# UPLOAD TO S3
# ----------------------------------------------------------------------------
echo "☁️ Uploading to S3..."

aws s3 cp "$OUTPUT_TXT" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$OUTPUT_TXT")"
aws s3 cp "$OUTPUT_CSV" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$OUTPUT_CSV")"
aws s3 cp "$OUTPUT_PDF" "s3://$S3_BUCKET/$S3_PREFIX/$(basename "$OUTPUT_PDF")"

# ----------------------------------------------------------------------------
# CLEANUP
# ----------------------------------------------------------------------------
rm -rf "$WORKDIR"

# ----------------------------------------------------------------------------
# DONE
# ----------------------------------------------------------------------------
echo "===================================================="
echo "🎉 EXPORT COMPLETED SUCCESSFULLY"
echo "📄 PDF  : s3://$S3_BUCKET/$S3_PREFIX/$(basename "$OUTPUT_PDF")"
echo "📊 CSV  : Uploaded"
echo "📝 TXT  : Uploaded"
echo "===================================================="
