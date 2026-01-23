# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 7 — AWS CAFE CI/CD (CodePipeline)

### 🎯 Goal of This Section (Read First)

#### Whenever you push code to GitHub, AWS should:

1️⃣ Automatically build your Lambda code

2️⃣ Package it

3️⃣ Deploy it to Lambda

4️⃣ Without manual ZIP uploads

This is real-world DevOps used in production.

### 🧠 FINAL ARCHITECTURE (MENTAL MODEL)

```
GitHub (Code Push)
      ↓
CodePipeline
      ↓
CodeBuild (zip code)
      ↓
AWS Lambda (deploy)
```



# PHASE 1 — CI/CD (CodePipeline)

## 1️⃣ Create GitHub Repository

### 1.1 Create Repository

- Go to GitHub

- Click New Repository

- Name it:

```
aws-cafe-project
```

- Visibility: Private or Public

- Click Create

### 1.2 Repository Folder Structure (MUST MATCH)

#### Inside your repo, create this exact structure:

```
aws-cafe-project/
│
├── lambda-api/
│   ├── app.py
│   ├── requirements.txt
│
├── lambda-worker/
│   ├── worker.py
│   ├── requirements.txt
│
├── buildspec.yml
```

### 1.3 Example Files (IMPORTANT)

#### lambda-api/app.py

```
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "API Lambda Deployed Successfully"
    }
```

#### lambda-api/requirements.txt

```
pymysql
```

#### lambda-worker/worker.py

```
def lambda_handler(event, context):
    print("Worker Lambda running")
```

#### lambda-worker/requirements.txt

```

```



## 2️⃣  — CREATE IAM ROLE FOR CODEBUILD (SECURITY)

### 2.1 Go to IAM → Roles → Create role

- Trusted entity: AWS service

- Use case: CodeBuild

- Click Next

### 2.2 Attach Policies

#### Attach these 3 policies:

✅ AWSCodeBuildDeveloperAccess

✅ AWSLambda_FullAccess

✅ AmazonS3FullAccess

  #### 🔐 This allows CodeBuild to:

  - Build code

  - Store artifacts

  - Update Lambda

Click Create role

#### 📌 Name:

```
CodeBuildCafeRole
```

## 3️⃣  — CREATE CODEBUILD PROJECT

### 3.1 Open CodeBuild → Create build project

#### Basic Info

| Field        | Value            |
| ------------ | ---------------- |
| Project name | `cafe-api-build` |
| Description  | Build Lambda API |


#### Source Section

| Field           | Value     |
| --------------- | --------- |
| Source provider | GitHub    |
| Repository      | Your repo |
| Branch          | main      |

Authorize GitHub when asked ✅

#### Environment Section

| Setting           | Value               |
| ----------------- | ------------------- |
| Environment image | Managed             |
| OS                | Amazon Linux        |
| Runtime           | Python              |
| Version           | **3.12**            |
| Privileged        | ❌ Disabled          |
| Service role      | `CodeBuildCafeRole` |

#### Buildspec

Choose:

```
Use a buildspec file
```

File name:

```
buildspec.yml
```

### 3.2 FINAL buildspec.yml (ROOT of repo)

```
version: 0.2

phases:
  install:
    commands:
      - cd lambda-api
      - pip install -r requirements.txt -t .

  build:
    commands:
      - zip -r function.zip .

artifacts:
  files:
    - lambda-api/function.zip
```

**⚠️ This file MUST be in repo root**

## 4️⃣ - CREATE API LAMBDA FUNCTION (ONE TIME)

### 4.1 Lambda → Create function

| Field       | Value             |
| ----------- | ----------------- |
| Name        | `cafe-api-lambda` |
| Runtime     | Python 3.12       |
| Permissions | Default           |

**⚠️ Do NOT upload code manually**


## 5️⃣ - CREATE CODEPIPELINE (MAIN PART)

### 5.1 Go to CodePipeline → Create pipeline

#### Pipeline settings

| Field        | Value               |
| ------------ | ------------------- |
| Name         | `cafe-api-pipeline` |
| Service role | New role            |

### 5.2 Source Stage

| Field            | Value              |
| ---------------- | ------------------ |
| Source provider  | GitHub (Version 2) |
| Repo             | aws-cafe-project   |
| Branch           | main               |
| Change detection | Automatic          |

### 5.3 Build Stage

| Field          | Value            |
| -------------- | ---------------- |
| Build provider | CodeBuild        |
| Project        | `cafe-api-build` |


### 5.4 Deploy Stage

| Field           | Value             |
| --------------- | ----------------- |
| Deploy provider | AWS Lambda        |
| Function name   | `cafe-api-lambda` |
| Input artifact  | BuildArtifact     |

Click Create Pipeline

## 6️⃣ - TEST THE PIPELINE (CRITICAL)

### 6.1 Make a Code Change

#### Edit:

```
lambda-api/app.py
```

#### Change text:

```
"API Lambda Updated via CI/CD"
```

#### Push to GitHub:

```
git add .
git commit -m "Test CI/CD"
git push origin main
```

### 6.2 Watch Pipeline

- Go to CodePipeline

#### You should see:

Source ✅

Build ✅

Deploy ✅

### 6.3 Verify Lambda

- Open cafe-api-lambda

- Click Test

#### Output:

```
API Lambda Updated via CI/CD
```

🎉 CI/CD WORKING

## 7️⃣ - REPEAT FOR WORKER LAMBDA

### Repeat Steps 3 → 6 with changes:

| Item              | Value                |
| ----------------- | -------------------- |
| CodeBuild project | `cafe-worker-build`  |
| Lambda name       | `cafe-worker-lambda` |
| Folder            | `lambda-worker`      |
| buildspec.yml     | adjust cd path       |

---
### 🧠 WHY THIS DESIGN IS CORRECT (REAL WORLD)

✔ Separate pipelines per Lambda

✔ GitHub as source of truth

✔ No manual uploads

✔ Easy rollback

✔ Industry standard

### ✅ FINAL CHECKLIST

| Item                | Status |
| ------------------- | ------ |
| GitHub repo         | ✅      |
| buildspec.yml       | ✅      |
| CodeBuild role      | ✅      |
| CodeBuild project   | ✅      |
| CodePipeline        | ✅      |
| Lambda deploy       | ✅      |
| Auto deploy on push | ✅      |
