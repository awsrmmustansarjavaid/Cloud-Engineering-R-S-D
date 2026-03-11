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

### Step 1: Create a GitHub Repository

- Go to GitHub  → log in.

- Click New Repository (green button).

- Set repository Name → aws-docker-lab.

- Optional: add a Description → “Simple Node.js Docker Lab”.

- Repository Type → Public or Private.

- Check Add README (optional but helpful).

- Click Create Repository.

### Step 2: Create a Node.js App

- On your local machine, create a folder named aws-docker-lab.

- Inside this folder, create a file called server.js.

- Add the following code:

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

