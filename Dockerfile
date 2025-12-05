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

RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    libsqlite3-dev sqlite3 nginx \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip pdo_sqlite pdo_pgsql

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

COPY --from=frontend /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache /var/www/database \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

RUN php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear


# ============================
#  FINAL RUNTIME IMAGE
# ============================
FROM php:8.4-fpm

# Cài pdo_pgsql trong FINAL IMAGE
RUN apt-get update && apt-get install -y \
    nginx libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm /etc/nginx/sites-enabled/default

COPY --from=backend /var/www /var/www
COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www

# Fix permission để ghi log
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache /var/www/public \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

EXPOSE 80

CMD service nginx start && php-fpm
