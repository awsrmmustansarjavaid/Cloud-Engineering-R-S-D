#!/bin/bash
# =========================================================
# Upload HTML + Bash Scripts to S3 (Folder + ZIP) - Fully Final
# =========================================================
# Features:
# - Automatically creates folder structure in S3
# - Uploads both folder and ZIP archive
# - Handles spaces and special characters in filenames
# - Works even if script runs via sudo
# - Verifies all uploads
# - Generates final report
# =========================================================

set -euo pipefail

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                      # Local html folder to upload
EC2_USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")   # Correct home directory even if run with sudo
LOCAL_BASH_DIR="$EC2_USER_HOME"                     # Local directory containing .sh scripts
S3_BUCKET="charlie-cafe-s3-bucket"                 # Your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"            # Virtual folder in S3

# HTML targets
S3_HTML_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"
S3_HTML_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html.zip"

# Bash script targets
S3_BASH_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash script"
S3_BASH_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash_script.zip"

# Temporary ZIP files
ZIP_HTML_FILE="/tmp/html_$(date +%Y%m%d%H%M%S).zip"
ZIP_BASH_FILE="/tmp/bash_$(date +%Y%m%d%H%M%S).zip"

# =========================
# 1️⃣ Upload HTML folder + ZIP
# =========================
echo "📥 Uploading HTML folder to S3..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_HTML_FOLDER/" --recursive
echo "✅ HTML folder uploaded."

echo "📦 Creating ZIP archive of HTML..."
zip -r -q "$ZIP_HTML_FILE" "$LOCAL_HTML_DIR"
aws s3 cp "$ZIP_HTML_FILE" "$S3_HTML_ZIP"
echo "✅ HTML ZIP uploaded."

# =========================
# 2️⃣ Upload Bash scripts folder + ZIP
# =========================
echo "📥 Uploading all .sh files from $LOCAL_BASH_DIR to S3..."

# Find all .sh files in home directory
mapfile -t SH_FILES < <(find "$LOCAL_BASH_DIR" -maxdepth 1 -type f -name "*.sh")

if [ ${#SH_FILES[@]} -eq 0 ]; then
    echo "⚠️ No .sh files found in $LOCAL_BASH_DIR"
else
    # Create temp folder for .sh upload
    TMP_BASH_DIR="/tmp/bash_upload_$(date +%s)"
    mkdir -p "$TMP_BASH_DIR"

    # Copy .sh files to temp folder
    for f in "${SH_FILES[@]}"; do
        cp "$f" "$TMP_BASH_DIR/"
    done

    # Upload folder to S3
    aws s3 cp "$TMP_BASH_DIR" "$S3_BASH_FOLDER/" --recursive
    echo "✅ Bash scripts folder uploaded."

    # Create ZIP and upload
    zip -r -q "$ZIP_BASH_FILE" "$TMP_BASH_DIR"
    aws s3 cp "$ZIP_BASH_FILE" "$S3_BASH_ZIP"
    echo "✅ Bash scripts ZIP uploaded."

    # Cleanup temp files
    rm -rf "$TMP_BASH_DIR" "$ZIP_BASH_FILE"
fi

# Cleanup HTML ZIP
rm -f "$ZIP_HTML_FILE"

# =========================
# 3️⃣ Verification
# =========================
echo "🔍 Verifying uploads..."

# HTML folder
HTML_S3_FILES=$(aws s3 ls "$S3_HTML_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 HTML files in S3:"
echo "$HTML_S3_FILES"

# Bash folder
BASH_S3_FILES=$(aws s3 ls "$S3_BASH_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 Bash scripts in S3:"
echo "$BASH_S3_FILES"

# ZIP files
echo "🔹 Checking ZIP files existence..."
aws s3 ls "$S3_HTML_ZIP" > /dev/null && echo "✅ HTML ZIP exists in S3." || echo "⚠️ HTML ZIP missing!"
aws s3 ls "$S3_BASH_ZIP" > /dev/null && echo "✅ Bash ZIP exists in S3." || echo "⚠️ Bash ZIP missing!"

echo "✅ Charlie Cafe S3 upload completed successfully!"
