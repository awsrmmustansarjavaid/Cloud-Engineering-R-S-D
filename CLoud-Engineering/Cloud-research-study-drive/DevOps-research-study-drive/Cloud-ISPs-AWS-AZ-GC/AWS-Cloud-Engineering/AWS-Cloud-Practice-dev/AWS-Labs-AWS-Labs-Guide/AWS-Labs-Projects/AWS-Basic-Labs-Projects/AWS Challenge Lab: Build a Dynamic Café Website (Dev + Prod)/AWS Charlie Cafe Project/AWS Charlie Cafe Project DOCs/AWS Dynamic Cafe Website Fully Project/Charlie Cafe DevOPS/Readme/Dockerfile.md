# Charlie Cafe - Dockerfile

```
# -------------------------------------------------
# ☕ Charlie Cafe Dockerfile - PHP + Apache
# Copy multiple frontend folders to Apache web root
# -------------------------------------------------

# 1️⃣ Use official PHP + Apache image
FROM php:8.2-apache

# 2️⃣ Install required PHP extensions (MySQL / RDS)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 3️⃣ Enable Apache rewrite module (for clean URLs)
RUN a2enmod rewrite

# 4️⃣ Set working directory inside container
WORKDIR /var/www/html

# 5️⃣ Copy HTML files to Apache root
# Source: app/frontend/html/
# Destination: /var/www/html/
COPY ./app/frontend/html/ ./  

# 6️⃣ Copy PHP files to Apache root
# Source: app/frontend/php/
# Destination: /var/www/html/
COPY ./app/frontend/php/ ./  

# 7️⃣ Copy CSS files (optional, for frontend styling)
COPY ./app/frontend/css/ ./css/

# 8️⃣ Copy JS files (optional, for frontend scripts)
COPY ./app/frontend/js/ ./js/

# 9️⃣ Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# 🔟 Expose Apache port
EXPOSE 80
```

### 1️⃣ Your Dockerfile Explained

Your Dockerfile is:

```
FROM php:8.2-apache

# 1️⃣ Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 2️⃣ Enable Apache rewrite module
RUN a2enmod rewrite

# 3️⃣ Set working directory
WORKDIR /var/www/html

# 4️⃣ Copy app files
COPY ./app/frontend/html/ ./
COPY ./app/frontend/php/ ./
COPY ./app/frontend/css/ ./css/
COPY ./app/frontend/js/ ./js/

# 5️⃣ Set ownership so Apache can serve files
RUN chown -R www-data:www-data /var/www/html
```

#### Step-by-step explanation:

| Step | Command                                           | What it does                                                                                                            |
| ---- | ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 1    | `FROM php:8.2-apache`                             | Starts from the official PHP image with Apache installed.                                                               |
| 2    | `RUN docker-php-ext-install mysqli pdo pdo_mysql` | Installs PHP extensions for MySQL database support.                                                                     |
| 3    | `RUN a2enmod rewrite`                             | Enables Apache mod_rewrite (needed for pretty URLs in PHP apps).                                                        |
| 4    | `WORKDIR /var/www/html`                           | Sets the working directory inside the container. All subsequent commands (COPY, RUN, etc.) are relative to this folder. |
| 5    | `COPY ./app/frontend/html/ ./`                    | Copies all HTML files from your host folder into `/var/www/html` inside the container.                                  |
| 6    | `COPY ./app/frontend/php/ ./`                     | Copies all PHP files into the same container folder.                                                                    |
| 7    | `COPY ./app/frontend/css/ ./css/`                 | Copies CSS files into a subfolder `/var/www/html/css`.                                                                  |
| 8    | `COPY ./app/frontend/js/ ./js/`                   | Copies JS files into `/var/www/html/js`.                                                                                |
| 9    | `RUN chown -R www-data:www-data /var/www/html`    | Changes ownership of all files so Apache (user `www-data`) can serve them.                                              |

✅ After docker build, all files exist inside the image, not your host system.

#### 2️⃣ Build the Docker Image

```
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
```

- -t charlie-cafe → gives the image a name/tag.

- -f docker/apache-php/Dockerfile → tells Docker where the Dockerfile is.

- . → build context (current directory, must include your app files).

#### 3️⃣ Run the Container

```
docker run -d -p 80:80 --name charlie-cafe-server charlie-cafe
```

