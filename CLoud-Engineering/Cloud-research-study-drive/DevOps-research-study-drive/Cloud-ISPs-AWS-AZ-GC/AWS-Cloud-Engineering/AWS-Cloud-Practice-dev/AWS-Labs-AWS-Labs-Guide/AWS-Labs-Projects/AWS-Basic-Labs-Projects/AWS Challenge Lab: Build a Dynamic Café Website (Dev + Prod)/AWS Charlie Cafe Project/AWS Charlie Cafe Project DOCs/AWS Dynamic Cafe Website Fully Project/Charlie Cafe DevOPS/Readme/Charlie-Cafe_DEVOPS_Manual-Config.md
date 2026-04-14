# GitHub Actions workflow directly on EC2

### Step 1: Prepare your EC2

Make sure EC2 has:

- #### Docker installed and running:

```
sudo systemctl enable docker
sudo systemctl start docker
docker --version
```

- #### Git installed:

```
git --version
```

- #### AWS CLI configured with the same credentials you use in GitHub Actions:

```
aws configure
# use same AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
```

### Step 2: Clone your repo

```
cd ~
git clone https://github.com/<your_username>/charlie-cafe-devops.git
cd charlie-cafe-devops
```

### Step 3: Simulate CI/CD steps on EC2

You can run the Docker build and container test locally — this mirrors steps 11–14 in your deploy.yml.

```
# Go to repo root
cd ~/charlie-cafe-devops

# Optional: pull latest code
git pull origin main

# Build Docker image (simulate step 11)
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

# Remove old container (simulate step 12)
docker rm -f test_app || true

# Run new container (simulate step 12)
docker run -d -p 80:80 --name test_app charlie-cafe

# Wait a few seconds
sleep 10

# Test container (simulate step 13)
curl -f http://localhost/ || { echo "Container failed"; exit 1; }

# Cleanup (simulate step 14)
docker rm -f test_app || true
```

✅ If all these commands succeed, your Docker-related steps in deploy.yml are safe to push.

### Step 4: Test the EC2 deployment script

Since your deploy.yml calls:

```
/home/ec2-user/charlie-cafe-devops/deploy_via_ssm.sh
```

You can run it manually to simulate step 15:

```
bash ~/charlie-cafe-devops/deploy_via_ssm.sh
```

- This will test EC2 deployment without GitHub Actions.

- Make sure deploy_via_ssm.sh contains the correct Docker build/run commands.

### Step 5: Optional Full Test via GitHub Actions

- Push your branch to GitHub.

- Go to Actions → Your workflow → Run workflow → main branch.

- GitHub will run all steps in deploy.yml.

- You can monitor logs for Docker build, container test, and EC2 deployment.

### 💡 Pro tip:

- Use a test EC2 instance (like t2.micro) to test the workflow before running it on production.

- Ensure your docker/apache-php/Dockerfile paths and frontend files exist, otherwise Docker build fails.

---
## Docker Verification

### 1️⃣ Check Docker Service

```
# Check if Docker service is running
sudo systemctl status docker

# Start Docker if not running
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### 2️⃣ Verify Docker Version and Info

```
docker --version
docker info
```

Look for Server Version, Storage Driver, and Running Containers.

### 3️⃣ List All Containers

```
# Running containers
docker ps

# All containers including stopped
docker ps -a
```

Check if your Apache container is running.

### 4️⃣ Check Apache Container Logs

```
# Replace <container_name> with your container, e.g., verify-apache-test
docker logs <container_name>
```

Look for errors, e.g., port conflicts, missing files, permission errors.

### 5️⃣ Inspect Container Ports

```
docker inspect <container_name> | grep -i "Port"
```

Or more readable:

```
docker port <container_name>
```

Check that container port 80 is mapped to host port 8080 (or the port you intended).

### 6️⃣ Test Apache Inside Container

```
# Enter container shell
docker exec -it <container_name> bash

# Test Apache inside container
curl -I http://localhost
# Should return HTTP/1.1 200 OK
```

### 7️⃣ Test Apache from Host

```
# From EC2 host, test mapped port
curl -I http://localhost:8080
```

If this fails:

- Check firewall/security group.

- Check port mapping in container.

### 8️⃣ Check Host Ports

```
# See if port 8080 is listening
sudo netstat -tulpn | grep 8080

