#!/bin/sh
"${COMPOSER_VENDOR_DIR}"/bin/wp-l10n-validator -1c "${TEXT_DOMAIN}" .wp-l10n-validator -- "$(cat "${PHP_DIFF_FILE}")"
