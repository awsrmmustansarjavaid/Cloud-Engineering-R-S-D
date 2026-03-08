# Charlie Cafe - charlie-cafe-pymysql-layer

### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

#### ✅ charlie-cafe-pymysql-layer.sh

```
#!/bin/bash
# ============================================================
# Charlie Cafe ☕
# PyMySQL Lambda Layer – FULL AUTOMATION SCRIPT
# Author: You
# Purpose:
#  - Build PyMySQL Lambda Layer
#  - Publish via AWS CLI (NO S3)
#  - Auto-attach to all Lambdas
#  - Optional Docker parity build
#  - Optional Secrets Manager creation
# ============================================================

set -e  # Exit immediately if any command fails

# -----------------------------
# CONFIGURATION (EDIT THESE)
# -----------------------------
LAYER_NAME="pymysql-layer"
PYTHON_RUNTIMES="python3.9 python3.10 python3.11"
WORKDIR="$HOME/pymysql-layer"
REGION="$(aws configure get region)"

# Secrets Manager (optional)
SECRET_NAME="cafe-db-credentials"
DB_SECRET_JSON='{
  "host":"db-endpoint",
  "user":"admin",
  "password":"secret",
  "dbname":"cafe"
}'

# -----------------------------
# PHASE 0️⃣ – PREREQUISITES
# -----------------------------
echo "🔍 Verifying prerequisites..."

aws --version
python3 --version || sudo dnf install -y python3
pip3 --version || sudo dnf install -y python3-pip
zip -v >/dev/null || sudo dnf install -y zip

echo "✅ Prerequisites OK"
echo

# -----------------------------
# PHASE 1️⃣ – BUILD PYMYSQL LAYER
# -----------------------------
echo "📦 Building PyMySQL Lambda Layer..."

# Clean old directory if exists
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/python"
cd "$WORKDIR"

echo "📥 Installing pymysql into python/ directory..."
pip3 install pymysql -t python/

echo "📂 Verifying installation..."
ls python/

echo "🗜 Creating ZIP archive..."
zip -r pymysql-layer.zip python >/dev/null

echo "📏 ZIP size:"
ls -lh pymysql-layer.zip
echo

# -----------------------------
# PHASE 1️⃣ – PUBLISH LAYER
# -----------------------------
echo "🚀 Publishing Lambda Layer via AWS CLI (NO S3)..."

LAYER_PUBLISH_OUTPUT=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Charlie Cafe PyMySQL Lambda Layer" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes $PYTHON_RUNTIMES)

echo "$LAYER_PUBLISH_OUTPUT"

LAYER_ARN=$(echo "$LAYER_PUBLISH_OUTPUT" | jq -r '.LayerVersionArn')

echo "✅ Layer published:"
echo "$LAYER_ARN"
echo

# -----------------------------
# PHASE 2️⃣ – AUTO-ATTACH TO ALL LAMBDAS
# -----------------------------
echo "🔁 Attaching layer to ALL Lambda functions..."

FUNCTIONS=$(aws lambda list-functions \
  --query 'Functions[].FunctionName' \
  --output text)

for FN in $FUNCTIONS; do
  echo "➡ Updating Lambda: $FN"

  aws lambda update-function-configuration \
    --function-name "$FN" \
    --layers "$LAYER_ARN"
done

echo "✅ All Lambdas updated"
echo

# -----------------------------
# PHASE 3️⃣ – OPTIONAL DOCKER BUILD
# -----------------------------
echo "🐳 Optional: Docker-based AWS parity build"
echo "⏭ Skipped by default (uncomment section to enable)"
: '
docker build -t pymysql-layer-docker - <<EOF
FROM public.ecr.aws/lambda/python:3.10
RUN pip install pymysql -t /layer/python
CMD ["bash"]
EOF

docker run --rm -v $(pwd):/out pymysql-layer-docker \
  cp -r /layer /out

zip -r pymysql-layer.zip layer/python

aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
'
echo

# -----------------------------
# PHASE 4️⃣ – OPTIONAL SECRETS MANAGER
# -----------------------------
echo "🔐 Optional: Creating Secrets Manager DB credentials"
echo "⏭ Skipped if secret already exists"

if ! aws secretsmanager describe-secret --secret-id "$SECRET_NAME" >/dev/null 2>&1; then
  aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --secret-string "$DB_SECRET_JSON"

  echo "✅ Secret created: $SECRET_NAME"
else
  echo "ℹ️ Secret already exists: $SECRET_NAME"
fi

echo

# -----------------------------
# CLEANUP (OPTIONAL)
# -----------------------------
echo "🧹 Cleanup local build files (optional)"
echo "⏭ Comment out next line if you want to keep files"
rm -rf "$WORKDIR"

echo
echo "🎉 ALL DONE!"
echo "Layer ARN: $LAYER_ARN"
echo "Region: $REGION"
echo "Charlie Cafe ☕ infrastructure ready."
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

[PyMySQL Lambda Layer via AWS CLI](./☕%20CC-%206%20—pymysql-layer.md)

---

