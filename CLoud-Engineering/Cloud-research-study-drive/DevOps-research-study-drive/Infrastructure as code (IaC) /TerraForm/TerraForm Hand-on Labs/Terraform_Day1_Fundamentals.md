# 🌍 Terraform Learning Journey

> **Author: Charlie

## Terraform Day 1 – Fundamentals & First Infrastructure (AWS)

## Goal
Learn Terraform basics, understand how it works, and create your first AWS resource using Infrastructure as Code.

---

## What is Terraform?
Terraform is an **Infrastructure as Code (IaC)** tool that allows you to define, provision, and manage cloud infrastructure using code.

**One-line definition:**
> Terraform lets you describe your infrastructure in code and safely create, update, or destroy it.

---

## Why Terraform?
- No manual AWS console clicks
- Repeatable and consistent environments
- Version-controlled infrastructure
- Safer changes using plan & apply

---

## Terraform Mental Model
```
You describe infrastructure
→ Terraform plans changes
→ Terraform applies changes
```

You define **WHAT** you want, not **HOW** to create it.

---

## Core Concepts
| Concept | Description |
|------|------------|
| Provider | Cloud platform (AWS) |
| Resource | Infrastructure object (EC2, S3) |
| State | Terraform’s memory |
| Plan | Preview of changes |
| Apply | Executes changes |

---

## How Terraform Works Internally
1. Read configuration files
2. Load provider plugins
3. Compare desired state vs actual state
4. Show execution plan
5. Apply changes
6. Update state file

---

## Lab 1: Install Terraform (Amazon Linux / RHEL)
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform -y
```

Verify installation:
```bash
terraform version
```

---

## Lab 2: Create Project Directory
```bash
mkdir terraform-day1
cd terraform-day1
```

---

## Lab 3: Create main.tf
```bash
nano main.tf
```

---

## Terraform Provider Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

---

## Lab 4: Initialize Terraform
```bash
terraform init
```

---

## Lab 5: Create S3 Bucket Resource
```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraform-day1-my-first-bucket-12345"
}
```

---

## Lab 6: Terraform Plan
```bash
terraform plan
```

---

## Lab 7: Terraform Apply
```bash
terraform apply
```
Type `yes` when prompted.

---

## Lab 8: Terraform State
Terraform creates a file called:
```
terraform.tfstate
```

This file tracks your infrastructure. Do NOT edit manually.

---

## Practice Tasks
1. Destroy resources:
```bash
terraform destroy
```

2. Change bucket name and run plan again

3. Create two S3 buckets using two resources

---

## Key Takeaways
- Terraform is declarative
- State file is critical
- Always run plan before apply
- Infrastructure = Code

---

## Day 2 Preview
- Variables
- Outputs
- Reusable configurations
- EC2 instance using Terraform
