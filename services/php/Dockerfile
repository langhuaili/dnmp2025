ARG PHP_VERSION
FROM php:7.4-fpm

ARG TZ
ARG PHP_EXTENSIONS
ARG CONTAINER_PACKAGE_URL


ADD ./extensions/install-php-extensions  /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

# 安装系统依赖及常用工具
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libssl-dev \
    libxml2-dev \
    libicu-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安装核心PHP扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install exif

# 安装PECL扩展 (Redis, Xdebug等)
RUN pecl install redis-5.3.7 \
    && pecl install xdebug-3.1.6 \
    && docker-php-ext-enable redis xdebug

# 创建快捷命令脚本
RUN echo '#!/bin/bash\n\
if [ "$1" = "install" ]; then\n\
    shift\n\
    docker-php-ext-install "$@" \n\
elif [ "$1" = "pecl-install" ]; then\n\
    shift\n\
    pecl install "$@" \n\
    docker-php-ext-enable "${@%%-*}" \n\
else\n\
    echo "Usage: php-ext install [extension_name]"\n\
    echo "       php-ext pecl-install [pecl_package]"\n\
fi' > /usr/local/bin/php-ext \
    && chmod +x /usr/local/bin/php-ext

# 清理缓存
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

# Install composer and change it's cache home
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN set -eux; \
    # 修改用户组GID
    groupmod -g 1000 www-data; \
    # 修改用户UID并关联到已修改的组
    usermod -u 1000 -g 1000 www-data; \
    # 清理apt缓存（非必须但推荐）
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

WORKDIR /var/www
