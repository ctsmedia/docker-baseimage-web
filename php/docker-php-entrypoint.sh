#!/bin/sh
set -e

# Run init scripts before firing up php
for f in /docker-entrypoint-init.d/*.sh; do
    . "$f"
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"