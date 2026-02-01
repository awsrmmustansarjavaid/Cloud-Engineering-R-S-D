# ☕ AWS CAFE — PyMySQL Lambda Layer


### Use the IAM role attached to EC2 (Recommended)

- Go to the EC2 Console → IAM Role → EC2-Cafe-Secrets-Role

#### Attach a policy with S3 write permissions for your bucket:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::charlie-cafe-s3-bucket",
                "arn:aws:s3:::charlie-cafe-s3-bucket/*"
            ]
        }
    ]
}
```

#### Option 2: Use Environment Variables (temporary override)

You can export AWS keys in the same shell:

```
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Add this at the top of your bash script, before aws s3 cp:

```
# -------- CONFIGURATION --------
AWS_DEFAULT_REGION="us-east-1"
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
```

**⚠️ Warning: This is less secure. Never commit keys to git.**

#### Option 3: Use aws configure inside script (less recommended for automation)

```
aws configure set aws_access_key_id "YOUR_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "YOUR_SECRET_ACCESS_KEY"
aws configure set default.region "us-east-1"
```

This writes credentials to ~/.aws/credentials, but is messy for automation. Prefer Option 1 or 2.

### ✅ Updated Script (Option 2 — Works Anywhere)

Here’s your PyMySQL Lambda Layer script with AWS credentials support and proper comments:

```
#!/bin/bash
# =========================================
# Bash Script: Create PyMySQL Lambda Layer
# Correct Structure for AWS Lambda
# =========================================

set -e  # Exit on error

# -------- CONFIGURATION --------
AWS_DEFAULT_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/pymysql-layer.zip"

# Optional: Use environment variables for AWS credentials
# (Only if EC2 IAM role does not have S3 permissions)
# export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
# export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"

# Local build folders
BUILD_DIR="lambda-layer"
PYTHON_DIR="$BUILD_DIR/python"
ZIP_FILE="pymysql-layer.zip"

# -------- STEP 1: Prepare Environment --------
echo "✅ Installing Python & Pip (if missing)..."
sudo dnf install -y python3 python3-pip zip

# Clean old builds
echo "🧹 Cleaning old build files..."
rm -rf "$BUILD_DIR" "$ZIP_FILE"

# -------- STEP 2: Create Correct Folder Structure --------
echo "📁 Creating Lambda layer structure..."
mkdir -p "$PYTHON_DIR"

# -------- STEP 3: Install PyMySQL --------
echo "📦 Installing PyMySQL into python/ folder..."
pip3 install pymysql -t "$PYTHON_DIR" --no-cache-dir

# -------- STEP 4: Zip ONLY python/ --------
echo "🗜️ Zipping layer (correct structure)..."
cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" python
cd ..

# -------- STEP 5: Verify ZIP CONTENT --------
echo "🔍 Verifying ZIP structure..."
unzip -l "$ZIP_FILE"

# -------- STEP 6: Upload to S3 --------
echo "☁️ Uploading to S3..."
# If AccessDenied occurs, either:
# 1️⃣ Attach S3 write policy to EC2 IAM role, OR
# 2️⃣ Uncomment export AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY above

aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_DEFAULT_REGION"

echo "✅ DONE!"
echo "Attach this layer to Lambda (Python 3.9 / 3.10 / 3.11)"
```

### 🔑 Key Notes

- Recommended: Use the EC2 IAM role with S3 PutObject permission → secure & no hardcoding.

- Optional: Only if no IAM role, export AWS keys as environment variables.

Never hardcode credentials in scripts if you can avoid it.

----

