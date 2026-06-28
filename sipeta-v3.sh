#!/usr/bin/env bash
# ============================================================
#  SIPETA v3 — Dashboard elegan, dark mode, identitas kantor
#  Jalankan di ~/myapp:  bash sipeta-v3.sh
# ============================================================
set -e
[ -f artisan ] || { echo "!! Jalankan di dalam folder Laravel (~/myapp)."; exit 1; }
echo "==> Project: $(pwd)"
mkdir -p config resources/views/layouts resources/views

# ============================================================
# 1. CONFIG IDENTITAS KANTOR
# ============================================================
echo "==> config/kantor.php"
cat > config/kantor.php << 'EOF'
<?php
return [
    'nama'      => 'Kantor Camat Brang Ene',
    'wilayah'   => 'Kabupaten Sumbawa Barat',
    'telp'      => '+62 851-7346-4488',
    'email'     => 'kantorbrangene@gmail.com',
    'alamat'    => 'Kantor Camat Brang Ene, Kabupaten Sumbawa Barat',
    'jam'       => 'Senin–Jumat, 08.00–16.00 WITA',
    'hak_cipta' => 'Kantor Camat Brang Ene',
];
EOF

# ============================================================
# 2. CSS — tema + DARK MODE (override global, tanpa ubah view)
# ============================================================
echo "==> resources/css/app.css"
cat > resources/css/app.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap');
@import "tailwindcss";
@source "../views";

