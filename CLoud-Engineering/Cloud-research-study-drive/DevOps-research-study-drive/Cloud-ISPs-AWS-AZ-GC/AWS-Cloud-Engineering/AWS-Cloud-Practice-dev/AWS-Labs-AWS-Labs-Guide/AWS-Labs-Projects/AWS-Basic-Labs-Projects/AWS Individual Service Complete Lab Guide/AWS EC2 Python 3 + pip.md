# AWS EC2 Python 3 + Pip

> **Author & Arthitecture Designer:** Charlie


## ✅ METHOD A (BEST & SIMPLE) – Use pip3

### 🔹 Step 1: Install Python 3 + pip

####  Run these commands one by one:

```
sudo yum update -y
sudo yum install python3 -y
```

#### Now verify:

```
python3 --version
```

#### You should see:

```
Python 3.x.x
```

### 🔹 Step 2: Install pip for Python 3

```
sudo yum install python3-pip -y
```

#### Now verify:

```
pip3 --version
```

#### You should see:

```
pip 23.x from ...
```

### 🔹 Step 3: Create Layer Folder 

#### On your local machine (Windows / Linux / Mac):

```
mkdir -p pymysql-layer/python
cd pymysql-layer
```

##### ⚠️ Folder name MUST be python (lowercase)

###### If this is wrong → Lambda will NOT find pymysql.


### 🔹 Step 4: Install PyMySQL into Layer

#### Run this inside pymysql-layer directory:

##### ⚠️ Use pip3 NOT pip

```
pip3 install pymysql -t python/
```

#### Now verify:

```
ls python/
```

#### You should see:

```
pymysql-layer/
└── python/
    ├── pymysql/
    ├── pymysql-1.x.x.dist-info/
```

##### ✅ If you do NOT see pymysql/ → STOP, it’s wrong.

### 🔹 Step 5: Zip the Layer (CRITICAL)

#### Run:

```
zip -r pymysql-layer.zip python
```

#### Check zip contents:

```
unzip -l pymysql-layer.zip
```

#### You MUST see:

```
python/pymysql/__init__.py
```

### 🔹 Step 6: Upload Layer Zip to AWS

#### From your EC2:

```
aws s3 cp pymysql-layer.zip s3://YOUR-BUCKET/
```

#### OR download locally:

```
scp -i key.pem ec2-user@<EC2-IP>:pymysql-layer.zip .
```

#### Then:

- ✔ Lambda → Layers → Create layer

- ✔ Upload zip

- ✔ Runtime: Python 3.10

## ✅ METHOD B (QUICK FIX)

### If you just want pip immediately:

```
python3 -m ensurepip --upgrade
```

#### Then:

```
python3 -m pip install pymysql -t python/
```