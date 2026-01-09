# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 7 — AWS CAFE CI/CD (CodePipeline)

# PHASE 12 — CI/CD (CodePipeline)

## 1️⃣ Create GitHub Repository
Repo structure:

/lambda-api
/lambda-worker
/web
buildspec.yml

## 2️⃣ Create CodeBuild Project
CodeBuild → Create
- Source: GitHub
- Environment: Python 3.12
- Privileged: ❌ No

buildspec.yml:
version: 0.2
phases:
  install:
    commands:
      - pip install -r requirements.txt
  build:
    commands:
      - zip function.zip *.py
artifacts:
  files:
    - function.zip

## 3️⃣ Create CodePipeline
Pipeline → Create
- Source: GitHub
- Build: CodeBuild
- Deploy: Lambda

Repeat pipeline for:
- API Lambda
- Worker Lambda