FROM php:7.4-fpm-alpine

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

# we don't need a CMD here because we want the default CMD in the base image to run.