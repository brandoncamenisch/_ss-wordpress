#!/bin/sh
coverage_filename="/tmp/coverage-${WORDPRESS_THEME}-$(git rev-parse --short HEAD).xml"
codecov_repo_token=$(curl -X GET --silent "https://codecov.io/api/bb/${ORG}/${WORDPRESS_THEME}" -H "Authorization: token ${CODECOV_AUTH_TOKEN}" | jq -r '.repo.upload_token')
if [ -n "${codecov_repo_token}" ]
	then curl -s https://codecov.io/bash | bash -s -- -t "${codecov_repo_token}" -c -B "$(git rev-parse --abbrev-ref HEAD)" -n "${coverage_filename}" -f "${coverage_filename}" -F unittests
fi
