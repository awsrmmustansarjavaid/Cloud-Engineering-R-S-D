# Charlie Cafe - DevOPS 

### 📄 ✅ FINAL deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # MySQL Service (for testing DB schema)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # Install MySQL Client
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client

    # -------------------------------------------------
    # Wait for MySQL to be ready
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Sample Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # Run Verification Tests (QA)
    # -------------------------------------------------
    - name: ✅ Run DB Verification
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # Build Docker Image (PHP + Apache)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Docker Container
      run: docker run -d -p 8080:80 charlie-cafe

    # -------------------------------------------------
    # Basic Health Check
    # -------------------------------------------------
    - name: 🌐 Test Web Server
      run: |
        sleep 10
        curl -I http://localhost:8080 || exit 1

    # -------------------------------------------------
    # Success
    # -------------------------------------------------
    - name: 🎉 Deployment Success
      run: echo "Charlie Cafe CI/CD Pipeline Successful 🚀"
```


### 1️⃣ Why You Need .gitignore and .dockerignore

Even though they look similar, they solve two completely different problems.

### 1️⃣ .dockerignore

This file tells Docker which files/folders to ignore when building your image.

#### ✅ Why it’s needed:

Docker copies your project folder into the image. If you don’t ignore unnecessary files, your image becomes huge, slow, and may include sensitive data.
Keeps image clean and small → faster builds, faster deploys.

#### ✅ Your entries explained:

| Entry                | Why ignored                                      |
| -------------------- | ------------------------------------------------ |
| `.git`               | Git history is not needed in container           |
| `.gitignore`         | Not needed inside image                          |
| `node_modules`       | Can rebuild via `npm install` in image if needed |
| `.env`               | Contains sensitive secrets, never put in image   |
| `*.log`              | Runtime logs don’t belong in image               |
| `vendor`             | PHP dependencies; can rebuild if needed          |
| `docker-compose.yml` | Only used on host, not in container              |
| `.github`            | CI/CD workflows not needed in image              |
| `README.md`          | Documentation, not runtime                       |

✅ Result: image only contains what it needs to run.

### 2️⃣ .gitignore

This file tells Git which files/folders to ignore when committing to GitHub.

#### ✅ Why it’s needed:

Prevents committing unnecessary files to repo → keeps repo clean, smaller, and secure.
Avoids committing sensitive files (like .env) and OS junk files (.DS_Store).
Helps teams avoid conflicts with local-only files.

#### ✅ Your entries explained:

| Entry           | Why ignored                        |
| --------------- | ---------------------------------- |
| `node_modules/` | Rebuildable, too large for Git     |
| `vendor/`       | PHP dependencies; can rebuild      |
| `.env`          | Secrets, never push to GitHub      |
| `*.log`         | Runtime logs, not source code      |
| `.DS_Store`     | Mac OS junk file                   |
| `Thumbs.db`     | Windows junk file                  |
| `docker/*.tar`  | Docker images/archives, don’t push |

✅ Result: Git repo stays clean, safe, and professional.

### ⚡ TL;DR — Difference:

| Feature         | Purpose                                                                               |
| --------------- | ------------------------------------------------------------------------------------- |
| `.dockerignore` | Keeps **Docker images small and clean** by ignoring unnecessary files during build    |
| `.gitignore`    | Keeps **Git repo clean and safe**, avoiding committing unnecessary or sensitive files |

### 🖼️ Charlie Cafe DevOps: .gitignore vs .dockerignore

```
charlie-cafe-devops/   <-- Your project root
│
├── .gitignore         <-- Git ignores listed files/folders
├── .dockerignore      <-- Docker ignores listed files/folders
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── apache-php/Dockerfile
│   └── mysql/Dockerfile
├── app/
│   ├── frontend/
│   └── backend/
├── infrastructure/
│   └── rds/
│       ├── schema.sql
│       ├── data.sql
│       └── verify.sql
├── docker-compose.yml
├── README.md
└── node_modules/
```

### 🔹 1. How .gitignore works

- Git sees the whole project but ignores files listed in .gitignore

- These files never get pushed to GitHub, keeping your repo clean and secure.

#### Example from Charlie Cafe:

```
.gitignore
├── node_modules/       # big, rebuildable
├── vendor/             # PHP dependencies, rebuildable
├── .env                # secret config
├── *.log               # runtime logs
├── .DS_Store           # macOS junk
├── Thumbs.db           # Windows junk
├── docker/*.tar        # local docker archives
```

✅ Git will track everything else (app code, infrastructure scripts, Dockerfiles, workflow files).

### 🔹 2. How .dockerignore works

- Docker sees the context folder when building an image (normally your repo root)

- Docker ignores files in .dockerignore → they are not copied into the container

#### Example from Charlie Cafe:

```
.dockerignore
.git
.gitignore
node_modules
vendor
.env
*.log
docker-compose.yml
.github
README.md
```

✅ Docker only copies what is needed to run the app (e.g., app/frontend/, app/backend/, maybe infrastructure/rds/ if using SQL files in container).

### 🔹 3. Visual Flow Diagram

```
[ Your Local Repo ]
        │
        │ git push → GitHub
        ▼
[ GitHub Repo ]
        │
        │ Git ignores .gitignore files
        ▼
[ Docker Build Context ]
        │
        │ Docker ignores .dockerignore files
        ▼
[ Docker Image ]
        ├── app/frontend/          ✔ included
        ├── app/backend/           ✔ included
        ├── infrastructure/rds/    ✔ if needed in container
        └── unnecessary files → ❌ not included
```

### 🔹 4. Key Takeaways

- .gitignore → controls what Git tracks

- .dockerignore → controls what Docker includes in images

- Both prevent junk, secrets, and big files from leaking into repo or container

- Using both keeps your Charlie Cafe DevOps project clean, professional, and production-ready

### ✅ 1. Can you ignore folders like AWS IAM Policies/ and docs/?

👉 YES — your syntax is correct

#### In both .dockerignore and .gitignore, you can ignore folders like this:

```
AWS IAM Policies/
docs/
```

#### ✔ This will ignore:

- The folder itself

- All files inside it

- All subfolders

### ⚠️ 2. Important Issue in Your Case (Very Important)

Your folder name has a space:

```
AWS IAM Policies/
```

####  👉 This works, but it’s not recommended because:

- Can break scripts

- Causes issues in CI/CD, Docker, Linux

### 🔥 ✅ BEST PRACTICE (Fix This)

Rename folder:

```
AWS-IAM-Policies/
```

or

```
aws-iam-policies/
```

#### 👉 Then update ignore files:

```
aws-iam-policies/
docs/
```

### ✅ 3. FINAL .dockerignore (Clean Version)

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
aws-iam-policies/
docs/
```

### ✅ 4. FINAL .gitignore (Clean Version)

```
node_modules/
vendor/
.env
*.log
.DS_Store
Thumbs.db
docker/*.tar
aws-iam-policies/
docs/
```

### 🧠 5. What Happens After This?
.gitignore

#### 👉 Git will:

NOT upload docs/ and aws-iam-policies/ to GitHub
.dockerignore

#### 👉 Docker will:

NOT include these folders in image
Faster build
Smaller image

### ⚠️ 6. VERY IMPORTANT WARNING

#### 👉 If you ignore docs/ in .gitignore:

❌ Your documentation will NOT be uploaded to GitHub

### 💡 Recommendation (SMART APPROACH)

#### 👉 Use this:

#### .dockerignore

```
docs/
aws-iam-policies/
```

#### .gitignore

```
aws-iam-policies/
```

👉 Keep docs/ in GitHub (important for portfolio)

### 🎯 Final Advice

| Folder            | GitHub   | Docker   |
| ----------------- | -------- | -------- |
| docs/             | ✅ KEEP   | ❌ IGNORE |
| aws-iam-policies/ | ❌ IGNORE | ❌ IGNORE |

---
### 📄 ✅ FINAL deploy.yml (CLEAN + PROFESSIONAL)

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # 🐬 MySQL Service (for DB testing)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository (AUTO)
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Install Dependencies
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client curl

    # -------------------------------------------------
    # 3️⃣ Wait for MySQL
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # 4️⃣ Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 5️⃣ Apply Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 6️⃣ Verify Database (QA)
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 7️⃣ Build Docker Image (APP)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 8️⃣ Run Docker Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: docker run -d -p 8080:80 --name cafe-app charlie-cafe

    # -------------------------------------------------
    # 9️⃣ Test Container (Health Check)
    # -------------------------------------------------
    - name: ❤️ Test Application (Health Check)
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 🔟 Success Message
    # -------------------------------------------------
    - name: 🎉 Pipeline Success
      run: echo "Charlie Cafe CI/CD Pipeline Completed Successfully 🚀"
```

### 🧠 Now Let’s Map Your Requirements

| Your Requirement         | Where it is           |
| ------------------------ | --------------------- |
| Clone repo automatically | `actions/checkout@v3` |
| Build container          | Docker build step     |
| Build Docker image       | Step 7                |
| Run container            | Step 8                |
| Test container           | Step 9 (health.php)   |

### 🔥 What You Were Missing (Important Insight)

#### Your previous version:

❌ Steps existed but not clearly structured

❌ No health endpoint test

❌ No clear DevOps flow

#### 👉 Now it’s:

✔ Step-by-step pipeline

✔ Easy to explain in interview

✔ Professional level

### 📁 Final Folder Structure

```
charlie-cafe-devops/
│
├── .github/
│   └── workflows/
│       └── deploy.yml   ✅ CI/CD pipeline
│
├── docker/
│   ├── apache-php/
│   │   └── Dockerfile
│   └── mysql/
│       └── Dockerfile
│
├── app/
│   ├── frontend/
│   │   └── health.php   ✅ (used in CI/CD)
│   └── backend/
│       └── lambda/
│
├── infrastructure/
│   └── rds/
│       ├── schema.sql
│       ├── data.sql
│       └── verify.sql
│
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md
```

### 🧠 Why This Matters 

This pipeline ensures that every code change is automatically validated by cloning the repository, setting up the database, building and running the application in Docker, and testing it through a health check. This guarantees that your application is always deployable, reduces manual errors, and reflects real-world DevOps practices used in production environments.

### 🎯 Final Result (Your Level Now)

You now have:

✅ Real CI/CD pipeline

✅ Database validation (QA)

✅ Docker build + run

✅ Health check testing

✅ Clean architecture

👉 This is junior → mid-level DevOps engineer project
---

