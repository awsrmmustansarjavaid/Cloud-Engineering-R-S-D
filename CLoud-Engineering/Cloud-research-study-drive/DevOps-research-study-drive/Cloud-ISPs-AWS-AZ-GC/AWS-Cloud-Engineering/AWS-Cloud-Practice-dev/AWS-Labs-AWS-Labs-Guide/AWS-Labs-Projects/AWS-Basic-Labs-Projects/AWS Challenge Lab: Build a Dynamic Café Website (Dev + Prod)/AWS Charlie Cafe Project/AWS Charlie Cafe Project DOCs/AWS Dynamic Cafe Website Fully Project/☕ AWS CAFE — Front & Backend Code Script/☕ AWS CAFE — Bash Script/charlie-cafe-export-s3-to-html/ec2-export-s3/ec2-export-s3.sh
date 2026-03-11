#!/bin/bash
# =========================================================
# Upload HTML + Bash Scripts + HTTPD Config to S3
# Charlie Cafe Infrastructure Backup Script
# =========================================================
# Features:
# - Automatically creates folder structure in S3
# - Uploads folders + ZIP archives
# - Handles spaces and special characters
# - Works with sudo
# - Verifies all uploads
# - Generates final report
# =========================================================

set -euo pipefail

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"
EC2_USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
LOCAL_BASH_DIR="$EC2_USER_HOME"

HTTPD_CONF_FILE="/etc/httpd/conf/httpd.conf"

S3_BUCKET="charlie-cafe-s3-bucket"
S3_ROOT_FOLDER="charlie-cafe-web-drive"

# HTML
S3_HTML_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"
S3_HTML_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html.zip"

# Bash
S3_BASH_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash script"
S3_BASH_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash_script.zip"

# HTTPD
S3_HTTPD_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/httpd"
S3_HTTPD_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/httpd.zip"

# Temporary ZIP files
ZIP_HTML_FILE="/tmp/html_$(date +%Y%m%d%H%M%S).zip"
ZIP_BASH_FILE="/tmp/bash_$(date +%Y%m%d%H%M%S).zip"
ZIP_HTTPD_FILE="/tmp/httpd_$(date +%Y%m%d%H%M%S).zip"

# =========================================================
# 1️⃣ Upload HTML folder + ZIP
# =========================================================
echo "📥 Uploading HTML folder to S3..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_HTML_FOLDER/" --recursive
echo "✅ HTML folder uploaded."

echo "📦 Creating ZIP archive of HTML..."
zip -r -q "$ZIP_HTML_FILE" "$LOCAL_HTML_DIR"
aws s3 cp "$ZIP_HTML_FILE" "$S3_HTML_ZIP"
echo "✅ HTML ZIP uploaded."

# =========================================================
# 2️⃣ Upload Bash scripts folder + ZIP
# =========================================================
echo "📥 Uploading all .sh files from $LOCAL_BASH_DIR to S3..."

mapfile -t SH_FILES < <(find "$LOCAL_BASH_DIR" -maxdepth 1 -type f -name "*.sh")

if [ ${#SH_FILES[@]} -eq 0 ]; then
    echo "⚠️ No .sh files found in $LOCAL_BASH_DIR"
else

    TMP_BASH_DIR="/tmp/bash_upload_$(date +%s)"
    mkdir -p "$TMP_BASH_DIR"

    for f in "${SH_FILES[@]}"; do
        cp "$f" "$TMP_BASH_DIR/"
    done

    aws s3 cp "$TMP_BASH_DIR" "$S3_BASH_FOLDER/" --recursive
    echo "✅ Bash scripts folder uploaded."

    zip -r -q "$ZIP_BASH_FILE" "$TMP_BASH_DIR"
    aws s3 cp "$ZIP_BASH_FILE" "$S3_BASH_ZIP"
    echo "✅ Bash scripts ZIP uploaded."

    rm -rf "$TMP_BASH_DIR" "$ZIP_BASH_FILE"
fi

# =========================================================
# 3️⃣ Upload HTTPD Configuration
# =========================================================
echo "📥 Uploading Apache HTTPD configuration..."

if [ -f "$HTTPD_CONF_FILE" ]; then

    TMP_HTTPD_DIR="/tmp/httpd_upload_$(date +%s)"
    mkdir -p "$TMP_HTTPD_DIR"

    cp "$HTTPD_CONF_FILE" "$TMP_HTTPD_DIR/"

    aws s3 cp "$TMP_HTTPD_DIR" "$S3_HTTPD_FOLDER/" --recursive
    echo "✅ httpd.conf uploaded to S3 folder."

    zip -r -q "$ZIP_HTTPD_FILE" "$TMP_HTTPD_DIR"
    aws s3 cp "$ZIP_HTTPD_FILE" "$S3_HTTPD_ZIP"
    echo "✅ HTTPD ZIP uploaded."

    rm -rf "$TMP_HTTPD_DIR" "$ZIP_HTTPD_FILE"

else
    echo "⚠️ httpd.conf file not found!"
fi

# Cleanup HTML ZIP
rm -f "$ZIP_HTML_FILE"

# =========================================================
# 4️⃣ Verification
# =========================================================
echo "🔍 Verifying uploads..."

# HTML
HTML_S3_FILES=$(aws s3 ls "$S3_HTML_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 HTML files in S3:"
echo "$HTML_S3_FILES"

# Bash
BASH_S3_FILES=$(aws s3 ls "$S3_BASH_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 Bash scripts in S3:"
echo "$BASH_S3_FILES"

# HTTPD
HTTPD_S3_FILES=$(aws s3 ls "$S3_HTTPD_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 HTTPD configuration in S3:"
echo "$HTTPD_S3_FILES"

# ZIP files check
echo "🔹 Checking ZIP files existence..."

aws s3 ls "$S3_HTML_ZIP" > /dev/null && echo "✅ HTML ZIP exists in S3." || echo "⚠️ HTML ZIP missing!"
aws s3 ls "$S3_BASH_ZIP" > /dev/null && echo "✅ Bash ZIP exists in S3." || echo "⚠️ Bash ZIP missing!"
aws s3 ls "$S3_HTTPD_ZIP" > /dev/null && echo "✅ HTTPD ZIP exists in S3." || echo "⚠️ HTTPD ZIP missing!"

echo "🎉 Charlie Cafe S3 upload completed successfully!"