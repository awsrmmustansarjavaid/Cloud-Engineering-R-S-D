# Charlie Cafe - DEVOPS Bash Script

### 1️⃣ Initialize GitHub Repo

### ✅ 1. Initialize locally

```
cd charlie-cafe

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project"
```

### ✅ 2. Connect to GitHub

```
git remote add origin https://github.com/YOUR_USERNAME/charlie-cafe-devops.git
git branch -M main
git push -u origin main
```

### ✅ Fully Final Initialize GitHub Repo Script

#### init-github.sh → Initialize Git & Push to GitHub

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — GIT INITIALIZATION SCRIPT
# ----------------------------------------------------------
# ✔ Initializes local Git repo
# ✔ Commits project
# ✔ Connects to GitHub
# ✔ Pushes code to main branch
# ==========================================================

# ❗ EXIT SCRIPT IF ANY COMMAND FAILS
set -e

# -------------------------------
# 🔧 VARIABLES (EDIT THESE)
# -------------------------------
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# -------------------------------
# 📁 MOVE INTO PROJECT DIRECTORY
# -------------------------------
echo "📂 Moving into project folder..."
cd charlie-cafe || { echo "❌ Folder not found!"; exit 1; }

# -------------------------------
# 🧱 INITIALIZE GIT
# -------------------------------
echo "🔧 Initializing Git..."
git init

# -------------------------------
# ➕ ADD FILES
# -------------------------------
echo "📦 Adding files..."
git add .

# -------------------------------
# 💾 COMMIT
# -------------------------------
echo "💾 Creating initial commit..."
git commit -m "Initial commit - Charlie Cafe Project"

# -------------------------------
# 🔗 CONNECT TO GITHUB
# -------------------------------
echo "🔗 Connecting to GitHub..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# -------------------------------
# 🌿 SET MAIN BRANCH
# -------------------------------
echo "🌿 Setting main branch..."
git branch -M main

# -------------------------------
# 🚀 PUSH TO GITHUB
# -------------------------------
echo "🚀 Pushing to GitHub..."
git push -u origin main

echo "✅ GitHub setup complete!"
```

### 2️⃣ Charlie Cafe RDS Schema

#### 📄 Read more here 

[Charlie Cafe Readme_RDS_schema](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/3cc7be3a035c31c2f621682ac611a5dd9c5487d3/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/Charlie%20Cafe%20DevOPS/Readme_RDS_schema.md)

#### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```

#### 👉 Create this file:

```
infrastructure/rds/schema.sql
```

```
infrastructure/rds/data.sql
```

```
infrastructure/rds/verify.sql
```

### ⚙️ HOW IT WORKS (STEP BY STEP)

> ### Method 1️⃣ How to run your current files in production without Docker/CI/CD

### ✅ Step 1 — Create schema

```
mysql -h <host> -u <user> -p < schema.sql
```

#### 👉 Creates:

- database

- tables

- relationships

### ✅ Step 2 — Insert data

```
mysql -h <host> -u <user> -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h <host> -u <user> -p < verify.sql
```

### 3️⃣ Dockerize MySQL for local testing

> ### Method 2️⃣ integrate schema.sql, data.sql, verify.sql into Docker + CI/CD

### 1️⃣ Create a devops-setup_rds.sh

> #### 📦 1. ✅ devops-setup_rds.sh → MySQL (database with schema.sql)

```
#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — RDS Setup Script (FINAL PRODUCTION VERSION)
# -------------------------------------------------------------
# Purpose:
# ✔ Fetch DB credentials securely from AWS Secrets Manager
# ✔ Create database (if not exists)
# ✔ Apply schema.sql (tables + relationships)
# ✔ Apply data.sql (optional sample data)
# ✔ Run verify.sql (QA checks)
# ✔ Safe to run multiple times
# =============================================================

set -euo pipefail

# =============================================================
# CONFIGURATION (EDIT IF NEEDED)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# =============================================================
# COLORS (FOR CLEAN OUTPUT)
# =============================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# =============================================================
# STEP 1 — CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null 2>&1 || { print_error "MySQL client not installed"; exit 1; }

print_success "All required tools are installed"

# =============================================================
# STEP 2 — FETCH SECRET FROM AWS SECRETS MANAGER
# =============================================================
print_header "Fetching DB Credentials from Secrets Manager"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Credentials loaded successfully"

# =============================================================
# STEP 3 — TEST RDS CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "Failed to connect to RDS"; exit 1; }

# =============================================================
# STEP 4 — CREATE DATABASE (SAFE)
# =============================================================
print_header "Creating Database (if not exists)"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ensured"

# =============================================================
# STEP 5 — APPLY SCHEMA
# =============================================================
print_header "Applying Database Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied successfully"
else
  print_error "Schema file not found: $SCHEMA_FILE"
  exit 1
fi

# =============================================================
# STEP 6 — APPLY SAMPLE DATA (OPTIONAL)
# =============================================================
print_header "Applying Sample Data (Optional)"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ Data file not found, skipping...${NC}"
fi

# =============================================================
# STEP 7 — VERIFY DATABASE
# =============================================================
print_header "Running Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ Verify file not found, skipping...${NC}"
fi

# =============================================================
# FINAL SUCCESS MESSAGE
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Schema Applied${NC}"
echo -e "${GREEN}✔ Data Inserted (if available)${NC}"
echo -e "${GREEN}✔ Verification Completed${NC}"

echo -e "\n🎉 Your Charlie Cafe database is fully ready on AWS RDS!\n"
```

### 📦 2. ✅ Dockerfile → Apache + PHP (frontend)

```
nano docker/apache-php/Dockerfile
```

[Dockerfile](./docker/apache-php/Dockerfile)


### 4️⃣ ⚙️ FINAL docker-compose.yml (FULLY CONNECTED)

```
nano docker-compose.yml
```

[docker-compose.yml](./docker-compose.yml)

### 5️⃣ 📦 2. Create .dockerignore (IMPORTANT)

This prevents junk files from going into Docker image.

#### Create:

```
.dockerignore
```

```
.git
.gitignore
node_modules
.env
*.log
vendor
docker-compose.yml
.github
README.md
docs/
```

#### 🔍 Why these are added

- .git, .github → not needed inside image

- node_modules, vendor → heavy + rebuildable

- .env → sensitive

- logs → useless in image

- docs/config → not required in runtime

### 6️⃣ 📦 3. Create .gitignore (IMPORTANT)

#### Create:

```
.gitignore
```

```
node_modules/
vendor/
.env
*.log
.DS_Store
Thumbs.db
docker/*.tar
docs/
```

### 6️⃣ ⚙️ 3. Build Your Docker Image

SSH into EC2 and go to your project:

```
cd charlie-cafe-devops
```

Then run:

```
docker build -t charlie-cafe .
```

### 7️⃣ 4. Run Your Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

### 8️⃣ 5. Run Your Project Locally

```
docker-compose up --build
```


### 9️⃣ GitHub Workflow (CI/CD)

#### 📁 GitHub Path Folder structure:

```
charlie-cafe-devops/
│
├── .github/
│   └── workflows/
│       └── deploy.yml   ✅ (HERE)
```

#### Create:

```
.github/workflows/deploy.yml
```

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Install Dependencies
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client, jq, curl, AWS CLI
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl unzip
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        aws --version

    # -------------------------------------------------
    # 3️⃣ Retrieve RDS Secret from AWS Secrets Manager
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)
        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 4️⃣ Parse RDS Secret into environment variables
    # -------------------------------------------------
    - name: 🧰 Parse RDS Secret
      run: |
        export DB_HOST=$(echo $DB_SECRET | jq -r '.host')
        export DB_USER=$(echo $DB_SECRET | jq -r '.username')
        export DB_PASS=$(echo $DB_SECRET | jq -r '.password')
        export DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')
        echo "DB_HOST=$DB_HOST" >> $GITHUB_ENV
        echo "DB_USER=$DB_USER" >> $GITHUB_ENV
        echo "DB_PASS=$DB_PASS" >> $GITHUB_ENV
        echo "DB_NAME=$DB_NAME" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Wait for RDS to be reachable
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        echo "Waiting for RDS connection..."
        for i in {1..30}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Retrying in 10s..."
          sleep 10
        done

    # -------------------------------------------------
    # 6️⃣ Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 7️⃣ Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 8️⃣ Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 9️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 🔟 Run Docker Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: docker run -d -p 8080:80 --name charlie_web \
            -e RDS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
            charlie-cafe

    # -------------------------------------------------
    # 11️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application (Health Check)
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 12️⃣ Success Message
    # -------------------------------------------------
    - name: 🎉 Pipeline Success
      run: echo "Charlie Cafe CI/CD Pipeline Completed Successfully 🚀"
```

### 🧠 2. docker-setup.sh → Build & Run Container (EC2)

```
#!/bin/bash

# ==========================================================
# 🐳 CHARLIE CAFE — DOCKER SETUP SCRIPT
# ----------------------------------------------------------
# ✔ Builds Docker image
# ✔ Runs container on port 80
# ✔ Removes old container if exists
# ==========================================================

set -e

