#!/bin/sh
set -e
for i in $(cat "${DIFF_FILE_PHP}"); do php -l "${i}"; done
set +e
