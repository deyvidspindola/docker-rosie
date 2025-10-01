# Dockerfile — Laravel 6.x (PHP 7.4)
FROM php:7.4-fpm-bullseye

ARG UID=1000
ARG GID=1000
ARG INSTALL_XDEBUG=false

# Pacotes do sistema
RUN apt-get update && apt-get install -y \
    git curl zip unzip nano sudo \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    libicu-dev \
    ghostscript imagemagick libmagickwand-dev \
    default-mysql-client \
 && rm -rf /var/lib/apt/lists/*

# Extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring bcmath zip intl exif pcntl calendar \
 && docker-php-ext-enable exif

# Imagick
RUN printf "\n" | pecl install imagick \
 && docker-php-ext-enable imagick

# Xdebug (opcional — controlado por build-arg)
RUN if [ "$INSTALL_XDEBUG" = "true" ]; then \
      pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug; \
    fi

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Node.js 14 (para Laravel Mix antigo)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

# Usuário não-root alinhado ao host (evita problemas de permissão)
RUN groupadd -g ${GID} laravel && useradd -u ${UID} -g laravel -m laravel

WORKDIR /var/www

# Configs PHP (copiadas do host)
COPY ./docker/php/conf.d/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY ./docker/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Permissões padrão
RUN chown -R laravel:laravel /var/www

USER laravel