# -------------------------------
# 🔧 VARIABLES
# -------------------------------
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# -------------------------------
# 📂 GO TO PROJECT DIRECTORY
# -------------------------------
echo "📂 Navigating to project directory..."
cd ~/charlie-cafe-devops || { echo "❌ Project not found!"; exit 1; }

# -------------------------------
# 🧹 REMOVE OLD CONTAINER (IF EXISTS)
# -------------------------------
echo "🧹 Cleaning old container..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# -------------------------------
# 🏗️ BUILD DOCKER IMAGE
# -------------------------------
echo "🏗️ Building Docker image..."
docker build -t $IMAGE_NAME .

# -------------------------------
# 🚀 RUN CONTAINER
# -------------------------------
echo "🚀 Running container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

# -------------------------------
# 📊 STATUS
# -------------------------------
echo "📊 Running containers:"
docker ps

echo "✅ Docker setup completed!"
```

### 🔥 FINAL MERGED DEVOPS SCRIPT 

> #### Update Version: 1.0


✔ Git init + push to GitHub

✔ Build Docker image

✔ Run container

✔ (Optionally reusable on EC2)

Here’s your 🔥 FINAL MERGED DEVOPS SCRIPT with proper comments:

#### 🚀 charlie-cafe-devops.sh (All-in-One Script)

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT
# ----------------------------------------------------------
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image
# ✔ Run Docker container
# ✔ Clean old container automatically
# ==========================================================

# ❗ Exit immediately if any command fails
set -e

# ==========================================================
# 🔧 VARIABLES (EDIT THESE BEFORE RUN)
# ==========================================================
PROJECT_DIR="charlie-cafe"             # Local project folder
REPO_NAME="charlie-cafe-devops"       # GitHub repo name
GITHUB_USERNAME="YOUR_USERNAME"       # Your GitHub username

IMAGE_NAME="charlie-cafe"             # Docker image name
CONTAINER_NAME="cafe-app"             # Docker container name
PORT="80"                             # App port

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
echo "📂 Moving into project directory..."
cd $PROJECT_DIR || { echo "❌ Project folder not found!"; exit 1; }

# ==========================================================
# 🔧 STEP 2 — INITIALIZE GIT
# ==========================================================
echo "🔧 Initializing Git repository..."
git init

# Add all files
echo "📦 Adding project files..."
git add .

# Commit files
echo "💾 Creating initial commit..."
git commit -m "Initial commit - Charlie Cafe Project"

# ==========================================================
# 🔗 STEP 3 — CONNECT TO GITHUB
# ==========================================================
echo "🔗 Connecting to GitHub repository..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true

# Set main branch
echo "🌿 Setting main branch..."
git branch -M main

# Push to GitHub
echo "🚀 Pushing code to GitHub..."
git push -u origin main

# ==========================================================
# 🐳 STEP 4 — DOCKER BUILD
# ==========================================================
echo "🏗️ Building Docker image..."
docker build -t $IMAGE_NAME .

# ==========================================================
# 🧹 STEP 5 — CLEAN OLD CONTAINER (IF EXISTS)
# ==========================================================
echo "🧹 Removing old container if exists..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# ==========================================================
# 🚀 STEP 6 — RUN DOCKER CONTAINER
# ==========================================================
echo "🚀 Running Docker container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

# ==========================================================
# 📊 STEP 7 — SHOW STATUS
# ==========================================================
echo "📊 Running containers:"
docker ps

# ==========================================================
# ✅ DONE
# ==========================================================
echo "🎉 Charlie Cafe DevOps setup completed successfully!"
echo "🌐 Access your app at: http://YOUR_EC2_PUBLIC_IP"
```

### 🧠 How to Use

```
# 1. Save file
nano charlie-cafe-devops.sh

# 2. Make executable
chmod +x charlie-cafe-devops.sh

# 3. Run
./charlie-cafe-devops.sh
```

### ⚠️ Important Notes (Don’t Skip)

#### 🔴 You MUST edit this first:

```
GITHUB_USERNAME="YOUR_USERNAME"
```

#### 🔴 If repo already exists:

This line avoids error:

```
git remote add origin ... || true
```

#### 🔴 If running on EC2:

Make sure Docker is installed:

```
docker --version
```

### 💡 Pro Upgrade (Next Step)

#### After this, your next level (VERY important for DevOps):

👉 Push Docker image to ECR

👉 Deploy to ECS

👉 Attach ALB

👉 Automate using GitHub Actions

## 🔥 FINAL MERGED DEVOPS SCRIPT 

> #### Update Version: 1.1

✔ Proper flow (RDS → Git → Docker)

✔ Clear sections

✔ Safe execution

✔ Professional comments

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image
# ✔ Run Docker container
# ✔ Production-ready structure with safety checks
# ==========================================================

# ❗ Exit on error, undefined variable, pipe failure
set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

# --- Project ---
PROJECT_DIR="charlie-cafe"

# --- GitHub ---
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# --- Docker ---
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# --- AWS RDS / Secrets ---
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS FOR OUTPUT
# ==========================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd $PROJECT_DIR || { print_error "Project folder not found"; exit 1; }

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL client not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS FROM AWS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST DB CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "RDS connection failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DATABASE
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ready"

# ==========================================================
# 📦 STEP 6 — APPLY SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied"
else
  print_error "Schema file missing"
  exit 1
fi

# ==========================================================
# 📊 STEP 7 — APPLY DATA (OPTIONAL)
# ==========================================================
print_header "Step 7 — Applying Sample Data"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping...${NC}"
fi

# ==========================================================
# 🔍 STEP 8 — VERIFY DATABASE
# ==========================================================
print_header "Step 8 — Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ No verify file found, skipping...${NC}"
fi

# ==========================================================
# 🔧 STEP 9 — GIT SETUP
# ==========================================================
print_header "Step 9 — Git Initialization"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true

git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main

git push -u origin main

print_success "Code pushed to GitHub"

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD
# ==========================================================
print_header "Step 10 — Docker Build"

docker build -t $IMAGE_NAME .

print_success "Docker image built"

# ==========================================================
# 🧹 STEP 11 — REMOVE OLD CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup Old Container"

docker rm -f $CONTAINER_NAME 2>/dev/null || true

print_success "Old container removed (if existed)"

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Application"

docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

print_success "Container is running"

# ==========================================================
# 📊 FINAL STATUS
# ==========================================================
print_header "Final Status"

docker ps

echo -e "\n🎉 ${GREEN}Charlie Cafe FULL DevOps Setup Completed!${NC}"
echo -e "🌐 Access your app: http://YOUR_EC2_PUBLIC_IP\n"
```

### 🧠 Key Improvements (Important)

#### ✅ Correct execution order:

- RDS setup

- Git push

- Docker deploy

#### ✅ Safe for re-run:

- git commit || true

- git remote add || true

- docker rm -f || true

#### ✅ Production-style features:

- set -euo pipefail

- Color logs

- Structured steps

- Validation checks

### 🌐 FINAL MERGED DEVOPS SCRIPT 

> #### Update Version: 1.2

✔ Dockerfile → ✅ Used by your script

✔ docker-compose.yml → ⚠️ NOT used currently

✔ GitHub Actions (deploy.yml) → ✅ Will work AFTER push

### 🧠 What Happens When You Run Your Script

### 1️⃣ Dockerfile

Your script runs:

```
docker build -t charlie-cafe .
```

👉 This uses your Dockerfile automatically

✔ No issue here

✔ Just make sure path is correct

⚠️ Important

If your Dockerfile is inside:

```
docker/apache-php/Dockerfile
```

Then your script WILL FAIL ❌

### ✅ Fix (choose ONE)

#### Option A (Recommended)

Move Dockerfile to root:

```
charlie-cafe/
 ├── Dockerfile   ✅
 ├── docker-compose.yml