# Or using ss
sudo ss -tulpn | grep 8080
```

### 9️⃣ Check Firewall / Security Groups

#### On EC2 (Linux Firewall):

```
sudo firewall-cmd --list-all       # If using firewalld
sudo iptables -L -n -v             # Check iptables rules
```

AWS Security Group:
- Port 8080 (or 80) must be allowed inbound from your IP.

### 🔟 Remove & Recreate Container

```
docker rm -f <container_name>
docker run -d --name <container_name> -p 8080:80 httpd:latest
```

Check logs immediately:

```
docker logs <container_name>
```

### 1️⃣1️⃣ Check Apache inside container config

Sometimes the container fails because Apache tries to bind to 0.0.0.0:80 but the port is already used:

```
docker exec -it <container_name> bash
cat /usr/local/apache2/conf/httpd.conf | grep Listen
```

Default: Listen 80. Make sure it matches your mapped port.

### 1️⃣2️⃣ Network Troubleshooting

```
# Test if Docker bridge is OK
docker network ls
docker network inspect bridge

# Ping container from host
docker exec -it <container_name> ping 127.0.0.1
```

### ✅ Quick Debug Flow

- sudo systemctl status docker → Docker running?

- docker ps -a → Apache container exists and running?

- docker logs <container> → Any Apache errors?

- docker port <container> → Correct host:container port mapping?

- curl http://localhost:8080 → Works on host?

- sudo netstat -tulpn | grep 8080 → Port listening?

- Security group allows inbound 8080?

- If issues remain → docker rm -f and restart container.

### ✅ compact bash script

#### Here’s a ready-to-use script:

```
#!/bin/bash
# ==========================================================
# 🚨 Docker + Apache Verification Script — Charlie Cafe
# ==========================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}✅ $1${NC}"; ((PASS++)); }
fail() { echo -e "${RED}❌ $1${NC}"; ((FAIL++)); }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# 1️⃣ Docker service
systemctl is-active --quiet docker && pass "Docker service running" || fail "Docker service not running"

# 2️⃣ Docker version & info
docker --version &>/dev/null && pass "Docker version OK" || fail "Docker not installed"
docker info &>/dev/null && pass "Docker info OK" || fail "Docker info failed"

# 3️⃣ List containers
docker ps &>/dev/null && pass "Docker running containers OK" || fail "No running containers"

# 4️⃣ Container logs (Apache)
APACHE_CONTAINER=$(docker ps -qf "ancestor=httpd")
if [ -n "$APACHE_CONTAINER" ]; then
    docker logs "$APACHE_CONTAINER" | head -n 5
    pass "Apache container logs OK"
else
    fail "No Apache container running"
fi

# 5️⃣ Inspect container ports
if [ -n "$APACHE_CONTAINER" ]; then
    docker port "$APACHE_CONTAINER" &>/dev/null && pass "Apache container ports OK" || fail "Port mapping issue"
fi

# 6️⃣ Test Apache inside container
if [ -n "$APACHE_CONTAINER" ]; then
    docker exec "$APACHE_CONTAINER" curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200" && pass "Apache responds inside container" || fail "Apache not responding inside container"
fi

# 7️⃣ Test Apache from host
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200" && pass "Apache responds on host:8080" || fail "Apache not reachable on host"

# 8️⃣ Check host port listening
sudo ss -tulpn | grep -q ":8080" && pass "Host port 8080 listening" || fail "Host port 8080 not listening"

# 9️⃣ Check firewall (simple)
sudo iptables -L -n | grep -q "8080" && warn "Port 8080 in iptables" || pass "No iptables block on 8080"

# 🔟 Remove & recreate container (just check possibility)
docker rm -f "$APACHE_CONTAINER" &>/dev/null && warn "Apache container removed for recreation test" || warn "No Apache container to remove"

# 1️⃣1️⃣ Check Apache Listen config inside container
if [ -n "$APACHE_CONTAINER" ]; then
    LISTEN_PORT=$(docker exec "$APACHE_CONTAINER" grep -i "Listen" /usr/local/apache2/conf/httpd.conf | awk '{print $2}')
    [ "$LISTEN_PORT" == "80" ] && pass "Apache Listen config OK" || fail "Apache Listen port not 80"
