# ☕ Charlie Cafe — GitHub → Lambda → API Gateway (CI/CD)

### 🧠 Your Current Architecture

```
GitHub Repo
   ↓
GitHub Actions (deploy.yml)
   ↓
AWS Lambda (multiple functions)
   ↓
API Gateway (already integrated)
   ↓
Frontend / Browser
```

#### 👉 IMPORTANT:

Y- our API Gateway is already connected to Lambda ✅

- So when Lambda updates → API auto uses new code (NO change needed)

### ✅ Difference: Paste Code vs GitHub CI/CD

This is VERY important for interviews 👇

### 🔴 1. Real Difference (Based on YOUR LAB) 

#### Manual Paste (Your Old Way)

You were doing:

```
GitHub → Copy code → AWS Lambda Console → Paste → Deploy
```

#### ❌ Problems in YOUR scenario:

- Your repo (charlie-cafe-devops) becomes useless for backend versioning

- If you break one Lambda → API Gateway breaks instantly

- No rollback if API fails

- Multiple Lambda functions = headache 😵

### 🟢 GitHub CI/CD (Your New Way)

Now you will do:

```
GitHub → Push Code → GitHub Actions → Auto Deploy → Lambda Updated
```

#### ✅ In YOUR lab:

- Each Lambda function is deployed automatically

- API Gateway endpoints stay SAME (no reconfiguration)

- Your backend becomes production-grade DevOps system

### ⚔️ Simple Comparison (Interview Ready)

| Feature           | Paste Code | GitHub → Lambda |
| ----------------- | ---------- | --------------- |
| API Stability     | ❌ Risky    | ✅ Safe          |
| Multi Lambda Mgmt | ❌ Hard     | ✅ Easy          |
| Rollback          | ❌ No       | ✅ Yes           |
| Automation        | ❌ No       | ✅ Yes 🔥        |
| DevOps Level      | ❌ Basic    | ✅ Professional  |

### 🚀 2. How to Implement (YOUR REPO STRUCTURE)

#### You already have:

```
app/backend/lambda/
   ├── order.py
   ├── menu.py
   ├── payment.py
```

👉 Each file = one Lambda function (important!)

### 🧠 3. Deployment Strategy (IMPORTANT DECISION)

#### You have 2 options:

- ✅ Option A (BEST for your lab) → Deploy ALL Lambdas in one pipeline

- ❌ Option B → Separate pipeline per Lambda (complex)

👉 You should use Option A

### 🔐 4. IAM Policy (Minimal Required)

#### Attach this to your IAM user:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:UpdateFunctionCode"
  ],
  "Resource": "*"
}
```

### 🔑 5. GitHub Secrets

#### Add in GitHub:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

#### AND (important for multi-lambda):

```
LAMBDA_MENU
LAMBDA_ORDER
LAMBDA_PAYMENT
```

### ⚙️ 6. FINAL deploy.yml (FOR YOUR LAB)

Add this inside your existing pipeline (don’t break ECS part)

```
# ==========================================================
# 🚀 Deploy ALL Lambda Functions (Charlie Cafe)
# ==========================================================

- name: 📦 Zip Lambda Code
  run: |
    cd app/backend/lambda
    zip -r lambda.zip .

- name: 🔐 Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

# ----------------------------------------------------------
# 🍽️ Deploy Menu Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Menu Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_MENU }} \
      --zip-file fileb://app/backend/lambda/lambda.zip

# ----------------------------------------------------------
# 🧾 Deploy Order Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Order Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_ORDER }} \
      --zip-file fileb://app/backend/lambda/lambda.zip

# ----------------------------------------------------------
# 💳 Deploy Payment Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Payment Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_PAYMENT }} \
      --zip-file fileb://app/backend/lambda/lambda.zip
```

### 🧠 7. IMPORTANT CONCEPT (Most People Miss This)

#### ❗ You are deploying SAME zip to ALL Lambdas

👉 That means:

Each Lambda must use correct handler

Example:

| Lambda Name    | Handler Setting          |
| -------------- | ------------------------ |
| menu-function  | `menu.lambda_handler`    |
| order-function | `order.lambda_handler`   |
| payment        | `payment.lambda_handler` |

👉 This is configured in AWS Lambda (not GitHub)

### 🔗 8. API Gateway — DO YOU NEED CHANGE?

#### 👉 ❌ NO CHANGE REQUIRED

Because:

- API Gateway → already linked to Lambda

- Lambda code updates automatically reflect

### 🧪 9. Optional (But Powerful)

Add testing before deploy:

```
- name: ✅ Test Lambda Code
  run: |
    python -m unittest discover app/backend/lambda
```

### 🔥 10. Final DevOps Flow (Your Lab)

```
Developer (You)
   ↓
Git Push
   ↓
GitHub Actions
   ↓
Zip Lambda Code
   ↓
Update Multiple Lambdas
   ↓
API Gateway (auto updated)
   ↓
