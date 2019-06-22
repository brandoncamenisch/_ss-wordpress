#!/bin/bash

install_wp() {
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
}

install_xdebug() {
	if [ 'dev' == "${APP_ENV}" ]; then
		apk add --no-cache $PHPIZE_DEPS
		pecl install -f xdebug
		docker-php-ext-enable xdebug

		echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /usr/local/etc/php/conf.d/xdebug.ini
		echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
		echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
		echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini && \
		echo "clear_env = no" >> /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
		# echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "xdebug.remote_autostart=${XDEBUG_REMOTE_AUTOSTART}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "xdebug.remote_connect_back=${XDEBUG_REMOTE_CONNECT_BACK}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "xdebug.remote_enable=${XDEBUG_REMOTE_ENABLE}" >> /etc/php/$PHP_VERSION/mods-available/xdeug.ini
		# echo "xdebug.remote_handler=${XDEBUG_REMOTE_HANDLER}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "xdebug.remote_host=${XDEBUG_REMOTE_HOST}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "xdebug.remote_port=${XDEBUG_REMOTE_PORT}" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		# echo "zend_extension=xdebug.so" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
		#
	fi
}

# Pulls down generic tests config from WP official
# Replaces with environment configs
	# Should not exist
install_wp_phpunit() {
	set -x

	local wp_tests_dir="${WEB_ROOT}/wp-tests"
	local wp_tests_config="${wp_tests_dir}/wp-tests-config.php"
	mkdir ${wp_tests_dir}

	# Get the version(s) we want from GH origin
	git -C ${wp_tests_dir} init
	git -C ${wp_tests_dir} remote add origin https://github.com/WordPress/wordpress-develop.git
	git -C ${wp_tests_dir} fetch --depth 1 origin ${WORDPRESS_VERSION}
	git -C ${wp_tests_dir} checkout "origin/${WORDPRESS_VERSION}" -- tests/phpunit/includes wp-tests-config-sample.php src
	cp -v ${wp_tests_dir}/wp-tests-config-sample.php ${wp_tests_config}

	# Replace with configurable tests variables
	sed -i  "s|dirname( __FILE__ ) . '/src/'|'$WEB_ROOT/'|" $wp_tests_config
	sed -i  "s|Test\ Blog|${WORDPRESS_TITLE}|" $wp_tests_config
	sed -i  "s|admins@example\.org|${WORDPRESS_EMAIL}|" $wp_tests_config
	sed -i  "s|example\.org|${WORDPRESS_DOMAIN}|" $wp_tests_config
	sed -i "s/youremptytestdbnamehere/$WORDPRESS_DB_NAME/" $wp_tests_config
	sed -i "s/yourpasswordhere/$WORDPRESS_DB_PASSWORD/" $wp_tests_config
	sed -i "s/yourusernamehere/$WORDPRESS_DB_USER/" $wp_tests_config
	sed -i "s|localhost|${WORDPRESS_TEST_DB_HOST}|" $wp_tests_config
	echo "define( 'AUTH_COOKIE', false );" >> $wp_tests_config
	echo "define( 'FILES_ACCESS_TOKEN', '123');" >> $wp_tests_config
	echo "define( 'FILES_CLIENT_SITE_ID', '123' );" >> $wp_tests_config
	echo "define( 'LOGGED_IN_COOKIE', false );" >> $wp_tests_config
	echo "define( 'WP_RUN_CORE_TESTS', '$wp_tests_dir');" >> $wp_tests_config
	# OFFICIAL
	echo "define( 'WP_TESTS_CONFIG_FILE_PATH', '$wp_tests_dir');" >> $wp_tests_config
	# PMC?
	echo "define( 'WP_TESTS_DIR', '$wp_tests_dir');" >> $wp_tests_config
}

run_npm_ci() {
	set -x
	export PATH=$(npm bin):$PATH
	apk add git
	if [ 'master' == $(git rev-parse --abbrev-ref HEAD) ]
		then lint-diff HEAD^..HEAD
		else lint-diff origin/master
	fi
}

# Runs all CI steps for the project
# Serves as a universal entrypoint
run_php_ci() {
	apk add jq git
	local commit=$(git rev-parse --short HEAD)
	local coverage_filename="/tmp/coverage-${WORDPRESS_THEME}-${commit}.xml"
	local commit_diff_filename="/tmp/commit-${commit}.diff"
	local codecov_filename="codecov-coverage-$(git rev-parse --short HEAD)"
	local codecov_repo_token=$(curl -X GET --silent "https://codecov.io/api/bb/${ORG}/${WORDPRESS_THEME}" -H "Authorization: token ${CODECOV_AUTH_TOKEN}" | jq -r '.repo.upload_token')

	# Master has different rules because it can't compare against itself and needs to only test the latest commit
	if [ 'master' == $(git rev-parse --abbrev-ref HEAD) ]
		then
			# Make a file for the commit diff to read into tests a variable is too large
			(git --no-pager diff --diff-filter=d --no-commit-id $(git rev-parse --short HEAD^) > $commit_diff_filename)
			export PHP_FILES="$(git --no-pager diff --diff-filter=d --no-commit-id --namr-only ${COMMIT}^ -- '*.php')"
		else
			(git --no-pager diff origin/master --diff-filter=d --no-commit-id) > $commit_diff_filename
			export PHP_FILES="$(git --no-pager diff origin/master --diff-filter=d --name-only -- '*.php')"
	fi

	for i in $PHP_FILES; do php -l $i; done
	$COMPOSER_VENDOR_DIR/bin/phpcs --config-set default_standard "${PHPCS_STANDARD}"
	$COMPOSER_VENDOR_DIR/bin/phpcs --runtime-set text_domain ${TEXT_DOMAIN} --report=json $PHP_FILES > phpcs.json
	$COMPOSER_VENDOR_DIR/bin/diffFilter --phpcsStrict $commit_diff_filename phpcs.json 100
	$COMPOSER_VENDOR_DIR/bin/wp-l10n-validator -1c ${TEXT_DOMAIN} .wp-l10n-validator -- $PHP_FILES

	install_wp_phpunit
	install_xdebug

	$COMPOSER_VENDOR_DIR/bin/phpunit -v --exclude-group pmc-phpunit-ignore-failed --coverage-clover=${coverage_filename}
	# $COMPOSER_VENDOR_DIR/bin/diffFilter --phpunit $commit_diff_filename ${coverage_filename}

	if [ -n "${codecov_repo_token}" ]
	  then curl -s https://codecov.io/bash | bash -s -- -t "${codecov_repo_token}" -c -B "$(git rev-parse --abbrev-ref HEAD)" -n "${codecov_filename}" -f "${codecov_filename}" -F unittests
	fi
}

translate_wp() {
	wp-pot \
	$(find -name "*.php" -not -path "./tests/*" -not -path "./vendor/*" | awk '{print "--src " $1}') \
	--dest-file "languages/${TEXT_DOMAIN}.pot" \
	--package "${TEXT_DOMAIN}" \
	--domain "${TEXT_DOMAIN}" \
	--last-translator "$(git --no-pager show -s --format="%an <%ae>" $(git rev-parse HEAD))" \
	--team "$(git config user.email) $(git config user.name)" \
	--bug-report '${ORG}'
}
