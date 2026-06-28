<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title', 'Masuk') · SIPETA</title>
  <script>(function(){try{var t=localStorage.getItem('sipeta-theme');if(t==='dark'||(!t&&window.matchMedia&&matchMedia('(prefers-color-scheme:dark)').matches)){document.documentElement.classList.add('dark');}}catch(e){}})();</script>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen grid lg:grid-cols-2">
  <div class="hidden lg:flex flex-col justify-between p-12 text-white relative overflow-hidden" style="background:radial-gradient(120% 120% at 0% 0%, #065f46 0%, #0f172a 70%)">
    <div class="flex items-center gap-2.5">
      <span class="grid place-items-center w-10 h-10 rounded-xl bg-white/10"><svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg></span>
      <span class="font-display font-bold text-lg">SIPETA</span>
    </div>
    <div>
      <h2 class="font-display text-3xl font-bold leading-tight">Sistem Pelaporan<br>Sengketa Tanah</h2>
      <p class="text-emerald-100/80 mt-3 max-w-sm text-sm">{{ config('kantor.nama') }} — {{ config('kantor.wilayah') }}. Pelaporan, disposisi, mediasi, hingga rekap dalam satu tempat.</p>
    </div>
    <p class="text-emerald-100/50 text-xs">© {{ date('Y') }} {{ config('kantor.hak_cipta') }}</p>
  </div>
  <div class="grid place-items-center px-4 py-10 bg-slate-50">
    <div class="w-full max-w-sm">
      <div class="lg:hidden flex items-center justify-center gap-2 mb-2"><span class="grid place-items-center w-9 h-9 rounded-xl bg-emerald-700 text-white"><svg viewBox="0 0 24 24" fill="none" class="w-5 h-5"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg></span><span class="font-display font-bold text-slate-900">SIPETA</span></div>
      <p class="lg:hidden text-center text-xs text-slate-500 mb-6">{{ config('kantor.nama') }}</p>
      @yield('content')
    </div>
  </div>
</body>
</html>