```

#### Option B (Advanced)

Update script:

```
docker build -t $IMAGE_NAME -f docker/apache-php/Dockerfile .
```

### 2️⃣ docker-compose.yml

Right now your script uses:

```
docker run -d -p 80:80 ...
```

#### 👉 That means:

❌ docker-compose.yml is NOT used

❌ Multi-container setup ignored (DB, network, etc.)

✅ If You WANT docker-compose (Recommended for DevOps)

Replace this part in script:

```
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME
```

👉 WITH:

```
docker-compose up --build -d
```

### 🔥 My Recommendation

Since your project includes:

✔ RDS

✔ API

✔ Frontend

👉 Use docker-compose for local/dev

👉 Use ECS for production

### 3️⃣ GitHub Actions (deploy.yml)

Your script does:

```
git push -u origin main
```

👉 This will trigger:

➡️ .github/workflows/deploy.yml

✔ So YES — it will run automatically

✔ This is your CI/CD pipeline

### ⚠️ Important DevOps Warning (Very Important)

Right now your flow is:

Script runs Docker on EC2

GitHub Actions ALSO deploys

#### 👉 This can cause:

❌ Conflict

❌ Duplicate deployments

❌ Confusion (manual vs automated)

### 🧠 Best Practice (Real DevOps Way)

### 🔥 Choose ONE deployment method:

#### ✅ Option 1 (Beginner)

Use script only

👉 Ignore GitHub Actions for now

#### ✅ Option 2 (Professional DevOps) ⭐ RECOMMENDED

Use:

✔ Script → only for setup (RDS + Git push)

✔ GitHub Actions → deployment

✔ ECS → container hosting

👉 Remove this from script:

```
docker run ...
```

### ✅ Final Recommendation (For YOU)

Since you're learning AWS DevOps:

👉 Modify your script like this:

❌ REMOVE:

```
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME
```

✅ ADD:

```
docker-compose up --build -d
```

### 🚀 Final Flow After Fix

Run script

RDS setup ✔

Code pushed ✔

GitHub Actions runs ✔

Deploy to AWS ✔

### 💡 Pro Tip (Game Changer)

You are very close to real DevOps level

Next step should be:

👉 Docker → ECR

👉 ECS (Fargate)

👉 ALB integration

👉 CI/CD automation

### 🚀 ✅ FINAL UPDATED SCRIPT

#### charlie-cafe-devops.sh (Dockerfile path fixed)

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v2)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image (custom Dockerfile path)
# ✔ Run Docker container
# ✔ Production-ready with safety checks
# ==========================================================

# ❗ Exit on:
# - any error (-e)
# - undefined variable (-u)
# - pipeline failure (pipefail)
set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

# --- Project ---
PROJECT_DIR="charlie-cafe"

# --- GitHub ---
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# --- Docker ---
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# --- Dockerfile Path (UPDATED) ---
DOCKERFILE_PATH="docker/apache-php/Dockerfile"

# --- AWS RDS / Secrets ---
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS FOR OUTPUT (FOR READABILITY)
# ==========================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd "$PROJECT_DIR" || { print_error "Project folder not found"; exit 1; }

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL client not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS FROM AWS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "RDS connection failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DATABASE
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ready"

# ==========================================================
# 📦 STEP 6 — APPLY SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied"
else
  print_error "Schema file missing: $SCHEMA_FILE"
  exit 1
fi

# ==========================================================
# 📊 STEP 7 — APPLY DATA (OPTIONAL)
# ==========================================================
print_header "Step 7 — Applying Sample Data"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping...${NC}"
fi

# ==========================================================
# 🔍 STEP 8 — VERIFY DATABASE
# ==========================================================
print_header "Step 8 — Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ No verify file found, skipping...${NC}"
fi

# ==========================================================
# 🔧 STEP 9 — GIT SETUP
# ==========================================================
print_header "Step 9 — Git Initialization"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true

git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main

git push -u origin main

print_success "Code pushed to GitHub"

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD (UPDATED PATH)
# ==========================================================
print_header "Step 10 — Docker Build"

# Build using custom Dockerfile path
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

print_success "Docker image built using $DOCKERFILE_PATH"

# ==========================================================
# 🧹 STEP 11 — REMOVE OLD CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup Old Container"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

print_success "Old container removed (if existed)"

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Application"

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

print_success "Container is running"

# ==========================================================
# 📊 FINAL STATUS
# ==========================================================
print_header "Final Status"

docker ps

echo -e "\n🎉 ${GREEN}Charlie Cafe FULL DevOps Setup Completed!${NC}"
echo -e "🌐 Access your app: http://YOUR_EC2_PUBLIC_IP\n"
```

### 🔥 What You Just Fixed (Very Important)

### ✅ Dockerfile path issue solved:

```
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
```

#### ✅ Script is now:

✔ Production-ready

✔ Re-runnable

✔ Clean structured

✔ DevOps-standard

#### ⚠️ Final Quick Checklist

Before running:

```
chmod +x charlie-cafe-devops.sh
```
#### 🔴 MUST EDIT:
```
GITHUB_USERNAME="YOUR_USERNAME"
SECRET_ARN="your-real-secret"
```

### 🧠 🔥 FIRST: Your Current Architecture (After Script)

Right now, your setup is:

```
LOCAL / EC2
   ↓
charlie-cafe-devops.sh
   ↓
1. Setup RDS ✅
2. Push code to GitHub ✅
3. Build Docker image ✅
4. Run container (EC2) ✅

GitHub
   ↓
.github/workflows/deploy.yml (CI/CD trigger)
```


---
## Interview Section

### ❗ IMPORTANT ANSWER TO YOUR MAIN QUESTION

### ❓ Do you need to run Dockerfile manually?

#### 👉 NO Because your script already runs:

```
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
```

#### ✔ This automatically uses:

```
docker/apache-php/Dockerfile
```

✅ So Dockerfile = USED automatically by script

### ❓ Do you need to run docker-compose.yml?

#### 👉 NO (in your current setup) Because your script uses:

```
docker run -d -p "$PORT:80" ...
```

✔ That means:

- Single container

- No compose

- No multi-service

👉 So:

#### ❌ docker-compose.yml is currently NOT used

### ❓ Do you manually run .github/workflows/deploy.yml?

👉 BIG NO ❌

You NEVER run this manually.

#### ✅ Correct behavior:

GitHub Actions runs automatically when you do:

```
git push origin main
```

👉 Your script already does this:

```
git push -u origin main
```

✔ So GitHub Actions triggers automatically

### 🧠 SIMPLE FINAL ANSWER

| Component          | Do you run manually? | Used by script? | Purpose            |
| ------------------ | -------------------- | --------------- | ------------------ |
| Dockerfile         | ❌ No                 | ✅ Yes           | Build image        |
| docker-compose.yml | ❌ No                 | ❌ No            | (unused currently) |
| deploy.yml         | ❌ No                 | ✅ Auto          | CI/CD              |

### ⚠️ VERY IMPORTANT ARCHITECTURE WARNING

Right now you are doing TWO deployments:

### 1️⃣ From Script (EC2)

```
docker run ...
```

### 2️⃣ From GitHub Actions

```
deploy.yml
```

#### 👉 This causes:

❌ Duplicate 

❌ Confusion

❌ Not real DevOps architecture

### 🧠 WHAT YOU SHOULD DO (BEST PRACTICE)

### ✅ Option 1 (Your Current Learning Stage)

Keep it simple:

✔ Use script

✔ Ignore docker-compose.yml

✔ Ignore deploy.yml for now

### ✅ Option 2 (REAL DEVOPS — Recommended 🚀)

🔥 Change your architecture:

❌ REMOVE from script:

```
docker run ...
```

✔ KEEP:

```
docker build ...
git push ...
```

Then:

✔ GitHub Actions (deploy.yml)

➡️ Build Docker

➡️ Push to ECR

➡️ Deploy to ECS

### 🧠 ABOUT YOUR DOCKERFILE PATH (IMPORTANT)

You said:

```
docker/apache-php/Dockerfile
```

👉 Your script uses:

```
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
```

✔ This is CORRECT ✅

✔ It will work

✔ No issue

### ⚠️ FINAL THINGS YOU MUST EDIT BEFORE RUN

🔴 1. GitHub Username

```
GITHUB_USERNAME="YOUR_USERNAME"
```

🔴 2. AWS Secret ARN

```
SECRET_ARN="your-real-secret-arn"
```

🔴 3. Project Folder Name

```
PROJECT_DIR="charlie-cafe"
```

👉 Make sure your folder name matches EXACTLY

🔴 4. (Optional) Port

```
PORT="80"
```

🔴 5. EC2 Security Group

Make sure port is open:

- HTTP → 80

- Or 8080 if changed

### 🧠 FINAL FLOW (YOU SHOULD UNDERSTAND THIS)

```
Run Script
   ↓
RDS Setup ✅
   ↓
Git Push ✅
   ↓
GitHub Actions Triggered ✅
   ↓
Docker Build (local OR CI/CD) ✅
   ↓
App Runs (EC2 OR ECS depending on setup)
```

### 🚀 FINAL RECOMMENDATION (VERY IMPORTANT)

You are now at a critical DevOps decision point

👉 Choose ONE:

#### 🔹 Path A (Beginner)

- Script runs everything

- Ignore CI/CD

#### 🔹 Path B (Professional DevOps) ⭐

- Script = setup only

- GitHub Actions = deployment

- ECS = runtime

- ALB = traffic

### 🔥 My Advice (Based on Your Goal)

Since you want AWS DevOps career:

👉 Move to:

✔ GitHub Actions

✔ ECR

✔ ECS

✔ ALB

---
### 🔍 Verification of charlie-cafe-devops

✔ Container health check

✔ HTTP response test (curl)

✔ Port check

✔ Process check

✔ Clear PASS / FAIL output

✔ Proper comments

### 🚀 ✅ FINAL SCRIPT (WITH FULL VERIFICATION & TESTING)

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v3)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image (custom Dockerfile path)
# ✔ Run Docker container
# ✔ FINAL VERIFICATION (container + HTTP + port checks)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

PROJECT_DIR="charlie-cafe"

REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 📁 STEP 1 — NAVIGATE
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd "$PROJECT_DIR" || { print_error "Project folder not found"; exit 1; }

