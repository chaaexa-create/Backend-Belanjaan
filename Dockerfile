FROM php:8.3-fpm-alpine

# 1. Install dependensi (termasuk supervisor untuk manage proses)
RUN apk add --no-cache \
    libpq-dev \
    libzip-dev \
    zip \
    nginx \
    supervisor \
    curl

RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 2. Atur konfigurasi Nginx
RUN mkdir -p /run/nginx
COPY .docker/nginx.conf /etc/nginx/nginx.conf

# 3. Buat file konfigurasi Supervisor untuk manage 3 proses
RUN printf "[supervisord]\nnodaemon=true\nuser=root\nlogfile=/var/log/supervisord.log\npidfile=/var/run/supervisord.pid\n\n[program:php-fpm]\ncommand=php-fpm -F\nstdout_logfile=/dev/stdout\nstderr_logfile=/dev/stderr\n\n[program:nginx]\ncommand=nginx -g 'daemon off;'\nstdout_logfile=/dev/stdout\nstderr_logfile=/dev/stderr\n\n[program:reverb]\ncommand=php artisan reverb:start --port=8000\nstdout_logfile=/dev/stdout\nstderr_logfile=/dev/stderr\n" > /etc/supervisord.conf

WORKDIR /var/www/html

# 4. Copy file composer dkk
COPY composer.json composer.lock /var/www/html/

RUN composer install --no-interaction --no-scripts --no-autoloader --prefer-dist

# 5. Copy seluruh sisa file project
COPY . /var/www/html

RUN composer dump-autoload --optimize

# 6. Atur permission folder storage & cache Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

# 7. Jalankan Supervisor (untuk start PHP-FPM, Nginx, Reverb sekaligus)
CMD sed -i "s/8080/$PORT/g" /etc/nginx/nginx.conf && /usr/bin/supervisord -c /etc/supervisord.conf