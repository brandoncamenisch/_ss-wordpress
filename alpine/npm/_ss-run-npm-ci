#!/bin/sh
export PATH=$(npm bin):$PATH
if [ 'master' == $(git rev-parse --abbrev-ref HEAD) ]
	then lint-diff HEAD^..HEAD
	else lint-diff origin/master
fi
