FROM php:8.3-apache

ARG DEBIAN_FRONTEND=noninteractive

# 1. Install library sistem Linux yang dibutuhkan
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    zip

# 2. Atur modul Apache MPM agar tidak bentrok (Wajib sebelum install ekstensi PHP)
RUN a2dismod mpm_event && a2enmod mpm_prefork

# 3. Install ekstensi PHP (Cukup jalankan SATU kali saja di sini)
RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

# 4. Aktifkan mod_rewrite Laravel
RUN a2enmod rewrite

# 5. Ubah Document Root Apache ke folder public Laravel
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf

# 6. Copy semua file project
COPY . /var/www/html

# 7. Set permission folder storage & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

CMD sed -i "s/80/$PORT/g" /etc/apache2/ports.conf \
    && sed -i "s/:80/:$PORT/g" /etc/apache2/sites-available/000-default.conf \
    && apache2-foreground