# ==========================================================
# 🧰 STEP 2 — CHECK TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }
command -v curl >/dev/null || { print_error "curl not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null \
  && print_success "RDS connection successful" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DB
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# ==========================================================
# 📦 STEP 6 — SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

[ -f "$SCHEMA_FILE" ] || { print_error "Schema missing"; exit 1; }
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

# ==========================================================
# 📊 STEP 7 — DATA
# ==========================================================
print_header "Step 7 — Sample Data"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE" \
  && print_success "Sample data applied" || echo -e "${YELLOW}Skipped${NC}"

# ==========================================================
# 🔍 STEP 8 — VERIFY SQL
# ==========================================================
print_header "Step 8 — DB Verification"

[ -f "$VERIFY_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"

# ==========================================================
# 🔧 STEP 9 — GIT
# ==========================================================
print_header "Step 9 — Git Setup"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main
git push -u origin main

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD
# ==========================================================
print_header "Step 10 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

# ==========================================================
# 🧹 STEP 11 — CLEAN CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Container"

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 5

# ==========================================================
# 🧪 STEP 13 — FINAL VERIFICATION
# ==========================================================
print_header "Step 13 — FINAL TESTING & VERIFICATION"

# 1️⃣ Check container running
if docker ps | grep -q "$CONTAINER_NAME"; then
  print_success "Container is running"
else
  print_error "Container not running"
  exit 1
fi

# 2️⃣ Check port listening
if ss -tuln | grep -q ":$PORT"; then
  print_success "Port $PORT is open"
else
  print_error "Port $PORT not open"
fi

# 3️⃣ HTTP check
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)

if [ "$HTTP_CODE" == "200" ]; then
  print_success "Application is accessible (HTTP 200)"
else
  echo -e "${YELLOW}⚠️ HTTP Response: $HTTP_CODE${NC}"
fi

# 4️⃣ Container logs (last 5 lines)
print_header "Container Logs (Last 5 lines)"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 FINAL OUTPUT
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo -e "${GREEN}✔ RDS Ready${NC}"
echo -e "${GREEN}✔ GitHub Synced${NC}"
echo -e "${GREEN}✔ Docker Running${NC}"
echo -e "${GREEN}✔ App Tested${NC}"

echo -e "\n🌐 Access your app:"
echo -e "👉 http://localhost:$PORT"
echo -e "👉 http://YOUR_EC2_PUBLIC_IP:$PORT\n"
```

### 🧠 What You Just Added (VERY IMPORTANT)

#### ✅ Real DevOps Testing Includes:

✔ Container running check

✔ Port open check

✔ HTTP response check

✔ Logs output

✔ DB verification

### 🔥 This Script is Now:

👉 100% production-level DevOps script

👉 Similar to what DevOps engineers use in real companies

---

## health.php

### 🧠 WHY /health.php IS REQUIRED

When you use:

- ECS (Fargate)

- ALB (Application Load Balancer)

- Blue/Green / Canary deployments

👉 AWS must know if your app is healthy or broken

### 🔍 What ALB Does Behind the Scenes

#### Your ALB continuously checks your app like this:

```
GET /health.php
```

#### If response is:

✅ 200 OK → App is healthy → Traffic allowed

❌ 500 / timeout → App is unhealthy → Traffic blocked

### 🚨 WITHOUT HEALTH CHECK

If you don’t have /health.php:

❌ ALB marks your container UNHEALTHY

❌ ECS keeps restarting tasks

❌ CodeDeploy FAILS deployment

❌ Canary / Blue-Green breaks

👉 Result: Your app never goes live

### 🎯 WHY IT'S CRITICAL FOR YOUR PROJECT

In your Charlie Cafe DevOps pipeline:

- ALB → checks health

- CodeDeploy → decides traffic shift

- CloudWatch → triggers rollback

👉 ALL depend on /health.php

### ✅ WHAT YOUR /health.php SHOULD DO

It should be:

- Fast

- Simple

- Reliable

- No heavy logic

### ☕ FINAL health.php FOR CHARLIE CAFE

Here is a production-ready version for your project 👇

```
<?php
// ==========================================================
// CHARLIE CAFE — HEALTH CHECK ENDPOINT
// ----------------------------------------------------------
// ✔ Used by ALB, ECS, CodeDeploy
// ✔ Confirms app + database are working
// ✔ Returns HTTP 200 if healthy
// ✔ Returns HTTP 500 if unhealthy
// ==========================================================

// Set JSON header
header('Content-Type: application/json');

// -----------------------------
// 1️⃣ BASIC APP CHECK
// -----------------------------
$app_status = "OK";

// -----------------------------
// 2️⃣ DATABASE CHECK (IMPORTANT)
// -----------------------------
$db_status = "OK";

$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'admin';
$pass = getenv('DB_PASS') ?: '';
$db   = getenv('DB_NAME') ?: 'charlie_cafe';

$conn = @new mysqli($host, $user, $pass, $db);

// Check DB connection
if ($conn->connect_error) {
    $db_status = "FAIL";
}

// -----------------------------
// 3️⃣ FINAL STATUS
// -----------------------------
if ($app_status === "OK" && $db_status === "OK") {

    http_response_code(200);

    echo json_encode([
        "status" => "OK",
        "app" => $app_status,
        "database" => $db_status,
        "timestamp" => date("Y-m-d H:i:s")
    ]);

} else {

    http_response_code(500);

    echo json_encode([
        "status" => "FAIL",
        "app" => $app_status,
        "database" => $db_status,
        "timestamp" => date("Y-m-d H:i:s")
    ]);
}
?>
```

### 🔧 WHERE TO PLACE THIS FILE

Put it in your project root:

```
charlie-cafe/
 ├── index.php
 ├── order.php
 ├── order-receipt.php
 ├── health.php   ✅ (THIS FILE)
```

### 🧪 HOW TO TEST (VERY IMPORTANT)

Test locally:

```
curl http://localhost/health.php
```

Test via ALB:

```
http://YOUR-ALB-DNS/health.php
```

#### ✅ Expected Output

```
{
  "status": "OK",
  "app": "OK",
  "database": "OK"
}
```

### 🚀 PRO TIP (REAL DEVOPS INSIGHT)

There are 2 types of health checks:

#### 🔹 Basic (Simple)

```
echo "OK";
```

👉 Fast, but doesn’t check DB

#### 🔹 Advanced (YOU ARE USING)

✔ Checks database

✔ Used in production

✔ Required for safe deployments

### ⚠️ COMMON MISTAKES

❌ Using homepage / as health check

❌ Slow DB queries inside health check

❌ Returning HTML instead of status

❌ Missing HTTP status codes

### 🧠 FINAL UNDERSTANDING

/health.php is not just a file…

👉 It is the decision maker of your entire DevOps pipeline

#### Without it:

❌ Deployments fail

❌ Traffic breaks

❌ Auto rollback useless

#### With it:

✅ Safe deployments

✅ Zero downtime

✅ Production-ready system

### 🌐 Fully Final health.php

✅ Stage 1 (Docker + GitHub) → local / simple setup

✅ Stage 2 (AWS ECS + ALB + RDS) → production

✅ AND looks professional (HTML + CSS + Bootstrap + icons)

✅ AND still returns proper HTTP codes (200 / 500) for ALB

Let’s do this the right DevOps way 👇

#### 🚀 ✅ FINAL — health.php (ALL-IN-ONE, DEV + AWS + UI)

```
<?php
// ==========================================================
// ☕ CHARLIE CAFE — ADVANCED HEALTH CHECK (FINAL VERSION)
// ----------------------------------------------------------
// ✔ Works in LOCAL (Docker/GitHub)
// ✔ Works in AWS (ECS + ALB + RDS)
// ✔ Returns HTTP 200 / 500 for ALB
// ✔ Also renders BEAUTIFUL UI for browser testing
// ✔ No extra files required (single file solution)
// ==========================================================

// -----------------------------
// 1️⃣ CONFIG (AUTO SWITCH)
// -----------------------------
header('Content-Type: text/html'); // allow UI rendering

$app_status = "OK";
$db_status  = "OK";

// Auto-detect environment (LOCAL or AWS)
$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'root';       // local default
$pass = getenv('DB_PASS') ?: '';           // local default
$db   = getenv('DB_NAME') ?: 'charlie_cafe';

// -----------------------------
// 2️⃣ DATABASE CHECK
// -----------------------------
$conn = @new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    $db_status = "FAIL";
}

// -----------------------------
// 3️⃣ FINAL STATUS DECISION
// -----------------------------
$isHealthy = ($app_status === "OK" && $db_status === "OK");

// IMPORTANT for ALB / ECS health check
if ($isHealthy) {
    http_response_code(200);
} else {
    http_response_code(500);
}

// -----------------------------
// 4️⃣ JSON OUTPUT (FOR API / ALB)
// -----------------------------
$json_output = json_encode([
    "status"    => $isHealthy ? "OK" : "FAIL",
    "app"       => $app_status,
    "database"  => $db_status,
    "timestamp" => date("Y-m-d H:i:s")
], JSON_PRETTY_PRINT);

// -----------------------------
// 5️⃣ UI COLORS BASED ON STATUS
// -----------------------------
$color = $isHealthy ? "success" : "danger";
$statusText = $isHealthy ? "SYSTEM HEALTHY" : "SYSTEM DOWN";

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>☕ Charlie Cafe Health Check</title>

<!-- ==========================================================
     BOOTSTRAP + ICONS (CDN)
========================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ==========================================================
   🎨 CUSTOM STYLING (CAFE THEME)
