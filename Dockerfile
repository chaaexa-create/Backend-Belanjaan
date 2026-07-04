FROM php:8.3-fpm-alpine

# 1. Install ekstensi database & zip via alpine package manager (Sangat cepat & bersih)
RUN apk add --no-cache \
    libpq-dev \
    libzip-dev \
    zip \
    nginx \
    supervisor

RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

# 2. Atur konfigurasi Nginx untuk Laravel public folder
RUN mkdir -p /run/nginx
COPY .docker/nginx.conf /etc/nginx/nginx.conf

# 3. Copy file project ke direktori web root
WORKDIR /var/www/html
COPY . /var/www/html

# 4. Atur permission folder storage & cache Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

# 5. Jalankan Nginx & PHP-FPM bersamaan menggunakan instruksi dinamis port Railway
CMD php-fpm -D && sed -i "s/8080/$PORT/g" /etc/nginx/nginx.conf && nginx -g "daemon off;"