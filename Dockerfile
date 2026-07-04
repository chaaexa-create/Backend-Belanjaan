FROM php:8.3-apache

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo_mysql pdo_pgsql zip

# Menonaktifkan mpm_event dan mengaktifkan mpm_prefork agar tidak konflik
RUN a2dismod mpm_event && a2enmod mpm_prefork    

RUN docker-php-ext-install pdo_mysql pdo_pgsql zip

RUN a2enmod rewrite

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf

COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

CMD sed -i "s/80/$PORT/g" /etc/apache2/ports.conf \
    && sed -i "s/:80/:$PORT/g" /etc/apache2/sites-available/000-default.conf \
    && apache2-foreground
