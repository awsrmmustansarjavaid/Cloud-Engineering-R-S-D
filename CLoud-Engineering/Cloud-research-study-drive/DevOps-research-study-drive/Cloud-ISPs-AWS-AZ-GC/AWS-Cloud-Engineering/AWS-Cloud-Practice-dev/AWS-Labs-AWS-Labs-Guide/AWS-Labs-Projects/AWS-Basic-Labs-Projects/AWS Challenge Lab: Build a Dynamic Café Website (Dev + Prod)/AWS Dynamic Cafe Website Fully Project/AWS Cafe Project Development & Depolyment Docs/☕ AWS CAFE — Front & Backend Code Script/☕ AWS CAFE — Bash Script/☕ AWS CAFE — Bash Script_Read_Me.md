# AWS ☕ Charlie CAFE — Bash Script

## ☕ Charlie CAFE 🌐 SECTION 1️⃣ AWS RDS DATABASE BASH Script

### PHASE 1️⃣ — Basic RDS CONFIGURATIONS

### 1️⃣ Create index.php

```
sudo nano /var/www/html/index.php
```

####  2️⃣ Make executable

```
sudo chmod +x lamp-verify.sh
```

####  3️⃣ Run (best as root/sudo)

```
sudo ./lamp-verify.sh
```

### 4️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

## Method 1️⃣ - ☕ AWS Café — RDS MySQL Setup Bash Script
> **📄 File name : ☕ AWS Café — RDS MySQL Setup Bash Script.sh**

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
> **📄 File name : ☕ AWS Café — API Gateway + rds-secret-test.sh**

#### 1️⃣ Create & edit file

```
sudo nano test-api-and-rds.sh
```

#### 2️⃣ Edit the Script and Add Your Details



#### 3️⃣ Make the script executable

```
sudo chmod +x test-api-and-rds.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./test-api-and-rds.sh
```

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 
---
### Method 2️⃣ RDS Quick Test Script — One-command style
> **📄 File name : ☕ AWS Café — API Gateway + rds-secret-test.sh**

#### 📢 Note: RDS Quick TestRDS Test Script using Secrets Manager

#### 1️⃣ IAM role

- The EC2 instance must have an IAM role attached with permission to call secretsmanager:GetSecretValue for your specific secret

- Recommended minimal policy example:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:your-region:your-account:secret:your-secret-name-*"
    }
  ]
}
```

#### 2️⃣ Install JSON processor

Install jq (JSON processor) — very common & small tool:

#### 1️⃣ Amazon Linux 2023

```
sudo dnf install -y jq
```

#### 2️⃣ older Amazon Linux 2

```
sudo yum install -y jq 
```

#### 3️⃣ RDS Test Script using Secrets Manager

#### 📢 Quick Usage

#### 1️⃣ Create & edit

```
sudo nano rds-secret-test.sh
```

#### 2️⃣ Paste script, change only SECRET_NAME and RDS_DB

##### Save as rds-secret-test.sh

#### 3️⃣ Make the script executable

```
sudo chmod +x rds-secret-test.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./rds-secret-test.sh
```

#### Common Secret JSON structures (choose correct jq paths)

| Secret format (what you see in console)                  | jq path for host | jq path for username | jq path for password |
|----------------------------------------------------------|------------------|----------------------|----------------------|
| `{"host":"...","username":"...","password":"..."}`       | `.host`          | `.username`          | `.password`          |
| `{"endpoint":"...","user":"...","pwd":"..."}`            | `.endpoint`      | `.user`              | `.pwd`               |
| RDS auto-generated rotation format                       | `.host`          | `.username`          | `.password`          |

- Adjust the three jq -r lines if your secret has different key names.

> **🟢 Method 2️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 2️⃣ — COMPLETE & VERIFIED**  ✅ 
---
### PHASE 3️⃣ — PyMySQL Lambda Layer

### Method 1️⃣ - PyMySQL Lambda Layer

#### 2️⃣ How to create, give permission, and run the script on EC2

#### 1️⃣ Create the file

```
nano pymysql-layer.sh
```

→ paste the script above

→ press Ctrl + O → Enter (save)

→ Ctrl + X (exit)


#### 2️⃣ Give execute permission

```
sudo chmod +x pymysql-layer.sh
```

#### 3️⃣ Run it

```
sudo ./pymysql-layer.sh
```

> **After it finishes → you will see pymysql-layer.zip in the current folder (or in ./lambda-layer/ if you cd'ed manually).**
> **You can now upload it to S3 using AWS console (or aws s3 cp if you have AWS CLI configured on the EC2).**

**✔️ Good luck with your Lambda + pymysql setup!**

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 3️⃣ — COMPLETE & VERIFIED**  ✅ 
---

