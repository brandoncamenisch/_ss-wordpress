#!/bin/sh
"${COMPOSER_VENDOR_DIR}"/bin/phpcs --config-set default_standard "${PHPCS_STANDARD}"
"${COMPOSER_VENDOR_DIR}"/bin/phpcs --runtime-set text_domain ${TEXT_DOMAIN} --parallel=3 --report=json > "${PHPCS_FILE}"
set -e
"${COMPOSER_VENDOR_DIR}"/bin/diffFilter --phpcsStrict "${DIFF_FILE}" "${PHPCS_FILE}" 100
set +e
