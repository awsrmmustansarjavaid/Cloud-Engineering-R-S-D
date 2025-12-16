# AWS EBS Lab Complete Guide 

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)


### 1.1 Create & Attach EBS
- Size: 10 GiB
- Attach to Public EC2


### 1.2 Format and Mount

#### Create File System

```
sudo mkfs -t xfs /dev/xvdf
```

#### Create Directory to Mount Volume

```
sudo mkdir /data
```

#### Mount the Volume

```
sudo mount /dev/xvdf /data
```

### 1.3 Persistent Mount

#### Edit /etc/fstab:

```
sudo nano /etc/fstab
```

Add this line:

```
/dev/xvdf /data xfs defaults,nofail 0 2
```

#### Save & exit, then test:

```
sudo mount -a
```


```
lsblk
```


