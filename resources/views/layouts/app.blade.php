<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>@yield('title', 'Dashboard') · SIMPATI</title>
  <script>(function(){try{var t=localStorage.getItem('simpati-theme');if(t==='dark'||(!t&&window.matchMedia&&matchMedia('(prefers-color-scheme:dark)').matches)){document.documentElement.classList.add('dark');}}catch(e){}})();</script>
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
        <p class="font-display font-bold text-slate-900">SIMPATI</p>
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
    function toggleTheme(){var h=document.documentElement;h.classList.toggle('dark');try{localStorage.setItem('simpati-theme',h.classList.contains('dark')?'dark':'light');}catch(e){}}
  </script>
</body>
</html>
