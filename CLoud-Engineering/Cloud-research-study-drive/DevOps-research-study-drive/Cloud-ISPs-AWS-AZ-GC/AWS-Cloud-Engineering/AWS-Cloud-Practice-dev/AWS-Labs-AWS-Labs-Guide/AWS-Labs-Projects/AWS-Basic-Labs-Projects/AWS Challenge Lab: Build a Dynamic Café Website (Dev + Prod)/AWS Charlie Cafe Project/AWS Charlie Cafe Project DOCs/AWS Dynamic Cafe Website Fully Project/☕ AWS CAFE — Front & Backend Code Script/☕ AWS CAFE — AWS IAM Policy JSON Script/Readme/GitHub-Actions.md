# Charlie Cafe - GitHub-Actions


### ✅ GitHub-Actions.json

> #### Latest Update Version: 1.0


```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "LambdaAccess",
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:PublishLayerVersion",
        "lambda:GetFunction",
        "lambda:ListFunctions"
      ],
      "Resource": "*"
    },

    {
      "Sid": "EC2SSMAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ECRAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ECSAccess",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeClusters",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*"
    },

    {
      "Sid": "PassRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    }

  ]
}
```

### 🧠 WHAT EACH BLOCK DOES

- ### 🔹 LambdaAccess

#### 👉 Required for:

- Deploy Lambda code

- Update configuration (layers)

- ### 🔹 EC2SSMAccess

#### 👉 Required for:

- Your existing EC2 deployment via SSM

- ### 🔹 SecretsManagerAccess

#### 👉 Required for:

- RDS credentials (already working)

- ### 🔹 ECRAccess

#### 👉 Required for:

- Docker push from GitHub Actions

Example:

```
docker push <your-ecr-repo>
```

- ### 🔹 ECSAccess

#### 👉 Required for:

- Updating ECS service after new image

Example:

```
aws ecs update-service --force-new-deployment
```

- ### 🔹 PassRole (VERY IMPORTANT 🔥)

#### 👉 Required when:

- ECS uses task roles
Lambda uses execution roles

#### Without this:

❌ ECS deployment fails

### ⚠️ COMMON MISTAKES

- ### ❌ Missing iam:PassRole

```
AccessDeniedException: User is not authorized to perform iam:PassRole
```

- ### ❌ Missing ECR permissions

#### Error:

```
no basic auth credentials
```

- ### ❌ Missing ECS UpdateService

#### Error:

```
AccessDeniedException: ecs:UpdateService
```

### 🔥 DO YOU NEED ALL THIS NOW?

#### 👉 Honest answer:

- For your current setup → Lambda + EC2 only

- ECS/ECR → only needed if you deploy containers

---