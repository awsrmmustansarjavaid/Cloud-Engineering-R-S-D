#!/bin/bash

# ---------------------------------------------
# Charlie Cafe - Set Permissions Script
# ---------------------------------------------

# List of files
FILES=(
"/var/www/html/index.php"
"/var/www/html/cafe-admin-dashboard.html"
"/var/www/html/orders.php"
"/var/www/html/order-status.html"
"/var/www/html/order-receipt.php"
"/var/www/html/admin-orders.html"
"/var/www/html/payment-status.php"
"/var/www/html/central-print.html"
"/var/www/html/analytics.html"
"/var/www/html/login.html"
"/var/www/html/logout.php"
"/var/www/html/price-list.html"
"/var/www/html/employee-login.html"
"/var/www/html/employee-portal.html"
"/var/www/html/hr-attendance.html"
"/var/www/html/checkin.html"
"/var/www/html/js/config.js"
"/var/www/html/js/central-auth.js"
"/var/www/html/js/utils.js"
"/var/www/html/js/api.js"
"/var/www/html/js/central-printing.js"
"/var/www/html/js/role-guard.js"
"/var/www/html/css/central_cafe_style.css"
)

# List of directories
DIRS=(
"/var/www/html/js"
"/var/www/html/css"
)

echo "---------------------------------------------"
echo "Setting ownership to apache:apache..."
sudo chown apache:apache "${FILES[@]}"
sudo chown -R apache:apache "${DIRS[@]}"

echo "---------------------------------------------"
echo "Setting directory permissions to 755..."
for dir in "${DIRS[@]}"; do
    sudo chmod 755 "$dir"
done

echo "---------------------------------------------"
echo "Setting file permissions to 644..."
for file in "${FILES[@]}"; do
    sudo chmod 644 "$file"
done

echo "---------------------------------------------"
echo "Verifying permissions..."
for file in "${FILES[@]}"; do
    perms=$(ls -l "$file" | awk '{print $1}')
    owner=$(ls -l "$file" | awk '{print $3":"$4}')
    echo "$file : $owner : $perms"
done

for dir in "${DIRS[@]}"; do
    perms=$(ls -ld "$dir" | awk '{print $1}')
    owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
    echo "$dir : $owner : $perms"
done

echo "---------------------------------------------"
echo "All permissions set and verified!"