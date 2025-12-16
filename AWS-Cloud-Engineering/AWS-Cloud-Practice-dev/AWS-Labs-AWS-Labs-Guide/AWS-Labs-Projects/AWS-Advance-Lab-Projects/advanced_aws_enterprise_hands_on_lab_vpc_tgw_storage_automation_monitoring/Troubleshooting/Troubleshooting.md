
# Advanced AWS Enterprise Hands-On Lab

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)




## Section 1 - EFS

### 🔵 How to Verify amazon-efs-utils Is Installed (Before Mounting)

####  1. Check if the Package Is Installed (RPM level)

```
rpm -qa | grep amazon-efs-utils
```

##### Expected output (example):

```
amazon-efs-utils-1.39-1.amzn2023.noarch
```

✔ This confirms the package is installed.


####  2. Check the EFS Mount Helper Exists (MOST IMPORTANT)

```
which mount.efs
```
##### Expected output:

```
/usr/bin/mount.efs
```

✔ This confirms the EFS mount helper is available.

If this command returns nothing, the install did not succeed.



####  3. Check Version of amazon-efs-utils

```
mount.efs --version
```

or:

```
amazon-efs-utils --version
```

✔ Confirms the tool is working.


####  4. Verify Required NFS Utilities Are Present

EFS uses NFS under the hood.

```
which mount.nfs4
```

##### Expected:

```
/usr/sbin/mount.nfs4
```

✔ Required for EFS mounting.

####  5. Confirm Package Files Are Installed

(Optional but useful)

```
rpm -ql amazon-efs-utils
```

##### You should see files like:

```
/usr/bin/mount.efs
/etc/amazon/efs/efs-utils.conf
```

####  6. Check TLS Support (Used by -o tls)

EFS with TLS uses stunnel.

```
which stunnel
```

or:

```
rpm -qa | grep stunnel
```

✔ If installed, TLS mounting will work.


####  🧪 Quick Pre-Mount Readiness Test

##### Before mounting, run these commands in order:

```
sudo mkdir -p /efs
which mount.efs
mount.efs --version
```

✔ If all return valid outputs → you are ready to mount.


####  🚨 If Something Is Missing

##### Reinstall safely:

```
sudo yum remove -y amazon-efs-utils
sudo yum clean all
sudo yum install -y amazon-efs-utils
```




