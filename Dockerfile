FROM node:18 AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


FROM php:8.4-fpm AS backend

RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip nginx \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear


FROM php:8.4-fpm

RUN apt-get update && apt-get install -y nginx \
    && rm /etc/nginx/sites-enabled/default

COPY --from=backend /var/www /var/www
COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www

EXPOSE 80

CMD service nginx start && php-fpm
