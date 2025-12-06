# ========================================
# Stage 1 — Build Vite assets
# ========================================
FROM node:20 AS build-assets

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build


# ========================================
# Stage 2 — PHP + Composer + Laravel
# ========================================
FROM php:8.4-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy Laravel source
COPY . .

# Copy built assets from Stage 1
COPY --from=build-assets /app/public/build /var/www/public/build

# Install PHP packages
RUN composer install --no-dev --optimize-autoloader

# Clear caches
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear

# ========================================
# Render Free Tier: Run migrate automatically
# ========================================
CMD php artisan migrate --force && php-fpm
