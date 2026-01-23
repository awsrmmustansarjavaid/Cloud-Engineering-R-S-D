#!/bin/bash
# --------------------------------------------
# EC2 User Data Script
# Amazon Linux 2023
# Installs LAMP Stack + MySQL Client
# --------------------------------------------

# 1️⃣ Update OS (MANDATORY FIRST)
dnf update -y

# 2️⃣ Install Apache (httpd)
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# 3️⃣ Install PHP + MySQL Support
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# 4️⃣ Fix Web Directory Permissions (MANDATORY)
chown -R apache:apache /var/www
chmod -R 755 /var/www

# 5️⃣ Install MySQL Client (MariaDB)
dnf install -y mariadb105

# 6️⃣ Create a PHP Info Page (Optional Verification)
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 7️⃣ Restart Apache to Apply PHP
systemctl restart httpd

# 8️⃣ Install AWS CLI
sudo dnf install -y awscli


# --------------------------------------------
# END OF USER DATA
# --------------------------------------------