# Charlie Cafe - AWS DEVOPS Master Script

> 👉 One master script on EC2:

```
deploy_master.sh
```

Inside:

```
deploy_via_ssm.sh
charlie_cafe_devops-rds_setup_full.sh
github-aws-devops-lambda-deploy.sh
```

Then GitHub runs ONLY:

```
aws ssm send-command deploy_master.sh
```

### 🚀 FINAL VERDICT

✔ Your pipeline is now correct

✔ Your SSM is now production safe

✔ Your Docker build is optimized

✔ Your CI/CD is senior-level structure

### ✅ deploy_master.sh

Below is your FULL FINAL PRODUCTION-GRADE deploy_master.sh

It ensures:

✔ Script 1 MUST succeed before Script 2

✔ Script 2 MUST succeed before Script 3

✔ Stops immediately on any failure

✔ Logs clear progress

✔ Safe for CI/CD via SSM

✔ Easy debugging

✔ Production-style structure

### 🚀 ✅ FINAL deploy_master.sh

```
#!/bin/bash

# ============================================================
# ☕ CHARLIE CAFE — MASTER DEPLOYMENT ORCHESTRATOR
# ============================================================
#
# PURPOSE:
# This script runs ALL DevOps deployment scripts in strict order:
#
#   1️⃣ EC2 App Deployment (deploy_via_ssm.sh)
#   2️⃣ RDS Database Setup (charlie_cafe_devops-rds_setup_full.sh)
#   3️⃣ Lambda Deployment (github-aws-devops-lambda-deploy.sh)
#
# RULES:
# ✔ Each script must complete successfully before next starts
# ✔ If ANY script fails → STOP pipeline immediately
# ✔ Fully production-safe execution flow
#
# USAGE:
# Called from AWS SSM via GitHub Actions CI/CD pipeline
#
# ============================================================

set -euo pipefail   # 🚨 STRICT MODE (VERY IMPORTANT)

# ============================================================
# 🎨 COLORS FOR LOGGING
# ============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}======================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}======================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

print_step() {
  echo -e "${YELLOW}🚀 $1${NC}\n"
}

# ============================================================
# 📁 BASE PATH CONFIGURATION
# ============================================================
BASE_DIR="/home/ec2-user/charlie-cafe-devops"

EC2_SCRIPT="$BASE_DIR/deploy_via_ssm.sh"
RDS_SCRIPT="$BASE_DIR/charlie_cafe_devops-rds_setup_full.sh"
LAMBDA_SCRIPT="$BASE_DIR/github-aws-devops-lambda-deploy.sh"

print_header "☕ CHARLIE CAFE MASTER DEPLOYMENT STARTED"

# ============================================================
# 1️⃣ STEP 1 - EC2 DEPLOYMENT
# ============================================================
print_step "STEP 1: Running EC2 Deployment Script"

if [ ! -f "$EC2_SCRIPT" ]; then
  print_error "EC2 script not found: $EC2_SCRIPT"
  exit 1
fi

chmod +x "$EC2_SCRIPT"

bash "$EC2_SCRIPT"

print_success "STEP 1 COMPLETED: EC2 Deployment Successful"

# ============================================================
# 2️⃣ STEP 2 - RDS SETUP
# ============================================================
print_step "STEP 2: Running RDS Setup Script"

if [ ! -f "$RDS_SCRIPT" ]; then
  print_error "RDS script not found: $RDS_SCRIPT"
  exit 1
fi

chmod +x "$RDS_SCRIPT"

bash "$RDS_SCRIPT"

print_success "STEP 2 COMPLETED: RDS Setup Successful"

# ============================================================
# 3️⃣ STEP 3 - LAMBDA DEPLOYMENT
# ============================================================
print_step "STEP 3: Running Lambda Deployment Script"

if [ ! -f "$LAMBDA_SCRIPT" ]; then
  print_error "Lambda script not found: $LAMBDA_SCRIPT"
  exit 1
fi

chmod +x "$LAMBDA_SCRIPT"

bash "$LAMBDA_SCRIPT"

print_success "STEP 3 COMPLETED: Lambda Deployment Successful"

# ============================================================
# 🎉 FINAL SUCCESS
# ============================================================
print_header "☕ ALL DEPLOYMENTS COMPLETED SUCCESSFULLY"

echo -e "${GREEN}✔ EC2 Deployment Done${NC}"
echo -e "${GREEN}✔ RDS Setup Done${NC}"
echo -e "${GREEN}✔ Lambda Deployment Done${NC}"

echo -e "\n${GREEN}🚀 CHARLIE CAFE FULL SYSTEM IS NOW PRODUCTION READY!${NC}\n"
```

### ⚠️ WHY THIS IS PRODUCTION-GRADE

#### ✅ 1. STRICT FAILURE CONTROL

```
set -euo pipefail
```

👉 If ANY command fails → entire pipeline stops immediately

#### ✅ 2. SAFE FILE CHECKS

Each script is verified:

```
if [ ! -f "$SCRIPT" ]; then exit 1; fi
```

✔ prevents silent failures

#### ✅ 3. ORDER IS GUARANTEED

Execution flow:

```
EC2 → RDS → Lambda
```

No skipping possible.

#### ✅ 4. CLEAN LOGGING

You get clear stages:

```
🚀 STEP 1
🚀 STEP 2
🚀 STEP 3
```

### 🚀 HOW YOUR GITHUB ACTION WILL CALL IT

Your SSM command becomes:

```
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=InstanceIds,Values=YOUR_INSTANCE_ID" \
  --parameters commands=["bash /home/ec2-user/charlie-cafe-devops/deploy_master.sh"]
```

### ✅ FINAL VERDICT

✔ Your system is now real DevOps orchestration level

✔ Fully automated pipeline chain

✔ Safe execution order guaranteed

✔ Production-ready structure

---

