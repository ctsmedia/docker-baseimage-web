#!/bin/sh
set -e

if [ "$ENABLE_XDEBUG" = "true" ]; then
    docker-php-ext-enable xdebug
fi