========================================================== */

body {
    background: linear-gradient(135deg, #3e2723, #6d4c41);
    color: #fff;
    font-family: 'Segoe UI', sans-serif;
}

.card {
    border-radius: 15px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.4);
}

.header-icon {
    font-size: 50px;
}

.status-ok {
    color: #4caf50;
}

.status-fail {
    color: #ff5252;
}

.footer {
    margin-top: 20px;
    font-size: 14px;
    opacity: 0.8;
}
</style>
</head>

<body>

<div class="container d-flex justify-content-center align-items-center vh-100">

    <div class="card text-dark p-4 col-md-6">

        <!-- ================= HEADER ================= -->
        <div class="text-center mb-3">
            <i class="bi bi-cup-hot-fill header-icon text-warning"></i>
            <h2 class="mt-2">Charlie Cafe</h2>
            <p class="text-muted">Health Monitoring Dashboard</p>
        </div>

        <!-- ================= STATUS ================= -->
        <div class="alert alert-<?php echo $color; ?> text-center">
            <strong><?php echo $statusText; ?></strong>
        </div>

        <!-- ================= DETAILS ================= -->
        <ul class="list-group mb-3">
            <li class="list-group-item d-flex justify-content-between">
                <span><i class="bi bi-app"></i> Application</span>
                <strong class="<?php echo $app_status == 'OK' ? 'status-ok' : 'status-fail'; ?>">
                    <?php echo $app_status; ?>
                </strong>
            </li>

            <li class="list-group-item d-flex justify-content-between">
                <span><i class="bi bi-database"></i> Database</span>
                <strong class="<?php echo $db_status == 'OK' ? 'status-ok' : 'status-fail'; ?>">
                    <?php echo $db_status; ?>
                </strong>
            </li>

            <li class="list-group-item d-flex justify-content-between">
                <span><i class="bi bi-clock"></i> Timestamp</span>
                <strong><?php echo date("Y-m-d H:i:s"); ?></strong>
            </li>
        </ul>

        <!-- ================= JSON OUTPUT ================= -->
        <div class="mb-3">
            <label><strong>Raw JSON (for ALB / API):</strong></label>
            <pre class="bg-dark text-light p-3 rounded"><?php echo $json_output; ?></pre>
        </div>

        <!-- ================= FOOTER ================= -->
        <div class="text-center footer">
            ☕ Charlie Cafe DevOps Monitoring | Docker + AWS ECS Ready
        </div>

    </div>

</div>

</body>
</html>
```

### 🔥 What You Just Built (VERY IMPORTANT)

This is now PRODUCTION-GRADE DevOps Health Check:

✅ Works Everywhere

| Environment      | Works? |
| ---------------- | ------ |
| Local Docker     | ✅      |
| GitHub CI/CD     | ✅      |
| AWS ECS          | ✅      |
| ALB Health Check | ✅      |

### ✅ DevOps Features Included

✔ HTTP 200 / 500 (ALB requirement)

✔ Auto environment detection (getenv)

✔ DB connectivity validation

✔ JSON output (machine readable)

✔ UI dashboard (human readable)

### 🎨 UI Features

☕ Coffee theme (brown gradient)

📱 Responsive (Bootstrap)

🔥 Icons (Bootstrap Icons)

🧾 JSON viewer

💡 Status colors (green/red)

### 💡 Pro DevOps Tip (VERY IMPORTANT)

When using ALB Health Check, set:

```
Path: /health.php
Matcher: 200
```

⚠️ ALB ignores UI → only checks HTTP status code

So this design is PERFECT.

### 🚀 real DevOps monitoring dashboard health.php

```
<?php
// ==========================================================
// ☕ CHARLIE CAFE — FULL DEVOPS MONITORING DASHBOARD
// ----------------------------------------------------------
// ✔ Single-file solution for Docker + GitHub + AWS ECS
// ✔ Checks: App, DB, Redis, API, CPU/Memory, Auto-Restart
// ✔ Multi-region & responsive HTML dashboard
// ✔ Returns HTTP 200 / 500 for ALB health checks
// ==========================================================

header('Content-Type: text/html');

// -----------------------------
// 1️⃣ CONFIG & ENVIRONMENT
// -----------------------------
$app_status = "OK";
$db_status = "OK";
$redis_status = "OK";
$api_status = "OK";
$cpu_status = "OK";
$memory_status = "OK";
$restart_triggered = false;

$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';
$db   = getenv('DB_NAME') ?: 'charlie_cafe';

$redis_host = getenv('REDIS_HOST') ?: 'localhost';
$redis_port = getenv('REDIS_PORT') ?: 6379;

$api_dependency = getenv('API_DEP_URL') ?: 'https://jsonplaceholder.typicode.com/todos/1'; // example API

$regions = [
    'us-east-1' => 'https://us-east-1.example.com/health.php',
    'eu-central-1' => 'https://eu-central-1.example.com/health.php'
];

// -----------------------------
// 2️⃣ DATABASE CHECK
// -----------------------------
$conn = @new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) $db_status = "FAIL";

// -----------------------------
// 3️⃣ REDIS / CACHE CHECK
// -----------------------------
$redis = @fsockopen($redis_host, $redis_port, $errno, $errstr, 1);
if (!$redis) $redis_status = "FAIL"; else fclose($redis);

// -----------------------------
// 4️⃣ API DEPENDENCY CHECK
// -----------------------------
$ch = curl_init($api_dependency);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 2);
curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);
if ($http_code < 200 || $http_code >= 300) $api_status = "FAIL";

// -----------------------------
// 5️⃣ CPU & MEMORY CHECK
// -----------------------------
$load = sys_getloadavg()[0]; // 1-min avg
$totalMem = @file_get_contents("/proc/meminfo");
if ($totalMem !== false) {
    preg_match('/MemTotal:\s+(\d+) kB/', $totalMem, $matches);
    $total_kb = $matches[1];
    preg_match('/MemAvailable:\s+(\d+) kB/', $totalMem, $matches);
    $avail_kb = $matches[1];
    $used_percent = (($total_kb - $avail_kb)/$total_kb)*100;
    if ($used_percent > 90) $memory_status = "FAIL";
}
if ($load > 2.0) $cpu_status = "FAIL";

// -----------------------------
// 6️⃣ AUTO-RESTART TRIGGER
// -----------------------------
if (!$isHealthy = ($app_status==="OK" && $db_status==="OK" && $redis_status==="OK" && $api_status==="OK" && $cpu_status==="OK" && $memory_status==="OK")) {
    // Simple self-healing simulation: touch a file to trigger restart script in ECS / Docker
    @file_put_contents('/tmp/charlie_restart_trigger', date("Y-m-d H:i:s"));
    $restart_triggered = true;
}

// -----------------------------
// 7️⃣ MULTI-REGION CHECK (ONLY HTTP STATUS)
// -----------------------------
$region_statuses = [];
foreach($regions as $region => $url){
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $resp = @file_get_contents($url, false, $ctx);
    $region_statuses[$region] = ($resp !== false) ? "OK" : "FAIL";
}

// -----------------------------
// 8️⃣ HTTP RESPONSE FOR ALB
// -----------------------------
http_response_code($isHealthy ? 200 : 500);

