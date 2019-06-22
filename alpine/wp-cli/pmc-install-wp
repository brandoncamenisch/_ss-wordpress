#!/bin/sh
# Install WordPress
wp --allow-root core install \
	--admin_email="${WORDPRESS_EMAIL}" \
	--admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
	--admin_user="${WORDPRESS_ADMIN_USER}"\
	--skip-email \
	--title="${WORDPRESS_TITLE}" \
	--url="${WORDPRESS_DOMAIN}" \
	--quiet

# Activate theme
wp --allow-root --url=$WORDPRESS_DOMAIN theme activate $WORDPRESS_THEME