Frontend calls API 🚀
```

### 💡 PRO TIP (VERY IMPORTANT FOR YOUR CAREER)

#### Right now your architecture becomes:

✅ ECS (containers)

✅ EC2 (LAMP)

✅ Lambda (serverless)

✅ API Gateway

✅ GitHub CI/CD

👉 This is FULL HYBRID AWS ARCHITECTURE

💥 This is what companies ask for (DevOps + Cloud Engineer role)

### ❓ If You Want Next Level Upgrade

#### I can help you add:

✅ Lambda versioning + rollback

✅ Dev / Stage / Prod environments

✅ Auto API testing after deploy

✅ CloudWatch monitoring integration

✅ Terraform (infra as code)

---
### ✅ How CI/CD deployment works for Lambda

- #### GitHub file:

You have CafeOrderProcessor.py in your repo:

```
app/backend/lambda/CafeOrderProcessor.py
```

- #### GitHub Actions pipeline:

Your deploy.yml does these two steps:

```
zip lambda_zips/CafeOrderProcessor.zip app/backend/lambda/CafeOrderProcessor.py
aws lambda update-function-code --function-name CafeOrderProcessor --zip-file fileb://lambda_zips/CafeOrderProcessor.zip
```

#### What this does:

- It zips the .py file

- It uploads the zip to AWS Lambda

- AWS Lambda code is replaced with this new zip

### 🧩 What happens in AWS Lambda console

After CI/CD runs successfully, if you go to AWS Lambda → CafeOrderProcessor → Code tab:

✅ You will see the exact code from GitHub file inside the Lambda editor

✅ It is identical to your GitHub file

❌ No copy-paste required

Lambda essentially syncs its code with the GitHub file via CI/CD.

### ⚠️ Important Notes

- No GitHub link: Lambda does not link to GitHub. It only gets the zip file.

- Editable in Lambda: You can edit code in Lambda console, but next GitHub push → Lambda is overwritten.

- Dependencies: Only the .py file itself is copied. If your Lambda uses external libraries (pymysql, requests), they must be included in the zip or via Lambda Layer.

### ✅ TL;DR

- After CI/CD runs, Lambda looks exactly like your GitHub file

- No manual copy-paste needed

- GitHub is now the source of truth

---
## ☕ Charlie Cafe Full AWS DevOps Upgrade from GitHub

> This project upgrades the existing Charlie Cafe application into a fully automated AWS DevOps workflow using GitHub, CI/CD, and AWS services. The goal is to have automatic deployment for Lambda functions, API Gateway, RDS, DynamoDB, and LAMP components via GitHub Actions and scripts, ensuring version control, testing, and zero manual deployment steps. This setup allows you to maintain all Lambda code in your GitHub repo and deploy updates seamlessly across all integrated AWS services.

### 🔥 First — What You MUST Understand (Very Important)

Before touching anything, keep these rules in mind:

- ### 1️⃣ Lambda code SHOULD be inside GitHub (✔ already done)

You already have:

```
app/backend/lambda/*.py
```

✅ Perfect — DO NOT move them

- ### 2️⃣ Each Lambda = separate deployment unit

Every file like:

CafeOrderProcessor.py
hr-attendance.py

👉 is a separate Lambda function in AWS

So:

❌ You cannot deploy all in one command

✅ You must update each Lambda individually

- ### 3️⃣ Two deployment methods (choose one)

| Method          | Use case                      |
| --------------- | ----------------------------- |
| ZIP upload      | ✅ BEST for your current setup |
| Container (ECR) | advanced (skip for now)       |

👉 We will use ZIP method (simple + professional)

### 🧠 Answer to Your Main Question

should i add lambda .py inside deploy.yml?

👉 ❌ NO (not directly inside YAML)

👉 ✅ Instead:

- Keep .py files in repo ✔

- Use deploy.yml to:

- Zip them

- Upload to AWS Lambda

### 🚀 FULL STEP-BY-STEP AWS DevOps Configuration Guide

### 🌐 Prerequisites

- AWS Account with permissions: EC2, Lambda, API Gateway, DynamoDB, RDS, IAM, S3, CloudWatch, CloudFormation.

- GitHub repository already containing your project structure (as listed).

- AWS CLI installed locally or in your CI/CD runner.

- Docker installed if using Lambda layers or containerized deployment.

- AWS IAM user with programmatic access (Access Key & Secret Key) for GitHub Actions.

### 1️⃣ Add Lambda Function Names (IMPORTANT)

You must know exact AWS Lambda names.

Example mapping:

| File                  | Lambda Name in AWS |
| --------------------- | ------------------ |
| CafeOrderProcessor.py | CafeOrderProcessor |
| CafeMenuLambda.py     | CafeMenuLambda     |

👉 These names MUST match AWS exactly

### 2️⃣ GitHub Repository Setup

- Ensure your repo structure matches the one you shared.

- Add .gitignore for:

```
__pycache__/
*.pyc
.env
.aws/
```

- Add .dockerignore in Docker folder to exclude unnecessary files.

### 3️⃣ Prepare AWS IAM Roles and Policies

#### Add IAM Permission

Your GitHub IAM user MUST have:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:UpdateFunctionCode",
    "lambda:GetFunction",
    "lambda:ListFunctions"
  ],
  "Resource": "*"
}
```

#### Read more about [Charlie Cafe DevOps IAM Policy](https://github.dev/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Readme/Charlie%20Cafe%20DevOps.md)

- #### Lambda Execution Role

   - Attach policies: AWSLambdaFullAccess, AmazonDynamoDBFullAccess, AmazonRDSFullAccess, AmazonS3FullAccess, CloudWatchLogsFullAccess.

- #### GitHub CI/CD Role (for GitHub Actions)

   - Policy allowing: lambda:UpdateFunctionCode, apigateway:*, s3:*, ec2:*, ecs:*.

- Save Access Key & Secret Key securely (for GitHub Secrets).

[Charlie Cafe DevOps IAM Policy](https://github.dev/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Charlie%20Cafe%20DevOps.json)

### 4️⃣ Configure AWS Secrets in GitHub

- Go to GitHub repo → Settings → Secrets → Actions → Add the following secrets:

| Secret Name             | Value                                |
| ----------------------- | ------------------------------------ |
| `AWS_ACCESS_KEY_ID`     | Your IAM user access key             |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key             |
| `AWS_REGION`            | e.g., `us-east-1`                    |
| `AWS_ACCOUNT_ID`        | Your AWS account ID                  |
| `ECR_REPO`              | If using containerized Lambda or ECS |
| `ECS_CLUSTER`           | If using ECS                         |
| `ECS_SERVICE`           | If using ECS                         |

### 5️⃣ Lambda Deployment Preparation

- Ensure each Lambda function has a requirements.txt if using Python dependencies.

- If using Lambda layers, place shared dependencies in a lambda_layer.sh script for automation.

- Optional: Containerize Lambda for advanced CI/CD:

```
docker build -t lambda-name ./app/backend/lambda/
```

### 6️⃣ API Gateway Configuration

- Each Lambda already has an API Gateway.

- For CI/CD:

   - Create a script to deploy/update API Gateway:

```
aws apigateway get-rest-apis
aws apigateway import-rest-api --parameters endpointConfigurationTypes=REGIONAL --body 'swagger.json'
```

- This allows API Gateway to auto-update whenever Lambda code changes.

### 7️⃣ RDS & DynamoDB Integration

- #### RDS

   - Keep schema.sql, data.sql, verify.sql under infrastructure/rds/.

   - Add a CI/CD step to initialize or test RDS with:

```
mysql -h <RDS_ENDPOINT> -u <user> -p <password> < schema.sql
```

- #### DynamoDB

- Use aws dynamodb put-item scripts to seed or verify tables.

- Integrate in GitHub Actions for testing.

### 8️⃣ Docker & LAMP Setup

- Apache-PHP Dockerfile: Ensure all your PHP & HTML code runs inside.

- MySQL Dockerfile: Ensure it uses schema.sql & data.sql.

- docker-compose.yml: Make services linkable and networked.

- CI/CD Step: Build and push Docker images to ECR:

```
docker build -t charlie-cafe ./docker/apache-php
docker tag charlie-cafe:latest <ECR_URI>:latest
docker push <ECR_URI>:latest
```

### 9️⃣ GitHub Actions — deploy.yml

Your deploy.yml should include:

- Trigger: On push to main.

- #### Steps:

   - Checkout repo

   - Configure AWS credentials

   - Build & push Docker images

   - Deploy Lambda functions:

```
aws lambda update-function-code \
    --function-name AdminMarkPaidLambda \
    --zip-file fileb://app/backend/lambda/AdminMarkPaidLambda.zip
```

- Update API Gateway

- Run RDS/DynamoDB tests

- Optional: Restart EC2 LAMP containers or ECS service

> This ensures every push automatically updates Lambda, APIs, and backend infrastructure.

- #### ✳️ Modify deploy.yml

👉 Add this NEW section after step 14️⃣ Cleanup

- #### ✳️ PACKAGE LAMBDA CODE

```
    # -------------------------------------------------
    # 15️⃣ Package Lambda Functions
    # -------------------------------------------------
    - name: 📦 Package Lambda Functions
      run: |
        mkdir lambda_zips

        for file in app/backend/lambda/*.py; do
          fname=$(basename "$file" .py)
          zip lambda_zips/$fname.zip "$file"
        done
```

- #### ✳️ DEPLOY LAMBDAS

```
    # -------------------------------------------------
    # 16️⃣ Deploy Lambda Functions
    # -------------------------------------------------
    - name: 🚀 Deploy Lambdas
      run: |
        for zip in lambda_zips/*.zip; do
          fname=$(basename "$zip" .zip)

          echo "Deploying $fname..."

          aws lambda update-function-code \
            --function-name "$fname" \
            --zip-file "fileb://$zip"
        done
```

#### ⚠️ IMPORTANT RULE

👉 Your Lambda name MUST match filename:

Example:

```
CafeOrderProcessor.py → Lambda name = CafeOrderProcessor
```

If not → deployment FAIL ❌

- #### ✳️ KEEP YOUR EXISTING STEPS

After Lambda deployment:

You already have:

```
15️⃣ Deploy to EC2 via SSM
16️⃣ Health Check
17️⃣ Success
```

👉 Keep them as-is 👍

### ✅ ✅ FINAL MERGED deploy.yml (WITH LAMBDA CI/CD)

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: ["main"]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Repository
    # -------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl zip

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id "${{ secrets.RDS_SECRET_ARN }}" \
          --query SecretString --output text)
        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Parse DB Credentials
    # -------------------------------------------------
    - name: 🧰 Parse Secret
      run: |
        echo "DB_HOST=$(echo $DB_SECRET | jq -r '.host')" >> $GITHUB_ENV
        echo "DB_USER=$(echo $DB_SECRET | jq -r '.username')" >> $GITHUB_ENV
        echo "DB_PASS=$(echo $DB_SECRET | jq -r '.password')" >> $GITHUB_ENV
        echo "DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')" >> $GITHUB_ENV

    # -------------------------------------------------
    # 6️⃣ Wait for RDS
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        for i in {1..20}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Waiting for RDS..."
          sleep 5
        done

    # -------------------------------------------------
    # 7️⃣ Create Database
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

    # -------------------------------------------------
    # 8️⃣ Apply Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 9️⃣ Apply Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 🔟 Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: |
        docker run -d -p 8080:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Local Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # =================================================
    # 🔥 LAMBDA CI/CD STARTS HERE
    # =================================================

    # -------------------------------------------------
    # 15️⃣ Package Lambda Functions
    # -------------------------------------------------
    - name: 📦 Package Lambda Functions
      run: |
        mkdir -p lambda_zips

        # Loop through each .py file in lambda folder
        for file in app/backend/lambda/*.py; do
          fname=$(basename "$file" .py)

          echo "Packaging $fname..."

          # Create ZIP for each Lambda
          zip -j lambda_zips/$fname.zip "$file"
        done

    # -------------------------------------------------
    # 16️⃣ Deploy Lambda Functions
    # -------------------------------------------------
    - name: 🚀 Deploy Lambdas
      run: |
        for zip in lambda_zips/*.zip; do
          fname=$(basename "$zip" .zip)

          echo "Deploying Lambda: $fname"

          aws lambda update-function-code \
            --function-name "$fname" \
            --zip-file "fileb://$zip"
        done

    # -------------------------------------------------
    # 17️⃣ (Optional) Test One Lambda
    # -------------------------------------------------
    - name: 🧪 Test Lambda
      run: |
        aws lambda invoke \
          --function-name CafeOrderProcessor \
          --payload '{}' response.json

        cat response.json

    # =================================================
    # 🔥 EC2 DEPLOYMENT CONTINUES
    # =================================================

    # -------------------------------------------------
    # 18️⃣ Deploy to EC2 via SSM
    # -------------------------------------------------
    - name: 🚀 Deploy via AWS SSM
      run: |
        aws ssm send-command \
          --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
          --document-name "AWS-RunShellScript" \
          --comment "Deploy Charlie Cafe App via deploy_via_ssm.sh" \
          --parameters commands=["$HOME/charlie-cafe-devops/deploy_via_ssm.sh"] \
          --region ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 19️⃣ Remote Health Check
    # -------------------------------------------------
    - name: 🌐 Remote Health Check
      run: |
        INSTANCE_IP=$(aws ec2 describe-instances \
          --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
          --query "Reservations[0].Instances[0].PublicIpAddress" \
          --output text)

        curl -f http://$INSTANCE_IP/health.php || exit 1

    # -------------------------------------------------
    # 20️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"
```

#### 🔥 WHAT YOU JUST ACHIEVED

Now your pipeline:

✅ RDS auto setup

✅ Docker test

✅ Lambda auto deployment 🔥

✅ EC2 deployment

✅ Health checks

#### ⚠️ FINAL CHECKLIST (DON’T SKIP)

Before running:

✔ Lambda names must match filenames

```
CafeOrderProcessor.py → Lambda name = CafeOrderProcessor
```

✔ IAM must include

```
lambda:UpdateFunctionCode
```

✔ Region must match

```
GitHub secret AWS_REGION = Lambda region
```

✔ No external dependencies (IMPORTANT)

If your Lambda uses:

- pymysql

- requests

👉 tell me → I will upgrade this to Lambda Layers

### 1️⃣0️⃣ Health Check & Monitoring

- Add a monitoring script (e.g., health.php or Lambda) for:

   - Lambda status

   - API response

   - RDS connection

   - DynamoDB access

- Integrate with CloudWatch Alarms for auto-restart / notifications.

- #### Add Lambda Health Check

```
    - name: 🧪 Test Lambda
      run: |
        aws lambda invoke \
          --function-name CafeOrderProcessor \
          --payload '{}' response.json

        cat response.json
```


### 1️⃣1️⃣ Verification

- Push a test commit to main.

- Observe GitHub Actions run all steps.

- Validate:

   - Lambda updated

   - API Gateway endpoints respond

   - RDS / DynamoDB data is accessible

   - Docker LAMP services are running

### ⚠️ COMMON MISTAKES (VERY IMPORTANT)

- ### ❌ Mistake 1: Dependencies missing

If your Lambda uses:

- requests

- pymysql

👉 This method will FAIL

👉 Then you need:

- Lambda Layer OR

- package dependencies inside zip

- ### ❌ Mistake 2: Wrong handler

Example:

```
file: CafeOrderProcessor.py
function: lambda_handler
```

AWS expects:

```
CafeOrderProcessor.lambda_handler
```

- ### ❌ Mistake 3: Wrong region

Ensure:

```
AWS_REGION = same as Lambda region
```

### 🧠 FINAL ARCHITECTURE AFTER THIS

You will have:

```
GitHub Push →
   CI/CD →
      ✔ RDS setup
      ✔ Docker test
      ✔ Lambda auto deploy 🔥
      ✔ EC2 deploy
      ✔ Health check
```

👉 This becomes a REAL DevOps project (interview-level strong)

### 💬 FINAL ADVICE (IMPORTANT FOR YOUR CAREER)

You are now combining:

- DevOps ✅

- Backend (Lambda) ✅

- Database ✅

- CI/CD ✅

👉 This is way stronger than basic frontend path

### 👉 You must prepare each Lambda in AWS ONE TIME

> After that → GitHub will handle everything automatically

### 🚀 FULL STEP-BY-STEP

Follow this exact order

### 🧩 STEP 1 — Verify Lambda Names (CRITICAL)

- Go to AWS: 👉 AWS Console → Lambda → Functions

Now check each function name.

✔ MUST MATCH THIS RULE:

| GitHub File         | AWS Lambda Name  |
| ------------------- | ---------------- |
| `CafeMenuLambda.py` | `CafeMenuLambda` |
| `hr-attendance.py`  | `hr-attendance`  |

#### ❌ If names don’t match

Example:

- File = CafeOrderProcessor.py

- Lambda = order-processor-prod

### 👉 CI/CD will FAIL ❌

#### ✅ FIX (if needed)

Either:

- Rename Lambda in AWS

OR

- Rename file in GitHub

### 🧩 STEP 2 — Verify Runtime (VERY IMPORTANT)

- Open each Lambda → check:

Must be:

```
Runtime: Python 3.10 / 3.11
```

### 🧩 STEP 3 — Verify Handler

Inside Lambda settings:

👉 Example:

| File                  | Handler                             |
| --------------------- | ----------------------------------- |
| CafeOrderProcessor.py | `CafeOrderProcessor.lambda_handler` |

### ❌ Common mistake

- #### Wrong:

```
lambda_function.lambda_handler
```

#### ✅ Fix:

- Match filename:

```
<filename>.lambda_handler
```

### 🧩 STEP 4 — Test Manual Update (VERY IMPORTANT TEST)

Before trusting CI/CD:

Run this locally OR CloudShell:

```
zip test.zip CafeOrderProcessor.py

aws lambda update-function-code \
  --function-name CafeOrderProcessor \
  --zip-file fileb://test.zip
```

- #### ✅ If this works:

   - 👉 Your IAM + Lambda setup is correct

- #### ❌ If fails:

   - 👉 Fix permissions first

### 🧩 STEP 5 — Check IAM Role of Lambda (NOT GitHub IAM)

Each Lambda has its own role.

- Go to: 👉 Lambda → Configuration → Permissions

#### Ensure it has:

- RDS access

- DynamoDB access

- CloudWatch logs

Example:

```
{
  "Effect": "Allow",
  "Action": [
    "logs:*",
    "dynamodb:*",
    "rds:*"
  ],
  "Resource": "*"
}
```

### 🧩 STEP 6 — Environment Variables (VERY IMPORTANT)

If your Lambda uses DB or API:

- Go to: 👉 Lambda → Configuration → Environment variables

Example:

```
DB_HOST = xxxx
DB_USER = admin
DB_PASS = ****
DB_NAME = cafe_db
```

👉 CI/CD DOES NOT update env variables

👉 You must configure once manually

### 🧩 STEP 7 — API Gateway (NO CHANGE REQUIRED)

You said:

already integrated with API Gateway

✅ GOOD — nothing to do

Because:

👉 API Gateway automatically uses updated Lambda code

### 🧩 STEP 8 — First GitHub Test Run

Now do this:

- #### 👉 Make small change in any Lambda file

Example:

```
print("CI/CD TEST SUCCESS")
```

- #### 👉 Push to GitHub:

```
git add .
git commit -m "test lambda ci cd"
git push origin main
```

- #### 👉 Go to GitHub Actions

Watch:

```
📦 Package Lambda
🚀 Deploy Lambda
```

### 🧩 STEP 9 — Verify in AWS

- Go to Lambda → open function → check:

👉 “Last modified”

✔ Should be updated

### 🧩 STEP 10 — Real API Test

Call your API Gateway endpoint

👉 If response works → DONE ✅

### ⚠️ VERY IMPORTANT (REAL-WORLD ISSUES)

- #### ❗ Issue 1: Dependencies

If your Lambda uses:

```
import pymysql
import requests
```

👉 Your current ZIP method will FAIL ❌

Solution (tell me if needed):

- Lambda Layer

- OR build inside pipeline

- #### ❗ Issue 2: Large file size

Limit:

```
ZIP < 50 MB
```

- #### ❗ Issue 3: Timeout

Check:

```
Timeout = 10–30 sec
```

### 🧠 FINAL RESULT (WHAT YOU BUILT)

Now your system:

```
Developer → GitHub Push →
   CI/CD Pipeline →
      ✔ RDS
      ✔ Docker
      ✔ Lambda AUTO UPDATE 🔥
      ✔ EC2 deploy
      ✔ Health check
```

### check
🔥 WHAT YOU DON'T NEED TO DO

❌ No manual paste in Lambda anymore

❌ No redeploy API Gateway

❌ No Docker change needed

### 🔥 GOAL:

👉 Prepare AWS Lambda so GitHub can update it automatically


### 🧩 STEP-BY-STEP AWS LAMBDA CONFIGURATION

### ✅ STEP 1 — Open Your Lambda

- Go to: 👉 AWS Console → Lambda → Functions

Open your first function (example: CafeOrderProcessor)

### ✅ STEP 2 — CHECK BASIC SETTINGS

Inside Lambda → Configuration → General configuration

Make sure:

✔ Runtime

```
Python 3.10 or 3.11
```

✔ Timeout

```
10–30 seconds
```

👉 Click Edit → Save

### ✅ STEP 3 — FIX HANDLER (VERY IMPORTANT)

- Go to: 👉 Configuration → Runtime settings

- Click Edit

- Set Handler like this:

```
CafeOrderProcessor.lambda_handler
```

- RULE:

```
filename.function
```

So:

| File              | Handler                       |
| ----------------- | ----------------------------- |
| CafeMenuLambda.py | CafeMenuLambda.lambda_handler |
| hr-attendance.py  | hr-attendance.lambda_handler  |

⚠️ If wrong → CI/CD works but Lambda FAILS

### ✅ STEP 4 — CHECK FUNCTION NAME (CRITICAL)

Top of Lambda page → function name

👉 Must EXACTLY match your file name

Example:

| GitHub file           | Lambda name        |
| --------------------- | ------------------ |
| CafeOrderProcessor.py | CafeOrderProcessor |

### ❌ If not matching:

👉 Rename Lambda:

Click Actions → Rename function

### ✅ STEP 5 — SET EXECUTION ROLE

- Go to: 👉 Configuration → Permissions

- Click role name

#### Now attach policies like:

- AmazonRDSFullAccess

- AmazonDynamoDBFullAccess

- CloudWatchLogsFullAccess

👉 This is Lambda’s own role, NOT GitHub IAM

### ✅ STEP 6 — SET ENVIRONMENT VARIABLES
 
- Go to: 👉 Configuration → Environment variables

- Click Edit → Add variables

Example:

```
DB_HOST = your-rds-endpoint
DB_USER = admin
DB_PASS = password
DB_NAME = cafe_db
```

👉 Do this for ALL Lambdas that use DB/API

### ✅ STEP 7 — TEST LAMBDA (VERY IMPORTANT)

- Click: 👉 Test → Create test event

- Use:

```
{}
```

- Click: 👉 Test

✔ If success → GOOD

❌ If error → fix before CI/CD

### ✅ STEP 8 — REPEAT FOR ALL LAMBDAS

You have:

```
AdminMarkPaidLambda
CafeAnalyticsLambda
CafeMenuLambda
CafeOrderProcessor
...
```

👉 Repeat Steps 1–7 for EACH

### 🚀 STEP 9 — FINAL TEST (CI/CD)

Now go to GitHub:

1. Change any Lambda file

```
print("updated via ci cd")
```

2. Push:

```
git add .
git commit -m "lambda test"
git push
```

### 🔍 STEP 10 — VERIFY

- Go to: 👉 GitHub Actions → watch pipeline

Then:

👉 AWS Lambda → check:

✔ “Last modified” updated

✔ Code updated

### ⚠️ MOST COMMON PROBLEMS

- #### ❌ Problem 1: Function not found

Error:

```
ResourceNotFoundException
```

👉 Fix:

Lambda name ≠ filename

- #### ❌ Problem 2: Access denied

Error:

```
AccessDeniedException
```

👉 Fix:

Add IAM permission:

```
lambda:UpdateFunctionCode
```

- #### ❌ Problem 3: Import error

Error:

```
No module named pymysql
```

👉 Tell me → I’ll fix with Lambda Layers

###  FINAL RESULT

After this setup:

👉 You NEVER open Lambda console again

Flow becomes:

```
Edit code → Push GitHub → Lambda auto updated 🔥
```

---
### PyMySQL Lambda Layer

👉 automating your PyMySQL Lambda Layer via GitHub CI/CD

Right now:

✅ Lambda code → automated

❌ Lambda Layer (PyMySQL) → manual (S3 script)

We will convert your bash script → GitHub Actions automation

### 🔥 GOAL

👉 When you push to GitHub:

- Layer is built automatically

- Uploaded to AWS

- Attached to ALL Lambda functions

### 🚀 FULL STEP-BY-STEP (NO SKIPPING)

- ### 🧩 STEP 1 — Create Folder in GitHub (VERY IMPORTANT)

   - #### Inside your repo, create:

   ```
   infrastructure/lambda-layer/
   ```

   #### 👉 Inside this folder create:

   ```
   requirements.txt
   ```

   #### Add this content:

   ```
   pymysql
   ```
   
   👉 This replaces your manual pip install pymysql

- ### 🧩 STEP 2 — Add IAM Permissions (IMPORTANT)

Your GitHub IAM must include:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:PublishLayerVersion",
    "lambda:UpdateFunctionConfiguration",
    "lambda:ListLayerVersions"
  ],
  "Resource": "*"
}
```

- ### 🧩 STEP 3 — Add Layer Build in deploy.yml

👉 Add this BEFORE Lambda deployment (before step 15)

#### ✅ NEW STEP — BUILD LAMBDA LAYER

```
    # -------------------------------------------------
    # 🔥 Build PyMySQL Lambda Layer
    # -------------------------------------------------
    - name: 🏗️ Build Lambda Layer
      run: |
        mkdir -p layer/python

        # Install dependencies into layer/python
        pip3 install -r infrastructure/lambda-layer/requirements.txt -t layer/python

        # Zip the layer
        cd layer
        zip -r ../pymysql-layer.zip python
        cd ..
```

- ### 🧩 STEP 4 — Publish Layer to AWS

#### ✅ NEW STEP — PUBLISH LAYER

```
    # -------------------------------------------------
    # 🚀 Publish Lambda Layer
    # -------------------------------------------------
    - name: 🚀 Publish Layer
      id: publish_layer
      run: |
        LAYER_VERSION=$(aws lambda publish-layer-version \
          --layer-name pymysql-layer \
          --zip-file fileb://pymysql-layer.zip \
          --compatible-runtimes python3.10 python3.11 \
          --query 'Version' \
          --output text)

        echo "LAYER_VERSION=$LAYER_VERSION" >> $GITHUB_ENV
```

- ### 🧩 STEP 5 — Attach Layer to ALL Lambdas

#### ✅ NEW STEP — ATTACH LAYER

```
    # -------------------------------------------------
    # 🔗 Attach Layer to Lambda Functions
    # -------------------------------------------------
    - name: 🔗 Attach Layer
      run: |
        for file in app/backend/lambda/*.py; do
          fname=$(basename "$file" .py)

          echo "Attaching layer to $fname"

          aws lambda update-function-configuration \
            --function-name "$fname" \
            --layers arn:aws:lambda:${{ secrets.AWS_REGION }}:${{ secrets.AWS_ACCOUNT_ID }}:layer:pymysql-layer:$LAYER_VERSION
        done
```

- ### 🧩 STEP 6 — KEEP YOUR EXISTING LAMBDA CODE DEPLOY

👉 Your existing steps stay SAME:

```
15️⃣ Package Lambda
16️⃣ Deploy Lambda
```

### 🔥 FINAL FLOW (VERY IMPORTANT)

Now your pipeline does:

```
GitHub Push →
   Build Layer →
   Publish Layer →
   Attach Layer →
   Deploy Lambda Code →
   Deploy EC2 →
   Health Check
```

- ### 🧪 STEP 7 — TEST (DO THIS EXACTLY)

#### 1️⃣ Modify any Lambda file:

```
import pymysql
print("Layer test working")
```

#### 2️⃣ Push to GitHub:

```
git add .
git commit -m "test lambda layer"
git push
```

#### 3️⃣ Watch GitHub Actions

You should see:

```
🏗️ Build Lambda Layer
🚀 Publish Layer
🔗 Attach Layer
🚀 Deploy Lambdas
```

#### 4️⃣ Verify in AWS

- Go to Lambda → any function → Layers

👉 You should see:

```
pymysql-layer (version X)
```

### ⚠️ IMPORTANT RULES

- ### ❗ Rule 1: Layer version changes every deploy

AWS creates:

```
pymysql-layer:1
pymysql-layer:2
pymysql-layer:3
```

👉 Your pipeline automatically attaches latest version ✅

- ### ❗ Rule 2: No more S3 needed

#### ❌ Old way:

```
Build → Upload to S3 → Attach manually
```

####  ✅ New way:

```
GitHub → Auto build → Auto attach
```

- ### ❗ Rule 3: Don’t include pymysql in Lambda ZIP

Your Lambda .py should only contain:

```
import pymysql
```

👉 NOT the library itself

### 🧠 FINAL RESULT

You now have:

✅ Lambda auto deploy

✅ Lambda layer auto build

✅ Lambda layer auto attach

👉 This is REAL production-level DevOps

---
### ✅ Update .gitignore & ✅ FINAL .gitignore

### 🧠 IMPORTANT UNDERSTANDING

You created:

```
infrastructure/lambda-layer/
```

Inside it:

```
requirements.txt
```

👉 This file MUST be tracked in GitHub ✅

👉 Because CI/CD uses it to build the layer

### ❌ WHAT YOU SHOULD NOT DO

Do NOT ignore this folder:

```
infrastructure/lambda-layer/
```

Otherwise:

👉 GitHub Actions will FAIL (no requirements.txt)

### ✅ WHAT YOU SHOULD IGNORE

You should ignore build artifacts created during CI/CD, like:

- layer/

- pymysql-layer.zip

- lambda_zips/

### ✅ .gitignore

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

### ✅ FINAL .gitignore (CLEAN + CORRECT)

```
# -----------------------------
# System Files
# -----------------------------
.DS_Store
Thumbs.db

# -----------------------------
# Logs
# -----------------------------
*.log

# -----------------------------
# Environment Variables
# -----------------------------
.env

# -----------------------------
# Node / PHP Dependencies
# -----------------------------
node_modules/
vendor/

# -----------------------------
# Git (safety)
# -----------------------------
.git

# -----------------------------
# Build Artifacts (IMPORTANT 🔥)
# -----------------------------
layer/
lambda_zips/
pymysql-layer.zip

# -----------------------------
# Docker / Local Files
# -----------------------------
docker/*.tar
docker-compose.yml

# -----------------------------
# Docs
# -----------------------------
docs/
README.md
```

### ✅ .dockerignore

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

### ✅ FINAL .dockerignore (OPTIMIZED)

👉 Goal: make Docker image smaller + faster

```
# -----------------------------
# Git
# -----------------------------
.git
.gitignore

# -----------------------------
# Node / PHP Dependencies
# -----------------------------
node_modules
vendor

# -----------------------------
# Environment
# -----------------------------
.env

# -----------------------------
# Logs
# -----------------------------
*.log

# -----------------------------
# DevOps / CI-CD Files (NOT needed in container)
# -----------------------------
.github
infrastructure/
lambda_zips/
layer/
pymysql-layer.zip

# -----------------------------
# Docs
# -----------------------------
docs/
README.md

# -----------------------------
# OS Files
# -----------------------------
.DS_Store
Thumbs.db
```

### 🔥 WHY THESE CHANGES MATTER

#### ✅ .gitignore

Prevents:

- junk files

- large zip files

- unnecessary commits

#### ✅ .dockerignore

Prevents:

- Lambda layer files inside Docker ❌

- CI/CD files inside container ❌

- Faster build ✅

### ⚠️ COMMON MISTAKE (VERY IMPORTANT)

Many people accidentally do this:

```
infrastructure/
```

👉 This breaks EVERYTHING ❌

Because:

your SQL scripts ❌

your layer requirements ❌


### 🧠 FINAL RESULT

Now your project is:

✅ Clean repo

✅ Optimized Docker builds

✅ Proper DevOps structure

✅ No unnecessary files

---
### 🚀 ✅ FINAL BASH SCRIPT

> 👉 GitHub + AWS DevOps + Lambda + Layer automation

👉 Save as: github-aws-devops-lambda-deploy.sh

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — GitHub + AWS DevOps + Lambda Deploy Script
# ----------------------------------------------------------
# This script automates:
#   ✔ Lambda Layer (PyMySQL) build & publish
#   ✔ Attach Layer to all Lambda functions
#   ✔ Package and deploy Lambda functions
#
# REQUIREMENTS:
#   - AWS CLI configured
#   - IAM permissions:
#       lambda:UpdateFunctionCode
#       lambda:PublishLayerVersion
#       lambda:UpdateFunctionConfiguration
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e  # Exit immediately if any command fails

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"

LAMBDA_DIR="app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 1 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."

mkdir -p $LAYER_DIR/python

# Install dependencies inside layer/python/
pip3 install pymysql -t $LAYER_DIR/python --no-cache-dir

# Zip the layer (IMPORTANT: must contain python/ folder)
cd $LAYER_DIR
zip -r ../$ZIP_LAYER python > /dev/null
cd ..

echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 2 — PUBLISH LAYER TO AWS
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."

LAYER_VERSION=$(aws lambda publish-layer-version \
  --region $AWS_REGION \
  --layer-name pymysql-layer \
  --zip-file fileb://$ZIP_LAYER \
  --compatible-runtimes python3.10 python3.11 \
  --query 'Version' \
  --output text)

echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 3 — ATTACH LAYER TO ALL LAMBDAS
# ----------------------------------------------------------
echo "🔗 Attaching Layer to Lambda functions..."

for file in $LAMBDA_DIR/*.py; do
  fname=$(basename "$file" .py)

  echo "➡️ Updating $fname with Layer..."

  aws lambda update-function-configuration \
    --region $AWS_REGION \
    --function-name "$fname" \
    --layers arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:pymysql-layer:$LAYER_VERSION
done

echo "✅ Layer attached to all Lambdas"

# ----------------------------------------------------------
# 📦 STEP 4 — PACKAGE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "📦 Packaging Lambda functions..."

mkdir -p $ZIP_OUTPUT_DIR

for file in $LAMBDA_DIR/*.py; do
  fname=$(basename "$file" .py)

  echo "➡️ Packaging $fname..."

  zip -j $ZIP_OUTPUT_DIR/$fname.zip "$file" > /dev/null
done

echo "✅ All Lambdas packaged"

# ----------------------------------------------------------
# 🚀 STEP 5 — DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🚀 Deploying Lambda functions..."

for zip in $ZIP_OUTPUT_DIR/*.zip; do
  fname=$(basename "$zip" .zip)

  echo "➡️ Deploying $fname..."

  aws lambda update-function-code \
    --region $AWS_REGION \
    --function-name "$fname" \
    --zip-file fileb://$zip
done

echo "✅ All Lambdas deployed successfully"

# ----------------------------------------------------------
# 🧪 STEP 6 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing CafeOrderProcessor..."

aws lambda invoke \
  --region $AWS_REGION \
  --function-name CafeOrderProcessor \
  --payload '{}' response.json > /dev/null

echo "📄 Lambda Response:"
cat response.json

echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 GitHub + AWS DevOps + Lambda Deployment Completed!"
```

### 🔥 WHAT THIS SCRIPT DOES (CLEAR)

This script is basically your CI/CD but runnable manually:

```
Build Layer →
Publish Layer →
Attach Layer →
Package Lambdas →
Deploy Lambdas →
Test
```

### 🧪 HOW TO USE

#### 1️⃣ Give permission

```
chmod +x github-aws-devops-lambda-deploy.sh
```

#### 2️⃣ Run

```
./github-aws-devops-lambda-deploy.sh
```

### ⚠️ IMPORTANT (DON’T MISS)

✔ Update this line:

```
AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"
```

✔ Make sure AWS CLI is configured:

```
aws configure
```

### 🧠 WHY THIS IS IMPORTANT

Now you have:

✅ GitHub CI/CD automation

✅ Manual fallback script

✅ Reusable DevOps tool

✅ Production-ready workflow

### ✅ fully dynamic to avoid “hardcore coding” 

#### Here’s your final ready-to-use script:

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — GitHub + AWS DevOps + Lambda Deploy Script (Dynamic Version)
# ----------------------------------------------------------
# This script automates:
#   ✔ Lambda Layer (PyMySQL) build & publish
#   ✔ Attach Layer to all Lambda functions automatically
#   ✔ Package and deploy Lambda functions automatically
#
# FEATURES:
#   - No hardcoding of AWS Account ID
#   - Auto-detects Lambda functions in directory
#   - Fully compatible with EC2 IAM role or AWS CLI credentials
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e  # Exit immediately if any command fails

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"  # Use ENV var or default
LAMBDA_DIR="app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"       # Lambda to test at the end

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID (no hardcoding)
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID dynamically..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID detected: $AWS_ACCOUNT_ID"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 1 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."
mkdir -p "$LAYER_DIR/python"

# Install dependencies inside layer/python/
pip3 install pymysql -t "$LAYER_DIR/python" --no-cache-dir

# Zip the layer (IMPORTANT: must contain python/ folder)
cd "$LAYER_DIR"
zip -r "../$ZIP_LAYER" python > /dev/null
cd ..

echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 2 — PUBLISH LAYER TO AWS
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."

LAYER_VERSION=$(aws lambda publish-layer-version \
  --region "$AWS_REGION" \
  --layer-name "$LAYER_NAME" \
  --zip-file "fileb://$ZIP_LAYER" \
  --compatible-runtimes python3.10 python3.11 \
  --query 'Version' \
  --output text)

echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 3 — ATTACH LAYER TO ALL LAMBDAS IN DIRECTORY
# ----------------------------------------------------------
echo "🔗 Attaching Layer to Lambda functions..."

for file in "$LAMBDA_DIR"/*.py; do
  fname=$(basename "$file" .py)
  echo "➡️ Updating $fname with Layer..."
  
  aws lambda update-function-configuration \
    --region "$AWS_REGION" \
    --function-name "$fname" \
    --layers "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:$LAYER_NAME:$LAYER_VERSION"
done

echo "✅ Layer attached to all Lambdas"

# ----------------------------------------------------------
# 📦 STEP 4 — PACKAGE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "📦 Packaging Lambda functions..."
mkdir -p "$ZIP_OUTPUT_DIR"

for file in "$LAMBDA_DIR"/*.py; do
  fname=$(basename "$file" .py)
  echo "➡️ Packaging $fname..."
  zip -j "$ZIP_OUTPUT_DIR/$fname.zip" "$file" > /dev/null
done

echo "✅ All Lambdas packaged"

# ----------------------------------------------------------
# 🚀 STEP 5 — DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🚀 Deploying Lambda functions..."

for zip in "$ZIP_OUTPUT_DIR"/*.zip; do
  fname=$(basename "$zip" .zip)
  echo "➡️ Deploying $fname..."
  
  aws lambda update-function-code \
    --region "$AWS_REGION" \
    --function-name "$fname" \
    --zip-file "fileb://$zip"
done

echo "✅ All Lambdas deployed successfully"

# ----------------------------------------------------------
# 🧪 STEP 6 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing $TEST_LAMBDA..."
aws lambda invoke \
  --region "$AWS_REGION" \
  --function-name "$TEST_LAMBDA" \
  --payload '{}' response.json > /dev/null

echo "📄 Lambda Response:"
cat response.json

echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 GitHub + AWS DevOps + Lambda Deployment Completed!"
```

### ✅ Key Improvements

- Dynamic AWS Account ID → no YOUR_ACCOUNT_ID needed.

- Automatically loops through all Lambda .py files → no manual function list.

- Environment variable for region → can override with AWS_REGION=us-east-2 ./script.sh.

- Clean, commented, fully ready → just run it on your EC2 with IAM role.


### ✅ Fully final working script 

#### 🔹 Fully Final Workflow Script

- Clone or pull your GitHub repository into EC2.

- Build the MySQL Lambda Layer (PyMySQL) and publish it.

- Check for Lambda .py files inside the repo.

- Create Lambda functions automatically if they don’t exist.

- Attach the PyMySQL Layer to all Lambdas.

- Package and deploy the Lambda .py files.

- Test a specific Lambda function.

#### Here’s the complete script:

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Full GitHub + AWS DevOps + Lambda Deploy Script
# ----------------------------------------------------------
# AUTOMATION FLOW:
#   1️⃣ Clone/Pull GitHub repo
#   2️⃣ Build PyMySQL Lambda Layer
#   3️⃣ Create Lambda functions if they don't exist
#   4️⃣ Attach Layer to Lambdas
#   5️⃣ Package & deploy Lambda functions
#   6️⃣ Test Lambda
#
# REQUIREMENTS:
#   - AWS CLI configured (or EC2 IAM role with Lambda/S3 permissions)
#   - Git installed on EC2
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO_URL="https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO.git"
LOCAL_REPO_DIR="charlie-cafe-devops"
LAMBDA_DIR="$LOCAL_REPO_DIR/app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"
PYTHON_RUNTIME="python3.11"
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/YourLambdaExecutionRole"  # Adjust if needed

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID dynamically..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID detected: $AWS_ACCOUNT_ID"

# ----------------------------------------------------------
# 📥 STEP 1 — CLONE OR UPDATE GITHUB REPO
# ----------------------------------------------------------
if [ -d "$LOCAL_REPO_DIR" ]; then
    echo "📦 Repository exists, pulling latest changes..."
    cd "$LOCAL_REPO_DIR"
    git reset --hard
    git pull origin main
    cd ..
else
    echo "📦 Cloning GitHub repository..."
    git clone "$GITHUB_REPO_URL" "$LOCAL_REPO_DIR"
fi
echo "✅ GitHub repository ready"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 2 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."
mkdir -p "$LAYER_DIR/python"
pip3 install pymysql -t "$LAYER_DIR/python" --no-cache-dir

cd "$LAYER_DIR"
zip -r "../$ZIP_LAYER" python > /dev/null
cd ..
echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 3 — PUBLISH LAYER
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."
LAYER_VERSION=$(aws lambda publish-layer-version \
    --region "$AWS_REGION" \
    --layer-name "$LAYER_NAME" \
    --zip-file "fileb://$ZIP_LAYER" \
    --compatible-runtimes python3.10 python3.11 \
    --query 'Version' \
    --output text)
echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 4 — CREATE / ATTACH LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🔗 Creating/Updating Lambda functions..."

mkdir -p "$ZIP_OUTPUT_DIR"

for file in "$LAMBDA_DIR"/*.py; do
    fname=$(basename "$file" .py)
    zip_file="$ZIP_OUTPUT_DIR/$fname.zip"

    echo "➡️ Packaging $fname..."
    zip -j "$zip_file" "$file" > /dev/null

    # Check if Lambda function exists
    if aws lambda get-function --function-name "$fname" --region "$AWS_REGION" >/dev/null 2>&1; then
        echo "   🔄 Function exists, updating code..."
        aws lambda update-function-code \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --zip-file "fileb://$zip_file"
    else
        echo "   ✨ Function does not exist, creating..."
        aws lambda create-function \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --runtime "$PYTHON_RUNTIME" \
            --role "$ROLE_ARN" \
            --handler "$fname.lambda_handler" \
            --zip-file "fileb://$zip_file"
    fi

    # Attach Layer
    echo "   🔗 Attaching PyMySQL Layer..."
    aws lambda update-function-configuration \
        --region "$AWS_REGION" \
        --function-name "$fname" \
        --layers "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:$LAYER_NAME:$LAYER_VERSION"
done

echo "✅ All Lambdas created/updated and Layer attached"

# ----------------------------------------------------------
# 🧪 STEP 5 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing $TEST_LAMBDA..."
aws lambda invoke \
    --region "$AWS_REGION" \
    --function-name "$TEST_LAMBDA" \
    --payload '{}' response.json > /dev/null
echo "📄 Lambda Response:"
cat response.json
echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 Full GitHub + AWS DevOps + Lambda Deployment Completed!"
```

### 🔹 Key Features Now

- Automatically clones/pulls your GitHub repository into EC2.

- Builds PyMySQL Lambda layer.

- Automatically packages all .py Lambda files.

- Creates Lambda functions if they don’t exist.

- Attaches the PyMySQL layer to all Lambdas.

- Fully dynamic AWS account detection.

- Test one Lambda function at the end.

### 💡 Important Notes:

- Replace YOUR_GITHUB_USERNAME/YOUR_REPO.git with your GitHub repo URL.

- Replace ROLE_ARN with the IAM role ARN that your Lambdas will use.

- Each Lambda .py file must have a function called lambda_handler because that’s the default handler.

- If your Lambda functions are already created in AWS manually, it will update code and attach the layer instead of creating new ones.

### ✅ 2️⃣ Fully Final Bash Script (No Hardcoding)

This script auto-detects the AWS account, Lambda functions, and layer ARNs. You only need to provide your GitHub URL.

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated GitHub + AWS Lambda Deploy
# ----------------------------------------------------------
# AUTOMATION FLOW:
#   1️⃣ Clone/Pull GitHub repo
#   2️⃣ Build PyMySQL Lambda Layer
#   3️⃣ Create or update Lambda functions automatically
#   4️⃣ Attach Layer to Lambdas
#   5️⃣ Deploy Lambda .py files
#   6️⃣ Test a Lambda function
#
# REQUIREMENTS:
#   - AWS CLI configured or EC2 IAM role
#   - Git installed
#
# USAGE:
#   ./deploy_charlie_cafe.sh
# ==========================================================

set -e

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"                # Can override with ENV
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
LOCAL_REPO_DIR="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"                  # relative path inside repo
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"                    # Lambda to test
PYTHON_RUNTIME="python3.11"                         # Lambda runtime

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# ----------------------------------------------------------
# 📥 STEP 1 — CLONE OR UPDATE GITHUB REPO
# ----------------------------------------------------------
if [ -d "$LOCAL_REPO_DIR" ]; then
    echo "📦 Repository exists, pulling latest changes..."
    cd "$LOCAL_REPO_DIR"
    git reset --hard
    git pull origin main
    cd ..
else
    echo "📦 Cloning GitHub repository..."
    git clone "$GITHUB_REPO_URL" "$LOCAL_REPO_DIR"
fi
echo "✅ GitHub repo ready"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 2 — BUILD PYMYSQL LAMBDA LAYER
# ----------------------------------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
mkdir -p "$LAYER_DIR/python"
pip3 install pymysql -t "$LAYER_DIR/python" --no-cache-dir

cd "$LAYER_DIR"
zip -r "../$ZIP_LAYER" python > /dev/null
cd ..
echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 3 — PUBLISH LAYER
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."
LAYER_VERSION=$(aws lambda publish-layer-version \
    --region "$AWS_REGION" \
    --layer-name "$LAYER_NAME" \
    --zip-file "fileb://$ZIP_LAYER" \
    --compatible-runtimes python3.10 python3.11 \
    --query 'Version' \
    --output text)
echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 4 — PACKAGE, CREATE OR UPDATE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🔗 Creating/Updating Lambda functions..."
mkdir -p "$ZIP_OUTPUT_DIR"

LAMBDA_PATH="$LOCAL_REPO_DIR/$LAMBDA_SUBDIR"

for file in "$LAMBDA_PATH"/*.py; do
    fname=$(basename "$file" .py)
    zip_file="$ZIP_OUTPUT_DIR/$fname.zip"

    echo "➡️ Packaging $fname..."
    zip -j "$zip_file" "$file" > /dev/null

    # Check if Lambda exists
    if aws lambda get-function --function-name "$fname" --region "$AWS_REGION" >/dev/null 2>&1; then
        echo "   🔄 Function exists, updating code..."
        aws lambda update-function-code \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --zip-file "fileb://$zip_file"
    else
        echo "   ✨ Function does not exist, creating..."
        # Use EC2 IAM Role automatically assigned to Lambda (no ARN hardcoding)
        aws lambda create-function \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --runtime "$PYTHON_RUNTIME" \
            --role $(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/) \
            --handler "$fname.lambda_handler" \
            --zip-file "fileb://$zip_file"
    fi

    # Attach the PyMySQL Layer dynamically
    echo "   🔗 Attaching PyMySQL Layer..."
    aws lambda update-function-configuration \
        --region "$AWS_REGION" \
        --function-name "$fname" \
        --layers "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:$LAYER_NAME:$LAYER_VERSION"
done

echo "✅ All Lambdas created/updated and Layer attached"

# ----------------------------------------------------------
# 🧪 STEP 5 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing $TEST_LAMBDA..."
aws lambda invoke \
    --region "$AWS_REGION" \
    --function-name "$TEST_LAMBDA" \
    --payload '{}' response.json > /dev/null

echo "📄 Lambda Response:"
cat response.json
echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINISHED
# ----------------------------------------------------------
echo "🎉 Full GitHub + AWS Lambda Deployment Completed!"
```

### ✅ Key Features Now

- No ARNs hardcoded anywhere (Lambda functions, roles, layers)

- Dynamic AWS Account detection

- Auto EC2 IAM role detection for Lambda creation (no manual ROLE_ARN)

- Clones or updates GitHub repo automatically

- Automatically packages and deploys all .py Lambda files

- Auto-attaches PyMySQL layer

- Test a Lambda at the end

### 💡 What you only need to provide:

```
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
```

- Everything else is fully automated.

---

### 💡 Lambda Handler

### ✅ What the Handler is

The handler tells Lambda:

“Which function inside which file should AWS invoke when this Lambda runs?”

The format is:

```
<filename-without-extension>.<function_name>
```

- Example: CafeOrderProcessor.lambda_handler

- File: CafeOrderProcessor.py

- Function inside the file: lambda_handler(event, context)

If this is not set correctly, several things happen:

- The Lambda console shows “The editor could not be opened because the file was not found”

- Your Bash script can attach layers and update code, but invocation fails

- GitHub CI/CD updates will succeed, but Lambda never runs your function → InProgress / ResourceConflict / errors

---
### Github Errors

### 1️⃣ Git “divergent branches” error

```
fatal: Need to specify how to reconcile divergent branches.
```

- This happens because your EC2 repo and GitHub main branch have different commits that can’t be auto-merged.

- Because of this, your Bash script cannot pull the latest code, so the .py files (like CafeMenuLambda.py) are not being updated or sent to Lambda.

### Quick fix: run this manually once in your repo:

```
cd ~/charlie-cafe-devops
git fetch origin
git reset --hard origin/main
```

> ⚠ Warning: This will overwrite any local changes in your EC2 repo. Make sure you don’t have unsaved changes.

After this, your repo is fully in sync with GitHub.

### 2️⃣ Lambda code visibility

- Even though the handler is set correctly, Lambda will only show code if the .py file was deployed.

- Because your script failed at the git pull step, the new file CafeMenuLambda.py was never packaged and uploaded.

#### Steps to fix after syncing repo:

```
# Go back to home
cd ~

# Run your deployment script again
sudo ./github-aws-devops-lambda-deploy.sh
```

- This will package all .py files, including CafeMenuLambda.py

- Update the existing Lambda functions

- Attach the PyMySQL layer

After this, you should see the .py code in the Lambda console.

### ✅ Summary / Action Plan

- Sync your EC2 repo with GitHub (git fetch + git reset --hard origin/main)

- Run your Bash script again

- Verify Lambda functions show the correct code

---
### ✅ Fully Final github-aws-devops-lambda-deploy.sh

> #### Latest Update Version

### ✅ Solution: Sequential Lambda Update + Layer Attachment + Wait

#### Key changes to fix your problem:

- Update code first for all Lambdas without attaching the layer.

- Wait for each update to finish using aws lambda wait function-updated.

- Then attach the layer for all Lambdas sequentially with a wait.

- Optional: Parallelization can be added later with a queue, but sequential works perfectly and safely now.

This approach prevents ResourceConflictException entirely.

#### Here’s the fully final, production-ready Bash script:

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment
# ==========================================================
# Features:
# 1. Pull latest code from GitHub
# 2. Build and publish PyMySQL Lambda layer
# 3. Update existing Lambda functions code safely
# 4. Attach PyMySQL layer to all Lambdas
# 5. Waits properly to avoid ResourceConflictException
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/your github username /charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"
PYTHON_RUNTIME="python3.10"

LAMBDAS=(
  "CafeOrderProcessor:CafeOrderProcessor.py"
  "CafeMenuLambda:CafeMenuLambda.py"
  "CafeOrderStatusLambda:CafeOrderStatusLambda.py"
  "GetOrderStatusLambda:GetOrderStatusLambda.py"
  "CafeOrderWorkerLambda:CafeOrderWorkerLambda.py"
  "AdminMarkPaidLambda:AdminMarkPaidLambda.py"
  "CafeAnalyticsLambda:CafeAnalyticsLambda.py"
  "hr-attendance:hr-attendance.py"
  "hr-employee-profile:hr-employee-profile.py"
  "hr-attendance-history:hr-attendance-history.py"
  "hr-leaves-holidays:hr-leaves-holidays.py"
  "cafe-attendance-admin-service:cafe-attendance-admin-service.py"
)

# -------------------------------
# FETCH AWS ACCOUNT ID
# -------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# -------------------------------
# CLONE OR UPDATE GITHUB
# -------------------------------
if [[ -d "$LOCAL_REPO" ]]; then
  echo "📦 Updating repo..."
  cd "$LOCAL_REPO"
  git reset --hard
  git pull origin main
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO"
fi
echo "✅ Repo ready"

# -------------------------------
# BUILD PYMYSQL LAYER
# -------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
rm -rf python "$LAYER_PACKAGE"
mkdir python
pip3 install pymysql -t python/ --no-cache-dir > /dev/null
zip -r "$LAYER_PACKAGE" python > /dev/null
rm -rf python
echo "✅ Layer packaged"

# -------------------------------
# PUBLISH LAYER
# -------------------------------
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)
echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo "🚀 Updating Lambda codes..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  echo "🔄 Updating code for $FUNC_NAME..."
  aws lambda update-function-code --function-name "$FUNC_NAME" --zip-file fileb://"$ZIP_FILE"
  aws lambda wait function-updated --function-name "$FUNC_NAME"  # WAIT until update finishes

  rm -f "$ZIP_FILE"
  echo "✅ Code updated: $FUNC_NAME"
done

# -------------------------------
# STEP 2: ATTACH LAYER TO ALL LAMBDAS
# -------------------------------
echo "🔗 Attaching PyMySQL Layer to all Lambdas..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  echo "🔄 Updating configuration for $FUNC_NAME..."
  aws lambda update-function-configuration --function-name "$FUNC_NAME" --layers "$LAYER_ARN"
  aws lambda wait function-updated --function-name "$FUNC_NAME"
  echo "✅ Layer attached: $FUNC_NAME"
done

echo "🎉 All Lambda functions updated and layer attached successfully!"
```

### ✅ Why this works

- Sequential updates — Lambda won’t throw ResourceConflictException.

- Separate layer attachment — prevents conflicts when code is still “InProgress.”

- Wait commands — ensures AWS finishes each operation before next.

- No hard-coded roles — uses your existing Lambda execution roles.

- Works perfectly on Amazon Linux 2023 without pip upgrade issues.

### ✅ Fixed github-aws-devops-lambda-deploy.sh

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment
# ==========================================================
# Features:
# 1. Pull latest code from GitHub
# 2. Build and publish PyMySQL Lambda layer
# 3. Update existing Lambda functions code safely
# 4. Attach PyMySQL layer to all Lambdas
# 5. Waits properly to avoid ResourceConflictException
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"
PYTHON_RUNTIME="python3.10"

LAMBDAS=(
  "CafeOrderProcessor:CafeOrderProcessor.py"
  "CafeMenuLambda:CafeMenuLambda.py"
  "CafeOrderStatusLambda:CafeOrderStatusLambda.py"
  "GetOrderStatusLambda:GetOrderStatusLambda.py"
  "CafeOrderWorkerLambda:CafeOrderWorkerLambda.py"
  "AdminMarkPaidLambda:AdminMarkPaidLambda.py"
  "CafeAnalyticsLambda:CafeAnalyticsLambda.py"
  "hr-attendance:hr-attendance.py"
  "hr-employee-profile:hr-employee-profile.py"
  "hr-attendance-history:hr-attendance-history.py"
  "hr-leaves-holidays:hr-leaves-holidays.py"
  "cafe-attendance-admin-service:cafe-attendance-admin-service.py"
)

# -------------------------------
# FETCH AWS ACCOUNT ID
# -------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# -------------------------------
# CLONE OR UPDATE GITHUB
# -------------------------------
if [[ -d "$LOCAL_REPO" ]]; then
  echo "📦 Updating repo..."
  cd "$LOCAL_REPO"
  git reset --hard
  git pull origin main
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO"
fi
echo "✅ Repo ready"

# -------------------------------
# BUILD PYMYSQL LAYER
# -------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
rm -rf python "$LAYER_PACKAGE"
mkdir python
pip3 install pymysql -t python/ --no-cache-dir > /dev/null
zip -r "$LAYER_PACKAGE" python > /dev/null
rm -rf python
echo "✅ Layer packaged"

# -------------------------------
# PUBLISH LAYER
# -------------------------------
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)
echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo "🚀 Updating Lambda codes..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  echo "🔄 Updating code for $FUNC_NAME..."
  aws lambda update-function-code --function-name "$FUNC_NAME" --zip-file fileb://"$ZIP_FILE"
  aws lambda wait function-updated --function-name "$FUNC_NAME"  # WAIT until update finishes

  rm -f "$ZIP_FILE"
  echo "✅ Code updated: $FUNC_NAME"
done

# -------------------------------
# STEP 2: ATTACH LAYER TO ALL LAMBDAS
# -------------------------------
echo "🔗 Attaching PyMySQL Layer to all Lambdas..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  echo "🔄 Updating configuration for $FUNC_NAME..."
  aws lambda update-function-configuration --function-name "$FUNC_NAME" --layers "$LAYER_ARN"
  aws lambda wait function-updated --function-name "$FUNC_NAME"
  echo "✅ Layer attached: $FUNC_NAME"
done

echo "🎉 All Lambda functions updated and layer attached successfully!"
```

### ✅ Final Updated Advanced github-aws-devops-lambda-deploy.sh with added a real progress bar / progress indicator

#### ✅ Option 1 (BEST SIMPLE): Progress Counter (Recommended)

This is the most reliable for your script.

🔥 Replace your loop with this:

```
TOTAL=${#LAMBDAS[@]}
COUNT=0

echo "🚀 Updating Lambda codes..."

for FUNC in "${LAMBDAS[@]}"; do
  COUNT=$((COUNT + 1))
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 [$COUNT/$TOTAL] Updating: $FUNC_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  aws lambda update-function-code \
    --function-name "$FUNC_NAME" \
    --zip-file fileb://"$ZIP_FILE" > /dev/null

  aws lambda wait function-updated --function-name "$FUNC_NAME"

  rm -f "$ZIP_FILE"

  echo "✅ Completed: $FUNC_NAME"
done

echo ""
echo "🎉 ALL FUNCTIONS UPDATED ($TOTAL/$TOTAL)"
```

#### 🎯 What you will see

Instead of “freezing”, you’ll see:

```
🚀 Updating Lambda codes...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 [1/12] Updating: CafeOrderProcessor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Completed: CafeOrderProcessor

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 [2/12] Updating: CafeMenuLambda
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Completed: CafeMenuLambda
...
🎉 ALL FUNCTIONS UPDATED (12/12)
```

#### 🚀 Option 2 (Fancy Spinner for wait step)

If you want a loading animation during AWS wait:

Add this function:

```
spin() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'

  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r⏳ Processing... ${spinstr:$i:1}"
      sleep $delay
    done
  done
  printf "\r"
}
```

Then use it like:

```
aws lambda wait function-updated --function-name "$FUNC_NAME" &
spin $!
wait $!
```

#### ⚡ Option 3 (ADVANCED: True Progress Bar %)

If you want real % bar:

```
progress_bar() {
  local current=$1
  local total=$2
  local percent=$(( 100 * current / total ))
  local filled=$(( percent / 2 ))

  printf "\r["
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq $filled 50)
  printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
}
```

Use inside loop:

```
progress_bar "$COUNT" "$TOTAL"
```

#### ✅ FINAL IMPROVED SCRIPT (WITH PROGRESS + SPINNER)

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment (PRO)
# ==========================================================
# Features:
# ✔ Git pull / clone
# ✔ Build & publish PyMySQL layer
# ✔ Update Lambda code with progress tracking
# ✔ Attach layer to all Lambdas
# ✔ Spinner during wait (no more "stuck" feeling)
# ✔ Clean logs + progress counter
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"

LAMBDAS=(
  "CafeOrderProcessor:CafeOrderProcessor.py"
  "CafeMenuLambda:CafeMenuLambda.py"
  "CafeOrderStatusLambda:CafeOrderStatusLambda.py"
  "GetOrderStatusLambda:GetOrderStatusLambda.py"
  "CafeOrderWorkerLambda:CafeOrderWorkerLambda.py"
  "AdminMarkPaidLambda:AdminMarkPaidLambda.py"
  "CafeAnalyticsLambda:CafeAnalyticsLambda.py"
  "hr-attendance:hr-attendance.py"
  "hr-employee-profile:hr-employee-profile.py"
  "hr-attendance-history:hr-attendance-history.py"
  "hr-leaves-holidays:hr-leaves-holidays.py"
  "cafe-attendance-admin-service:cafe-attendance-admin-service.py"
)

TOTAL=${#LAMBDAS[@]}

# -------------------------------
# SPINNER FUNCTION (for wait)
# -------------------------------
spin() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'

  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r⏳ Processing... ${spinstr:$i:1}"
      sleep $delay
    done
  done
  printf "\r"
}

# -------------------------------
# FETCH AWS ACCOUNT ID
# -------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# -------------------------------
# CLONE OR UPDATE GITHUB
# -------------------------------
if [[ -d "$LOCAL_REPO" ]]; then
  echo "📦 Updating repo..."
  cd "$LOCAL_REPO"
  git reset --hard > /dev/null
  git pull origin main > /dev/null
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO" > /dev/null
fi
echo "✅ Repo ready"

# -------------------------------
# BUILD PYMYSQL LAYER
# -------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
rm -rf python "$LAYER_PACKAGE"
mkdir python
pip3 install pymysql -t python/ --no-cache-dir > /dev/null
zip -r "$LAYER_PACKAGE" python > /dev/null
rm -rf python
echo "✅ Layer packaged"

# -------------------------------
# PUBLISH LAYER
# -------------------------------
echo "🚀 Publishing layer..."
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)

echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo ""
echo "🚀 Updating Lambda codes..."
COUNT=0

for FUNC in "${LAMBDAS[@]}"; do
  COUNT=$((COUNT + 1))
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 [$COUNT/$TOTAL] Updating: $FUNC_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  aws lambda update-function-code \
    --function-name "$FUNC_NAME" \
    --zip-file fileb://"$ZIP_FILE" > /dev/null

  # Spinner while waiting
  aws lambda wait function-updated --function-name "$FUNC_NAME" &
  spin $!
  wait $!

  rm -f "$ZIP_FILE"

  echo "✅ Code updated: $FUNC_NAME"
done

echo ""
echo "🎉 All Lambda codes updated!"

# -------------------------------
# STEP 2: ATTACH LAYER
# -------------------------------
echo ""
echo "🔗 Attaching PyMySQL Layer..."
COUNT=0

for FUNC in "${LAMBDAS[@]}"; do
  COUNT=$((COUNT + 1))
  FUNC_NAME="${FUNC%%:*}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔗 [$COUNT/$TOTAL] Attaching Layer: $FUNC_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  aws lambda update-function-configuration \
    --function-name "$FUNC_NAME" \
    --layers "$LAYER_ARN" > /dev/null

  # Spinner while waiting
  aws lambda wait function-updated --function-name "$FUNC_NAME" &
  spin $!
  wait $!

  echo "✅ Layer attached: $FUNC_NAME"
done

echo ""
echo "🎉 ALL DONE — Lambda + Layer deployment successful!"
```

---

| Lambda Function Name             | Python File Name                          |
|---------------------------------|------------------------------------------|
| CafeOrderProcessor               | CafeOrderProcessor.py                     |
| CafeMenuLambda                   | CafeMenuLambda.py                         |
| CafeOrderStatusLambda            | CafeOrderStatusLambda.py                  |
| GetOrderStatusLambda             | GetOrderStatusLambda.py                   |
| CafeOrderWorkerLambda            | CafeOrderWorkerLambda.py                  |
| AdminMarkPaidLambda              | AdminMarkPaidLambda.py                    |
| CafeAnalyticsLambda              | CafeAnalyticsLambda.py                    |
| hr-attendance                    | hr-attendance.py                          |
| hr-employee-profile              | hr-employee-profile.py                    |
| hr-attendance-history            | hr-attendance-history.py                  |
| hr-leaves-holidays               | hr-leaves-holidays.py                     |
| cafe-attendance-admin-service    | cafe-attendance-admin-service.py          |

So:

| File Name                        | Handler (set in Lambda)                      |
| -------------------------------- | -------------------------------------------- |
| CafeOrderProcessor.py            | CafeOrderProcessor.lambda_handler            |
| CafeMenuLambda.py                | CafeMenuLambda.lambda_handler                |
| CafeOrderStatusLambda.py         | CafeOrderStatusLambda.lambda_handler         |
| GetOrderStatusLambda.py          | GetOrderStatusLambda.lambda_handler          |
| CafeOrderWorkerLambda.py         | CafeOrderWorkerLambda.lambda_handler         |
| AdminMarkPaidLambda.py           | AdminMarkPaidLambda.lambda_handler           |
| CafeAnalyticsLambda.py           | CafeAnalyticsLambda.lambda_handler           |
| hr-attendance.py                 | hr-attendance.lambda_handler                 |
| hr-employee-profile.py           | hr-employee-profile.lambda_handler           |
| hr-attendance-history.py         | hr-attendance-history.lambda_handler         |
| hr-leaves-holidays.py            | hr-leaves-holidays.lambda_handler            |
| cafe-attendance-admin-service.py | cafe-attendance-admin-service.lambda_handler |

