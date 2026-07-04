FROM php:8.3-fpm-alpine

# 1. Install ekstensi database & zip via alpine package manager
RUN apk add --no-cache \
    libpq-dev \
    libzip-dev \
    zip \
    nginx \
    supervisor \
    curl

RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

# 2. Ambil binary Composer resmi dari image composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Atur konfigurasi Nginx
RUN mkdir -p /run/nginx
COPY .docker/nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html

# 4. Salin file composer terlebih dahulu agar proses caching layer Docker cepat
COPY composer.json composer.lock /var/www/html/

# 5. Jalankan composer install tanpa skrip autoloader dulu (opsional untuk optimasi)
RUN composer install --no-directory --no-scripts --no-autoloader --prefer-dist

# 6. Copy seluruh sisa file project ke direktori web root
COPY . /var/www/html

# 7. Dump autoloader ulang agar membaca file yang baru disalin
RUN composer dump-autoload --optimize

# 8. Atur permission folder storage & cache Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

CMD php-fpm -D && sed -i "s/8080/$PORT/g" /etc/nginx/nginx.conf && nginx -g "daemon off;"