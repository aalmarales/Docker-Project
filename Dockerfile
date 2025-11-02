FROM php:8.4-fpm

# Instalar Node.js (para Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs

# Instalar PHP extensions y Composer...
RUN apt-get update && apt-get install -y \
    git libpng-dev libxml2-dev libzip-dev unzip libonig-dev libpq-dev postgresql-client \
    && docker-php-ext-install pdo pdo_mysql gd zip mbstring \
    exif \
    pcntl \
    bcmath \
    pdo_pgsql \
    pgsql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 1. Copiar archivos de Composer y package.json
COPY composer.json composer.lock package.json package-lock.json vite.config.js ./

# 4. Copiar el resto (INCLUYE vite.config.js y resources/)
COPY . .

# 2. Crear directorios de cache y storage con permisos ANTES de composer install
RUN mkdir -p /var/www/html/bootstrap/cache \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/framework/cache \
    /var/www/html/storage/logs

#RUN chown -R www-data:www-data /var/www/html/storage
#RUN chown -R www-data:www-data /var/www/html/bootstrap/cache
#RUN chmod -R 775 /var/www/html/storage
#RUN chmod -R 775 /var/www/html/bootstrap/cache

# 2. Instalar dependencias PHP
RUN composer install --no-dev  --optimize-autoloader

# 3. Instalar dependencias Node.js
RUN npm ci



# 5. Build de assets con Vite
RUN npm run build

# 6. Ejecutar scripts de Composer
#RUN composer run-script post-install-cmd

# Permisos de Laravel...
#RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
#RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

CMD ["php-fpm"]