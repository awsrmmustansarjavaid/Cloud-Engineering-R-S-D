**Charlie Notes**

**🐧 Linux Fundamentals**

**Youtube Playlist URL:** [**Linux Zero To Hero**](https://www.youtube.com/playlist?list=PLe-5mmZeZbmhZZD5tBIReNOOnygP9yhGF)

## **📌 What is Linux?**

**Linux is an open-source operating system (OS) that manages computer hardware and software resources and allows users to run applications.**

-   **Free and publicly available source code**
-   **Widely used in servers, cloud computing, DevOps, cybersecurity, and embedded systems**
-   **Supports both:**
    -   **Graphical User Interface (GUI)**
    -   **Command-Line Interface (CLI / Terminal)**

## **🧱 Core Components of Linux**

**Component**

**Description**

**Kernel**

**Core of the OS that interacts directly with hardware (CPU, RAM, Disk)**

**Shell**

**Interface for user interaction (CLI or GUI)**

**File System**

**Organizes and manages files and directories**

**Bootloader**

**Loads the OS into memory during system startup**

**GUI (Optional)**

**Graphical interface like GNOME or KDE**

## **🧠 Key Definitions**

-   **Kernel: Lowest-level software that communicates with hardware**
-   **Bootloader: Program that starts the system and loads the OS**
-   **Shell: Command interface between user and OS**
-   **File System: Structure used to store and organize data**

## **🌳 Linux File System Structure**

**Linux uses a hierarchical (tree-like) structure, starting from the root directory /.**

-   **No separate drives like Windows (C:, D:)**
-   **Everything is treated as a file (including devices and processes)**

### **Example Structure:**

**/**

**├── home**

**├── etc**

**├── var**

**├── usr**

**├── bin**

**└── boot**

**📁 Important Linux Directories**

**Directory**

**Purpose**

**/**

**Root directory (starting point of all files)**

**/home**

**User personal directories**

**/root**

**Home directory of root user**

**/etc**

**System configuration files**

**/bin**

**Essential user commands (ls, cp, mv)**

**/sbin**

**System/admin commands**

**/var**

**Logs, cache, databases**

**/usr**

**Installed programs and libraries**

**/tmp**

**Temporary files**

**/dev**

**Device files (USB, disks)**

**/proc**

**System/process information**

**/boot**

**Bootloader and kernel files**

**/lib**

**Shared system libraries**

**💻 Basic Linux Commands**

**Command**

**Description**

**pwd**

**Show current directory**

**ls**

**List files and directories**

**cd**

**Change directory**

**mkdir**

**Create directory**

**touch**

**Create empty file**

**cp**

**Copy files/folders**

**mv**

**Move or rename files**

**rm**

**Delete files**

**cat**

**Display file contents**

**clear**

**Clear terminal**

**exit**

**Close terminal**

## **👤 Users and Permissions**

**Linux is a multi-user system with controlled access.**

### **User Types**

-   **root: Superuser (full access)**
-   **Normal users: Limited permissions**

### **Permission Types**

-   **r → Read**
-   **w → Write**
-   **x → Execute**

### **Permission Structure Example**

**\-rwxr-xr–**

**Section**

**Meaning**

**rwx**

**Owner permissions (full access)**

**r-x**

**Group permissions (read + execute)**

**r--**

**Others (read only)**

## **📦 Package Management**

**Used to install and manage software.**

-   **Debian/Ubuntu:**

**apt-get install <package-name>**

**Red Hat/CentOS:**

**yum install <package-name>**

**dnf install <package-name>**

**Other tools:**

-   **pacman, zypper, snap, flatpak**

## **🔍 Process Management & Monitoring**

**Command**

**Description**

**ps**

**Show running processes**

**top**

**Real-time system usage**

**htop**

**Advanced process viewer**

**kill**

**Stop a process**

**🧰 File Compression & Archiving**

**Command**

**Description**

**tar -cvf**

**Create archive**

**tar -xvf**

**Extract archive**

**gzip**

**Compress files**

**gunzip**

**Decompress files**

**🔑 Important Linux Concepts**

**Concept**

**Description**

**Shell Script**

**Executable file containing commands (.sh)**

**Cron Job**

**Scheduled automated task**

**Log Files**

**Stored in /var/log for troubleshooting**

**SSH**

**Remote login (ssh user@ip)**

**Sudo**

**Run commands as root (sudo <command>)**

## **⚙️ Linux in DevOps**

**Linux is the backbone of modern DevOps:**

-   **Cloud platforms (AWS, Azure, GCP)**
-   **CI/CD pipelines**
-   **Docker & Kubernetes**
-   **Automation tools (Ansible, Terraform)**

## **📘 CRUD Operations in Linux**

**CRUD stands for:**

-   **C – Create**
-   **R – Read**
-   **U – Update**
-   **D – Delete**

### **Applied To:**

-   **Files**
-   **Directories**
-   **File contents**
-   **System records (users, processes)**

## **🎯 Summary**

**Linux is a powerful, flexible, and essential OS used in modern IT infrastructure.  
Mastering Linux commands and concepts is critical for:**

-   **DevOps Engineers**
-   **Cloud Engineers**
-   **System Administrators**
-   **Cybersecurity Professionals**

# **🐧 Linux CRUD, Vim, Permissions & User Management (Professional Edition)**

# **📘 CRUD Operations in Linux**

CRUD stands for:

-   **C – Create**
-   **R – Read**
-   **U – Update**
-   **D – Delete**

## **🟩 C – CREATE Operations**

### **📄 Create a File**

touch filename.txt

**Example:**

touch notes.txt

### **📝 Create File with Content**

echo "Hello, Linux!" > hello.txt

OR

cat > data.txt

\# Type content, then press Ctrl + D to save

### **📁 Create a Directory**

mkdir foldername

**Example:**

mkdir projects

### **📂 Create Nested Directories**

mkdir -p devops/scripts/yaml

## **🟦 R – READ Operations**

### **📖 View File Content**

cat filename.txt

less filename.txt # Scrollable

more filename.txt # Page-wise output

### **🔍 View First or Last Lines**

head filename.txt # First 10 lines

tail filename.txt # Last 10 lines

### **📂 List Directory Contents**

ls

ls -l # Detailed view

ls -a # Show hidden files

### **🎯 Read Specific Line**

sed -n '3p' filename.txt

awk 'NR==3' filename.txt

## **🟨 U – UPDATE Operations**

### **➕ Append to File**

echo "New line" >> file.txt

### **✏️ Edit File**

nano filename.txt # Beginner-friendly

vim filename.txt # Advanced editor

### **🔄 Replace Text**

sed -i 's/oldtext/newtext/g' filename.txt

**Example:**

sed -i 's/Devops/Linux DevOps/g' notes.txt

### **🔁 Rename File/Folder**

mv oldname.txt newname.txt

### **📦 Move File**

mv file.txt /home/user/docs/

## **🟥 D – DELETE Operations**

### **❌ Delete File**

rm filename.txt

### **❌ Delete Directory**

rm -r foldername

### **⚠️ Force Delete**

rm -rf foldername

⚠ **Warning:  
**Never run rm -rf / — it can delete the entire system.

## **🛠 DevOps Use Cases (CRUD)**

**Task**

**Command**

Create config file

touch nginx.conf

Read logs

less /var/log/syslog

Update YAML

nano deployment.yaml

Delete temp files

rm -rf /tmp/\*

Move backup

mv backup.tar.gz /mnt/backup/

## **🧪 Practice Exercise**

\# Step 1: Create directory and file

mkdir devops\_practice

cd devops\_practice

touch inventory.txt

\# Step 2: Add data

echo "Server1: 192.168.1.1" >> inventory.txt

echo "Server2: 192.168.1.2" >> inventory.txt

\# Step 3: Modify data

sed -i 's/192.168.1.2/10.0.0.2/' inventory.txt

\# Step 4: View file

cat inventory.txt

\# Step 5: Delete file

rm inventory.txt

# **🧠 Vim Editor in Linux**

## **🔹 What is Vim?**

Vim (Vi Improved) is a **powerful terminal-based text editor** used in:

-   DevOps (YAML, Docker, Terraform)
-   System configuration
-   Remote servers (SSH)

## **🎮 Vim Modes**

**Mode**

**Purpose**

**Enter**

**Exit**

Normal

Navigation & control

Default / Esc

i, v, :

Insert

Typing text

i, a, o

Esc

Command

Save, quit, search

:

Enter

## **🔵 Normal Mode (Navigation)**

**Action**

**Key**

Move

h (left), j (down), k (up), l (right)

Word jump

w (next), b (previous)

Start of line

0

End of line

$

Top of file

gg

Bottom

G

Delete line

dd

Copy line

yy

Paste

p

Undo

u

Redo

Ctrl + r

## **🟡 Insert Mode**

### **Enter Insert Mode**

-   i → before cursor
-   a → after cursor
-   o → new line below
-   O → new line above

### **Exit**

Esc

## **🟣 Command Mode**

**Command**

**Meaning**

:w

Save

:q

Quit

:wq / ZZ

Save & exit

:q!

Force quit

:set nu

Show line numbers

## **🔍 Search & Replace**

/nginx # search

n / N # next / previous

:%s/old/new/g # replace all

## **📋 Copy, Cut, Paste**

**Action**

**Command**

Copy line

yy

Copy 3 lines

3yy

Delete line

dd

Delete 5 lines

5dd

Paste below

p

Paste above

P

## **📑 Visual Modes**

-   v → Character selection
-   V → Line selection
-   Ctrl + v → Block selection

## **🧪 Vim Practice**

vim test.sh

Steps:

1.  Press i
2.  Type:

#!/bin/bash

echo "Hello, Vim World!"

1.  Press Esc
2.  Save: :wq
3.  Run:

chmod +x test.sh

./test.sh

# **🔐 Linux File Permissions**

## **✅ Why Permissions Matter**

-   Protect system files
-   Control user access
-   Essential for DevOps & security

## **👥 User Categories**

**Symbol**

**Meaning**

u

User (owner)

g

Group

o

Others

## **🔤 Permission Types**

**Symbol**

**Meaning**

r

Read

w

Write

x

Execute

## **📄 Example**

\-rwxr-xr--

**Part**

**Meaning**

rwx

Owner: full

r-x

Group: read + execute

r--

Others: read

## **🔢 Numeric Permissions**

**Permission**

**Value**

r

4

w

2

x

1

**Combo**

**Value**

rwx

7

rw-

6

r-x

5

**Example:**

chmod 755 file.sh

## **🔧 chmod**

### **Symbolic**

chmod u+x script.sh

chmod g-w file.txt

chmod o=r file.txt

### **Numeric**

chmod 644 file.txt

chmod 700 secrets.txt

## **👤 chown**

chown user:group file

**Example:**

chown devops:team deploy.sh

## **📁 Directory Permissions**

**Permission**

**Meaning**

r

List files

w

Add/remove files

x

Enter directory

## **⭐ Special Permissions**

**Symbol**

**Name**

**Purpose**

s

Setuid/Setgid

Run as owner/group

t

Sticky Bit

Only owner can delete

**Example:**

chmod +t /shared

## **📊 Common Permission Sets**

**Octal**

**Meaning**

777

Full access to all

755

Owner full, others read/execute

700

Only owner

644

Owner write, others read

600

Owner only read/write

# **👤 Linux User Management**

## **🔎 Importance**

-   Security
-   Access control
-   Multi-user environment

## **👥 User Types**

**Type**

**Description**

Root

Full control

System Users

Used by services

Regular Users

Normal login users

## **➕ Create User**

sudo adduser riyas

OR

sudo useradd -m riyas

sudo passwd riyas

## **❌ Delete User**

sudo deluser riyas

sudo deluser --remove-home riyas

OR

sudo userdel -r riyas

## **🛠 Modify User**

sudo usermod -aG devops riyas

sudo usermod -l newname oldname

sudo usermod -d /new/home riyas

## **📂 Important System Files**

**File**

**Purpose**

/etc/passwd

User info

/etc/shadow

Passwords

/etc/group

Groups

/etc/sudoers

Sudo access

## **🔍 Check User Info**

id riyas

groups riyas

cat /etc/passwd | grep riyas

## **👥 Group Management**

### **Create Group**

sudo groupadd devops

### **Add User to Group**

sudo usermod -aG devops riyas

### **Remove User**

sudo gpasswd -d riyas devops

### **Delete Group**

sudo groupdel devops

# **🎯 Final Summary**

This section covers **real-world Linux skills required for DevOps**, including:

-   File operations (CRUD)
-   Vim editor mastery
-   Permissions & security
-   User and group management

# **🐧 Linux Advanced Topics (Sudo, Process, Packages, Services, Networking)**

# **🔐 5. Sudo (Superuser Do) Access**

## **✅ Grant Sudo Access**

sudo usermod -aG sudo riyas

### **OR (Safe Method)**

sudo visudo

Add:

riyas ALL=(ALL:ALL) ALL

## **🔒 Limited Sudo Access (Security Best Practice)**

Allow only specific commands:

riyas ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx

# **📁 6. Home Directory & Shell**

**Task**

**Command**

View home directory

echo $HOME

Change default shell

chsh -s /bin/bash riyas

Set custom home

usermod -d /custom/home riyas

# **🔐 7. Lock / Unlock Users**

### **🚫 Lock User**

sudo usermod -L riyas

### **🔓 Unlock User**

sudo usermod -U riyas

### **❌ Disable Login Shell**

sudo usermod -s /usr/sbin/nologin riyas

# **🛠 8. DevOps Use Cases (User Management)**

**Task**

**Command**

Create Jenkins user

adduser jenkins\_agent

Restrict deploy user

usermod -aG docker deployer

SSH-only access

Disable password + configure SSH keys

Group access to web folder

Set group ownership /var/www

Limited sudo for NGINX

visudo + command restriction

SFTP-only users

Use nologin shell

# **📊 User Management Cheat Sheet**

**Task**

**Command**

Add user

adduser <name>

Delete user

deluser <name> or userdel -r

Add to group

usermod -aG <group> <user>

List groups

groups <user>

Create group

groupadd <group>

Lock account

usermod -L <user>

Grant sudo

usermod -aG sudo <user>

# **⚙️ Linux Process Management**

## **🧠 What is a Process?**

A **process** is a running program with a unique **PID (Process ID)**.

## **🔄 Process States**

**State**

**Meaning**

R

Running

S

Sleeping

T

Stopped

Z

Zombie

D

I/O wait

## **📋 View Processes**

ps -ef

### **🔄 Real-Time Monitoring**

top

htop # Better UI (install required)

## **🔍 Search Process**

ps aux | grep nginx

pgrep nginx

## **🌳 Process Hierarchy**

pstree

## **▶ Start Process**

./script.sh

### **🧱 Run in Background**

./script.sh &

### **⏱ Keep Running After Logout**

nohup ./script.sh &

## **❌ Kill Processes**

**Action**

**Command**

Kill by PID

kill <PID>

Force kill

kill -9 <PID>

Kill by name

pkill nginx

Kill all

killall nginx

## **🎯 Foreground & Background Jobs**

**Task**

**Command**

Pause job

Ctrl + Z

Background

bg

List jobs

jobs

Foreground

fg %1

## **⚖️ Process Priority**

nice -n 10 ./task.sh

renice -n 5 -p 1234

-   Range: **\-20 (highest) → 19 (lowest)**

## **📊 Resource Usage**

ps aux --sort=-%mem | head

ps aux --sort=-%cpu | head

## **🛠 DevOps Use Cases**

**Task**

**Command**

Check running service

pgrep jenkins

Monitor CPU

top, htop

Debug process

ps aux

Kill stuck script

kill -9 $(pgrep -f script.py)

## **🔥 Advanced Tools**

**Tool**

**Use**

strace

Trace system calls

lsof

List open files

watch

Repeat command

systemctl

Manage services

cron

Schedule jobs

# **📦 Linux Package Management**

## **🔍 Overview**

Package managers install, update, and remove software.

## **🧭 Package Manager Types**

**Distro**

**Tool**

**Format**

Ubuntu/Debian

apt, dpkg

.deb

RHEL/CentOS

yum, dnf, rpm

.rpm

Arch

pacman

.pkg

Universal

snap, flatpak

—

## **📘 APT Commands**

sudo apt update

sudo apt upgrade

sudo apt install nginx

sudo apt remove nginx

apt search <name>

apt show <package>

sudo apt autoremove

## **📥 Install .deb**

sudo dpkg -i file.deb

sudo apt -f install

## **📕 YUM / DNF**

sudo dnf install nginx

sudo dnf remove nginx

sudo dnf upgrade

## **📦 pacman**

sudo pacman -Syu

sudo pacman -S package

sudo pacman -R package

## **🌐 snap / flatpak**

sudo snap install code --classic

snap list

flatpak install flathub com.spotify.Client

## **🛠 DevOps Use Cases**

**Task**

**Command**

Install Docker

apt install docker.io

Install Git

yum install git

Install Terraform

dpkg -i terraform.deb

# **🛠 Linux Service Management (systemd)**

## **🚦 What is a Service?**

A **service (daemon)** runs in the background (e.g., nginx, docker, ssh).

## **🌟 systemctl Commands**

sudo systemctl start nginx

sudo systemctl stop nginx

sudo systemctl restart nginx

systemctl status nginx

## **🔁 Enable / Disable**

sudo systemctl enable nginx

sudo systemctl disable nginx

systemctl is-enabled nginx

## **📜 View Logs**

journalctl -u nginx

journalctl -u nginx -f

## **📘 Service File Example**

\[Unit\]

Description=My App

After=network.target

\[Service\]

ExecStart=/usr/bin/python3 app.py

Restart=always

\[Install\]

WantedBy=multi-user.target

## **🛠 DevOps Use Cases**

**Task**

**Command**

Restart Jenkins

systemctl restart jenkins

Enable Docker

systemctl enable docker

Debug failure

journalctl -xe

# **🌐 Linux Network Management**

## **📌 Why Important?**

-   Connectivity
-   Troubleshooting
-   Cloud & container networking

## **🧰 Basic Commands**

ip addr

ip route

hostname -I

## **📡 Troubleshooting Tools**

**Tool**

**Purpose**

ping

Connectivity

traceroute

Path

dig / nslookup

DNS

ss / netstat

Ports

curl / wget

HTTP test

nmap

Scan ports

## **🌍 Configure Network**

sudo ip addr add 192.168.1.10/24 dev eth0

sudo ip link set eth0 up

## **📁 Config Files**

**File**

**Purpose**

/etc/hosts

Local DNS

/etc/resolv.conf

DNS servers

/etc/hostname

Hostname

## **🔥 Firewall**

### **UFW**

sudo ufw allow 22

sudo ufw enable

### **Firewalld**

sudo firewall-cmd --add-port=8080/tcp --permanent

sudo firewall-cmd --reload

## **🔗 Remote Access**

ssh user@host

scp file user@host:/path

rsync -av /src /dest

## **🛠 DevOps Use Cases**

**Task**

**Command**

Check open ports

ss -tuln

Test API

curl http://service

DNS check

dig domain.com

Port test

telnet host port

## **🧪 Practice Task**

ip a

ip route

ping 192.168.1.1

dig google.com

ss -tuln | grep 22

sudo ufw allow 80

# **🎯 Final Summary**

This section completes your **Linux + DevOps foundation**, covering:

-   Sudo & security control
-   Process management
-   Package management
-   Service management (systemd)
-   Networking & troubleshooting

# **🐧 Linux Troubleshooting, Access Control & File System (Professional Edition)**

# **🛠 Linux Troubleshooting – Full Guide**

## **📌 What is Troubleshooting?**

Troubleshooting in Linux is the process of identifying and resolving:

-   System errors
-   Service failures
-   Performance issues
-   Network problems
-   Disk and storage issues
-   Permission and access errors

## **🔍 1. Diagnostic Approach (Think Like DevOps)**

Before using tools, always ask:

-   What exactly is not working?
-   When did the issue start?
-   What changed recently (deployment, config, updates)?
-   Can the issue be reproduced?
-   Are logs available?

## **🧠 2. System Health Check**

### **⚙ CPU, Memory, Load**

top

htop

uptime # Load average

free -h # Memory usage

vmstat 1 # Real-time stats

### **💾 Disk Usage**

df -h # Disk space

du -sh \* # Folder sizes

lsblk # Block devices

### **⚠ Disk Errors**

dmesg | grep -i error

sudo smartctl -a /dev/sda

## **🌐 3. Network Troubleshooting**

**Task**

**Command**

Check IP

ip a

Ping host

ping 8.8.8.8

Trace route

traceroute google.com

DNS check

dig, nslookup

Port test

telnet, nc, nmap

Open ports

ss -tuln

Restart network

systemctl restart NetworkManager

## **📜 4. Log Files (Most Important)**

**Location**

**Purpose**

/var/log/syslog

System logs

/var/log/auth.log

Login & sudo logs

/var/log/dmesg

Kernel logs

/var/log/nginx/

Web server logs

/var/log/mysql/

Database logs

/var/log/journal/

systemd logs

### **View Logs**

tail -n 50 /var/log/syslog

journalctl -xe

## **⚙ 5. Service Troubleshooting**

systemctl status nginx

journalctl -u nginx -b

sudo systemctl restart nginx

## **🔑 6. Permission Issues**

### **Symptoms**

-   Permission denied
-   Scripts not executable
-   Service cannot read config

### **Commands**

ls -l file

chmod +x script.sh

chown user:group file

## **🧪 7. Application Debugging**

**Tool**

**Purpose**

bash -x script.sh

Debug shell scripts

python3 -m pdb script.py

Python debugging

node app.js

Node logs

curl -v

API debugging

## **🐘 8. Database Troubleshooting**

**Task**

**Command**

Check MySQL

systemctl status mysql

Access DB

mysql -u root -p

Logs

/var/log/mysql/error.log

Test connection

mysqladmin ping

## **📦 9. Package Issues**

### **Debian/Ubuntu**

sudo apt update

sudo apt install -f

sudo dpkg --configure -a

### **RHEL/CentOS**

sudo yum clean all

sudo yum check

## **⚙ 10. Process & Resource Issues**

ps -ef

top

kill <PID>

pkill <name>

ps aux --sort=-%mem

ps aux --sort=-%cpu

## **🔁 11. Recovery Operations**

**Task**

**Command**

Reboot

sudo reboot

Shutdown

sudo shutdown now

Remount FS

mount -o remount,rw /

Filesystem check

fsck /dev/sda1

## **✅ 12. Troubleshooting Checklist**

-   Is the service running?
-   Is the port open?
-   Can you ping or curl?
-   Are logs showing errors?
-   Is it permission related?
-   Is disk/memory full?
-   Any recent changes?

## **🧰 Useful Tools**

**Tool**

**Purpose**

htop

Resource monitoring

ncdu

Disk analyzer

strace

Debug system calls

lsof

Open files

tcpdump

Network capture

## **🧪 Practice Scenario**

systemctl status myapp

journalctl -u myapp -n 50

ss -tuln | grep 8080

df -h

ps -ef | grep myapp

# **🔐 Linux User Access Control (Real Scenario)**

## **🎯 Goal**

-   Create user
-   Give **full OR limited sudo access**

## **🔹 Step 1: Create User**

sudo adduser john

## **🔹 Step 2: Set Password**

sudo passwd john

## **🔹 Step 3: Full Sudo Access**

sudo usermod -aG sudo john

### **Test:**

sudo whoami # Output: root

## **🔒 Step 4: Limited Access**

sudo visudo

Add:

john ALL=(ALL) NOPASSWD: /bin/systemctl restart apache2

## **🔍 Multiple Commands**

john ALL=(ALL) NOPASSWD: /sbin/ifconfig, /usr/bin/apt-get update

## **🔎 Find Command Path**

which systemctl

## **🚫 Restrict Shell Access**

sudo usermod -s /usr/sbin/nologin john

## **🔄 Remove Sudo Access**

sudo deluser john sudo

## **📊 Summary**

**Task**

**Command**

Add user

adduser john

Set password

passwd john

Full sudo

usermod -aG sudo john

Limited sudo

visudo

Check access

sudo -l -U john

## **💡 DevOps Example**

**Intern can only restart NGINX + view logs:**

devopsintern ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx, /usr/bin/tail -n 100 /var/log/nginx/error.log

# **🗂 Linux File System Structure (Detailed)**

## **🧱 Root Directory /**

-   Top-level directory
-   Everything starts from /

## **📁 Standard Directories**

**Directory**

**Purpose**

/bin

Essential commands

/sbin

Admin commands

/boot

Kernel & bootloader

/dev

Device files

/etc

Configuration files

/home

User directories

/lib

Libraries

/media

Removable media

/mnt

Temporary mounts

/opt

Third-party apps

/proc

Process info

/root

Root user home

/run

Runtime data

/srv

Service data

/sys

Kernel/device info

/tmp

Temporary files

/usr

Programs & libraries

/var

Logs, cache, data

## **📘 Important /etc Files**

**File**

**Purpose**

/etc/passwd

User info

/etc/shadow

Passwords

/etc/group

Groups

/etc/hostname

Hostname

/etc/fstab

Mount config

/etc/hosts

Local DNS

/etc/resolv.conf

DNS

## **📂 /var Subdirectories**

**Directory**

**Purpose**

/var/log

Logs

/var/cache

Cache

/var/tmp

Temp files

/var/www

Web data

## **🧠 Virtual File Systems**

**Path**

**Purpose**

/proc

System & process info

/sys

Kernel interface

/dev

Hardware devices

## **📦 Binary & Package Locations**

**Path**

**Purpose**

/bin

Core commands

/usr/bin

User programs

/sbin

Admin tools

/lib

Libraries

/opt

Third-party apps

## **🏗 Mount Points**

mount /dev/sdb1 /mnt/usb

-   /mnt, /media commonly used

## **🌳 File System Hierarchy Diagram**

/

├── bin

├── boot

├── dev

├── etc

├── home

├── lib

├── media

├── mnt

├── opt

├── proc

├── root

├── run

├── sbin

├── srv

├── sys

├── tmp

├── usr

└── var

# **🎯 Final Summary (Your Complete Linux Notes)**

You now have a **complete Linux + DevOps foundation**, including:

-   System troubleshooting
-   User & access control
-   File system architecture
-   Logs, services, networking
-   Real-world DevOps scenarios

##