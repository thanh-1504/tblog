# Stage 1 - Build Frontend (Vite)
FROM node:18 AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


# Stage 2 - PHP Backend
FROM php:8.4-fpm AS backend

RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip nginx \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader

# Clear caches
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear


# Stage 3 - Runtime (Nginx + PHP-FPM)
FROM php:8.4-fpm

# Install Nginx
RUN apt-get update && apt-get install -y nginx \
    && rm /etc/nginx/sites-enabled/default

# Copy App + PHP-FPM from backend
COPY --from=backend /var/www /var/www

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www

EXPOSE 80

CMD service nginx start && php-fpm
