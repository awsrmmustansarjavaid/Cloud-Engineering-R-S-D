#!/bin/bash
# =========================================================
# Upload /var/www/html to S3 (Folder + ZIP) - Fully Final
# =========================================================
# Features:
# - Automatically creates folder structure in S3
# - Uploads both the folder and a ZIP archive
# - Handles spaces and special characters in filenames
# - Verifies all uploads
# - Generates a final report
# - Works using IAM role attached to EC2 (no AWS profile needed)
# =========================================================

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                # Local html folder to upload
S3_BUCKET="charlie-cafe-s3-bucket"           # Your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"      # Virtual folder in S3
S3_TARGET_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"   # Folder upload target
S3_TARGET_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html.zip"  # ZIP upload target

# Temporary ZIP file
ZIP_FILE="/tmp/html_$(date +%Y%m%d%H%M%S).zip"

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
echo "☁️ Uploading folder $LOCAL_HTML_DIR to $S3_TARGET_FOLDER ..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_TARGET_FOLDER/" --recursive
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Folder upload failed! Ensure EC2 role has S3 permissions."
    exit 1
fi
echo "✅ Folder upload completed successfully."
echo "---------------------------------------------"

# =========================
# 3. Create ZIP archive of HTML folder
# =========================
echo "📦 Creating ZIP archive $ZIP_FILE ..."
zip -r -q "$ZIP_FILE" "$LOCAL_HTML_DIR"
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to create ZIP archive!"
    exit 1
fi
echo "✅ ZIP archive created successfully."
echo "---------------------------------------------"

# =========================
# 4. Upload ZIP archive to S3
# =========================
echo "☁️ Uploading ZIP archive to $S3_TARGET_ZIP ..."
aws s3 cp "$ZIP_FILE" "$S3_TARGET_ZIP"
if [ $? -ne 0 ]; then
    echo "❌ ERROR: ZIP upload failed!"
    exit 1
fi
echo "✅ ZIP upload completed successfully."
echo "---------------------------------------------"

# =========================
# 5. Verify folder upload
# =========================
echo "🔍 Verifying folder upload ..."
mapfile -t S3_FILES < <(aws s3 ls "$S3_TARGET_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')

# Generate relative paths of local files
RELATIVE_LOCAL_FILES=()
for FILE in "${LOCAL_FILES[@]}"; do
    RELATIVE_LOCAL_FILES+=("$(realpath --relative-to="$LOCAL_HTML_DIR" "$FILE")")
done

# Compare local vs S3 folder
MISSING_FILES=0
for REL_FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
    if ! printf '%s\n' "${S3_FILES[@]}" | grep -Fxq "$REL_FILE"; then
        echo "⚠️ MISSING in S3 folder: $REL_FILE"
        MISSING_FILES=$((MISSING_FILES+1))
    fi
done

echo
if [ $MISSING_FILES -eq 0 ]; then
    echo "✅ Folder verification complete: All files uploaded successfully!"
else
    echo "⚠️ Folder verification complete: $MISSING_FILES file(s) missing in S3!"
fi
echo "---------------------------------------------"

# =========================
# 6. Verify ZIP upload
# =========================
echo "🔍 Verifying ZIP archive in S3 ..."
aws s3 ls "$S3_TARGET_ZIP" > /dev/null
ZIP_EXISTS=$?

if [ $ZIP_EXISTS -eq 0 ]; then
    echo "✅ ZIP file exists in S3."
else
    echo "⚠️ ZIP file missing in S3!"
fi
echo "---------------------------------------------"

# =========================
# 7. Final Report
# =========================
REPORT_FILE="html_upload_report_$(date +%Y%m%d%H%M%S).txt"
{
    echo "📋 Upload Report - $(date)"
    echo "Local directory: $LOCAL_HTML_DIR"
    echo "S3 folder target: $S3_TARGET_FOLDER"
    echo "S3 ZIP target: $S3_TARGET_ZIP"
    echo "---------------------------------------------"
    echo "📁 Local files:"
    for FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    echo "📄 Files in S3 folder:"
    for FILE in "${S3_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    if [ $MISSING_FILES -eq 0 ]; then
        echo "✅ All folder files uploaded successfully!"
    else
        echo "⚠️ $MISSING_FILES folder file(s) missing in S3!"
    fi
    echo
    if [ $ZIP_EXISTS -eq 0 ]; then
        echo "✅ ZIP archive uploaded successfully!"
    else
        echo "⚠️ ZIP archive missing in S3!"
    fi
} > "$REPORT_FILE"

echo "📄 Final report saved to $REPORT_FILE"

# =========================
# 8. Cleanup
# =========================
rm -f "$ZIP_FILE"
echo "🧹 Temporary ZIP file removed."