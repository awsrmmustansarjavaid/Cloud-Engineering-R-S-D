# AWS IAM 



## PHASE 1️⃣ IAM Role for EC2 (Secrets Access)

### Step 1: Create IAM Role

Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
  }]
}
```

Role name:

```
EC2-Cafe-Secrets-Role
```

Attach role to EC2 (NO reboot).

### Step 2: Verify IAM Role is Attached

#### Run this on EC2:

###### If an IAM role is attached correctly to an EC2 instance, these MUST work:

```
curl http://169.254.169.254/latest/meta-data/iam/info
```

#### Expected output (example):

```
{
  "Code" : "Success",
  "LastUpdated" : "2026-01-04T10:22:18Z",
  "InstanceProfileArn" : "arn:aws:iam::123456789012:instance-profile/EC2-Cafe-Secrets-Role",
  "InstanceProfileId" : "AIPAXXXXXXXXX"
}
```

```
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

#### Expected output (example):

```
EC2-Cafe-Secrets-Role
```

###### ✅ If role is attached, you will see JSON output.

---

## PHASE 2️⃣ IAM Role for EC2 (Secrets Access)

