# Charlie Cafe --  S3 TO EC2 EXPORT SCRIPT

- Pulls all files from a specific folder in an S3 bucket (e.g., html/) and copies them to /var/www/html on your EC2 instance.

- Pulls another folder (e.g., bash-scripts/) from the same S3 bucket to /home/download.

- Uses a config section where you can easily replace your S3 bucket name, AWS Access Key, and Secret Key.

#### Here’s a ready-to-use script for that:

```
#!/bin/bash
# =========================================================
# S3 TO EC2 EXPORT SCRIPT
# =========================================================

# =========================
# ⚙️ CONFIGURATION
# =========================
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
AWS_REGION="us-east-1"           # Replace with your bucket region
S3_BUCKET="your-bucket-name"     # Replace with your S3 bucket name

# =========================
# FOLDERS TO SYNC
# =========================
S3_HTML_FOLDER="html/"
EC2_HTML_FOLDER="/var/www/html"

S3_BASH_FOLDER="bash-scripts/"
EC2_BASH_FOLDER="/home/download"

# =========================
# EXPORT LOGIC
# =========================
echo "======================================================="
echo "Starting S3 to EC2 export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

# Export HTML folder to /var/www/html
echo "Syncing HTML folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" --region $AWS_REGION --delete

# Export bash script folder to /home/download
echo "Syncing bash scripts folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" --region $AWS_REGION --delete

echo "======================================================="
echo "S3 export completed successfully!"
echo "HTML folder -> $EC2_HTML_FOLDER"
echo "Bash scripts folder -> $EC2_BASH_FOLDER"
echo "======================================================="
```

### ✅ How to Use:

- Save this as s3_export.sh on your EC2 instance.

- Make it executable:

```
chmod +x s3_export.sh
```

-  Replace the configuration section with your AWS credentials, bucket name, and region.

-  Run it:

```
sudo ./s3_export.sh
```

Note: sudo is needed for /var/www/html since it requires root permissions.