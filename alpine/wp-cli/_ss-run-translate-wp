#!/bin/sh
wp-pot \
$(find -name "*.php" -not -path "./tests/*" -not -path "./vendor/*" | awk '{print "--src " $1}') \
--dest-file "languages/${TEXT_DOMAIN}.pot" \
--package "${TEXT_DOMAIN}" \
--domain "${TEXT_DOMAIN}" \
--last-translator "$(git --no-pager show -s --format="%an <%ae>" $(git rev-parse HEAD))" \
--team "$(git config user.email) $(git config user.name)" \
--bug-report '${ORG_URL}'
