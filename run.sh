#!/bin/sh

php artisan migrate:fresh --seed

exec "$@"
