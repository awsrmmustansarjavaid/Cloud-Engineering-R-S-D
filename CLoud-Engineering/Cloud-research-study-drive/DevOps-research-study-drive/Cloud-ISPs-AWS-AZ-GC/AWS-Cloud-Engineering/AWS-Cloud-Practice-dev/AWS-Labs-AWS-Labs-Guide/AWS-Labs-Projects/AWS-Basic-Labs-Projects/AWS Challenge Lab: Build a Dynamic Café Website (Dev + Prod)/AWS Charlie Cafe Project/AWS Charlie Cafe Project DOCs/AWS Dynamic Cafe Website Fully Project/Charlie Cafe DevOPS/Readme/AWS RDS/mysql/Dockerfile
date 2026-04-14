# -------------------------------------------------
# ☕ Charlie Cafe - MySQL Dockerfile (FINAL)
# Auto DB + Schema + Data Setup
# -------------------------------------------------

FROM mysql:8.0

# -------------------------------------------------
# Environment Variables
# -------------------------------------------------
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# -------------------------------------------------
# Auto-run SQL files on container startup
# (Executed in alphabetical order)
# -------------------------------------------------
COPY infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql

# -------------------------------------------------
# Expose MySQL port
# -------------------------------------------------
EXPOSE 3306