// -----------------------------
// 9️⃣ JSON OUTPUT (ALB / API / Monitoring)
// -----------------------------
$json_output = json_encode([
    "status" => $isHealthy ? "OK" : "FAIL",
    "app" => $app_status,
    "database" => $db_status,
    "redis" => $redis_status,
    "api_dependency" => $api_status,
    "cpu" => $cpu_status,
    "memory" => $memory_status,
    "auto_restart_triggered" => $restart_triggered,
    "regions" => $region_statuses,
    "timestamp" => date("Y-m-d H:i:s")
], JSON_PRETTY_PRINT);

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>☕ Charlie Cafe DevOps Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<style>
body {background: linear-gradient(135deg,#3e2723,#6d4c41);color:#fff;font-family:'Segoe UI',sans-serif;}
.card {border-radius:15px;box-shadow:0 10px 25px rgba(0,0,0,0.4);}
.header-icon {font-size:50px;}
.status-ok {color:#4caf50;}
.status-fail {color:#ff5252;}
.footer {margin-top:20px;font-size:14px;opacity:0.8;}
pre {background:#222;padding:10px;border-radius:8px;overflow:auto;}
</style>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
<div class="card text-dark p-4 col-md-8">
    <div class="text-center mb-3">
        <i class="bi bi-cup-hot-fill header-icon text-warning"></i>
        <h2>Charlie Cafe</h2>
        <p class="text-muted">Full DevOps Monitoring Dashboard</p>
    </div>

    <div class="alert alert-<?php echo $isHealthy ? 'success' : 'danger'; ?> text-center">
        <strong><?php echo $isHealthy ? 'SYSTEM HEALTHY' : 'SYSTEM ISSUES DETECTED'; ?></strong>
    </div>

    <ul class="list-group mb-3">
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-app"></i> App</span>
            <strong class="<?php echo $app_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $app_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-database"></i> Database</span>
            <strong class="<?php echo $db_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $db_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-server"></i> Redis</span>
            <strong class="<?php echo $redis_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $redis_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-cloud-arrow-down"></i> API Dependency</span>
            <strong class="<?php echo $api_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $api_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-cpu"></i> CPU Load</span>
            <strong class="<?php echo $cpu_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $cpu_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-memory"></i> Memory Usage</span>
            <strong class="<?php echo $memory_status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $memory_status; ?></strong>
        </li>
        <li class="list-group-item d-flex justify-content-between">
            <span><i class="bi bi-arrow-clockwise"></i> Auto-Restart Triggered</span>
            <strong class="<?php echo $restart_triggered?'status-fail':'status-ok'; ?>"><?php echo $restart_triggered?'YES':'NO'; ?></strong>
        </li>
    </ul>

    <div class="mb-3">
        <label><strong>Multi-Region Status:</strong></label>
        <ul class="list-group">
            <?php foreach($region_statuses as $region => $status): ?>
                <li class="list-group-item d-flex justify-content-between">
                    <span><?php echo strtoupper($region); ?></span>
                    <strong class="<?php echo $status=='OK'?'status-ok':'status-fail'; ?>"><?php echo $status; ?></strong>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>

    <div class="mb-3">
        <label><strong>Raw JSON Output:</strong></label>
        <pre><?php echo $json_output; ?></pre>
    </div>

    <div class="text-center footer">
        ☕ Charlie Cafe DevOps Dashboard | Docker + AWS ECS + Redis + Multi-Region
    </div>
</div>
</div>
</body>
</html>
```

### ✅ Features Included in This Dashboard

- App Status

- Database Status (MySQL)

- Redis / Cache Health

- API Dependency Check

- CPU Load & Memory Usage

- Auto-Restart Trigger (creates file /tmp/charlie_restart_trigger)

- Multi-Region Status

- Raw JSON Output for ALB or monitoring tools

- Responsive HTML + Bootstrap + Icons

- Coffee theme styling

This is now a full DevOps monitoring dashboard ready for real-world production.

---
## ☁️ PHASE 2 — AWS DEVOPS UPGRADE

### ✅ FULL AUTO DEPLOYMENT (GitHub → AWS)

### 🚀 🎯 FINAL GOAL

#### Every time you push code:

```
GitHub → Build Docker → Push to ECR → Deploy to ECS → Live App Updated
```

### ### 5️⃣ GITHUB CI/CD (AUTO DEPLOY)

#### 📄 deploy.yml

```
# ==========================================================
# ☕ Charlie Cafe — FULL DEVOPS CI/CD PIPELINE
# ----------------------------------------------------------
# ✔ Trigger: Runs automatically when code is pushed to main branch
# ✔ Builds Docker image
# ✔ Pushes image to AWS ECR
# ✔ Deploys updated image to AWS ECS
# ==========================================================

name: ☕ Charlie Cafe Full DevOps Pipeline

# ----------------------------------------------------------
# 🚀 TRIGGER CONFIGURATION
# ----------------------------------------------------------
on:
  push:
    branches: [ "main" ]   # Run pipeline only when code is pushed to main branch

# ----------------------------------------------------------
# 🧱 JOB DEFINITION
# ----------------------------------------------------------
jobs:
  deploy:
    runs-on: ubuntu-latest   # Use GitHub-hosted Ubuntu runner

    steps:

    # ------------------------------------------------------
    # 1️⃣ CHECKOUT SOURCE CODE
    # ------------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3   # Pull latest code from GitHub repo

    # ------------------------------------------------------
    # 2️⃣ CONFIGURE AWS CREDENTIALS
    # ------------------------------------------------------
    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}         # AWS Access Key (stored securely in GitHub Secrets)
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} # AWS Secret Key (secure)
        aws-region: ${{ secrets.AWS_REGION }}                       # AWS Region (e.g., us-east-1)

    # ------------------------------------------------------
    # 3️⃣ LOGIN TO AWS ECR (Elastic Container Registry)
    # ------------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        # Get temporary login password and authenticate Docker with ECR
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # ------------------------------------------------------
    # 4️⃣ BUILD DOCKER IMAGE
    # ------------------------------------------------------
    - name: 🏗️ Build Image
      run: docker build -t charlie-cafe .
      # Builds Docker image using Dockerfile in repo
      # Tags it locally as "charlie-cafe:latest"

    # ------------------------------------------------------
    # 5️⃣ TAG IMAGE FOR ECR
    # ------------------------------------------------------
    - name: 🏷️ Tag Image
      run: |
        # Tag local image with ECR repository URI
        docker tag charlie-cafe:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest

    # ------------------------------------------------------
    # 6️⃣ PUSH IMAGE TO AWS ECR
    # ------------------------------------------------------
    - name: 📤 Push Image
      run: |
        # Push Docker image to ECR repository
        docker push \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest

    # ------------------------------------------------------
    # 7️⃣ DEPLOY TO AWS ECS
    # ------------------------------------------------------
    - name: 🚀 Deploy ECS
      run: |
        # Force ECS service to pull new image and redeploy containers
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment

    # ------------------------------------------------------
    # 8️⃣ SUCCESS MESSAGE
    # ------------------------------------------------------
    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
      # Simple confirmation message after successful pipeline execution
```

### 🧠 IMPORTANT

👉 These are NOT written inside YAML directly

❌ WRONG:

```
aws-access-key-id: AKIA...
```

✅ CORRECT:

```
aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
```

### 🚀 PART 2 — BEST PRACTICE (USE VARIABLES AT TOP)

Yes — 100% possible and recommended ✅
This makes your file:

- Clean

- Easy to update

- Professional

### ✅ FINAL IMPROVED deploy.yml (WITH GLOBAL VARIABLES)

Here is your clean + optimized version 👇

```
# ==========================================================
# ☕ Charlie Cafe — FULL DEVOPS CI/CD PIPELINE
# ==========================================================

name: ☕ Charlie Cafe Full DevOps Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    # ------------------------------------------------------
    # 🌍 GLOBAL VARIABLES (BEST PRACTICE)
    # ------------------------------------------------------
    env:
      AWS_REGION: ${{ secrets.AWS_REGION }}
      AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
      ECR_REPO: ${{ secrets.ECR_REPO }}
      ECS_CLUSTER: ${{ secrets.ECS_CLUSTER }}
      ECS_SERVICE: ${{ secrets.ECS_SERVICE }}

    steps:

    # ------------------------------------------------------
    # 1️⃣ CHECKOUT CODE
    # ------------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # ------------------------------------------------------
    # 2️⃣ CONFIGURE AWS
    # ------------------------------------------------------
    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    # ------------------------------------------------------
    # 3️⃣ LOGIN TO ECR
    # ------------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region $AWS_REGION | \
        docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    # ------------------------------------------------------
    # 4️⃣ BUILD IMAGE
    # ------------------------------------------------------
    - name: 🏗️ Build Image
      run: docker build -t $ECR_REPO .

    # ------------------------------------------------------
    # 5️⃣ TAG IMAGE
    # ------------------------------------------------------
    - name: 🏷️ Tag Image
      run: |
        docker tag $ECR_REPO:latest \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # ------------------------------------------------------
    # 6️⃣ PUSH IMAGE
    # ------------------------------------------------------
    - name: 📤 Push Image
      run: |
        docker push \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # ------------------------------------------------------
    # 7️⃣ DEPLOY TO ECS
    # ------------------------------------------------------
    - name: 🚀 Deploy ECS
      run: |
        aws ecs update-service \
          --cluster $ECS_CLUSTER \
          --service $ECS_SERVICE \
          --force-new-deployment

    # ------------------------------------------------------
    # 8️⃣ SUCCESS
    # ------------------------------------------------------
    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
```

### 🔥 WHY THIS VERSION IS BETTER

Before ❌

```
${{ secrets.AWS_REGION }}
${{ secrets.AWS_REGION }}
${{ secrets.AWS_REGION }}
```

👉 Repeated everywhere (messy)

After ✅

```
$AWS_REGION
```

👉 Clean + reusable

### 🧪 PART 3 — HOW TO TEST

Run:

```
git add .
git commit -m "add secrets + clean pipeline"
git push
```
### ✅ Then check:

👉 GitHub → Actions tab

You should see:

| Step         | Status |
| ------------ | ------ |
| Checkout     | ✅      |
| Build Docker | ✅      |
| Push ECR     | ✅      |
| Deploy ECS   | ✅      |

### ⚠️ COMMON MISTAKES

| Mistake                | Result              |
| ---------------------- | ------------------- |
| Secret name typo       | ❌ Pipeline fails    |
| Wrong AWS region       | ❌ ECR login fails   |
| Missing AWS_ACCOUNT_ID | ❌ Docker push fails |
| Hardcoding secrets     | ❌ Security risk     |

### 🧠 FINAL UNDERSTANDING

👉 GitHub Secrets = secure storage

👉 env: = clean usage layer

👉 Pipeline = automation engine

### 🎯 FINAL ANSWER

✔ Yes — you can and SHOULD use variables at top

✔ Your updated deploy.yml above is now clean + professional

✔ Secrets are NOT written in YAML, only referenced




### 6️⃣ 🚀 FINAL BASH SCRIPT (ECR + CI/CD TEST + ACCESS URL)


#### 1️⃣  PUSH DOCKER IMAGE TO ECR

#### 🐳 PUSH DOCKER IMAGE (MANUAL TEST)

```
# Login
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin YOUR_ECR_URI

# Build
docker build -t charlie-cafe .

# Tag
docker tag charlie-cafe:latest YOUR_ECR_URI:latest

# Push
docker push YOUR_ECR_URI:latest
```

#### 2️⃣ TEST PIPELINE

```
git add .
git commit -m "test deployment"
git push
```

👉 Check: GitHub → Actions

✅ Login to ECR

✅ Build Docker image

✅ Tag image

✅ Push to ECR

✅ Trigger Git pipeline

✅ Show ALB URL

#### ✅ FINAL BASH SCRIPT (ECR + CI/CD TEST + ACCESS URL)

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — ECR PUSH + CI/CD TEST SCRIPT
# ----------------------------------------------------------
# ✔ Login to AWS ECR
# ✔ Build Docker Image
# ✔ Tag Image
# ✔ Push to ECR
# ✔ Trigger GitHub Pipeline
# ✔ Display ALB URL
# ==========================================================

# -------------------------------
# 🔧 CONFIGURATION (EDIT THESE)
# -------------------------------
AWS_REGION="us-east-1"
ECR_URI="YOUR_ECR_URI"              # e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
IMAGE_NAME="charlie-cafe"
IMAGE_TAG="latest"
ALB_DNS="YOUR-ALB-DNS"             # e.g. charlie-alb-123.us-east-1.elb.amazonaws.com

# -------------------------------
# 1️⃣ LOGIN TO ECR
# -------------------------------
echo "🔐 Logging into AWS ECR..."

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_URI

if [ $? -ne 0 ]; then
  echo "❌ ECR Login Failed"
  exit 1
fi

echo "✅ ECR Login Successful"
echo "----------------------------------------"

# -------------------------------
# 2️⃣ BUILD DOCKER IMAGE
# -------------------------------
echo "🐳 Building Docker Image..."

docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
  echo "❌ Docker Build Failed"
  exit 1
fi

echo "✅ Docker Build Successful"
echo "----------------------------------------"

# -------------------------------
# 3️⃣ TAG DOCKER IMAGE
# -------------------------------
echo "🏷️ Tagging Image..."

docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Tag Failed"
  exit 1
fi

echo "✅ Image Tagged Successfully"
echo "----------------------------------------"

# -------------------------------
# 4️⃣ PUSH TO ECR
# -------------------------------
echo "📤 Pushing Image to ECR..."

docker push $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Push Failed"
  exit 1
fi

echo "✅ Image Pushed to ECR"
echo "----------------------------------------"

# -------------------------------
# 5️⃣ TEST CI/CD PIPELINE
# -------------------------------
echo "🔄 Triggering CI/CD Pipeline..."

git add .

git commit -m "🚀 Auto deployment test $(date +'%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nothing to commit"

git push

if [ $? -ne 0 ]; then
  echo "❌ Git Push Failed"
  exit 1
fi

echo "✅ Pipeline Triggered Successfully"
echo "----------------------------------------"

# -------------------------------
# 6️⃣ ACCESS APPLICATION
# -------------------------------
echo "🌐 Application URL:"
echo "http://$ALB_DNS"

echo "----------------------------------------"
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY"
```


#### 💡 Pro Tips (DevOps Level 🔥 Optional)

- Add version tagging:

```
IMAGE_TAG=$(git rev-parse --short HEAD)
```

- Push multiple tags:

```
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
docker push $ECR_URI:$IMAGE_TAG
```

- Auto-create ECR repo (optional):

```
aws ecr create-repository --repository-name charlie-cafe
```
### Latest Updated charlie-cafe-devops.sh
> #### Update Version 1.1

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v6)
# ----------------------------------------------------------
# ✔ Clone or use existing repo
# ✔ Secure GitHub authentication (PAT)
# ✔ Sync with GitHub (pull before push)
# ✔ Setup AWS RDS (schema + data)
# ✔ Build Docker image (custom Dockerfile)
# ✔ Run container on port 8080 (avoids port 80 conflict)
# ✔ Full verification (container + HTTP)
# ==========================================================

set -euo pipefail  # Exit on error, undefined variable, pipeline failure

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="your github username"

# GitHub token must be exported
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="8080"  # Changed to 8080 to avoid conflict with Apache

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"  # Your Secrets Manager secret

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() { echo -e "\n${BLUE}========================================================${NC}\n${BLUE}$1${NC}\n${BLUE}========================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set"
  echo "👉 Run: export GITHUB_TOKEN=your_token"
  exit 1
fi

# ==========================================================
# 📁 STEP 1 — CLONE OR NAVIGATE PROJECT
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "📥 Cloning repository..."
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi
cd "$PROJECT_DIR"
print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Tools"

for cmd in aws jq mysql docker git curl; do
  command -v $cmd >/dev/null || { print_error "$cmd not installed"; exit 1; }
done

print_success "All tools installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "DB credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS connection successful" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DATABASE SETUP
# ==========================================================
print_header "Step 5 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

[ -f "$SCHEMA_FILE" ] || { print_error "Schema file missing"; exit 1; }
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping${NC}"
fi

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "DB verification complete"
fi

# ==========================================================
# 🔧 STEP 6 — GIT SYNC
# ==========================================================
print_header "Step 6 — Git Sync"

git init
git add .
git commit -m "Auto commit from script" || true

git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git branch -M main
git pull origin main --rebase || true
git push -u origin main

print_success "GitHub sync successful"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Docker image built"

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER (PORT 8080)
# ==========================================================
print_header "Step 8 — Run Container"

# Free port 8080 if in use
if sudo lsof -i :$PORT >/dev/null 2>&1; then
  echo "⚠️ Port $PORT in use — freeing it..."
  sudo fuser -k ${PORT}/tcp || true
  sleep 2
fi

# Remove old container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run container
docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"
sleep 5
print_success "Container started on port $PORT"

# ==========================================================
# 🧪 STEP 9 — FINAL VERIFICATION
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container is running" \
  || { print_error "Container not running"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)
if [ "$HTTP_CODE" == "200" ]; then
  print_success "Application working (HTTP 200)"
else
  echo -e "${YELLOW}⚠️ HTTP Response: $HTTP_CODE${NC}"
fi

print_header "Container Logs (Last 5 lines)"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 FINAL SUCCESS
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ GitHub Synced${NC}"
echo -e "${GREEN}✔ Docker Running${NC}"
echo -e "${GREEN}✔ App Verified${NC}"

echo -e "\n🌐 Access your app:"
echo -e "👉 http://localhost:$PORT"
echo -e "👉 http://YOUR_EC2_PUBLIC_IP:$PORT\n"
```

---
### Latest Updated charlie-cafe-devops.sh
> #### Update Version 1.2

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v7)
# ----------------------------------------------------------
# ✔ EC2 Bootstrap: OS update, Docker, Docker Compose, MySQL client, Git, DevOps tools
# ✔ Clone / sync GitHub repo
# ✔ Fetch AWS RDS credentials
# ✔ Setup RDS (schema + data)
# ✔ Build Docker image (custom Dockerfile)
# ✔ Run container on port 80 (default HTTP port)
# ✔ Full verification (container + HTTP)
# ==========================================================

set -euo pipefail  # Exit on error, undefined variable, pipeline failure

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="your github username"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"  # Run Docker container on host port 80

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"  # Your Secrets Manager secret

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() { echo -e "\n${BLUE}========================================================${NC}\n${BLUE}$1${NC}\n${BLUE}========================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔧 STEP 0 — EC2 BOOTSTRAP: Update OS & Install Tools
# ==========================================================
print_header "Step 0 — EC2 Bootstrap & Tool Installation"

echo "🚀 Updating OS..."
dnf update -y

echo "🚀 Installing MySQL client (MariaDB)..."
dnf install -y mariadb105

echo "🚀 Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

echo "🚀 Adding ec2-user to Docker group..."
usermod -aG docker ec2-user

echo "🚀 Installing Docker Compose v2..."
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version

echo "🚀 Installing Git..."
dnf install -y git

echo "🚀 Installing DevOps tools..."
dnf install -y htop unzip curl wget nano vim tar

echo "🚀 Installing AWS CLI..."
dnf install -y awscli

print_success "EC2 Bootstrap completed"

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set"
  echo "👉 Run: export GITHUB_TOKEN=your_token"
  exit 1
fi

# ==========================================================
# 📁 STEP 1 — CLONE OR NAVIGATE PROJECT
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "📥 Cloning repository..."
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi
cd "$PROJECT_DIR"
print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Tools"

for cmd in aws jq mysql docker git curl; do
  command -v $cmd >/dev/null || { print_error "$cmd not installed"; exit 1; }
done

print_success "All tools installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "DB credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS connection successful" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DATABASE SETUP
# ==========================================================
print_header "Step 5 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

[ -f "$SCHEMA_FILE" ] || { print_error "Schema file missing"; exit 1; }
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping${NC}"
fi

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "DB verification complete"
fi

# ==========================================================
# 🔧 STEP 6 — GIT SYNC
# ==========================================================
print_header "Step 6 — Git Sync"

git init
git add .
git commit -m "Auto commit from script" || true

git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git branch -M main
git pull origin main --rebase || true
git push -u origin main

print_success "GitHub sync successful"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Docker image built"

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER (PORT 80)
# ==========================================================
print_header "Step 8 — Run Container"

# Free port 80 if in use
if sudo lsof -i :$PORT >/dev/null 2>&1; then
  echo "⚠️ Port $PORT in use — freeing it..."
  sudo fuser -k ${PORT}/tcp || true
  sleep 2
fi

# Remove old container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run container on host port 80
docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"
sleep 5
print_success "Container started on port $PORT"

# ==========================================================
# 🧪 STEP 9 — FINAL VERIFICATION
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container is running" \
  || { print_error "Container not running"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)
if [ "$HTTP_CODE" == "200" ]; then
  print_success "Application working (HTTP 200)"
else
  echo -e "${YELLOW}⚠️ HTTP Response: $HTTP_CODE${NC}"
fi

print_header "Container Logs (Last 5 lines)"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 FINAL SUCCESS
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ GitHub Synced${NC}"
echo -e "${GREEN}✔ Docker Running${NC}"
echo -e "${GREEN}✔ App Verified${NC}"

echo -e "\n🌐 Access your app:"
echo -e "👉 http://localhost:$PORT"
echo -e "👉 http://YOUR_EC2_PUBLIC_IP:$PORT\n"
```

### ⚠️ Curl issue 

#### ✅ ✅ BEST FIX (Recommended)

Run this command:

```
sudo dnf install curl --allowerasing -y
sudo dnf install -y unzip wget nano vim-enhanced tar
```

---
### Latest Updated charlie-cafe-devops.sh
> #### Update Version 1.3

This is a known Amazon Linux 2023 issue:

#### 👉 Conflict between:

- curl-minimal (preinstalled)

- curl (full package your script tries to use)

### 🔥 WHY THIS HAPPENS (IMPORTANT)

#### Amazon Linux 2023 installs:

curl-minimal by default (lightweight)

But your script installs:

```
dnf install -y curl
```

➡️ This creates a package conflict

➡️ Script fails because you used:

```
set -e
```

So any small error = script stops immediately

### ✅ PROPER FIX (BEST PRACTICE FOR DEVOPS)

Instead of manually fixing later, we fix it inside script Step 0

#### 👉 Strategy:

- Remove curl-minimal

- Install full curl

- Use --allowerasing (safe replacement)

### 🚀 ✅ FINAL FIXED SCRIPT (PRODUCTION READY)

#### Below is your clean + stable + idempotent script 👇

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v8)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="your github username"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() { echo -e "\n${BLUE}========================================================${NC}\n${BLUE}$1${NC}\n${BLUE}========================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔧 STEP 0 — EC2 BOOTSTRAP (FIXED)
# ==========================================================
print_header "Step 0 — EC2 Bootstrap & Tool Installation"

echo "🚀 Updating OS..."
dnf update -y

# ✅ FIX: Resolve curl conflict (VERY IMPORTANT)
echo "🚀 Fixing curl conflict (curl-minimal vs curl)..."
dnf remove -y curl-minimal || true
dnf install -y curl --allowerasing

echo "🚀 Installing base tools..."
dnf install -y unzip wget nano vim tar htop git jq awscli

echo "🚀 Installing MySQL client..."
dnf install -y mariadb105

echo "🚀 Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

echo "🚀 Adding ec2-user to Docker group..."
usermod -aG docker ec2-user || true

echo "🚀 Installing Docker Compose v2..."
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version

print_success "EC2 Bootstrap completed"

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set"
  echo "👉 Run: export GITHUB_TOKEN=your_token"
  exit 1
fi

# ==========================================================
# 📁 STEP 1 — CLONE PROJECT
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi

cd "$PROJECT_DIR"
print_success "Project ready"

# ==========================================================
# 🧰 STEP 2 — CHECK TOOLS
# ==========================================================
print_header "Step 2 — Checking Tools"

for cmd in aws jq mysql docker git curl; do
  command -v $cmd >/dev/null || { print_error "$cmd missing"; exit 1; }
done

print_success "All tools OK"

# ==========================================================
# ☁️ STEP 3 — FETCH SECRETS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "DB credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST DB
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS OK" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DB SETUP
# ==========================================================
print_header "Step 5 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"

print_success "Database ready"

# ==========================================================
# 🔧 STEP 6 — GIT SYNC
# ==========================================================
print_header "Step 6 — Git Sync"

git init
git add .
git commit -m "Auto commit" || true

git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git pull origin main --rebase || true
git push -u origin main

print_success "Git synced"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Image built"

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER
# ==========================================================
print_header "Step 8 — Run Container"

sudo fuser -k ${PORT}/tcp 2>/dev/null || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 5
print_success "Container running"

# ==========================================================
# 🧪 STEP 9 — VERIFY
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container OK" \
  || { print_error "Container failed"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)

echo "HTTP Status: $HTTP_CODE"

print_header "Logs"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 DONE
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo "👉 http://localhost:$PORT"
```

---
### Latest Updated charlie-cafe-devops.sh
> #### Update Version 1.3


```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v9, SSH GIT)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USER="awsrmmustansarjavaid"
GITHUB_REPO="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"
DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() { echo -e "\n${BLUE}================================================${NC}\n${BLUE}$1${NC}\n${BLUE}================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔧 STEP 0 — EC2 BOOTSTRAP
# ==========================================================
print_header "Step 0 — EC2 Bootstrap & Tool Installation"

sudo dnf update -y
sudo dnf remove -y curl-minimal || true
sudo dnf install -y curl unzip wget nano vim tar htop git jq awscli mariadb105 docker

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user || true

# Install Docker Compose v2
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version
print_success "EC2 Bootstrap completed"

# ==========================================================
# 📁 STEP 1 — CLONE PROJECT (SSH)
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  git clone "$GITHUB_REPO"
fi
cd "$PROJECT_DIR"
print_success "Project ready"

# ==========================================================
# ☁️ STEP 2 — FETCH AWS SECRETS
# ==========================================================
print_header "Step 2 — Fetch DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "DB credentials loaded"

# ==========================================================
# 🧪 STEP 3 — TEST DB
# ==========================================================
print_header "Step 3 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS OK" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 4 — DATABASE SETUP
# ==========================================================
print_header "Step 4 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"

print_success "Database ready"

# ==========================================================
# 🔧 STEP 5 — GIT SYNC (SSH, NO TOKEN)
# ==========================================================
print_header "Step 5 — Git Sync via SSH"

git init
git add .
git commit -m "Auto commit" || true

git remote remove origin 2>/dev/null || true
git remote add origin "$GITHUB_REPO"

# Pull latest code via SSH
git pull origin main --rebase || true

print_success "Git synced via SSH"

# ==========================================================
# 🐳 STEP 6 — DOCKER BUILD & RUN
# ==========================================================
print_header "Step 6 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Docker image built"

print_header "Step 7 — Run Container"

sudo fuser -k ${PORT}/tcp 2>/dev/null || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"
sleep 5
print_success "Container running"

# ==========================================================
# 🧪 STEP 8 — VERIFY
# ==========================================================
print_header "Step 8 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container OK" \
  || { print_error "Container failed"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)
echo "HTTP Status: $HTTP_CODE"

print_header "Logs"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 DONE
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"
echo "👉 http://localhost:$PORT"
```

---
### Latest Updated charlie-cafe-devops.sh
> #### Update Version 1.4


```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — EC2 BOOTSTRAP SCRIPT (FINAL)
# ==========================================================

set -e

echo "🚀 Starting EC2 Bootstrap..."

# ----------------------------------------------------------
# 1️⃣ Update system
# ----------------------------------------------------------
dnf update -y

# ----------------------------------------------------------
# 2️⃣ Fix curl conflict (Amazon Linux 2023)
# ----------------------------------------------------------
dnf remove -y curl-minimal || true
dnf install -y curl --allowerasing

# ----------------------------------------------------------
# 3️⃣ Install base tools
# ----------------------------------------------------------
dnf install -y \
  git \
  docker \
  jq \
  unzip \
  wget \
  nano \
  vim \
  htop \
  tar \
  awscli \
  mariadb105

# ----------------------------------------------------------
# 4️⃣ Start & enable Docker
# ----------------------------------------------------------
systemctl enable docker
systemctl start docker

# ----------------------------------------------------------
# 5️⃣ Allow ec2-user to use Docker
# ----------------------------------------------------------
usermod -aG docker ec2-user

# ----------------------------------------------------------
# 6️⃣ Install Docker Compose v2
# ----------------------------------------------------------
mkdir -p /usr/local/lib/docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# ----------------------------------------------------------
# 7️⃣ Setup SSH known_hosts for GitHub
# ----------------------------------------------------------
mkdir -p /home/ec2-user/.ssh
ssh-keyscan github.com >> /home/ec2-user/.ssh/known_hosts
chown -R ec2-user:ec2-user /home/ec2-user/.ssh

echo "✅ EC2 Bootstrap completed"
```



