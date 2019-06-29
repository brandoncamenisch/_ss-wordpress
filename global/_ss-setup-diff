#!/bin/sh

# Update refs for BB
git fetch --quiet origin +refs/heads/*:refs/remotes/origin/*
# Master has different rules because it can't compare against itself and needs to only test the latest commit
if [ "master" = "$(git rev-parse --abbrev-ref HEAD)" ]
	then

		# Make a file for the commit diff to read into tests a variable is too large
		(git --no-pager diff --diff-filter=d --no-commit-id "$(git rev-parse --short HEAD^)") > "${DIFF_FILE}"
		(git --no-pager diff --diff-filter=d --no-commit-id --name-only "$(git rev-parse --short HEAD^)" -- '*.css') >> "${DIFF_FILE_CSS}"
		(git --no-pager diff --diff-filter=d --no-commit-id --name-only "$(git rev-parse --short HEAD^)" -- '*.js') >> "${DIFF_FILE_JS}"
		(git --no-pager diff --diff-filter=d --no-commit-id --name-only "$(git rev-parse --short HEAD^)" -- '*.php') >> "${DIFF_FILE_PHP}"
		(git --no-pager diff --diff-filter=d --no-commit-id --name-only "$(git rev-parse --short HEAD^)" -- '*.scss') >> "${DIFF_FILE_SCSS}"
	else
		(git --no-pager diff origin/master --diff-filter=d --no-commit-id) >> "${DIFF_FILE}"
		(git --no-pager diff origin/master --diff-filter=d --name-only -- '*.css') >> "${DIFF_FILE_CSS}"
		(git --no-pager diff origin/master --diff-filter=d --name-only -- '*.js') >> "${DIFF_FILE_JS}"
		(git --no-pager diff origin/master --diff-filter=d --name-only -- '*.php') >> "${DIFF_FILE_PHP}"
		(git --no-pager diff origin/master --diff-filter=d --name-only -- '*.scss') >> "${DIFF_FILE_SCSS}"-
fi
