#!/bin/sh
echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini
