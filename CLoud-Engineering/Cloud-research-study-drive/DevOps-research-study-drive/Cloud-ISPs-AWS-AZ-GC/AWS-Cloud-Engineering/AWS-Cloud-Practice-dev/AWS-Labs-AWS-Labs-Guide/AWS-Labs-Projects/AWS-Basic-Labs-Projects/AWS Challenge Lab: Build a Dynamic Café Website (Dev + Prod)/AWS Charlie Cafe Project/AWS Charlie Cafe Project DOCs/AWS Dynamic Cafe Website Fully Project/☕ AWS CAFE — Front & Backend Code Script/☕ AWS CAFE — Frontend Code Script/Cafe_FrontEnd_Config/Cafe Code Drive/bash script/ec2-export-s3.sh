#!/bin/bash
# =========================================================
# Charlie Café S3 Backup & Upload Script (Final Production)
# =========================================================
# Features:
# - Uploads HTML, Bash scripts, and HTTPD config to S3
# - Creates timestamped ZIP archives for versioned backups
# - Logs every action
# - Robust error handling and verification
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

# =========================
# Logging functions
# =========================
log() {
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

error_exit() {
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] ❌ ERROR: $1"
    exit 1
}

# =========================
# Function to upload folder & ZIP
# =========================
upload_and_zip() {
    local LOCAL_PATH=$1
    local S3_FOLDER=$2
    local NAME=$3

    log "📥 Uploading $NAME to S3..."
    aws s3 cp "$LOCAL_PATH" "$S3_FOLDER/" --recursive || error_exit "Failed to upload $NAME folder to S3."

    # Create ZIP directly from the folder
    local ZIP_FILE="/tmp/${NAME}_${TIMESTAMP}.zip"
    log "📦 Creating ZIP archive for $NAME..."
    zip -r -q "$ZIP_FILE" "$LOCAL_PATH" || error_exit "Failed to create ZIP for $NAME."
    
    aws s3 cp "$ZIP_FILE" "${S3_FOLDER%/}.zip" || error_exit "Failed to upload ZIP for $NAME."
    log "✅ $NAME uploaded and ZIP created successfully."
    
    # Cleanup local ZIP
    rm -f "$ZIP_FILE"
}

# =========================
# 1️⃣ Upload HTML
# =========================
S3_HTML_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html/$TIMESTAMP"
upload_and_zip "$LOCAL_HTML_DIR" "$S3_HTML_FOLDER" "html"

# =========================
# 2️⃣ Upload Bash Scripts
# =========================
SH_FILES=$(find "$LOCAL_BASH_DIR" -maxdepth 1 -type f -name "*.sh")
if [ -z "$SH_FILES" ]; then
    log "⚠️ No .sh files found in $LOCAL_BASH_DIR"
else
    TMP_BASH_DIR="$LOCAL_BASH_DIR/bash_backup_$TIMESTAMP"
    mkdir -p "$TMP_BASH_DIR"
    for f in $SH_FILES; do
        cp "$f" "$TMP_BASH_DIR/"
    done
    S3_BASH_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash_scripts/$TIMESTAMP"
    upload_and_zip "$TMP_BASH_DIR" "$S3_BASH_FOLDER" "bash_scripts"
    rm -rf "$TMP_BASH_DIR"
fi

# =========================
# 3️⃣ Upload HTTPD Config
# =========================
if [ -f "$HTTPD_CONF_FILE" ]; then
    TMP_HTTPD_DIR="/tmp/httpd_backup_$TIMESTAMP"
    mkdir -p "$TMP_HTTPD_DIR"
    cp "$HTTPD_CONF_FILE" "$TMP_HTTPD_DIR/"
    S3_HTTPD_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/httpd/$TIMESTAMP"
    upload_and_zip "$TMP_HTTPD_DIR" "$S3_HTTPD_FOLDER" "httpd_conf"
    rm -rf "$TMP_HTTPD_DIR"
else
    log "⚠️ httpd.conf not found at $HTTPD_CONF_FILE"
fi

# =========================
# 4️⃣ Verification
# =========================
verify_s3() {
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

verify_s3 "$S3_HTML_FOLDER" "HTML"
[ -n "${S3_BASH_FOLDER:-}" ] && verify_s3 "$S3_BASH_FOLDER" "Bash Scripts"
[ -n "${S3_HTTPD_FOLDER:-}" ] && verify_s3 "$S3_HTTPD_FOLDER" "HTTPD Config"

log "🎉 Charlie Café S3 backup completed successfully!"