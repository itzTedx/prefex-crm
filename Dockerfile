FROM php:8.1-apache

# Install system dependencies required by Perfex CRM extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libonig-dev \
    libc-client-dev \
    libkrb5-dev \
    libexif-dev \
    libicu-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure extensions that need flags before installing
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Install all required PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    mbstring \
    gd \
    zip \
    imap \
    iconv \
    exif \
    intl \
    opcache

# Enable Apache modules required by Perfex CRM .htaccess
RUN a2enmod rewrite headers

# Enable AllowOverride All so .htaccess URL rewriting works
RUN sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

# PHP runtime configuration
RUN { \
    echo "allow_url_fopen = On"; \
    echo "memory_limit = 256M"; \
    echo "upload_max_filesize = 64M"; \
    echo "post_max_size = 64M"; \
    echo "max_execution_time = 300"; \
    echo "date.timezone = UTC"; \
} > /usr/local/etc/php/conf.d/perfex.ini

# OPcache tuning for production
RUN { \
    echo "opcache.enable=1"; \
    echo "opcache.memory_consumption=128"; \
    echo "opcache.interned_strings_buffer=8"; \
    echo "opcache.max_accelerated_files=4000"; \
    echo "opcache.revalidate_freq=60"; \
} > /usr/local/etc/php/conf.d/opcache.ini

WORKDIR /var/www/html

# Copy application source
COPY . /var/www/html/

# Ensure writable directories exist and have correct ownership
RUN mkdir -p \
    uploads \
    temp \
    application/cache \
    application/logs \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod -R 775 uploads temp application/cache application/logs

# Copy and configure the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
