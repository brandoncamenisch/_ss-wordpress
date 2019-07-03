#!/bin/sh
wp_tests_dir="${WEB_ROOT}/wp-tests"
wp_tests_config="${wp_tests_dir}/wp-tests-config.php"

if [ ! -d "${wp_tests_dir}/.git" ]; then
	mkdir "${wp_tests_dir}"
	git -C "${wp_tests_dir}" init
	git -C "${wp_tests_dir}" remote add origin https://github.com/WordPress/wordpress-develop.git
fi

git -C "${wp_tests_dir}" fetch --depth 1 origin "${WORDPRESS_VERSION}"
git -C "${wp_tests_dir}" checkout "origin/${WORDPRESS_VERSION}" -- tests/phpunit/includes wp-tests-config-sample.php src
cp -v "${wp_tests_dir}/wp-tests-config-sample.php" "${wp_tests_config}"

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
echo "define( 'WP_TESTS_CONFIG_FILE_PATH', '$wp_tests_dir');" >> $wp_tests_config