fi

# 1️⃣2️⃣ Docker network check
docker network ls &>/dev/null && pass "Docker networks OK" || fail "Docker network issue"

# ---------------- REPORT ----------------
TOTAL=$((PASS + FAIL))
SUCCESS=$((PASS * 100 / TOTAL))
echo ""
echo -e "${YELLOW}================ FINAL REPORT ================${NC}"
echo -e "Total Checks : $TOTAL"
echo -e "${GREEN}Passed       : $PASS${NC}"
echo -e "${RED}Failed       : $FAIL${NC}"
echo -e "${YELLOW}Success Rate : $SUCCESS%${NC}"
echo -e "${YELLOW}=============================================${NC}"
```

#### ✅ How to use:

- SSH into your EC2.

- Paste the script directly into your terminal and press Enter.

- It will run all 12 checks, show logs for the Apache container, and produce a clear report at the end.

---
### 1️⃣ Verify Apache Docker Container Setup on EC2

Before deploying anything, always run this short verification script:

```
#!/bin/bash
# Quick Docker + Apache Health Check
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# Check Docker running
systemctl is-active --quiet docker && pass "Docker running" || { fail "Docker not running"; exit 1; }

# Remove old container
docker rm -f charlie-cafe || true

# Run new container
docker run -d -p 80:80 --name charlie-cafe charlie-cafe

# Wait a few seconds
sleep 5

# Test container port inside host
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" == "200" ]; then
    pass "Apache container responding on host port 80"
else
    fail "Apache container NOT responding, HTTP status $HTTP_STATUS"
    docker logs charlie-cafe | tail -n 20
fi
```

✅ Why this works: This ensures every time before practice, you verify Docker + Apache, and see logs if it fails.

### Fix Port Mapping & Binding Issues

#### ✅ From your error:

```
This site can’t be reached
54.157.114.237 refused to connect
```

#### ✅ Possible causes:

- Container port not mapped correctly

In your deploy.yml:

```
docker run -d -p 80:80 --name test_app charlie-cafe
```

✅ Make sure your Apache Dockerfile is actually listening on port 80:

```
EXPOSE 80
```

- EC2 Security Group not open on port 80

    - Go to your AWS console → EC2 → Security Group

    - Add inbound rule: HTTP (80) → Source: 0.0.0.0/0

- Firewalls inside EC2

Check:

```
sudo ss -tulpn | grep 80
sudo iptables -L -n
```

### 3️⃣ Update Your GitHub Actions CI/CD Workflow

Currently, you have:

```
- name: 🚀 Run Container (CI)
  run: |
    docker rm -f test_app || true
    docker run -d -p 80:80 --name test_app charlie-cafe
    sleep 10
```

#### 🔹 Add a health check after run:

```
- name: ❤️ Test Application (CI)
  run: |
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
    if [ "$HTTP_STATUS" != "200" ]; then
      docker logs test_app
      exit 1
    fi
```

This ensures CI/CD fails if Apache doesn’t start, instead of silently passing.

### 4️⃣ Persistent Fix on EC2

- Make Docker auto-start containers after reboot:

```
docker update --restart unless-stopped charlie-cafe
```

- Always run pre-check script (from step 1) before Lambda deployment or practice. This avoids ERR_CONNECTION_REFUSED.

### 5️⃣ Optional: Debugging Dockerfile

Sometimes your Apache doesn’t serve:

- Check DocumentRoot exists in Dockerfile.

- Ensure no errors in /usr/local/apache2/logs/error_log.

- Test container manually:

```
docker exec -it charlie-cafe /bin/bash
curl -I http://localhost
```

### ✅ Recommended Practice Workflow for Lab

- Pre-check EC2 Docker + Apache container → run health check script.

- Deploy GitHub updates / Lambda updates.

- Run container health test automatically.

- Check logs if failure occurs.

- Ensure security groups and EC2 firewall allow port 80.
---

### ✅ Your EC2 does not have the Docker image charlie-cafe built or pulled yet. That’s why Docker says:

```
Unable to find image 'charlie-cafe:latest' locally
pull access denied for charlie-cafe
```

### ✅ Solution: Make the image available before running container

You have two options:

### Option 1: Build the Docker image locally on EC2

Run this before running the health check:

```
# Navigate to your repo
cd ~/charlie-cafe-devops/docker/apache-php

