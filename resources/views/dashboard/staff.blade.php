@extends('layouts.app')
@section('title','Dashboard Petugas')
@section('content')
  @php $u=auth()->user(); $max=max($chart->max('count'),1); @endphp

  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#1e40af 0%,#1e3a8a 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-48 h-48 rounded-full opacity-10" style="background:white;transform:translate(30%,-30%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-blue-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold mt-0.5">{{ $u->name }}</h1>
        <p class="text-blue-100/60 text-xs mt-0.5">Petugas · Seksi Ketentraman & Ketertiban</p>
        <div class="flex gap-2 mt-3">
          <a href="{{ route('reports.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">
            <svg class="w-3.5 h-3.5" viewBox="0 0 20 20" fill="currentColor"><path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z"/></svg>
            Laporan Masuk
            @if($stats['baru']>0)<span class="bg-rose-500 text-white text-[10px] rounded-full w-4 h-4 grid place-items-center">{{ $stats['baru'] }}</span>@endif
          </a>
          <a href="{{ route('mediations.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Mediasi</a>
        </div>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-blue-300 text-3xl" x-text="detik"></span></p>
        <p class="text-blue-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-5">
    @foreach([
      ['Total',$stats['total'],'#64748b'],['Baru',$stats['baru'],'#0ea5e9'],
      ['Diproses',$stats['diproses'],'#f59e0b'],['Selesai',$stats['selesai'],'#10b981'],
      ['Ditolak',$stats['ditolak'],'#ef4444'],['Tugas Saya',$stats['tugas_ku'],'#8b5cf6'],
    ] as [$l,$v,$c])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-3.5 text-center">
        <p class="font-display text-2xl font-bold text-slate-900">{{ $v }}</p>
        <p class="text-xs mt-0.5" style="color:{{ $c }}">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      {{-- Chart --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-4">Tren laporan 6 bulan</h2>
        <div class="flex items-end gap-3 h-36">
          @foreach($chart as $c)
            <div class="flex-1 bg-gradient-to-t from-blue-600 to-blue-400 rounded-t-lg relative" style="height:{{ max(3,round($c['count']/$max*100)) }}%">
              <span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span>
            </div>
          @endforeach
        </div>
        <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
      </div>

      {{-- Laporan masuk baru --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
        <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
          <h2 class="font-display font-semibold text-slate-900">Laporan Masuk (Baru)</h2>
          <a href="{{ route('reports.index','?status=baru') }}" class="text-xs text-blue-600 font-medium hover:underline">Lihat semua</a>
        </div>
        @forelse($laporanMasuk as $r)
          <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
            <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-slate-800 truncate">{{ $r->judul }}</p>
              <p class="text-xs text-slate-400 truncate">{{ $r->user->name }} · {{ $r->lokasi }}</p>
            </div>
            <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->diffForHumans() }}</span>
          </a>
        @empty
          <p class="px-5 py-8 text-center text-sm text-slate-400">Tidak ada laporan baru.</p>
        @endforelse
      </div>
    </div>

    <div class="space-y-4">
      {{-- Mediasi mendatang --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi Mendatang</h2>
        @forelse($mediasiMendatang as $m)
          <a href="{{ route('reports.show',$m->report) }}" class="flex gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-blue-50 rounded-lg py-1">
              <p class="font-bold text-blue-700 leading-none">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0"><p class="text-sm text-slate-700 truncate">{{ $m->report->judul }}</p><p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}</p></div>
          </a>
        @empty<p class="text-sm text-slate-400 py-4 text-center">Tidak ada jadwal.</p>@endforelse
      </div>

      {{-- Aktivitas --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Aktivitas Terbaru</h2>
        <div class="space-y-3">
          @foreach($activities->take(5) as $a)
            <div class="flex gap-2.5">
              <span class="mt-1.5 w-2 h-2 rounded-full {{ $a->dotColor() }} shrink-0"></span>
              <div><p class="text-xs text-slate-700 leading-relaxed">{{ $a->deskripsi }}</p><p class="text-[11px] text-slate-400">{{ $a->created_at->diffForHumans() }}</p></div>
            </div>
          @endforeach
        </div>
      </div>
    </div>
  </div>
  <script>function jamSimpati(){const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'],bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];return{jam:'00:00',detik:':00',tanggal:'',sapaan:'',tick(){const d=new Date(),p=n=>String(n).padStart(2,'0');this.jam=p(d.getHours())+':'+p(d.getMinutes());this.detik=':'+p(d.getSeconds());this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();const h=d.getHours();this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';},start(){this.tick();setInterval(()=>this.tick(),1000);}}}
  </script>
@endsection
