# AWS Linux 2023 Basic to Advance CLI Guide 

> **Author & Architecture Designer:** Charlie 


# 🐧 Amazon Linux 2023 – Basic to Advanced CLI Command Guide (AWS Focused)

This guide is designed for **AWS learners, Cloud Engineers, SysAdmins, and DevOps beginners** using **Amazon Linux 2023** on EC2.

It covers **daily-use, real-world commands** from **basic Linux operations → services → networking → security → web servers → troubleshooting → AWS-friendly tasks**.

---

## 📌 1. System Basics & Information

### Check OS Version

```bash
cat /etc/os-release
```

### Kernel Version

```bash
uname -r
```

### System Uptime

```bash
uptime
```

### CPU Information

```bash
lscpu
```

### Memory Usage

```bash
free -h
```

### Disk Usage

```bash
df -h
```

### Mounted Filesystems

```bash
lsblk
```

---

## 📌 2. Package Management (DNF – Daily Use)

### Update System (MOST COMMON)

```bash
sudo dnf update -y
```

### Search a Package

```bash
dnf search httpd
```

### Install a Package

```bash
sudo dnf install -y httpd
```

### Remove a Package

```bash
sudo dnf remove httpd
```

### List Installed Packages

```bash
dnf list installed
```

### Package Information

```bash
dnf info php
```

---

## 📌 3. File & Directory Management (Daily Admin Tasks)

### List Files

```bash
ls
ls -l
ls -la
```

### Create Directory

```bash
mkdir project
```

### Create File

```bash
touch index.html
```

### Copy Files

```bash
cp file1 file2
```

### Move / Rename

```bash
mv oldname newname
```

### Delete Files & Directories

```bash
rm file.txt
rm -rf folder
```

### File Permissions

```bash
chmod 755 script.sh
```

### Change Ownership

```bash
sudo chown ec2-user:ec2-user file.txt
```

---

## 📌 4. User & Permission Management (AWS EC2 Admin)

### Current User

```bash
whoami
```

### Add User

```bash
sudo useradd devuser
```

### Set Password

```bash
sudo passwd devuser
```

### Switch User

```bash
su - devuser
```

### Add User to sudo

```bash
sudo usermod -aG wheel devuser
```

---

## 📌 5. Service Management (systemctl – VERY IMPORTANT)

### Start Service

```bash
sudo systemctl start httpd
```

### Stop Service

```bash
sudo systemctl stop httpd
```

### Restart Service

```bash
sudo systemctl restart httpd
```

### Enable on Boot

```bash
sudo systemctl enable httpd
```

### Disable on Boot

```bash
sudo systemctl disable httpd
```

### Service Status

```bash
sudo systemctl status httpd
```

### List Running Services

```bash
systemctl list-units --type=service
```

---

## 📌 6. Networking Commands (AWS Troubleshooting)

### IP Address

```bash
ip a
```

### Routing Table

```bash
ip route
```

### Test Connectivity

```bash
ping google.com
```

### Check Open Ports

```bash
ss -tuln
```

### DNS Check

```bash
nslookup google.com
```

### Curl (API & Web Test)

```bash
curl http://localhost
```

---

## 📌 7. Firewall (firewalld – Optional in AL2023)

### Check Firewall Status

```bash
sudo systemctl status firewalld
```

### Start Firewall

```bash
sudo systemctl start firewalld
```

### Allow HTTP

```bash
sudo firewall-cmd --permanent --add-service=http
```

### Reload Firewall

```bash
sudo firewall-cmd --reload
```

⚠️ *In AWS, Security Groups are PRIMARY — firewall is secondary.*

---

## 📌 8. LAMP Stack Installation (COMMON AWS LAB TASK)

### Install Apache

```bash
sudo dnf install -y httpd
```

### Install PHP 8.x

```bash
sudo dnf install -y php php-cli php-common php-mysqlnd php-gd php-xml php-mbstring
```

### Start Apache

```bash
sudo systemctl start httpd
```

### Enable Apache

```bash
sudo systemctl enable httpd
```

### Verify Apache

```bash
curl http://localhost
```

### PHP Version

```bash
php -v
```

---

## 📌 9. Logs & Monitoring (Production Troubleshooting)

### View System Logs

```bash
journalctl -xe
```

### Service Logs

```bash
journalctl -u httpd
```

### Apache Logs

```bash
/var/log/httpd/access_log
/var/log/httpd/error_log
```

### Disk Usage by Folder

```bash
du -sh *
```

---

## 📌 10. Process Management

### Running Processes

```bash
ps aux
```

### Top (Live Monitoring)

```bash
top
```

### Kill Process

```bash
kill -9 PID
```

---

## 📌 11. Compression & Backup (AWS Admin Work)

### Create Archive

```bash
tar -czvf backup.tar.gz folder/
```

### Extract Archive

```bash
tar -xzvf backup.tar.gz
```

---

## 📌 12. AWS EC2-Specific Daily Commands

### Instance Metadata (VERY IMPORTANT)

```bash
curl http://169.254.169.254/latest/meta-data/
```

### Public IP

```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### Instance ID

```bash
curl http://169.254.169.254/latest/meta-data/instance-id
```

---

## 📌 13. Security Best Practices

### Disable Root Login (SSH)

```bash
sudo vi /etc/ssh/sshd_config
```

Set:

```
PermitRootLogin no
```

Restart SSH:

```bash
sudo systemctl restart sshd
```

---

## 📌 14. Useful Aliases (Productivity)

```bash
alias ll='ls -lah'
alias cls='clear'
```

---

## ✅ Final Notes

✔ Designed for **AWS EC2 + Amazon Linux 2023**
✔ Covers **real interview + job tasks**
✔ Perfect for **Cloud, SysAdmin, DevOps beginners**

---

If you want next:

* 🔹 **DevOps-focused Linux guide**
* 🔹 **Linux commands mapped to AWS interviews**
* 🔹 **Downloadable `.md` or `.pdf`**

Just tell me 👍

