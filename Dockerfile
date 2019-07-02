ARG NODE_VERSION
ARG PHP_VERSION
ARG WEB_ROOT
ARG WORDPRESS_VERSION

# @NOTE: that this build is only necessary because we need soap for this and cli
FROM "wordpress:${WORDPRESS_VERSION}-php${PHP_VERSION}-fpm-alpine" AS wp
RUN apk add --update --no-cache libxml2-dev \
&& docker-php-ext-install soap

# @NOTE: that this build is only necessary because we need soap in cli as well
FROM "wordpress:cli-php${PHP_VERSION}" AS cli
USER root
RUN apk add --update --no-cache libxml2-dev git \
&& docker-php-ext-install soap
USER www-data

FROM wp AS test-php
RUN apk add --update --no-cache jq git $PHPIZE_DEPS \
&& pecl install -f xdebug \
&& docker-php-ext-enable xdebug

FROM "node:${NODE_VERSION}-alpine" AS build-npm

FROM "node:${NODE_VERSION}-alpine" AS test-npm
RUN apk add --update --no-cache git
