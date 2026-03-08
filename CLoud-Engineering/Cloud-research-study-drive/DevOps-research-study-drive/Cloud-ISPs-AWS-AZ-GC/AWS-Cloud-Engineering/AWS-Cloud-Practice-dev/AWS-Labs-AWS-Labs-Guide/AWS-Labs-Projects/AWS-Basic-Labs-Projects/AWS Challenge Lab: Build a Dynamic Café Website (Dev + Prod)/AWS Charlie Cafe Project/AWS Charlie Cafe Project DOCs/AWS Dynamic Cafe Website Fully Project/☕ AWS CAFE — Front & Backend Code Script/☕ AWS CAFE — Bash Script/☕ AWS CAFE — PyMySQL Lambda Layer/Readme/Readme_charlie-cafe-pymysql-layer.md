# Charlie Cafe - charlie-cafe-pymysql-layer

### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

#### ✅ charlie-cafe-pymysql-layer.sh

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
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_DEFAULT_REGION"

echo "✅ DONE!"
echo "Attach this layer to Lambda (Python 3.9 / 3.10 / 3.11)"
```

### Method 2️⃣ - PyMySQL Lambda Layer (1-to-1)

#### Verify prerequisites (Optional)

```
aws --version
```

```
python3 --version
```

```
pip3 --version
```

#### 👁‍🗨 You should see:

```
aws-cli/2.x

Python 3.x
```

#### ❗️ If pip3 missing:

#### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```

#### 🔹 STEP 1 — Create clean working directory

```
sudo mkdir lambda-layer && cd lambda-layer
```

#### 🔹 STEP 2 — Create required Lambda layer folder structure

⚠️ Lambda REQUIRES this exact structure

```
mkdir python
```

#### 👁‍🗨 You should see:

```
pymysql-layer/
└── python/
```

#### 🔹 STEP 3 — Install PyMySQL INTO python folder

```
pip3 install pymysql -t python/
```

#### 🔄 Verify install:

```
ls python/
```

#### 👁‍🗨 You should see:

```
pymysql/
pymysql-*.dist-info/
```

#### 🔹 STEP 4 — Create ZIP file (VERY IMPORTANT)

```
zip -r pymysql-layer.zip python
```

#### Confirm ZIP exists:

```
ls -lh pymysql-layer.zip
```

#### 👁‍🗨 You should see:

```
pymysql-layer.zip   (few MB)
```

### ✅ METHOD 1 — PyMySQL Lambda Layer via AWS CLI (NO S3)

[PyMySQL Lambda Layer via AWS CLI](../../../../../Charlie%20Cafe%20Lambda%20pymysql-layer.md)

### 2️⃣ — S3 Bucket - Upload ZIP

### ✅ METHOD 2 — PyMySQL Lambda Layer via S3

## 1️⃣ S3 Bucket - Upload ZIP to Lambda

### Upload layer → Attach to Lambda.

### 1️⃣ Upload ZIP to S3

#### connect Configure AWS CLI

Run this on your local machine / EC2 / CloudShell:

```
aws configure
```

#### Enter values exactly like this:

```
AWS Access Key ID [None]: AKIA************
AWS Secret Access Key [None]: ********************
Default region name [None]: us-east-1
Default output format [None]: json
```

✔ Press Enter after each input

#### Verify CLI Configuration

```
aws sts get-caller-identity
```

#### Expected output:

```
{
  "UserId": "AIDA************",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/cafe-lab-cli-user"
}
```

✔ This confirms AWS CLI is correctly authenticated.


#### Upload via AWS CLI (Recommended)

```bash
aws s3 cp pymysql-layer.zip s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```

#### Expected output:

```
upload: ./pymysql-layer.zip to s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```

##### Option B: Upload via S3 Console

* Open your S3 bucket
* Click **Upload**
* Add file → select `pymysql-layer.zip`
* Click **Upload**

---