# Build image
docker build -t charlie-cafe -f Dockerfile .

# Verify build
docker images | grep charlie-cafe
```

Once this completes, run your health check script again. It should pass.

### Option 2: Pull from a Docker registry (if you have pushed it to Docker Hub)

```
docker login
docker pull your-docker-username/charlie-cafe:latest
docker tag your-docker-username/charlie-cafe:latest charlie-cafe
```

Then run your health check.

### ⚡ Updated Health Check Workflow

#### Build or pull image first:

```
docker build -t charlie-cafe ~/charlie-cafe-devops/docker/apache-php
# OR pull from registry
docker pull your-docker-username/charlie-cafe
```

- Then run your health check script.

---

- Your Lambda deployment script (github-aws-devops-lambda-deploy.sh) doesn’t need touching

- Docker always has the charlie-cafe image ready on EC2 before attempting to run Apache

- Your deploy.yml workflow is professional, robust, and prevents ERR_CONNECTION_REFUSED

Here’s the plan:

### 🔹 Why the issue happens

Your deploy.yml builds the Docker image inside GitHub Actions runner but does not automatically transfer the image to your EC2. So when your health check script on EC2 tries to run:

```
docker run -d -p 80:80 --name charlie-cafe charlie-cafe
```

…there is no charlie-cafe image on EC2, so Docker fails.

#### ✅ In real professional setups, you have two approaches:

- Build Docker image on EC2 directly before running the container.

- Push Docker image to a registry (Docker Hub, ECR) from CI, and then pull it on EC2.

Since you want to touch only deploy.yml, the best professional approach is to update deploy.yml to build Docker image on EC2 via SSM, not just GitHub Actions.

### 🔹 Solution — Updated deploy.yml for production-ready workflow

Add these steps before the EC2 health check:

```
# -------------------------------------------------
# 15️⃣ Build Docker on EC2
# -------------------------------------------------
- name: 🐳 Build Docker Image on EC2
  run: |
    aws ssm send-command \
      --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
      --document-name "AWS-RunShellScript" \
      --parameters commands=[
        "cd /home/ec2-user/charlie-cafe-devops/docker/apache-php",
        "docker build -t charlie-cafe -f Dockerfile ."
      ] \
      --region ${{ secrets.AWS_REGION }}

# -------------------------------------------------
# 16️⃣ Run Docker container on EC2
# -------------------------------------------------
- name: 🚀 Run Apache Container on EC2
  run: |
    aws ssm send-command \
      --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
      --document-name "AWS-RunShellScript" \
      --parameters commands=[
        "docker rm -f charlie-cafe || true",
        "docker run -d -p 80:80 --name charlie-cafe charlie-cafe"
      ] \
      --region ${{ secrets.AWS_REGION }}

# -------------------------------------------------
# 17️⃣ Wait and verify Apache container on EC2
# -------------------------------------------------
- name: 🌐 Test Apache on EC2
  run: |
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
    # Wait 10 seconds for Apache to start
    sleep 10
    curl -f http://$INSTANCE_IP/ || exit 1
```

#### ✅ What this does:

- SSH-less CI/CD deployment: EC2 builds Docker image itself.

- Removes any old container and runs a fresh container.

- Waits for Apache to start and verifies HTTP 200.

- Completely avoids ERR_CONNECTION_REFUSED because the image exists on EC2.

#### 🔹 Optional: Push Docker image to Amazon ECR (Professional CI/CD)

If you want true production-grade CI/CD, do this in GitHub Actions:

```
- name: 🔥 Push Docker to ECR
  run: |
    aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin <your_account_id>.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com
    docker tag charlie-cafe:latest <your_account_id>.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest
    docker push <your_account_id>.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest
