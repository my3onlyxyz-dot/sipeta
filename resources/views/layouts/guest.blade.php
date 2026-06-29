<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title','Masuk') · SIMPATI</title>
  @vite(['resources/css/app.css','resources/js/app.js'])
  <style>
    body{background:#f1f5f9;color:#0f172a}
    *:focus-visible{outline-color:#047857}
    [x-cloak]{display:none!important}
    .hero-pattern{background-color:#064e3b;background-image:url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23065f46' fill-opacity='0.6'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")}
  </style>
</head>
<body class="min-h-screen grid lg:grid-cols-[1.1fr_1fr]" x-data>

  {{-- PANEL KIRI --}}
  <div class="hidden lg:flex flex-col hero-pattern relative overflow-hidden">
    {{-- overlay gradient --}}
    <div class="absolute inset-0" style="background:linear-gradient(135deg,rgba(6,78,59,.95) 0%,rgba(4,120,87,.85) 50%,rgba(5,46,22,.98) 100%)"></div>

    {{-- ilustrasi peta/tanah --}}
    <div class="absolute inset-0 flex items-center justify-center opacity-10">
      <svg viewBox="0 0 400 400" class="w-3/4" fill="none">
        <rect x="20" y="80" width="120" height="90" rx="4" stroke="white" stroke-width="2"/>
        <rect x="160" y="60" width="100" height="110" rx="4" stroke="white" stroke-width="2"/>
        <rect x="280" y="90" width="100" height="70" rx="4" stroke="white" stroke-width="2"/>
        <rect x="40" y="200" width="90" height="80" rx="4" stroke="white" stroke-width="2"/>
        <rect x="150" y="190" width="130" height="100" rx="4" stroke="white" stroke-width="2"/>
        <rect x="300" y="180" width="80" height="110" rx="4" stroke="white" stroke-width="2"/>
        <line x1="20" y1="80" x2="380" y2="80" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="20" y1="170" x2="380" y2="170" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="20" y1="290" x2="380" y2="290" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="140" y1="40" x2="140" y2="380" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="260" y1="40" x2="260" y2="380" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <circle cx="200" cy="210" r="8" stroke="white" stroke-width="2" fill="rgba(255,255,255,0.2)"/>
        <path d="M200 202 L200 218 M192 210 L208 210" stroke="white" stroke-width="1.5"/>
      </svg>
    </div>

    <div class="relative z-10 flex flex-col h-full p-12">
      {{-- logo --}}
      <div class="flex items-center gap-3">
        <span class="grid place-items-center w-12 h-12 rounded-2xl bg-white/15 backdrop-blur-sm border border-white/20">
          <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6 text-white"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" fill="currentColor"/></svg>
        </span>
        <div>
          <p class="font-display font-extrabold text-white text-xl tracking-tight">SIMPATI</p>
          <p class="text-emerald-200/70 text-xs">Kantor Camat Brang Ene</p>
        </div>
      </div>

      {{-- konten tengah --}}
      <div class="flex-1 flex flex-col justify-center">
        <p class="text-emerald-300/70 text-xs uppercase tracking-widest font-semibold mb-4">Seksi Ketentraman & Ketertiban</p>
        <h2 class="font-display text-3xl font-bold text-white leading-snug">
          Sistem Informasi<br>Mediasi & Penanganan<br><span class="text-emerald-300">Sengketa Tanah</span>
        </h2>
        <p class="text-emerald-100/60 text-sm mt-4 max-w-xs leading-relaxed">Platform digital terpadu untuk pelaporan, penanganan, mediasi, dan rekap sengketa tanah masyarakat.</p>

        {{-- fitur kecil --}}
        <div class="mt-8 space-y-3">
          @foreach([
            ['Pelaporan online dengan identitas lengkap','M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'],
            ['Tracking status real-time','M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9'],
            ['Jadwal mediasi terstruktur','M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'],
          ] as [$teks,$path])
            <div class="flex items-center gap-3 text-emerald-100/80 text-sm">
              <span class="grid place-items-center w-7 h-7 rounded-lg bg-white/10 shrink-0">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none"><path d="{{ $path }}" stroke="currentColor" stroke-width="1.8"/></svg>
              </span>
              {{ $teks }}
            </div>
          @endforeach
        </div>
      </div>

      {{-- footer panel kiri --}}
      <div class="border-t border-white/10 pt-5 space-y-1 text-xs text-emerald-100/50">
        <p>📞 +62 85173464488</p>
        <p>✉ kantorbrangene@gmail.com</p>
        <p>📍 Kantor Brang Ene, Kab. Sumbawa Barat</p>
        <p class="mt-2">© {{ date('Y') }} Kantor Camat Brang Ene</p>
      </div>
    </div>
  </div>

  {{-- PANEL KANAN --}}
  <div class="flex items-center justify-center px-4 py-10 bg-white min-h-screen">
    <div class="w-full max-w-sm">
      <div class="lg:hidden flex flex-col items-center gap-2 mb-8 text-center">
        <span class="grid place-items-center w-12 h-12 rounded-2xl bg-emerald-700 text-white">
          <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" fill="currentColor"/></svg>
        </span>
        <div>
          <p class="font-display font-bold">SIMPATI</p>
          <p class="text-xs text-slate-500">Sistem Informasi Mediasi Sengketa Tanah</p>
        </div>
      </div>
      @yield('content')
    </div>
  </div>
</body>
</html>
