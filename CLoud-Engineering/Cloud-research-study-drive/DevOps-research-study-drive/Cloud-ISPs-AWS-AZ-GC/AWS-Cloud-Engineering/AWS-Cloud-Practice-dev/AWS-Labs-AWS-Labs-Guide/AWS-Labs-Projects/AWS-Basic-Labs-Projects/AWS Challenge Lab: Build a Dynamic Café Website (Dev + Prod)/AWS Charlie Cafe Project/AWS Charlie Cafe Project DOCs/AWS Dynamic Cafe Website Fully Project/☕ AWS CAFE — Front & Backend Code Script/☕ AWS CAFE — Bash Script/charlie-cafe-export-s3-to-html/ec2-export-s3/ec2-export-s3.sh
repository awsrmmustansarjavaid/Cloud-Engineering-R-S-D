#!/bin/bash
# =========================================================
# Charlie Café S3 Backup & Upload Script (Professional DevOps)
# =========================================================
# Features:
# - Uploads HTML, Bash scripts, and HTTPD config to S3
# - Creates timestamped folders for versioned backups
# - Generates ZIP archives of each folder
# - Logs every action
# - Robust error handling and verification
# - Can run under sudo or regular user
# =========================================================

set -euo pipefail
IFS=$'\n\t'

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"
EC2_USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
LOCAL_BASH_DIR="$EC2_USER_HOME"
HTTPD_CONF_FILE="/etc/httpd/conf/httpd.conf"

S3_BUCKET="charlie-cafe-s3-bucket"
S3_ROOT_FOLDER="charlie-cafe-web-drive"

# Timestamp for versioning
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Temporary ZIP paths
TMP_DIR="/tmp/charlie_cafe_backup_$TIMESTAMP"
ZIP_HTML_FILE="$TMP_DIR/html_$TIMESTAMP.zip"
ZIP_BASH_FILE="$TMP_DIR/bash_$TIMESTAMP.zip"
ZIP_HTTPD_FILE="$TMP_DIR/httpd_$TIMESTAMP.zip"

mkdir -p "$TMP_DIR"

# =========================
# Logging
# =========================
log() {
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

error_exit() {
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] ❌ ERROR: $1"
    exit 1
}

# =========================
# Function to upload folder and zip
# =========================
upload_folder_and_zip() {
    local LOCAL_PATH=$1
    local S3_FOLDER=$2
    local ZIP_PATH=$3
    local NAME=$4

    log "📥 Uploading $NAME folder to S3..."
    aws s3 cp "$LOCAL_PATH" "$S3_FOLDER/" --recursive || error_exit "Failed to upload $NAME folder."

    log "📦 Creating ZIP archive of $NAME..."
    zip -r -q "$ZIP_PATH" "$LOCAL_PATH" || error_exit "Failed to create ZIP for $NAME."
    aws s3 cp "$ZIP_PATH" "${S3_FOLDER%/}.zip" || error_exit "Failed to upload ZIP for $NAME."

    log "✅ $NAME upload completed successfully."
}

# =========================
# 1️⃣ Upload HTML
# =========================
S3_HTML_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html/$TIMESTAMP"
upload_folder_and_zip "$LOCAL_HTML_DIR" "$S3_HTML_FOLDER" "$ZIP_HTML_FILE" "HTML"

# =========================
# 2️⃣ Upload Bash Scripts
# =========================
mapfile -t SH_FILES < <(find "$LOCAL_BASH_DIR" -maxdepth 1 -type f -name "*.sh")
if [ ${#SH_FILES[@]} -eq 0 ]; then
    log "⚠️ No .sh files found in $LOCAL_BASH_DIR"
else
    TMP_BASH_DIR="$TMP_DIR/bash_scripts_$TIMESTAMP"
    mkdir -p "$TMP_BASH_DIR"
    for f in "${SH_FILES[@]}"; do
        cp "$f" "$TMP_BASH_DIR/"
    done
    S3_BASH_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash_script/$TIMESTAMP"
    upload_folder_and_zip "$TMP_BASH_DIR" "$S3_BASH_FOLDER" "$ZIP_BASH_FILE" "Bash Scripts"
fi

# =========================
# 3️⃣ Upload HTTPD Config
# =========================
if [ -f "$HTTPD_CONF_FILE" ]; then
    TMP_HTTPD_DIR="$TMP_DIR/httpd_$TIMESTAMP"
    mkdir -p "$TMP_HTTPD_DIR"
    cp "$HTTPD_CONF_FILE" "$TMP_HTTPD_DIR/"
    S3_HTTPD_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/httpd/$TIMESTAMP"
    upload_folder_and_zip "$TMP_HTTPD_DIR" "$S3_HTTPD_FOLDER" "$ZIP_HTTPD_FILE" "HTTPD Config"
else
    log "⚠️ httpd.conf not found at $HTTPD_CONF_FILE"
fi

# =========================
# 4️⃣ Verification
# =========================
log "🔍 Verifying uploads..."

verify_s3_folder() {
    local S3_FOLDER=$1
    local NAME=$2
    FILES=$(aws s3 ls "$S3_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
    if [ -z "$FILES" ]; then
        log "⚠️ $NAME folder is empty in S3!"
    else
        log "📁 $NAME files in S3:"
        echo "$FILES"
    fi

    aws s3 ls "${S3_FOLDER%/}.zip" > /dev/null && log "✅ $NAME ZIP exists in S3." || log "⚠️ $NAME ZIP missing!"
}

verify_s3_folder "$S3_HTML_FOLDER" "HTML"
verify_s3_folder "$S3_BASH_FOLDER" "Bash Scripts"
verify_s3_folder "$S3_HTTPD_FOLDER" "HTTPD Config"

# =========================
# Cleanup
# =========================
rm -rf "$TMP_DIR"

log "🎉 Charlie Café S3 backup completed successfully!"