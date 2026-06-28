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
