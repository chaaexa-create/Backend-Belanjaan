#!/bin/bash
set -e

cd "$(dirname "$0")"

# Run migrations first
php artisan migrate --force

# Substitute PORT from Railway into nginx config
PORT="${PORT:-8080}"
sed "s/\${PORT}/$PORT/g" nginx.conf > /tmp/nginx.conf

# Start Laravel dev server
php artisan serve --host=127.0.0.1 --port=8000 &

# Start Reverb WebSocket server
php artisan reverb:start --host=127.0.0.1 --port=8080 &

# Start Nginx (foreground — keeps container alive)
nginx -c /tmp/nginx.conf -g "daemon off;"
