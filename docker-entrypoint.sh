#!/bin/sh
set -e
echo "==> Migrasi..."
php artisan migrate --force || true
php artisan storage:link || true

echo "==> Seed akun..."
php artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'admin@simpati.test'],['name'=>'Administrator','password'=>bcrypt('password'),'role'=>'admin','no_hp'=>'08000000000','is_active'=>true]);" || true
php artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'petugas@simpati.test'],['name'=>'Petugas Camat','password'=>bcrypt('password'),'role'=>'petugas','no_hp'=>'08123456789','is_active'=>true]);" || true
php artisan tinker --execute="\App\Models\Setting::firstOrCreate([],['nama_kantor'=>'Kantor Camat Brang Ene','telepon'=>'+62 85173464488','email'=>'kantorbrangene@gmail.com','alamat'=>'Kantor Brang Ene, Kab. Sumbawa Barat','hak_cipta'=>'Kantor Camat Brang Ene - Seksi Ketentraman dan Ketertiban']);" || true

echo "==> Cache..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "==> Start port ${PORT:-8080}"
exec php artisan serve --host 0.0.0.0 --port "${PORT:-8080}"
