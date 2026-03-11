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

### AWS Docker Lab Visual Workflow

```
┌───────────────────────┐
│ 1️⃣ Local Machine     │
│   aws-docker-lab/    │
│ ┌───────────────┐    │
│ │ server.js     │    │
│ │ package.json  │    │
│ │ Dockerfile    │    │
│ └───────────────┘    │
│                       │
│ git push / GitHub Web │
└───────────┬──────────┘
            │
            ▼
┌─────────────────────────────┐
│ 2️⃣ GitHub Repository       │
│   https://github.com/       │
│   awsrmmustansarjavaid/     │
│   aws-docker-lab            │
│ ┌───────────────┐           │
│ │ server.js     │           │
│ │ package.json  │           │
│ │ Dockerfile    │           │
│ └───────────────┘           │
└───────────┬─────────────────┘
            │ git clone
            ▼
┌─────────────────────────────┐
│ 3️⃣ AWS EC2 Instance        │
│   Amazon Linux 2023         │
│ ┌───────────────┐           │
│ │ ~/aws-docker-lab │        │
│ │ server.js       │        │
│ │ package.json    │        │
│ │ Dockerfile      │        │
│ └───────────────┘           │
│ sudo docker build -t aws-docker-lab . │
│ sudo docker run -d -p 3000:3000 aws-docker-lab │
└───────────┬─────────────────┘
            │ Port 3000
            ▼
┌─────────────────────────────┐
│ 4️⃣ Browser / Public Access │
│ http://<EC2_PUBLIC_IP>:3000│
│ Output: "Hello from AWS EC2 + Docker!" │
└─────────────────────────────┘
```

### Deploying a Dockerized app on AWS

![Deploying a Dockerized app on AWS](./aws-lab-ec2-github-docker-lab.png)

### Docker deployment flowchart overview

![Deploying a Dockerized app on AWS](./aws-lab-ec2-github-docker-lab-flowcart.png)

### Explanation of Each Step

### 1️⃣ Local Machine

- You create the project folder with server.js, package.json, and Dockerfile.

- Push to GitHub via GitHub Web (or git push if Git installed locally).

### 2️⃣ GitHub Repository

- Central place to store your code.

- EC2 will pull the latest version from here.

### 3️⃣ AWS EC2

- Launch EC2 → install Docker → clone repo.

- Build Docker image → run container mapping port 3000.

### 4️⃣ Browser

- Use EC2 public IP and port 3000 to access your Node.js app.

- You should see: "Hello from AWS EC2 + Docker!".

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

### ✅ Verify Your Repository

#### After commit, your GitHub repo should display:

```
aws-docker-lab/
├── server.js
├── package.json
├── Dockerfile
```

- Each file should have a GitHub icon and clickable filename.

- You now have a complete repo ready for EC2 to clone.

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

#### 3️⃣ Install Git on Amazon Linux 2023

#### Run these commands:

```
sudo dnf update -y
sudo dnf install git -y
```

- dnf is the package manager for Amazon Linux 2023.

#### After installation, check Git version:

```
git --version
```

#### You should see something like:

```
git version 2.40.1
```

#### 4️⃣ Clone your repository:

Now you can clone your repo. Use your personal GitHub repo (the one you actually own):

```
git clone https://github.com/<your-username>/aws-docker-lab.git
```

> **Do not use https://github.com/aws-docker-lab/aws-docker-lab.git because that’s not your repo.**

> **⚠️ Replace <your-username> with your GitHub username.**

#### 5️⃣ Go inside the project folder:

```
cd aws-docker-lab
```

#### 6️⃣ Verify files are there:

```
ls -l
```

or 

```
cd ~/aws-docker-lab
```

#### ✅ You should see:

```
server.js
package.json
Dockerfile
```
#### ✅ If you see all 3, you’re ready for Docker.

### 9️⃣ Build the Docker Image

#### 1️⃣ Run the Docker build command in the project folder:

Build the Docker image with a name aws-docker-lab:

```
sudo docker build -t aws-docker-lab .
```

- -t aws-docker-lab → names the image

- . → current directory (Dockerfile location)

#### 2️⃣ Wait until it finishes — you should see something like:

```
Successfully built <image-id>
Successfully tagged aws-docker-lab:latest
```

### 🔟 Run the Docker Container

#### 1️⃣ Run the container with port mapping:

```
sudo docker run -d -p 3000:3000 aws-docker-lab
```

- -d → run in detached mode (runs in background)

- -p 3000:3000 → maps container port 3000 to EC2 port 3000

#### 2️⃣ Verify container is running:

```
sudo docker ps
```

#### Output example:

CONTAINER ID   IMAGE           COMMAND      CREATED        STATUS       PORTS                    NAMES
a1b2c3d4e5f6   aws-docker-lab "node server.js" 2 minutes ago Up 2 minutes 0.0.0.0:3000->3000/tcp   goofy_hopper

#### ✅ You should see PORTS 0.0.0.0:3000->3000/tcp — that means it’s ready to be accessed.

### 1️⃣1️⃣ Adjust EC2 Security Group (if needed)

- Go to AWS Console → EC2 → Security Groups.

- Select the security group attached to your instance.

#### ✅ Make sure there’s an Inbound rule:

| Type       | Protocol | Port Range | Source    |
| ---------- | -------- | ---------- | --------- |
| SSH        | TCP      | 22         | My IP     |
| Custom TCP | TCP      | 3000       | 0.0.0.0/0 |

- Save rules.

> **This allows your browser to access the Node.js app from anywhere**

### 1️⃣2️⃣ Access Your App in Browser

#### 1️⃣ Open your browser.

#### 2️⃣ Enter your EC2 public IPv4 address with port 3000:

```
http://<EC2_PUBLIC_IP>:3000
```

#### 3️⃣ You should see:

```
Hello from AWS EC2 + Docker!
```

#### ✅ Your Node.js app is now running inside Docker on EC2, publicly accessible.

### 1️⃣3️⃣ Stop or Remove the Container

#### 1️⃣ List containers:

```
sudo docker ps
```

#### 2️⃣ Stop a container:

```
sudo docker stop <container-id>
```

#### 3️⃣ Start a container:

```
sudo docker start <container-id>
```

#### 4️⃣ Remove a container:

```
sudo docker rm <container-id>
```

#### 5️⃣ Remove the image:

```
docker rmi aws-docker-lab
```

#### ▶️ Add Docker Compose later to automate multi-container apps.

#### 🌐 At this point, your AWS lab is fully working from:

- GitHub → EC2 → Docker → Browser ✅

#### At this point, your Node.js app is running in Docker on EC2 and publicly accessible. 🎉