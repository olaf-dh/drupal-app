FROM php:8.1-apache

WORKDIR /var/www/html

ENV APACHE_DOCUMENT_ROOT /var/www/html/web

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Get dependencies for Drupal
RUN apt-get update && \
    apt-get install -y libpng-dev \
                       libjpeg-dev \
                       libfreetype6-dev \
                       libwebp-dev \
                       libzip-dev \
                       unzip \
                       default-mysql-client

RUN docker-php-ext-install mysqli \
                           opcache \
                           pdo \
                           pdo_mysql

# Install image extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure zip && \
    docker-php-ext-install gd zip

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add some convenience
RUN echo "alias ll='ls -al --color'" > /etc/profile.d/app.sh
# works only when drush is required in composer.json
RUN echo "alias drush='vendor/bin/drush'" | tee -a /etc/profile.d/app.sh

# Use php.ini for development
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN a2enmod rewrite

# Clear composer list
RUN rm -rf /var/lib/apt/lists/*

COPY ./config/opcache.ini /usr/local/etc/php/conf.d/
