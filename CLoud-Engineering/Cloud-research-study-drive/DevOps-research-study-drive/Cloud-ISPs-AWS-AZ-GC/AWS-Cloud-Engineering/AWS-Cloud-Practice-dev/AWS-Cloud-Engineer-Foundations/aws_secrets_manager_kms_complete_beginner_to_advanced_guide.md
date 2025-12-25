# 🔐 AWS Secrets Manager & AWS KMS
## Complete Beginner → Advanced Guide with Hands‑On Labs

> **Trainer Mindset:** This guide is written as if you are starting from *zero*, but it will slowly take you to an **intermediate–advanced real‑world AWS skill level**. Read concepts first, then do labs. Do **not skip labs**.

---

# 📌 PART 1: FOUNDATIONS (VERY IMPORTANT)

## 1. Why Secrets & Encryption Matter in Cloud

In cloud environments:
- Applications need **passwords, API keys, DB credentials**
- Data must be **encrypted** to prevent breaches
- Hard‑coding secrets in code or EC2 is **dangerous**

AWS solves this using:
- **AWS Secrets Manager** → manages secrets securely
- **AWS KMS (Key Management Service)** → manages encryption keys

---

## 2. What Is AWS Secrets Manager?

AWS Secrets Manager is a **fully managed service** to:
- Store secrets securely
- Rotate secrets automatically
- Control access via IAM
- Retrieve secrets programmatically

### Examples of Secrets
- Database username/password
- API tokens
- OAuth secrets
- SMTP credentials

### What Secrets Manager Is NOT
- ❌ Not a password manager for humans
- ❌ Not free‑text storage
- ❌ Not for large files

---

## 3. What Is AWS KMS?

AWS Key Management Service (KMS) is used to:
- Create and manage **encryption keys**
- Encrypt & decrypt data
- Integrate with AWS services automatically

### Key Idea (Very Important)
> **Secrets Manager stores secrets, KMS encrypts them**

Secrets Manager **uses KMS behind the scenes**.

---

# 📌 PART 2: AWS KMS – DEEP CONCEPTS

## 4. Encryption Basics (Must Understand)

### Encryption at Rest
- Data stored encrypted
- Example: S3, EBS, RDS

### Encryption in Transit
- Data encrypted while moving
- Example: HTTPS, TLS

### Symmetric vs Asymmetric Keys

| Type | Usage |
|----|----|
| Symmetric | Same key encrypt/decrypt (MOST USED) |
| Asymmetric | Public/Private keys |

AWS KMS mostly uses **symmetric keys**.

---

## 5. KMS Core Components

### 5.1 Customer Managed Key (CMK)
Now called **KMS Key**

Types:
- AWS managed key (aws/s3, aws/rds)
- Customer managed key (YOU control)

### 5.2 Key Material
- Actual cryptographic material
- Never exposed outside KMS

### 5.3 Key Policy
- Resource‑based policy
- Controls who can use the key

---

## 6. KMS Permissions Model

KMS access requires **BOTH**:
1. IAM Policy
2. KMS Key Policy

If one denies → access fails ❌

---

## 7. KMS Key States

- Enabled
- Disabled
- Pending deletion
- Deleted (after waiting period)

Minimum deletion wait time: **7 days**

---

# 📌 PART 3: AWS SECRETS MANAGER – DEEP CONCEPTS

## 8. How Secrets Manager Works Internally

1. Secret stored
2. Encrypted using KMS key
3. Access controlled via IAM
4. Retrieved via API/CLI/SDK

---

## 9. Secret Rotation

### What Is Rotation?
Automatically changes credentials periodically

### Supported Services
- Amazon RDS
- Amazon Aurora
- Custom Lambda rotation

Rotation uses **AWS Lambda**.

---

## 10. Secrets Manager vs Parameter Store

| Feature | Secrets Manager | SSM Parameter Store |
|------|------|------|
| Encryption | Yes | Yes |
| Rotation | Yes | Limited |
| Cost | Paid | Free tier |
| Best for | Passwords | Config values |

---

# 📌 PART 4: HANDS‑ON LABS (BEGINNER → ADVANCED)

---

## 🔬 LAB 1: Create a KMS Customer Managed Key (Beginner)

### Objective
Create your own encryption key

### Steps
1. Open AWS Console
2. Go to **KMS → Customer managed keys**
3. Create key
4. Type: Symmetric
5. Usage: Encrypt & decrypt
6. Alias: `my-app-key`
7. Assign admin IAM user
8. Finish

### Verify
- Key status = Enabled

---

## 🔬 LAB 2: Encrypt & Decrypt Using KMS (CLI)

```bash
aws kms encrypt \
  --key-id alias/my-app-key \
  --plaintext "HelloAWS" \
  --output text \
  --query CiphertextBlob
```

```bash
aws kms decrypt \
  --ciphertext-blob fileb://ciphertext.txt \
  --output text \
  --query Plaintext | base64 --decode
```

---

## 🔬 LAB 3: Create Secret in Secrets Manager (Beginner)

### Objective
Store DB credentials securely

### Steps
1. Go to **Secrets Manager**
2. Store new secret
3. Type: Other type of secret
4. Key/Value:
   - username: admin
   - password: StrongPass123
5. Encryption key: `my-app-key`
6. Secret name: `my/db/credentials`
7. Create

---

## 🔬 LAB 4: Access Secret via AWS CLI

```bash
aws secretsmanager get-secret-value \
  --secret-id my/db/credentials
```

---

## 🔬 LAB 5: Use Secret in EC2 Application

### Steps
1. Create IAM Role
2. Attach policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
```

3. Attach role to EC2
4. Fetch secret from app

---

## 🔬 LAB 6: Enable Automatic Rotation (Intermediate)

### Steps
1. Open secret
2. Enable rotation
3. Choose RDS
4. Rotation interval: 30 days
5. Create Lambda automatically

---

## 🔬 LAB 7: Secure S3 Using KMS (Advanced)

### Objective
Encrypt S3 using customer key

1. Open S3
2. Bucket → Properties
3. Default encryption
4. SSE‑KMS
5. Select `my-app-key`

---

## 🔬 LAB 8: Secrets + Lambda + KMS (Advanced)

### Flow
Lambda → Secrets Manager → KMS → Encrypted Secret

### IAM Policy for Lambda
```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue",
    "kms:Decrypt"
  ],
  "Resource": "*"
}
```

---

# 📌 PART 5: REAL‑WORLD BEST PRACTICES

## 11. Security Best Practices

- Never hardcode secrets
- Use IAM roles, not IAM users
- Rotate secrets regularly
- Use customer‑managed KMS keys
- Enable CloudTrail logging

---

## 12. Common Mistakes

❌ Using wildcard `*` in KMS policy
❌ Deleting KMS key accidentally
❌ Storing secrets in EC2 user data

---

# 📌 PART 6: LEARNING PATH (WHAT TO DO NEXT)

✅ Combine with:
- RDS
- Lambda
- ECS
- EKS
- CI/CD pipelines

✅ Next labs I recommend:
- Secrets Manager + RDS MySQL
- KMS + EBS encryption
- Secrets rotation with custom Lambda

---

# 🎯 FINAL TRAINER ADVICE

> **Mastering Secrets Manager & KMS makes you a REAL cloud engineer, not just a console user.**

Move slowly. Practice labs. Break things. Fix them.

---

📄 **How to Download**
- Copy this content
- Save as: `aws-secrets-manager-kms-guide.md`

If you want, I can:
- Add architecture diagrams
- Convert this into PDF
- Create a mini project using EC2 + RDS + Secrets + KMS

