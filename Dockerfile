FROM php:8.4

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip nodejs npm \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app source
COPY . .

# Install PHP deps
RUN composer install --no-dev --optimize-autoloader

# Install JS deps and build Vite
RUN npm install
RUN npm run build

# Laravel setup
RUN php artisan key:generate --force || true
RUN php artisan storage:link || true

# Fix permissions
RUN chmod -R 777 storage bootstrap/cache

# Auto migrate
RUN php artisan migrate --force || true

EXPOSE 8080

CMD php artisan serve --host 0.0.0.0 --port 8080
