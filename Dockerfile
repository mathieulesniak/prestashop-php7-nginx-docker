FROM php:7.2-fpm

MAINTAINER Mathieu LESNIAK <mathieu@lesniak.fr>

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y --no-install-recommends \
    nginx \
    apt-utils \
    locales \
    wget \
    curl \
    git \
    msmtp \
    libmemcached-dev \
    libxml2-dev \
    libfreetype6-dev \
    libicu-dev \
    libmcrypt-dev \
    zlib1g-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxpm-dev \
    libzip-dev \
    libmagickwand-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install mcrypt-1.0.2 memcached \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
    && docker-php-ext-install -j$(nproc) iconv intl pdo_mysql mbstring soap gd zip xml json mysqli opcache \
    && docker-php-ext-enable mcrypt memcached
RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/bin/msmtp -t"'; \
    } > /usr/local/etc/php/conf.d/msmtp.ini

# opcode recommended settings
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=0'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini
# Prestashop settings
RUN { \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=128M'; \
    echo 'max_input_vars=5000'; \
    echo "date.timezone='Europe/Paris'"; \
    } > /usr/local/etc/php/conf.d/prestashop.ini

RUN apt-get remove --purge curl -y && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*

COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh

RUN usermod -u 1000 www-data
WORKDIR /var/www/
EXPOSE 80

ENTRYPOINT ["sh", "/etc/entrypoint.sh"]

