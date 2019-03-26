#!/bin/sh
set -e

if [ "$ENABLE_XDEBUG" = "true" ]; then
    echo "Enabling xdebug"
    gosu root docker-php-ext-enable xdebug
fi