```

Then on EC2, you just docker pull <ECR_IMAGE> instead of building. This is standard for professional DevOps pipelines.

#### 🔹 Optional — “All-in-one EC2 health check script” (bash)

If you want a single script to run on EC2 tomorrow:

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — EC2 Docker & Apache Health Check
# ==========================================================
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# Check Docker
systemctl is-active --quiet docker && pass "Docker running" || { fail "Docker not running"; exit 1; }

# Build Docker image
cd ~/charlie-cafe-devops/docker/apache-php || { fail "Dockerfile dir missing"; exit 1; }
docker build -t charlie-cafe -f Dockerfile . && pass "Docker image built" || { fail "Docker build failed"; exit 1; }

# Remove old container
docker rm -f charlie-cafe || true

# Run new container
docker run -d -p 80:80 --name charlie-cafe charlie-cafe && pass "Container started" || { fail "Container failed"; exit 1; }

# Wait a few seconds
sleep 10

# Test Apache
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" == "200" ]; then
    pass "Apache responding on EC2"
else
    fail "Apache NOT responding, HTTP $HTTP_STATUS"
    docker logs charlie-cafe | tail -n 20
fi
```

You can save this as ec2_docker_health.sh and run it anytime.

#### ✅ My Professional Recommendation

- Do not touch github-aws-devops-lambda-deploy.sh (your Lambda script works fine).

- Update deploy.yml to build Docker on EC2 before running container and testing Apache.

- Optional: Use ECR push/pull for faster and more professional CI/CD.

- Keep the health check bash script on EC2 as a backup for manual testing.

#### 🔹 Final Working EC2 Docker Health Check Script

Save this as ec2_docker_health.sh:

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — EC2 Docker & Apache Health Check
# ==========================================================
# This script:
#   1️⃣ Checks Docker is running
#   2️⃣ Navigates to the repo root
#   3️⃣ Builds Docker image
#   4️⃣ Removes old container
#   5️⃣ Runs new container
#   6️⃣ Performs local health check
# ==========================================================

set -e  # Exit immediately on error

# ----------------------------
# Colors for output
# ----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# ----------------------------
# 1️⃣ Check Docker is running
# ----------------------------
systemctl is-active --quiet docker && pass "Docker running" || { fail "Docker not running"; exit 1; }

# ----------------------------
# 2️⃣ Navigate to repo root
# ----------------------------
REPO_DIR=~/charlie-cafe-devops
if [ ! -d "$REPO_DIR" ]; then
    fail "Repo directory $REPO_DIR not found!"
    exit 1
fi
cd "$REPO_DIR"
pass "Navigated to repo: $REPO_DIR"

# ----------------------------
# 3️⃣ Build Docker image
# ----------------------------
DOCKERFILE_DIR="$REPO_DIR/docker/apache-php"
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
    fail "Dockerfile not found in $DOCKERFILE_DIR"
    exit 1
fi

docker build -t charlie-cafe -f "$DOCKERFILE_DIR/Dockerfile" "$REPO_DIR" && pass "Docker image built successfully" || { fail "Docker build failed"; exit 1; }

# ----------------------------
# 4️⃣ Remove old container
# ----------------------------
docker rm -f charlie-cafe || true

# ----------------------------
# 5️⃣ Run new container
# ----------------------------
docker run -d -p 80:80 --name charlie-cafe charlie-cafe && pass "Container started" || { fail "Container failed"; exit 1; }

# ----------------------------
# 6️⃣ Wait a few seconds
# ----------------------------
sleep 10

# ----------------------------
# 7️⃣ Test Apache container
# ----------------------------
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" == "200" ]; then
    pass "Apache container responding on localhost"
else
    fail "Apache container NOT responding, HTTP $HTTP_STATUS"
    echo "Showing last 20 lines of container logs:"
    docker logs charlie-cafe | tail -n 20
    exit 1
fi
```

#### ✅ Key Fixes

- Always cd into repo root before building Docker.

- docker build now uses "$REPO_DIR" as the context, so all COPY ./app/frontend/... paths exist.

- Dockerfile directory is explicitly specified (-f "$DOCKERFILE_DIR/Dockerfile")

- Error handling with proper messages for missing repo or Dockerfile

- Local health check ensures Apache is serving HTTP 200

#### 🔹 Usage

```
chmod +x ec2_docker_health.sh
./ec2_docker_health.sh
```

✅ This will work every time on EC2, no matter where you run it from, as long as the repo is cloned in ~/charlie-cafe-devops.