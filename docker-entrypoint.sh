#!/bin/sh
set -e
echo "==> Menjalankan migrasi..."
php artisan migrate --force || true
php artisan storage:link || true

echo "==> Cache konfigurasi..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "==> Start server di port ${PORT:-8080}"
exec php artisan serve --host 0.0.0.0 --port "${PORT:-8080}"
