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
