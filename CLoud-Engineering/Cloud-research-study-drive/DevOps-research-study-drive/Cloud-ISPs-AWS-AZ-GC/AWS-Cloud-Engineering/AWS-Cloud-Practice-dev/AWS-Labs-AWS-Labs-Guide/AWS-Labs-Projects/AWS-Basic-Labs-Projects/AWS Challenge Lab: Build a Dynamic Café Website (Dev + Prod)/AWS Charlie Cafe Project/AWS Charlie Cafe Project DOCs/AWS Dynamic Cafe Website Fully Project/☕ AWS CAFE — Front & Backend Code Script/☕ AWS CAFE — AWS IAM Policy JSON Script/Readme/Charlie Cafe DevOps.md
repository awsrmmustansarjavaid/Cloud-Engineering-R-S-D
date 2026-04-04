# Charlie Cafe - Charlie Cafe DevOps

### 1️⃣ Prepare AWS IAM Roles and Policies

- #### Lambda Execution Role

   - Attach policies: AWSLambdaFullAccess, AmazonDynamoDBFullAccess, AmazonRDSFullAccess, AmazonS3FullAccess, CloudWatchLogsFullAccess.

- #### GitHub CI/CD Role (for GitHub Actions)

   - Policy allowing: lambda:UpdateFunctionCode, apigateway:*, s3:*, ec2:*, ecs:*.

- Save Access Key & Secret Key securely (for GitHub Secrets).

#### ✅ Merged IAM Policy — Charlie Cafe DevOps

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaExecution",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunction",
                "lambda:UpdateFunctionCode",
                "lambda:ListFunctions",
                "lambda:PublishVersion",
                "lambda:CreateFunction",
                "lambda:DeleteFunction",
                "lambda:AddPermission"
            ],
            "Resource": "*"
        },
        {
            "Sid": "APIGatewayManagement",
            "Effect": "Allow",
            "Action": [
                "apigateway:GET",
                "apigateway:POST",
                "apigateway:PUT",
                "apigateway:PATCH",
                "apigateway:DELETE",
                "apigateway:UPDATE"
            ],
            "Resource": "*"
        },
        {
            "Sid": "DynamoDBFullAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "RDSFullAccess",
            "Effect": "Allow",
            "Action": [
                "rds:*",
                "rds-data:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3FullAccess",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2Management",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECSManagement",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:DescribeTasks",
                "ecs:ListTasks",
                "ecs:RunTask"
            ],
            "Resource": "*"
        }
    ]
}
```

### ✅ Key Notes

- Lambda Execution

    - Includes Invoke, UpdateFunctionCode, CreateFunction, DeleteFunction.

    - Covers full lifecycle of Lambda for DevOps automation.

- API Gateway

    - Full access for creating/updating REST APIs or integrating with Lambda.

- DynamoDB / RDS / S3

    - Full CRUD access for CI/CD scripts and Lambda integration.

- CloudWatch Logs

    - Full logging for monitoring and troubleshooting.

- EC2 & ECS

    - Limited to describe, start, stop, update for automated container/LAMP deployment.

---
