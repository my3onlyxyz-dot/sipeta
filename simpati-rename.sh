#!/usr/bin/env bash
# ============================================================
#  SIMPATI — Ganti nama SIMPATI → SIMPATI di seluruh project
#  Jalankan di ~/myapp:  bash simpati-rename.sh
# ============================================================
set -e
[ -f artisan ] || { echo "!! Jalankan di dalam folder Laravel (~/myapp)."; exit 1; }
echo "==> Ganti nama SIMPATI → SIMPATI"

# ============================================================
# 1. Ganti semua kemunculan teks di file PHP, Blade, JS, CSS, sh, md
# ============================================================
find . -type f \( \
  -name "*.php" -o -name "*.blade.php" -o \
  -name "*.js" -o -name "*.css" -o \
  -name "*.sh" -o -name "*.md" -o \
  -name "*.env*" -o -name "*.json" -o \
  -name "Dockerfile" -o -name "*.txt" \
\) \
  ! -path "./.git/*" \
  ! -path "./vendor/*" \
  ! -path "./node_modules/*" \
  ! -path "./public/build/*" \
| while read f; do
  sed -i \
    -e 's/SIMPATI/SIMPATI/g' \
    -e 's/Simpati/Simpati/g' \
    -e 's/simpati/simpati/g' \
    "$f"
done
echo "   Teks diganti di semua file."

# ============================================================
# 2. Tulis ulang layout app.blade.php — nama + tagline lengkap
# ============================================================
echo "==> Layout & branding"

# Fungsi bantu: ganti teks di dalam file spesifik
update_brand() {
  # Judul sidebar
  sed -i \
    -e 's|<p class="font-display font-bold text-slate-900">SIMPATI</p>|<p class="font-display font-bold text-slate-900 text-xs leading-tight">SIMPATI</p>|g' \
    resources/views/layouts/app.blade.php

  # Tagline sidebar (ganti teks lama)
  sed -i \
    -e 's|<p class="text-\[11px\] text-slate-400">Sengketa Tanah</p>|<p class="text-[10px] text-slate-400 leading-tight">Mediasi \&amp; Penanganan<br>Sengketa Tanah</p>|g' \
    resources/views/layouts/app.blade.php
}

# ============================================================
# 3. Tulis ulang layout guest.blade.php — panel kiri + tagline
# ============================================================
cat > resources/views/layouts/guest.blade.php << 'BEOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title', 'Masuk') · SIMPATI</title>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
  <style>body{background:#f1f5f9;color:#0f172a}*:focus-visible{outline-color:#047857}</style>
</head>
<body class="min-h-screen grid lg:grid-cols-2">
  <div class="hidden lg:flex flex-col justify-between p-12 text-white relative overflow-hidden"
       style="background:radial-gradient(120% 140% at 100% 0%, #10b981 0%, #047857 45%, #065f46 100%)">
    <div class="flex items-center gap-2.5">
      <span class="grid place-items-center w-10 h-10 rounded-xl bg-white/10">
        <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
      </span>
      <div class="leading-tight">
        <p class="font-display font-bold text-lg">SIMPATI</p>
        <p class="text-emerald-100/70 text-xs">Kantor Camat Brang Ene</p>
      </div>
    </div>
    <div>
      <p class="text-emerald-100/60 text-xs uppercase tracking-widest mb-3">Seksi Ketentraman & Ketertiban</p>
      <h2 class="font-display text-2xl font-bold leading-snug">Sistem Informasi Mediasi<br>dan Penanganan<br>Sengketa Tanah</h2>
      <p class="text-emerald-100/70 mt-3 max-w-sm text-sm">Pelaporan, disposisi, penjadwalan mediasi, hingga rekap — dalam satu sistem yang terpadu dan terpantau.</p>
      <div class="mt-6 text-xs text-emerald-100/50 space-y-0.5">
        <p>Kantor Camat Brang Ene, Kab. Sumbawa Barat</p>
        <p>+62 85173464488 · kantorbrangene@gmail.com</p>
      </div>
    </div>
    <p class="text-emerald-100/40 text-xs">© {{ date('Y') }} Kantor Camat Brang Ene</p>
  </div>

  <div class="grid place-items-center px-4 py-10 bg-slate-50">
    <div class="w-full max-w-sm">
      <div class="lg:hidden flex flex-col items-center gap-2 mb-8 text-center">
        <span class="grid place-items-center w-12 h-12 rounded-xl bg-emerald-700 text-white">
          <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
        </span>
        <div>
          <p class="font-display font-bold text-slate-900">SIMPATI</p>
          <p class="text-xs text-slate-500">Sistem Informasi Mediasi dan Penanganan Sengketa Tanah</p>
          <p class="text-xs text-slate-400">Kantor Camat Brang Ene</p>
        </div>
      </div>
      @yield('content')
    </div>
  </div>
</body>
</html>
BEOF

# ============================================================
# 4. Ganti judul tab browser di layout app
# ============================================================
sed -i \
  's|<title>@yield.*· SIMPATI</title>|<title>@yield('\''title'\'', '\''Dashboard'\'') · SIMPATI</title>|g' \
  resources/views/layouts/app.blade.php

# Ganti nama sidebar
sed -i \
  's|>SIMPATI</p>.*<p class="text-\[11px\].*Sengketa Tanah</p>|>SIMPATI</p><p class="text-[10px] text-slate-400 leading-tight">Mediasi \&amp; Sengketa Tanah</p>|g' \
  resources/views/layouts/app.blade.php

# ============================================================
# 5. Update .env lokal + .env.production.example
# ============================================================
sed -i 's/^APP_NAME=.*/APP_NAME=SIMPATI/' .env
sed -i 's/^APP_NAME=.*/APP_NAME=SIMPATI/' .env.production.example 2>/dev/null || true

# ============================================================
# 6. Update database setting (nama kantor di seeder entrypoint)
# ============================================================
sed -i \
  -e "s/SIMPATI/SIMPATI/g" \
  -e "s/Simpati/Simpati/g" \
  docker-entrypoint.sh 2>/dev/null || true

# ============================================================
# 7. Update setting di database (kalau sudah ada datanya)
# ============================================================
php artisan tinker --execute="
\App\Models\Setting::where('id','>=',1)->update([
  'nama_kantor' => 'Kantor Camat Brang Ene',
  'telepon' => '+62 85173464488',
  'email' => 'kantorbrangene@gmail.com',
  'alamat' => 'Kantor Brang Ene, Kab. Sumbawa Barat',
  'hak_cipta' => 'Kantor Camat Brang Ene - Seksi Ketentraman dan Ketertiban',
]);
" 2>/dev/null || true

# ============================================================
# 8. Build ulang
# ============================================================
echo "==> Build"
php artisan optimize:clear
npm run build

# ============================================================
# 9. Push ke GitHub (Railway otomatis redeploy)
# ============================================================
echo "==> Push ke GitHub"
git add .
git commit -m "rename: SIMPATI → SIMPATI (Sistem Informasi Mediasi dan Penanganan Sengketa Tanah)"
git push

echo ""
echo "============================================================"
echo "  SIMPATI SIAP ✓"
echo ""
echo "  Nama baru: SIMPATI"
echo "  Kepanjangan:"
echo "  Sistem Informasi Mediasi dan Penanganan Sengketa Tanah"
echo "  Seksi Ketentraman & Ketertiban, Kantor Camat Brang Ene"
echo ""
echo "  Railway akan redeploy otomatis dalam ~2 menit."
echo "  Buka: https://simpati-production.up.railway.app/login"
echo "        (atau domain lama simpati-production masih jalan)"
echo "============================================================"
