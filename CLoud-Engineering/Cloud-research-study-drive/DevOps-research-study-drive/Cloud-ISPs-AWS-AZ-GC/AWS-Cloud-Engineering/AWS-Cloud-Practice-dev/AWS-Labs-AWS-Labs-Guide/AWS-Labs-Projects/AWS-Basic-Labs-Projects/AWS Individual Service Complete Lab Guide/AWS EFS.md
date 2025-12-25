# AWS EFS Lab Complete Guide 

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)


### 14.1 Create EFS
- **Go to Amazon EFS → Create File System**
- Name: AdvancedLabEFS
- VPC: AdvancedLabVPC
- Mount target in private subnet
- SG: Allow NFS 2049 from EC2 SG

##### Click Customize (important)

### 14.2 Choose Network Settings:

#### Availability Zones:

- **Select AZs where your private EC2 instance exists**

#### Add mount targets:

- **Subnet: Private Subnet (e.g., 10.10.2.0/24)**

- **Security Group: Create new → EFS-SG**

```
Allow inbound NFS (2049) from EC2 SG
```

##### Click Create File System

#### Configure EFS Security Group

##### EFS-SG (Inbound rules):

- **Type:** NFS

- **Port:** 2049

- **Source:** EC2 instance Security Group (e.g., PrivateEC2-SG)

##### PrivateEC2-SG (Outbound rules):

- **Allow outbound to EFS-SG on port 2049**

✔ This ensures only private EC2 instances can mount the EFS.



### 14.3 Mount EFS on EC2

#### Install NFS Utilities on Private EC2

##### SSH into the private EC2 instance through your bastion or SSM session manager:

```
sudo yum install -y amazon-efs-utils
```

#### Create a Mount Directory for EFS

```
sudo mkdir /<filename>
```

**Example:**

```
sudo mkdir /efsdata
```

##### Verify:

```
ls -ld /<filename>
```

**Example:**

```
ls -ld /efsdata
```



#### Mount EFS on EC2

- **Go to : EFS → Your File System → Attach**

###### You’ll find your EFS mount command in the AWS console under Access Points → EC2 mount instructions.

##### Copy the command like this:

**Example:**

##### Mount EFS using DNS



```
sudo mount -t efs -o tls fs-12345678:/ /efsdata
```
or 

##### Mount EFS using IP

```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.3.127:/ efsdata
```

##### If this works, test:

```
df -h | grep efsdata
```

**🎉 EFS is mounted**

**✅ This uses:**

- **✔ DNS**

- **✔ TLS encryption**

- **✔ AZ-aware mount targets**

#### Verify Mount

```
df -h
```

##### You should see:

```
fs-xxxxxxxx:/  →  /efs
```

#### Test write:

```
sudo touch /efsdata/testfile.txt
```

#### Verify 

```
ls -l /efsdata
```


#### 🔒 Why Private EC2 Can Mount EFS (No Internet Needed)

##### EFS is VPC-internal:

```
Private EC2 ───► EFS Mount Target (ENI)
```

- **✔ No NAT**
- **✔ No IGW**
- **✔ No Internet**
- **✔ Uses private IP only**

###### So your design is 100% correct.




**📣 Replace fs-12345678 with your actual file system ID.**

### 14.3 Make EFS Persistent (Automatic Mounting)

#### Edit the fstab file:

```
sudo nano /etc/fstab
```

#### Edit the fstab file:

Add this line:

```
fs-12345678:/ /efsdata efs _netdev,tls 0 0
```

Save & exit.

Test it:

```
sudo mount -a
```

### 14.4 Test EFS Shared Storage

#### On EC2 instance:

```
sudo touch /efsdata/app-file.txt
```

```
ls -l /efsdata
```



**🕛 If you mount EFS on multiple EC2 instances later, all will see the same file.**
