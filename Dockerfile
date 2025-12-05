# ============================
#  FRONTEND BUILD
# ============================
FROM node:18 AS frontend
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build


# ============================
#  BACKEND BUILD
# ============================
FROM php:8.4-fpm AS backend

# Install system libs needed for sqlite + zip
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    libsqlite3-dev sqlite3 nginx \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip \
    && docker-php-ext-install pdo_sqlite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Copy frontend build output
COPY --from=frontend /app/public/build ./public/build

# Ensure SQLite database exists
RUN mkdir -p /var/www/database && \
    touch /var/www/database/database.sqlite

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache /var/www/database && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache /var/www/database

# Clear Laravel caches
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear


# ============================
#  FINAL RUNTIME IMAGE
# ============================
FROM php:8.4-fpm

RUN apt-get update && apt-get install -y nginx && \
    rm /etc/nginx/sites-enabled/default

COPY --from=backend /var/www /var/www
COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www
EXPOSE 80

RUN php artisan migrate --force || true

CMD service nginx start && php-fpm