:root{color-scheme:light}
body{font-family:'Inter',system-ui,sans-serif;background:#f1f5f9;color:#0f172a;-webkit-font-smoothing:antialiased}
.font-display{font-family:'Space Grotesk',sans-serif}
.font-code{font-family:'JetBrains Mono',monospace}
*:focus-visible{outline:2px solid #047857;outline-offset:2px;border-radius:6px}
[x-cloak]{display:none!important}

/* ikon toggle tema */
.theme-moon{display:none}
.dark .theme-moon{display:block}
.dark .theme-sun{display:none}

/* ===================== DARK MODE ===================== */
.dark{color-scheme:dark}
.dark body{background:#0b1120 !important;color:#e2e8f0 !important}

.dark .bg-white{background-color:#111827 !important}
.dark .bg-slate-50{background-color:#0b1120 !important}
.dark .bg-slate-100{background-color:#1e293b !important}
.dark .bg-slate-900{background-color:#334155 !important}
.dark .hover\:bg-slate-50:hover{background-color:#1e293b !important}
.dark .hover\:bg-slate-100:hover{background-color:#293548 !important}

.dark .text-slate-900{color:#f1f5f9 !important}
.dark .text-slate-800{color:#e2e8f0 !important}
.dark .text-slate-700{color:#cbd5e1 !important}
.dark .text-slate-600{color:#94a3b8 !important}
.dark .text-slate-500{color:#94a3b8 !important}
.dark .text-slate-400{color:#64748b !important}

.dark .ring-slate-200{--tw-ring-color:#1f2937 !important}
.dark .border-slate-300{border-color:#334155 !important}
.dark .border-slate-200{border-color:#1f2937 !important}
.dark .border-slate-100{border-color:#1f2937 !important}
.dark .border-slate-50{border-color:#172033 !important}
.dark .divide-slate-50 > :not([hidden]) ~ :not([hidden]){border-color:#172033 !important}
.dark .divide-slate-100 > :not([hidden]) ~ :not([hidden]){border-color:#1f2937 !important}

.dark input,.dark select,.dark textarea{background-color:#0f172a !important;color:#e2e8f0 !important;border-color:#334155 !important}
.dark input::placeholder,.dark textarea::placeholder{color:#64748b !important}

.dark .bg-emerald-50{background-color:rgba(16,185,129,.12) !important}
.dark .bg-emerald-50\/40{background-color:rgba(16,185,129,.08) !important}
.dark .bg-sky-50{background-color:rgba(56,189,248,.12) !important}
.dark .bg-amber-50{background-color:rgba(245,158,11,.12) !important}
.dark .bg-rose-50{background-color:rgba(244,63,94,.12) !important}
.dark .text-emerald-700{color:#34d399 !important}
.dark .text-sky-700{color:#7dd3fc !important}
.dark .text-amber-700{color:#fbbf24 !important}
.dark .text-rose-700{color:#fb7185 !important}
.dark .text-rose-600{color:#fb7185 !important}
.dark .ring-emerald-200{--tw-ring-color:rgba(16,185,129,.3) !important}
.dark .ring-sky-200{--tw-ring-color:rgba(56,189,248,.3) !important}
.dark .ring-amber-200{--tw-ring-color:rgba(245,158,11,.3) !important}
.dark .ring-rose-200{--tw-ring-color:rgba(244,63,94,.3) !important}
.dark .ring-emerald-300{--tw-ring-color:rgba(16,185,129,.4) !important}
.dark .ring-rose-300{--tw-ring-color:rgba(244,63,94,.4) !important}
.dark .ring-slate-300{--tw-ring-color:#334155 !important}
.dark .hover\:bg-rose-50:hover{background-color:rgba(244,63,94,.12) !important}
.dark .hover\:bg-emerald-50:hover{background-color:rgba(16,185,129,.12) !important}
EOF

# ============================================================
# 3. LAYOUT app (toggle tema, footer kontak, menu kontak)
# ============================================================
echo "==> layouts/app.blade.php"
cat > resources/views/layouts/app.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>@yield('title', 'Dashboard') · SIPETA</title>
  <script>(function(){try{var t=localStorage.getItem('sipeta-theme');if(t==='dark'||(!t&&window.matchMedia&&matchMedia('(prefers-color-scheme:dark)').matches)){document.documentElement.classList.add('dark');}}catch(e){}})();</script>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
  <style>.nav-ico{width:18px;height:18px;flex:none}</style>
</head>
<body class="min-h-screen" x-data="{ sidebar:false, notif:false, user:false }">
  @php
    $u = auth()->user();
    $active = fn ($p) => request()->routeIs($p) ? 'bg-emerald-50 text-emerald-700 font-medium' : 'text-slate-600 hover:bg-slate-50';
    $notifs = $u->pemberitahuan()->latest()->limit(8)->get();
    $unread = $u->unreadNotif();
  @endphp

  <div x-show="sidebar" x-cloak @click="sidebar=false" class="fixed inset-0 bg-slate-900/40 z-30 lg:hidden"></div>

  <aside class="fixed inset-y-0 left-0 w-64 bg-white border-r border-slate-200 z-40 flex flex-col transition-transform lg:translate-x-0" :class="sidebar ? 'translate-x-0' : '-translate-x-full'">
    <div class="h-16 flex items-center gap-2.5 px-5 border-b border-slate-100">
      <span class="grid place-items-center w-9 h-9 rounded-xl bg-emerald-700 text-white">
        <svg viewBox="0 0 24 24" fill="none" class="w-5 h-5"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
      </span>
      <div class="leading-tight">
        <p class="font-display font-bold text-slate-900">SIPETA</p>
        <p class="text-[11px] text-slate-400">Brang Ene</p>
      </div>
    </div>

    <nav class="flex-1 overflow-y-auto p-3 space-y-1 text-sm">
      <p class="px-3 pt-2 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Menu Utama</p>
      <a href="{{ route('dashboard') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('dashboard') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M4 13h6V4H4v9zM14 20h6v-9h-6v9zM14 4v4h6V4h-6zM4 20h6v-4H4v4z" stroke="currentColor" stroke-width="1.8"/></svg> Dashboard</a>
      <a href="{{ route('reports.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('reports.index') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M8 4h8a2 2 0 012 2v14l-6-3-6 3V6a2 2 0 012-2z" stroke="currentColor" stroke-width="1.8"/></svg> {{ $u->isStaff() ? 'Semua Laporan' : 'Laporan Saya' }}</a>
      @unless($u->isStaff())
        <a href="{{ route('reports.create') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('reports.create') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="1.8"/></svg> Buat Laporan</a>
      @endunless
      <a href="{{ route('mediations.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('mediations.*') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.8"/><path d="M3 9h18M8 3v4M16 3v4" stroke="currentColor" stroke-width="1.8"/></svg> Jadwal Mediasi</a>

      @if($u->isStaff())
        <p class="px-3 pt-4 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Administrasi</p>
        <a href="{{ route('rekap.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('rekap.*') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M4 19V5M4 19h16M8 16v-5M12 16V8M16 16v-3" stroke="currentColor" stroke-width="1.8"/></svg> Rekap & Statistik</a>
        @if($u->isAdmin())
          <a href="{{ route('users.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('users.*') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3" stroke="currentColor" stroke-width="1.8"/><path d="M3 20c0-3 3-5 6-5s6 2 6 5M17 11l2 2 3-3" stroke="currentColor" stroke-width="1.8"/></svg> Manajemen Pengguna</a>
        @endif
      @endif

      <p class="px-3 pt-4 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Informasi & Akun</p>
      <a href="{{ route('kontak') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('kontak') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M4 6a2 2 0 012-2h12a2 2 0 012 2v12a2 2 0 01-2 2H6a2 2 0 01-2-2V6z" stroke="currentColor" stroke-width="1.8"/><path d="M8 9h8M8 13h5" stroke="currentColor" stroke-width="1.8"/></svg> Kontak & Bantuan</a>
      <a href="{{ route('profile.edit') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('profile.*') }}"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="3.2" stroke="currentColor" stroke-width="1.8"/><path d="M5 20c0-3.3 3-6 7-6s7 2.7 7 6" stroke="currentColor" stroke-width="1.8"/></svg> Profil</a>
    </nav>

    <div class="p-3 border-t border-slate-100">
      <form method="POST" action="{{ route('logout') }}">@csrf
        <button class="flex items-center gap-3 w-full px-3 py-2 rounded-lg text-slate-600 hover:bg-rose-50 hover:text-rose-600 text-sm"><svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M15 12H3m4-4l-4 4 4 4M11 4h6a2 2 0 012 2v12a2 2 0 01-2 2h-6" stroke="currentColor" stroke-width="1.8"/></svg> Keluar</button>
      </form>
    </div>
  </aside>

  <div class="lg:pl-64 flex flex-col min-h-screen">
    <header class="h-16 bg-white border-b border-slate-200 sticky top-0 z-20 flex items-center gap-3 px-4 lg:px-6">
      <button @click="sidebar=true" class="lg:hidden w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100"><svg viewBox="0 0 24 24" class="w-6 h-6" fill="none"><path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2"/></svg></button>
      <h1 class="font-display font-semibold text-slate-900 truncate">@yield('heading', 'Dashboard')</h1>

      <div class="ml-auto flex items-center gap-1.5">
        <button onclick="toggleTheme()" class="w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100 text-slate-600" title="Mode terang/gelap">
          <svg class="theme-sun w-5 h-5" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="4" stroke="currentColor" stroke-width="1.8"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5L19 19M19 5l-1.5 1.5M6.5 17.5L5 19" stroke="currentColor" stroke-width="1.8"/></svg>
          <svg class="theme-moon w-5 h-5" viewBox="0 0 24 24" fill="none"><path d="M21 12.8A9 9 0 1111.2 3a7 7 0 109.8 9.8z" stroke="currentColor" stroke-width="1.8"/></svg>
        </button>

        <div class="relative">
          <button @click="notif=!notif; user=false" class="relative w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100 text-slate-600">
            <svg viewBox="0 0 24 24" class="w-5 h-5" fill="none"><path d="M6 9a6 6 0 1112 0c0 5 2 6 2 6H4s2-1 2-6zM10 19a2 2 0 004 0" stroke="currentColor" stroke-width="1.8"/></svg>
            @if($unread)<span class="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-rose-500 text-white text-[10px] grid place-items-center">{{ $unread > 9 ? '9+' : $unread }}</span>@endif
          </button>
          <div x-show="notif" x-cloak @click.outside="notif=false" class="absolute right-0 mt-2 w-80 bg-white rounded-xl ring-1 ring-slate-200 shadow-lg overflow-hidden">
            <div class="flex items-center justify-between px-4 py-2.5 border-b border-slate-100"><span class="text-sm font-medium text-slate-800">Notifikasi</span>@if($unread)<form method="POST" action="{{ route('notif.readAll') }}">@csrf<button class="text-xs text-emerald-700">Tandai dibaca</button></form>@endif</div>
            <div class="max-h-80 overflow-y-auto">
              @forelse($notifs as $n)
                <a href="{{ route('notif.open', $n) }}" class="block px-4 py-3 border-b border-slate-50 hover:bg-slate-50 {{ $n->dibaca_pada ? '' : 'bg-emerald-50/40' }}"><p class="text-sm font-medium text-slate-800">{{ $n->judul }}</p><p class="text-xs text-slate-500">{{ $n->isi }}</p><p class="text-[11px] text-slate-400 mt-0.5">{{ $n->created_at->diffForHumans() }}</p></a>
              @empty<p class="px-4 py-8 text-center text-sm text-slate-400">Belum ada notifikasi.</p>@endforelse
            </div>
          </div>
        </div>

        <div class="relative">
          <button @click="user=!user; notif=false" class="flex items-center gap-2 pl-1 pr-2 py-1 rounded-lg hover:bg-slate-100">
            <span class="grid place-items-center w-8 h-8 rounded-full bg-emerald-700 text-white text-xs font-semibold">{{ $u->initials() }}</span>
            <span class="hidden sm:block text-left leading-tight"><span class="block text-sm font-medium text-slate-800">{{ $u->name }}</span><span class="block text-[11px] text-slate-400">{{ $u->roleLabel() }}</span></span>
          </button>
          <div x-show="user" x-cloak @click.outside="user=false" class="absolute right-0 mt-2 w-44 bg-white rounded-xl ring-1 ring-slate-200 shadow-lg py-1 text-sm">
            <a href="{{ route('profile.edit') }}" class="block px-4 py-2 text-slate-700 hover:bg-slate-50">Profil & Sandi</a>
            <a href="{{ route('kontak') }}" class="block px-4 py-2 text-slate-700 hover:bg-slate-50">Kontak & Bantuan</a>
            <form method="POST" action="{{ route('logout') }}">@csrf<button class="block w-full text-left px-4 py-2 text-rose-600 hover:bg-rose-50">Keluar</button></form>
          </div>
        </div>
      </div>
    </header>

    <main class="p-4 lg:p-6 max-w-6xl mx-auto w-full flex-1">
      @if(session('success'))
        <div x-data="{s:true}" x-show="s" class="mb-4 flex items-start gap-3 rounded-xl bg-emerald-50 ring-1 ring-emerald-200 text-emerald-800 px-4 py-3"><span class="mt-0.5">✓</span><p class="flex-1 text-sm">{{ session('success') }}</p><button @click="s=false">✕</button></div>
      @endif
      @yield('content')
    </main>

    <footer class="border-t border-slate-200 bg-white">
      <div class="max-w-6xl mx-auto px-4 lg:px-6 py-6 grid sm:grid-cols-3 gap-4 text-sm">
        <div><p class="text-xs text-slate-400 mb-1">Kontak Administrasi</p><a href="tel:+6285173464488" class="text-slate-700 hover:text-emerald-700">{{ config('kantor.telp') }}</a></div>
        <div><p class="text-xs text-slate-400 mb-1">Email</p><a href="mailto:{{ config('kantor.email') }}" class="text-slate-700 hover:text-emerald-700">{{ config('kantor.email') }}</a></div>
        <div><p class="text-xs text-slate-400 mb-1">Alamat</p><p class="text-slate-700">{{ config('kantor.alamat') }}</p></div>
      </div>
      <div class="border-t border-slate-100 py-3 text-center text-xs text-slate-400">© {{ date('Y') }} {{ config('kantor.hak_cipta') }}. Hak cipta dilindungi.</div>
    </footer>
  </div>

  <script>
    function toggleTheme(){var h=document.documentElement;h.classList.toggle('dark');try{localStorage.setItem('sipeta-theme',h.classList.contains('dark')?'dark':'light');}catch(e){}}
  </script>
</body>
</html>
EOF

# ============================================================
# 4. GUEST layout (pre-paint tema + identitas kantor)
# ============================================================
echo "==> layouts/guest.blade.php"
cat > resources/views/layouts/guest.blade.php << 'EOF'
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
EOF

# ============================================================
# 5. DASHBOARD elegan + jam live
# ============================================================
echo "==> dashboard.blade.php"
cat > resources/views/dashboard.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Dashboard')
@section('content')
  @php
    $max = max($chart->max('count'), 1);
    $wa = preg_replace('/\D/', '', config('kantor.telp'));
  @endphp

  <!-- HERO + JAM -->
  <div class="rounded-2xl p-6 lg:p-7 text-white relative overflow-hidden mb-5 shadow-sm"
       style="background:linear-gradient(120deg,#065f46 0%,#047857 50%,#0f766e 100%)"
       x-data="{hh:'',mm:'',ss:'',tgl:'',sapaan:'',t(){const d=new Date();this.hh=String(d.getHours()).padStart(2,'0');this.mm=String(d.getMinutes()).padStart(2,'0');this.ss=String(d.getSeconds()).padStart(2,'0');this.tgl=d.toLocaleDateString('id-ID',{weekday:'long',day:'numeric',month:'long',year:'numeric'});const h=d.getHours();this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';}}"
       x-init="t(); setInterval(()=>t(),1000)">
    <div class="absolute -right-10 -top-10 w-48 h-48 rounded-full bg-white/10"></div>
    <div class="absolute -right-20 top-20 w-56 h-56 rounded-full bg-white/5"></div>
    <div class="relative flex flex-wrap items-center justify-between gap-4">
      <div>
        <p class="text-emerald-50/80 text-sm"><span x-text="sapaan"></span>,</p>
        <p class="font-display text-2xl font-bold">{{ auth()->user()->name }}</p>
        <p class="text-emerald-50/70 text-sm mt-1">{{ config('kantor.nama') }}</p>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tracking-tight leading-none text-4xl lg:text-5xl tabular-nums">
          <span x-text="hh"></span>:<span x-text="mm"></span><span class="text-emerald-200 text-2xl lg:text-3xl">:<span x-text="ss"></span></span>
        </p>
        <p class="text-emerald-50/80 text-sm mt-2 font-code" x-text="tgl"></p>
      </div>
    </div>
  </div>

  <!-- STAT -->
  <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
    @foreach([
      ['Total laporan',$stats['total'],'text-slate-900','from-slate-100 to-slate-50'],
      ['Baru',$stats['baru'],'text-sky-700','from-sky-100 to-sky-50'],
      ['Diproses',$stats['diproses'],'text-amber-700','from-amber-100 to-amber-50'],
      ['Selesai',$stats['selesai'],'text-emerald-700','from-emerald-100 to-emerald-50'],
    ] as [$l,$v,$tc,$bg])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-4">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br {{ $bg }} mb-3"></div>
        <p class="font-display text-3xl font-bold {{ $tc }}">{{ $v }}</p>
        <p class="text-sm text-slate-500">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-900 mb-4">Laporan 6 bulan terakhir</h2>
      <div class="flex items-end gap-3 h-40">
        @foreach($chart as $c)<div class="flex-1 bg-gradient-to-t from-emerald-600 to-emerald-400 rounded-t-lg relative" style="height:{{ max(3, round($c['count']/$max*100)) }}%"><span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span></div>@endforeach
      </div>
      <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi mendatang</h2>
      @forelse($mediasiMendatang as $m)
        <a href="{{ route('reports.show', $m->report) }}" class="block py-2 border-b border-slate-50 last:border-0"><p class="text-sm font-medium text-slate-800">{{ $m->tanggal->format('d M Y · H:i') }}</p><p class="text-xs text-slate-500 truncate">{{ $m->report->judul }}</p></a>
      @empty<p class="text-sm text-slate-400 py-6 text-center">Tidak ada jadwal.</p>@endforelse
    </div>
  </div>

  <div class="grid lg:grid-cols-3 gap-4 mt-4">
    <div class="lg:col-span-2 bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
      <div class="px-5 py-3 border-b border-slate-100 flex items-center justify-between"><h2 class="font-display font-semibold text-slate-900">Aktivitas terbaru</h2><a href="{{ route('reports.index') }}" class="text-sm text-emerald-700 hover:underline">Lihat laporan</a></div>
      <div class="p-5 space-y-4">
        @forelse($activities as $a)
          <div class="flex gap-3"><span class="mt-1.5 w-2 h-2 rounded-full {{ $a->dotColor() }} shrink-0"></span><div class="flex-1 min-w-0"><p class="text-sm text-slate-700">{{ $a->deskripsi }}</p><a href="{{ route('reports.show', $a->report) }}" class="text-xs text-slate-400 hover:text-emerald-700">{{ $a->report->nomor }} · {{ $a->created_at->diffForHumans() }}</a></div></div>
        @empty<p class="text-sm text-slate-400 text-center py-6">Belum ada aktivitas.</p>@endforelse
      </div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-900 mb-3">Informasi Kantor</h2>
      <ul class="space-y-3 text-sm">
        <li class="flex gap-3"><span class="text-emerald-700">☏</span><a href="tel:+{{ $wa }}" class="text-slate-700 hover:text-emerald-700">{{ config('kantor.telp') }}</a></li>
        <li class="flex gap-3"><span class="text-emerald-700">✉</span><a href="mailto:{{ config('kantor.email') }}" class="text-slate-700 hover:text-emerald-700 break-all">{{ config('kantor.email') }}</a></li>
        <li class="flex gap-3"><span class="text-emerald-700">⚲</span><span class="text-slate-700">{{ config('kantor.alamat') }}</span></li>
        <li class="flex gap-3"><span class="text-emerald-700">◷</span><span class="text-slate-700">{{ config('kantor.jam') }}</span></li>
      </ul>
      <a href="https://wa.me/{{ $wa }}" target="_blank" class="mt-4 inline-flex items-center justify-center w-full gap-2 rounded-lg bg-emerald-700 text-white py-2 text-sm hover:bg-emerald-800">Hubungi via WhatsApp</a>
    </div>
  </div>
@endsection
EOF

# ============================================================
# 6. HALAMAN KONTAK & BANTUAN
# ============================================================
echo "==> kontak.blade.php"
cat > resources/views/kontak.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Kontak & Bantuan')
@section('content')
  @php $wa = preg_replace('/\D/', '', config('kantor.telp')); @endphp
  <h1 class="font-display text-xl font-bold text-slate-900 mb-1">Kontak & Bantuan</h1>
  <p class="text-sm text-slate-500 mb-5">Hubungi {{ config('kantor.nama') }} untuk pertanyaan seputar laporan sengketa tanah.</p>

  <div class="grid sm:grid-cols-2 gap-4">
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">☏</div>
      <p class="text-xs text-slate-400">Telepon / WhatsApp</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.telp') }}</p>
      <div class="flex gap-2 mt-3">
        <a href="tel:+{{ $wa }}" class="rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Telepon</a>
        <a href="https://wa.me/{{ $wa }}" target="_blank" class="rounded-lg bg-emerald-700 text-white px-3 py-1.5 text-sm hover:bg-emerald-800">WhatsApp</a>
      </div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">✉</div>
      <p class="text-xs text-slate-400">Email</p>
      <p class="text-slate-800 font-medium break-all">{{ config('kantor.email') }}</p>
      <a href="mailto:{{ config('kantor.email') }}" class="inline-block mt-3 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Kirim Email</a>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">⚲</div>
      <p class="text-xs text-slate-400">Alamat Kantor</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.alamat') }}</p>
      <a href="https://www.google.com/maps/search/{{ urlencode(config('kantor.alamat')) }}" target="_blank" class="inline-block mt-3 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Lihat di Peta</a>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">◷</div>
      <p class="text-xs text-slate-400">Jam Pelayanan</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.jam') }}</p>
    </div>
  </div>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 mt-4">
    <h2 class="font-display font-semibold text-slate-900 mb-3">Panduan singkat</h2>
    <ol class="list-decimal pl-5 space-y-1.5 text-sm text-slate-600">
      <li>Daftar / masuk menggunakan akun warga.</li>
      <li>Pilih <b>Buat Laporan</b>, isi data, lokasi/koordinat, dan unggah bukti.</li>
      <li>Pantau status laporan di menu <b>Laporan Saya</b> dan notifikasi.</li>
      <li>Petugas akan memproses, menjadwalkan mediasi bila perlu, hingga selesai.</li>
    </ol>
  </div>
@endsection
EOF

# ============================================================
# 7. REKAP + Export CSV
# ============================================================
echo "==> RekapController + view"
cat > app/Http/Controllers/RekapController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;

class RekapController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isStaff(), 403);
        $byStatus = Report::selectRaw('status, count(*) c')->groupBy('status')->pluck('c', 'status');
        $byJenis  = Report::selectRaw('jenis, count(*) c')->groupBy('jenis')->orderByDesc('c')->get();
        $byKec    = Report::selectRaw('kecamatan, count(*) c')->whereNotNull('kecamatan')->groupBy('kecamatan')->orderByDesc('c')->limit(10)->get();
        $total    = Report::count();
        return view('rekap.index', compact('byStatus', 'byJenis', 'byKec', 'total'));
    }

    public function export(Request $request)
    {
        abort_unless($request->user()->isStaff(), 403);
        $rows = Report::with('user')->latest()->get();
        $callback = function () use ($rows) {
            $h = fopen('php://output', 'w');
            fputcsv($h, ['Nomor', 'Judul', 'Pelapor', 'Jenis', 'Prioritas', 'Lokasi', 'Kecamatan', 'Status', 'Tanggal']);
            foreach ($rows as $r) {
                fputcsv($h, [$r->nomor, $r->judul, $r->nama_pelapor, $r->jenis, $r->prioritasLabel(), $r->lokasi, $r->kecamatan, $r->statusLabel(), $r->created_at->format('Y-m-d H:i')]);
            }
            fclose($h);
        };
        return response()->stream($callback, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="rekap-laporan-' . now()->format('Ymd') . '.csv"',
        ]);
    }
}
EOF

cat > resources/views/rekap/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Rekap & Statistik')
@section('content')
  <div class="flex items-center justify-between mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">Rekap & Statistik</h1>
    <div class="flex gap-2">
      <a href="{{ route('rekap.export') }}" class="rounded-lg bg-emerald-700 text-white px-3 py-2 text-sm hover:bg-emerald-800">⬇ Unduh CSV</a>
      <button onclick="window.print()" class="rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-2 text-sm hover:bg-slate-50">🖨 Cetak</button>
    </div>
  </div>
  <div class="grid sm:grid-cols-2 gap-4">
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Status</h2>
      @foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)
        <div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $v }}</span><span class="font-medium text-slate-900">{{ $byStatus[$k] ?? 0 }}</span></div>
      @endforeach
      <div class="flex items-center justify-between pt-2 mt-1 text-sm font-semibold text-slate-900"><span>Total</span><span>{{ $total }}</span></div>
    </div>
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Jenis Sengketa</h2>
      @forelse($byJenis as $row)<div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $row->jenis ?: '—' }}</span><span class="font-medium text-slate-900">{{ $row->c }}</span></div>@empty<p class="text-sm text-slate-400">Belum ada data.</p>@endforelse
    </div>
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 sm:col-span-2">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Kecamatan (Top 10)</h2>
      @forelse($byKec as $row)<div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $row->kecamatan }}</span><span class="font-medium text-slate-900">{{ $row->c }}</span></div>@empty<p class="text-sm text-slate-400">Belum ada data.</p>@endforelse
    </div>
  </div>
@endsection
EOF

# ============================================================
# 8. ROUTES tambahan (kontak + export)
# ============================================================
echo "==> Routes tambahan"
if ! grep -q "rekap.export" routes/web.php; then
cat >> routes/web.php << 'EOF'

// ===== SIPETA v3 — kontak & export =====
Route::middleware('auth')->group(function () {
    Route::get('/kontak', fn () => view('kontak'))->name('kontak');
    Route::get('/rekap/unduh', [\App\Http\Controllers\RekapController::class, 'export'])->name('rekap.export');
});
EOF
fi

# ============================================================
# 9. Build
# ============================================================
echo "==> Build"
php artisan optimize:clear
npm run build

echo ""
echo "============================================================"
echo "  SIPETA v3 SIAP ✓  (Kantor Camat Brang Ene)"
echo "  Jalankan:  php artisan serve --host=0.0.0.0 --port=8000"
echo "  Buka:      http://127.0.0.1:8000/login"
echo "  Fitur baru: jam live di dashboard, mode terang/gelap,"
echo "              info kontak kantor, halaman Kontak, unduh CSV."
echo "============================================================"
