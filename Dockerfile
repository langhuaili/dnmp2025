# 使用官方PHP 7.4镜像作为基础
FROM php:7.4-fpm

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