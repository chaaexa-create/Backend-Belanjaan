#!/bin/bash
set -e

cd "$(dirname "$0")"

php artisan migrate --force

PORT="${PORT:-8080}"
# Ganti MATCH_RAILWAY_PORT menjadi port asli dari Railway
sed "s/MATCH_RAILWAY_PORT/$PORT/g" nginx.conf > /tmp/nginx.conf

# Jalankan Laravel internal di port 8001 agar tidak tabrakan dengan Nginx luar
php artisan serve --host=127.0.0.1 --port=8001 &

php artisan reverb:start --host=127.0.0.1 --port=8080 &

nginx -c /tmp/nginx.conf -g "daemon off;"
