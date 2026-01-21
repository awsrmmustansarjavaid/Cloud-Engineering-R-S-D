# AWS ☕ Charlie CAFE — Bash Script

## ☕ Charlie CAFE 🌐 SECTION 1️⃣ AWS RDS DATABASE BASH Script

### PHASE 1️⃣ — Basic RDS CONFIGURATIONS

## Method 1️⃣ - ☕ AWS Café — RDS MySQL Setup Bash Script
> **📄 File name : ☕ AWS Café — RDS MySQL Setup Bash Script.sh **

```
sudo nano setup_cafe_rds.sh
```

#### ⚠️ Important Configuration Values NOTE (Before Running This Cafe RDS Setup Script)

> **You MUST replace the placeholder values below with your own AWS RDS credentials before executing this script.**

#### 🔧 Required Changes

> **Update the following variables in the script according to your AWS environment:**

#### AWS Region:

```bash
AWS_REGION="us-east-1"
```
- **Current value:** us-east-1

- **Action:** Replace with your actual AWS region

**👉 Replace with your actual AWS Region**

**Examples: eu-west-1, ap-south-1, us-west-2, sa-east-1**

- **Why:** Secrets Manager and RDS are region-specific

#### Secrets Manager ARN:

```
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"
```

- **Current value:** arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV

- **Action:** Replace with the real ARN of your target secret
- **How to find it:**
    - AWS Console → Secrets Manager → select your secret → copy the ARN

    - Must match the secret that contains host, username, password

- **Most critical value – wrong ARN = script cannot get credentials**

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 1️⃣ — COMPLETE & VERIFIED**  ✅ 
---
### PHASE 2️⃣ Cafe Order API + RDS Tests (API Gateway + rds-secret-test.sh)

### Method 1️⃣ Cafe Order API + RDS Tests 
> **📄 File name : ☕ AWS Café — RDS MySQL Setup Bash Script.sh **

#### 1️⃣ Create & edit file

```
sudo nano test-api-and-rds.sh
```

#### 2️⃣ Edit the Script and Add Your Details



