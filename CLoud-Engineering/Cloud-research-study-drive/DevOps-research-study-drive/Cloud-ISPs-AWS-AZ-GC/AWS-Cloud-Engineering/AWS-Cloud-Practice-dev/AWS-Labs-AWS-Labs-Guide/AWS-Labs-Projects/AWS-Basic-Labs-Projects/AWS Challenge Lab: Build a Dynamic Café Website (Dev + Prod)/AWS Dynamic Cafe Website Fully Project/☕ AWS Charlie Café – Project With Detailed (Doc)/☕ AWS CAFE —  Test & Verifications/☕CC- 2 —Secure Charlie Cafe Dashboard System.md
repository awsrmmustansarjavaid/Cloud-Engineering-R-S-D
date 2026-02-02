# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System



# SECTION 1️⃣ Secure Admin Order Dashboard

## 🔐 PHASE 1️⃣ — Set Up Automatic HTTP → HTTPS Redirection

### 1️⃣  — USE EC2 PUBLIC IP (BEST FOR LAB)

> **This is 100% acceptable for labs and Cognito testing**

#### STEP 1️⃣ — CONFIRM EC2 IS PUBLIC

#### 1️⃣ Go to:

```
EC2 → Instances
```

#### 2️⃣ Select your instance

#### 3️⃣ Copy:

```
Public IPv4 address
```

Example:

```
54.183.22.10
```

#### ⚠️ If you do NOT see a public IP:

- Instance must be in a public subnet

- Must have Internet Gateway

#### STEP 2️⃣ — CONFIRM APACHE IS RUNNING

#### SSH into EC2:

```
sudo systemctl status httpd
```

#### If not running:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### STEP 3️⃣ — TEST PAGE DIRECTLY

#### Open browser:

```
http://54.183.22.10/cafe-admin-dashboard.html
```

✅ If page opens → PERFECT

❌ If not → check Security Group


#### STEP 4️⃣ — FIX SECURITY GROUP (VERY IMPORTANT)

#### 1️⃣ Go to:

```
EC2 → Security Groups → Your SG
```

#### 2️⃣ Inbound rules:

```
HTTP   TCP   80   0.0.0.0/0
```

Save

#### STEP 5️⃣ — USE THIS AS RETURN URL IN COGNITO

Now you FINALLY have a valid Return URL.

#### Use:

```
http://54.183.22.10/cafe-admin-dashboard.html
```

**⚠️ BUT Cognito REQUIRES HTTPS**

> **So for Cognito we must do ONE SMALL CHANGE**

#### STEP 6️⃣  — TEST ALB DNS WEB PAGE

Open:

```
https://ALB-DNS/cafe-admin-dashboard.html
```

✅ Works → DONE

#### STEP 6️⃣  — TEST cloudfront

#### 1️⃣ Basic Connectivity Test

Open in browser:

```
https://xxxxx.cloudfront.net/
```

#### Expected result:

```
order-status.html loads
OR

Cafe homepage loads (if root object not set)
```

#### 2️⃣ Direct File Test

Open:

```
https://xxxxx.cloudfront.net/cafe-admin-dashboard.html
```

#### Expected:

```
Page loads successfully

No 403 / 504 / timeout errors
```

#### 3️⃣ Backend Health Verification

If CloudFront fails:

Test ALB directly:

```
http://ALB-DNS-NAME/cafe-admin-dashboard.html
```

#### Ensure:

- ALB target group = Healthy

- EC2 Apache is running

- Security Groups allow ALB → EC2 (port 80)

#### ✅ FINAL RECOMMENDED PATH

| Step       | Do this                        |
| ---------- | ------------------------------ |
| Host page  | EC2 Apache                     |
| HTTPS      | ALB                            |
| Return URL | ALB DNS + `/cafe-admin-dashboard.html` |
| CloudFront | Later (optional)               |

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


