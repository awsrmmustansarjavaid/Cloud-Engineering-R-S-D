# AWS Secrets Manager – Complete Beginner to Advanced Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Why Secrets Manager?](#why-secrets-manager)
3. [Core Concepts](#core-concepts)
4. [Secrets Manager Features](#secrets-manager-features)
5. [Pricing](#pricing)
6. [Basic Hands-On Lab](#basic-hands-on-lab)
7. [Advanced Usage](#advanced-usage)
8. [Integrations](#integrations)
9. [Security Best Practices](#security-best-practices)
10. [Common Errors & Troubleshooting](#common-errors--troubleshooting)
11. [Automation with CLI, SDK, and Terraform](#automation-with-cli-sdk-and-terraform)
12. [Use Cases in Real World](#use-cases-in-real-world)
13. [Summary](#summary)

---

## Introduction

AWS Secrets Manager is a **fully managed service** that helps you **securely store, rotate, and retrieve secrets** such as:

* Database credentials
* API keys
* SSH keys
* OAuth tokens

It eliminates hardcoding secrets in your applications and helps meet security compliance requirements.

---

## Why Secrets Manager?

Before Secrets Manager:

* Developers stored credentials in plain text (risk of leaks)
* Manual rotation of passwords or keys
* Complex access control

Benefits of Secrets Manager:

* Centralized secret storage
* Automatic rotation for supported services
* Fine-grained access control with IAM
* Audit logging via AWS CloudTrail
* Encryption at rest using AWS KMS

---

## Core Concepts

1. **Secret** – The key-value pair storing sensitive data.
2. **Secret Name** – Unique name to identify the secret.
3. **Secret Value** – Actual credentials, password, or API key.
4. **Secret Version** – Every time a secret changes, Secrets Manager creates a new version.
5. **Secret Rotation** – Automated process to change the secret periodically.
6. **KMS Key** – Encryption key used to encrypt the secret.
7. **Resource Policy** – IAM-based policies controlling who can access the secret.

---

## Secrets Manager Features

1. **Secret Storage & Retrieval**

   * Supports JSON-based key-value storage.
   * Retrieve secrets via AWS console, CLI, SDKs, or environment variables.

2. **Automatic Rotation**

   * Integrates with RDS, Redshift, and DocumentDB.
   * Use Lambda functions to rotate custom secrets.

3. **Access Control**

   * IAM policies & resource-based policies.
   * Grant least-privilege access.

4. **Audit & Logging**

   * Logs all API calls in CloudTrail.

5. **Encryption**

   * Secrets are encrypted at rest using AWS KMS.
   * Supports custom KMS keys.

---

## Pricing

* Charged **per secret per month**.
* Additional costs for **API calls** and **KMS encryption requests**.
* Free tier available with limited usage.
* Good to estimate cost using AWS pricing calculator.

---

## Basic Hands-On Lab

### Step 1: Create a Secret

1. Go to **AWS Secrets Manager Console**.
2. Click **Store a new secret**.
3. Select **Other type of secret**.
4. Enter key-value pairs:

```text
username: admin
password: MySecurePassword123!
```

5. Choose **KMS key** (default or custom).
6. Name the secret: `MyAppSecret`.
7. Click **Next**, skip rotation for now.
8. Review and **store** the secret.

### Step 2: Retrieve a Secret

* Using AWS Console:

  1. Open secret `MyAppSecret`.
  2. Click **Retrieve secret value**.

* Using AWS CLI:

```bash
aws secretsmanager get-secret-value --secret-id MyAppSecret
```

### Step 3: Rotate Secret Manually

1. Click secret → **Rotation** → **Enable rotation**.
2. Choose **Create a new Lambda function** for rotation.
3. Configure rotation interval (e.g., 30 days).

---

## Advanced Usage

### JSON Secrets

Store multiple credentials in one secret:

```json
{
  "db_username": "admin",
  "db_password": "MySecurePassword123!",
  "api_key": "ABCD-1234-XYZ"
}
```

### Access Secret Programmatically

**Python (Boto3 example):**

```python
import boto3
import json

client = boto3.client('secretsmanager')

response = client.get_secret_value(SecretId='MyAppSecret')
secret = json.loads(response['SecretString'])

print(secret['db_username'])
print(secret['db_password'])
```

**Node.js Example:**

```javascript
const AWS = require('aws-sdk');
const client = new AWS.SecretsManager();

client.getSecretValue({ SecretId: 'MyAppSecret' }, (err, data) => {
    if (err) console.error(err);
    else console.log(JSON.parse(data.SecretString));
});
```

---

## Integrations

1. **RDS & Redshift** – Automatic credential rotation.
2. **Lambda** – Retrieve secrets dynamically during execution.
3. **ECS / EKS** – Inject secrets as environment variables.
4. **CodeBuild / CodePipeline** – Securely access secrets during CI/CD.

---

## Security Best Practices

* Use **least-privilege IAM policies**.
* Enable **automatic rotation**.
* Avoid embedding secrets in code or config files.
* Enable **CloudTrail logging**.
* Use **Custom KMS keys** for added control.

---

## Common Errors & Troubleshooting

1. **AccessDeniedException** → Fix IAM policy or resource policy.
2. **ResourceNotFoundException** → Secret name mismatch.
3. **InvalidRequestException** → Check secret format or rotation Lambda.
4. **DecryptionFailure** → Verify KMS key permissions.

---

## Automation with CLI, SDK, and Terraform

### CLI Commands

* Create secret:

```bash
aws secretsmanager create-secret --name MyAppSecret --secret-string '{"username":"admin","password":"pass123"}'
```

* List secrets:

```bash
aws secretsmanager list-secrets
```

* Update secret:

```bash
aws secretsmanager update-secret --secret-id MyAppSecret --secret-string '{"username":"admin","password":"NewPass123!"}'
```

### Terraform Example

```hcl
resource "aws_secretsmanager_secret" "mysecret" {
  name = "MyAppSecret"
}

resource "aws_secretsmanager_secret_version" "mysecret_version" {
  secret_id     = aws_secretsmanager_secret.mysecret.id
  secret_string = jsonencode({
    username = "admin"
    password = "MySecurePassword123!"
  })
}
```

---

## Use Cases in Real World

* Rotating DB credentials for RDS automatically.
* Storing third-party API keys securely.
* Providing secrets to CI/CD pipelines without hardcoding.
* Using Secrets Manager with Lambda for serverless apps.

---

## Summary

AWS Secrets Manager is essential for:

* Secure credential management
* Automatic rotation
* Centralized secret storage with audit logging

**Key Learning Path:**

1. Learn basic secret storage & retrieval.
2. Learn automatic rotation.
3. Programmatic access via CLI & SDK.
4. Advanced integration with AWS services (RDS, Lambda, ECS).
5. Apply security best practices & compliance.
