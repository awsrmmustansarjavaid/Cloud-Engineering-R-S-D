#!/bin/bash
# =========================================================
# Upload /var/www/html to S3 - Fully Final Version
# =========================================================
# Features:
# - Automatically creates folder structure in S3 (virtual folders)
# - Handles spaces and special characters in filenames
# - Verifies all files uploaded
# - Generates a final report
# - Works using IAM role attached to EC2 (no AWS profile needed)
# =========================================================

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                # Local html folder to upload
S3_BUCKET="charlie-cafe-s3-bucket"           # Your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"      # Virtual folder in S3
S3_TARGET="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"

# =========================
# 1. List all local files
# =========================
echo "🔍 Listing all files in $LOCAL_HTML_DIR ..."
mapfile -d $'\0' LOCAL_FILES < <(find "$LOCAL_HTML_DIR" -type f -print0)
echo "Total files found: ${#LOCAL_FILES[@]}"
echo "---------------------------------------------"

# =========================
# 2. Upload html folder to S3
# =========================
echo "☁️ Uploading $LOCAL_HTML_DIR to $S3_TARGET ..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_TARGET/" --recursive
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Upload failed! Ensure EC2 role has S3 permissions."
    exit 1
fi
echo "✅ Upload completed successfully."
echo "---------------------------------------------"

# =========================
# 3. Verify all files uploaded
# =========================
echo "🔍 Verifying all files uploaded to S3 ..."
mapfile -t S3_FILES < <(aws s3 ls "$S3_TARGET/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')

# Generate relative paths of local files
RELATIVE_LOCAL_FILES=()
for FILE in "${LOCAL_FILES[@]}"; do
    RELATIVE_LOCAL_FILES+=("$(realpath --relative-to="$LOCAL_HTML_DIR" "$FILE")")
done

# Compare local vs S3
MISSING_FILES=0
for REL_FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
    if ! printf '%s\n' "${S3_FILES[@]}" | grep -Fxq "$REL_FILE"; then
        echo "⚠️ MISSING in S3: $REL_FILE"
        MISSING_FILES=$((MISSING_FILES+1))
    fi
done

echo
if [ $MISSING_FILES -eq 0 ]; then
    echo "✅ Verification complete: All files uploaded successfully!"
else
    echo "⚠️ Verification complete: $MISSING_FILES file(s) missing in S3!"
fi
echo "---------------------------------------------"

# =========================
# 4. Final Report
# =========================
REPORT_FILE="html_upload_report_$(date +%Y%m%d%H%M%S).txt"
{
    echo "📋 Upload Report - $(date)"
    echo "Local directory: $LOCAL_HTML_DIR"
    echo "S3 target: $S3_TARGET"
    echo "---------------------------------------------"
    echo "📁 Local files:"
    for FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    echo "📄 Files in S3:"
    for FILE in "${S3_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    if [ $MISSING_FILES -eq 0 ]; then
        echo "✅ All files uploaded successfully!"
    else
        echo "⚠️ $MISSING_FILES file(s) missing in S3!"
    fi
} > "$REPORT_FILE"

echo "📄 Final report saved to $REPORT_FILE"