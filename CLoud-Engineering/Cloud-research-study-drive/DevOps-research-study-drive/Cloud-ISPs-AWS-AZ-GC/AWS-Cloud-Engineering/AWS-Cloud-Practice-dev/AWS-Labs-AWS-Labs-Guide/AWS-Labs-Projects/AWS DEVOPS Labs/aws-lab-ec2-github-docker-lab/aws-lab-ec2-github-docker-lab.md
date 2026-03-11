# 🚀 AWS Beginner Lab: Deploy a Simple Web App with Docker on EC2 from GitHub

### Goal: 

#### Deploy a simple “Hello World” Node.js web app from a GitHub repository, containerize it with Docker, and run it on an AWS EC2 instance.

### 🖼️ AWS Visual Architecture Diagram

Here’s a simple beginner-level diagram for this lab:

```
      GitHub Repo
          |
          |  git clone
          v
       AWS EC2
   +---------------+
   |  Docker Engine |
   |  Node.js App   |
   +---------------+
          |
      Port 3000
          |
          v
       Browser
```

### Deploying a Dockerized app on AWS

![Deploying a Dockerized app on AWS](./aws-lab-ec2-github-docker-lab.png)

### Docker deployment flowchart overview

![Deploying a Dockerized app on AWS](./aws-lab-ec2-github-docker-lab-flowcart.png)

### Explanation of Flow:

- GitHub Repo → stores your Node.js app and Dockerfile.

- EC2 Instance → host machine in AWS.

- Docker Engine → containerizes and runs your app.

- Browser → access app via EC2 public IP + mapped port (3000).

### Step 0: Prerequisites

- AWS account (with permissions to create EC2, Security Groups, and IAM user if needed)

- GitHub account

- Local machine with Git installed

- Basic terminal knowledge

## AWS Beginner Lab: Deploy a Node.js App with Docker on EC2 from GitHub

### 1️⃣ Create a GitHub Repository

- Go to GitHub  → log in.

- Click New Repository (green button on the top right).

- Set repository Name → aws-docker-lab.

- Optional: add a Description → “Simple Node.js Docker Lab”.

- Repository Type → Public or Private.

- Do not check “Initialize this repository with a README” (or you can, it’s optional but helpful).

- Click Create Repository.

### 2️⃣ Create Node.js App on Your Local Machine

### 1️⃣ Create a Project Folder

- Open File Explorer (Windows) or Finder (Mac) or terminal.

- Create a folder called aws-docker-lab.

#### ✅ Windows Example:

```
mkdir aws-docker-lab
cd aws-docker-lab
```

#### ✅ Mac/Linux Example:

```
mkdir ~/aws-docker-lab
cd ~/aws-docker-lab
```

### 2️⃣ Create server.js

Inside that folder, create a file called server.js.

#### ✅ On Windows, 

- right-click → New → Text Document → rename to server.js

#### ✅ On Mac/Linux, use:

```
touch server.js
```

- Open the file in a code editor (VS Code, Sublime Text, Notepad++).

#### ✅ Paste this following code:

```
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from AWS EC2 + Docker!');
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});
```

### 3️⃣ Create package.json

> **This file tells Node.js what dependencies the app needs.**

- Create a file called package.json in the same folder.

#### ✅ Add this content:

```
{
  "name": "aws-docker-lab",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2"
  },
  "scripts": {
    "start": "node server.js"
  }
}
```

### 4️⃣ Initialize Git (Optional, but needed for GitHub)

### 1️⃣ Upload Your Project Folder via GitHub APP

- Open terminal in your project folder.

```
git init
git add .
git commit -m "Initial Node.js app"
```

### 2️⃣ Upload Your Project Folder via GitHub Web

- Go to your newly created repository page.

- Click Add File → Upload Files.

- On your computer, open the aws-docker-lab folder.

- Drag and drop all files inside the folder (not the folder itself) into GitHub.

  - So, upload server.js, package.json, and later Dockerfile.

- Scroll down, enter a commit message like Initial Node.js app.

- Click Commit changes.

#### ✅ Now your project is on GitHub, and the repository contains all the files needed.

### 📢 Important Notes:

You do not need to upload the folder itself, only the contents of the folder.

#### Your repository on GitHub should now look like this:

```
aws-docker-lab/
├── server.js
├── package.json
```

- Later, you can add the Dockerfile the same way:
Add File → Upload Files → Commit.

### ✅ Result on your local machine

Your folder structure should look like this:

```
aws-docker-lab/
├── server.js
├── package.json
```

At this point, your Node.js app is ready locally.

Next, you will push it to GitHub, so EC2 can pull it and run it with Docker.

### 5️⃣ Create a Dockerfile

In your project folder, create a file named Dockerfile (no extension).

#### ✅ Add this content:

```
# Use Node.js official image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files
COPY . .

# Expose port
EXPOSE 3000

# Command to run app
CMD ["npm", "start"]
```

#### ✅ Commit and push:

```
git add Dockerfile
git commit -m "Add Dockerfile"
git push
```

### 6️⃣ AWS EC2 Instance

### 1️⃣ Launch an AWS EC2 Instance

- Log in to AWS Management Console
.
- Navigate to EC2 → Instances → Launch Instances.

- Choose AMI:

  - Amazon Linux 2023 (recommended) OR

  - Ubuntu 22.04

- Choose Instance Type → t2.micro (free tier eligible).

- Configure Key Pair:

  - Create new key pair → download .pem file → save securely.

- Configure Security Group:

  - Add SSH → port 22 → Source: My IP

  - Add Custom TCP Rule → port 3000 → Source: 0.0.0.0/0 (for testing)

- Click Launch Instance → wait for instance to start.

- Note Public IPv4 address of the instance.

### 2️⃣ Connect to EC2

- Open terminal on your machine.

#### ✅ Set correct permissions for your key:

```
sudo chmod 400 my-key.pem
```

- Connect:

- Amazon Linux:

```
ssh -i my-key.pem ec2-user@<EC2_PUBLIC_IP>
```

- Ubuntu:

```
ssh -i my-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### 7️⃣ Install Docker on Amazon Linux 2023

> **Amazon Linux commands:**

#### 1️⃣ Update packages

```
sudo dnf update -y
```

#### 2️⃣ Install Docker

```
sudo dnf install -y docker
```

#### 3️⃣ Start Docker service

```
sudo systemctl start docker
```

#### 4️⃣ Enable Docker to start on boot

```
sudo systemctl enable docker
```

#### 5️⃣ Add your EC2 user to Docker group (so you don’t need sudo every time)

```
sudo usermod -aG docker ec2-user
```

#### 6️⃣ Logout and log back in (or just reconnect via SSH) so the group changes take effect.

#### 7️⃣ Verify Docker is working

```
docker --version
```

#### ✅ You should see something like:

```
Docker version 24.0.5, build ffff...
```

#### ✔️ After this, you can clone your GitHub repo and run Docker exactly like we planned.

### 8️⃣ Clone Your GitHub Repository on EC2

#### 1️⃣ Go to your terminal on EC2.

#### 2️⃣ Navigate to your home directory (optional but clean):

```
cd ~
```

3️⃣ Clone your repository:

```
git clone https://github.com/<your-username>/aws-docker-lab.git
```

> **⚠️ Replace <your-username> with your GitHub username.**

4️⃣ Go inside the project folder:

```
cd aws-docker-lab
```

5️⃣ Verify files are there:

```
ls -l
```

#### ✅ You should see:

```
server.js
package.json
Dockerfile
```

