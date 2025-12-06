FROM php:8.4

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app files
COPY . .

# Copy .env.example nếu có
RUN cp .env.example .env || true

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel setup
RUN php artisan key:generate --force || true
RUN php artisan storage:link || true

# Fix permissions (important)
RUN chmod -R 777 storage bootstrap/cache

# Run migrations on build (Cách 1)
RUN php artisan migrate --force || true

EXPOSE 8080

# Start Laravel server
CMD php artisan serve --host 0.0.0.0 --port 8080
