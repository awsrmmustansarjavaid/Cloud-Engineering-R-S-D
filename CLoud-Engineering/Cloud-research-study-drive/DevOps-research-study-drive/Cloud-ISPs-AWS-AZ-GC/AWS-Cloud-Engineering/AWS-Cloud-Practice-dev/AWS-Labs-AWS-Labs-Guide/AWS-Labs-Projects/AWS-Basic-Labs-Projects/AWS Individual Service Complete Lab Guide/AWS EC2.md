# AWS EC2 CLI Lab Complete Guide

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)

## 🔐 Section 1 - Linux User, Group & Permissions

### 1.1 Create a New Group

```
sudo groupadd <group_name>
```

#### 💡 Example:

```
sudo groupadd labgroup
```

**🎙️ Explanation:**

>This command creates a new user group named labgroup on the system. Groups are used to efficiently manage permissions for multiple users.


### 1.2 Create a New User

```
sudo useradd <user_name>
```

#### 💡 Example:

```
sudo useradd labuser
```

**🎙️ Explanation:**

>This command creates a new user account named labuser with its own home directory and basic system configurations.


### 1.3 Set New Password

```
sudo passwd <user_password>
```

#### 💡 Example:

```
sudo passwd labuser
```

**🎙️ Explanation:**

>This command is used by the system administrator (sudo) to set or change the password for the specified user (labuser).



### 1.4 Assign Directory Permissions

###### We will assign ownership of the /data directory to the group.

#### 1️⃣ Change Group Ownership of Directory

```
sudo chgrp <group_name> </directory or file>
```

#### 💡 Example:

```
sudo chgrp labgroup /data
```

**🎙️ Explanation:**

>This command changes the group owner of the /data directory to the newly created labgroup.


#### 2️⃣ Set Standard Group Permissions (Read/Write/Execute)

```
sudo chmod 770 /<directory or file>
```

#### 💡 Example:

```
sudo chmod 770 /data
```

**🎙️ Explanation:**

>This command modifies the permissions on the /data directory using octal notation (770).

- **7 (Owner):** Read, Write, Execute (Full Control)

- **7 (Group):** Read, Write, Execute (Full Control)

- **0 (Others):** No Permissions


#### 3️⃣ Set Elevated Group Permissions (With SetGID Bit)

###### OR if you want group to have elevated (root-like) privileges on this directory specifically:

###### Give setgid bit so new files belong to the group:

```
sudo chmod 2770 /<directory or file>
```

#### 💡 Example:

```
sudo chmod 2770 /data
```

**🎙️ Explanation:**

>This sets the same permissions as above but adds the Set Group ID (SetGID) bit (represented by the leading 2). The SetGID bit ensures that any file or directory created within /data will automatically inherit the group ownership (labgroup) of the parent directory, making it useful for shared directories.


### 1.5 Add User to Group and Verify

### 1️⃣ Add User to Group

```
sudo usermod -aG <group_name> <user_name>
```

#### 💡 Example:

```
sudo usermod -aG labgroup labuser
```

**🎙️ Explanation:**

>This command modifies the user account (usermod). The options -aG mean "append to the supplementary groups," effectively adding labuser to the labgroup while keeping their existing group memberships.


#### 2️⃣ Verify:

```
id <user_name>
```

#### 💡 Example:

```
id labuser
```

**🎙️ Explanation:**

>This command prints the user's identity information, including the User ID (UID), Primary Group ID (GID), and all supplementary groups they belong to. You use this to confirm that labgroup is listed for labuser.


###### You should see: labgroup in the groups list.

### 1.6 Test Permissions

#### 1️⃣ Switch to the user:

```
su - <user_name>
```

#### 💡 Example:

```
su - labuser
```

**🎙️ Explanation:**

>This command switches the current terminal session to the labuser account, simulating what that user would see and be able to do. The - flag initiates a full login shell, ensuring the user's environment variables are loaded correctly.


#### 2️⃣ Try writing into the directory:

```
touch /<directory_path>/<file_name>.txt
```

#### 💡 Example:

```
touch /data/testfile.txt
```

**🎙️ Explanation:**

>This command attempts to create an empty file in the /data directory. If the previous permissions and group settings were successful, labuser (who is now part of labgroup) should be able to create this file.

#### 3️⃣ List and Verify File Details

```
ls -l /<directory_path>
```

#### 💡 Example:

```
ls -l /data
```

**🎙️ Explanation:**

>This command lists the contents of the /data directory in a long format (-l), showing file permissions, owner, group owner, size, and creation date. This verifies that testfile.txt was created and, if SetGID was used, that its group owner is labgroup.

**🏆 If permissions are correct → success.**
