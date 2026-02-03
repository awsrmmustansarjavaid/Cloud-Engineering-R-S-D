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
# USER CONFIGURATION
# ===============================

AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
AWS_REGION="us-east-1"
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
    PANDOC_VERSION="3.1.7"
    PANDOC_URL="https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/pandoc-$PANDOC_VERSION-linux-amd64.tar.gz"

    TMP_DIR=$(mktemp -d)
    curl -L "$PANDOC_URL" -o "$TMP_DIR/pandoc.tar.gz"
    tar -xzf "$TMP_DIR/pandoc.tar.gz" -C "$TMP_DIR"
    sudo cp "$TMP_DIR/pandoc-$PANDOC_VERSION/bin/pandoc" /usr/local/bin/
    sudo chmod +x /usr/local/bin/pandoc
    rm -rf "$TMP_DIR"
    echo "✅ Pandoc installed successfully"
fi

# ===============================
# CHECK & INSTALL PYTHON + PIP + WEASYPRINT
# ===============================
if ! command -v weasyprint >/dev/null 2>&1; then
    echo "📦 WeasyPrint not found. Installing Python3 + pip + WeasyPrint..."

    # Install python3 if not present
    sudo yum install -y python3

    # Install system dependencies required by WeasyPrint
    echo "📦 Installing WeasyPrint system dependencies..."
    sudo yum install -y cairo cairo-devel pango pango-devel gdk-pixbuf2 gdk-pixbuf2-devel libffi libffi-devel

    # Ensure pip is installed
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "📦 pip not found. Installing pip..."
        curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        sudo python3 /tmp/get-pip.py
        rm -f /tmp/get-pip.py
    fi

    # Upgrade pip to avoid old version issues
    python3 -m pip install --upgrade pip --user

    # Install WeasyPrint for the current user
    python3 -m pip install --user weasyprint

    # Add user bin to PATH
    export PATH=$PATH:$HOME/.local/bin

    echo "✅ WeasyPrint installed successfully"
fi


# ===============================
# RUN TARGET BASH SCRIPT
# ===============================
echo "🧪 Running target bash script: $TARGET_BASH_SCRIPT"
echo "-------------------------------------------------------------"
bash "$TARGET_BASH_SCRIPT" 2>&1 | tee "$OUTPUT_TEXT"

# ===============================
# CONVERT TEXT TO CSV
# ===============================
echo "🔄 Converting output to CSV..."
awk '{gsub(/"/,"\"\""); print "\"" $0 "\""}' "$OUTPUT_TEXT" > "$OUTPUT_CSV"
if [ -f "$OUTPUT_CSV" ]; then
    echo "✅ CSV created: $OUTPUT_CSV"
else
    echo "❌ Failed to create CSV"
fi

# ===============================
# CONVERT TEXT TO PDF
# ===============================
echo "🔄 Converting output to PDF using Pandoc..."
PDF_CREATED=false
if command -v pandoc >/dev/null 2>&1; then
    # Try default PDF engine (pdflatex)
    if pandoc "$OUTPUT_TEXT" -o "$OUTPUT_PDF" >/dev/null 2>&1; then
        PDF_CREATED=true
    else
        # Fallback: Use WeasyPrint
        echo "⚠️ pdflatex failed, trying WeasyPrint..."
        if pandoc "$OUTPUT_TEXT" -o "$OUTPUT_PDF" --pdf-engine=weasyprint >/dev/null 2>&1; then
            PDF_CREATED=true
        else
            echo "❌ PDF conversion failed with both engines"
        fi
    fi
fi

if $PDF_CREATED; then
    echo "✅ PDF created: $OUTPUT_PDF"
else
    echo "⚠️ PDF not generated, only TXT + CSV available"
fi

# ===============================
# UPLOAD FILES TO S3
# ===============================
echo "☁️ Uploading files to S3 bucket: $S3_BUCKET/$S3_PREFIX"
aws s3 cp "$OUTPUT_TEXT" "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_TEXT"
aws s3 cp "$OUTPUT_CSV"  "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_CSV"
if $PDF_CREATED; then
    aws s3 cp "$OUTPUT_PDF"  "s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_PDF"
fi

echo "✅ Files uploaded to S3 successfully:"
echo "   • $OUTPUT_TEXT"
echo "   • $OUTPUT_CSV"
if $PDF_CREATED; then
    echo "   • $OUTPUT_PDF"
fi

# ===============================
# FINAL MESSAGE
# ===============================
echo "============================================================="
echo "🎉 Bash script output successfully exported to S3"
echo "Files include timestamp: $TIMESTAMP"
echo "============================================================="