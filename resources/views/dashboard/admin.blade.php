@extends('layouts.app')
@section('title','Dashboard Administrator')
@section('content')
  @php $u=auth()->user(); $max=max($chart->max('count'),1); @endphp

  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#7c3aed 0%,#5b21b6 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-64 h-64 rounded-full opacity-10" style="background:white;transform:translate(40%,-40%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-violet-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold">{{ $u->name }}</h1>
        <p class="text-violet-100/60 text-xs mt-0.5">Administrator · SIMPATI</p>
        <div class="flex flex-wrap gap-2 mt-3">
          <a href="{{ route('users.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Kelola Pengguna</a>
          <a href="{{ route('rekap.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Rekap & Statistik</a>
          <a href="{{ route('settings.edit') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Pengaturan</a>
        </div>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-violet-300 text-3xl" x-text="detik"></span></p>
        <p class="text-violet-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  {{-- Stat cards admin --}}
  <div class="grid grid-cols-3 sm:grid-cols-3 lg:grid-cols-9 gap-3 mb-5">
    @foreach([
      ['Laporan',$stats['total'],'#64748b'],['Baru',$stats['baru'],'#0ea5e9'],['Proses',$stats['diproses'],'#f59e0b'],
      ['Selesai',$stats['selesai'],'#10b981'],['Ditolak',$stats['ditolak'],'#ef4444'],['Mediasi',$stats['mediasi'],'#6366f1'],
      ['Pengguna',$stats['pengguna'],'#8b5cf6'],['Warga',$stats['warga'],'#14b8a6'],['Petugas',$stats['petugas'],'#f97316'],
    ] as [$l,$v,$c])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-3 text-center col-span-1">
        <p class="font-display text-xl font-bold text-slate-900">{{ $v }}</p>
        <p class="text-[11px] mt-0.5 leading-tight" style="color:{{ $c }}">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      {{-- Chart --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <div class="flex items-center justify-between mb-4">
          <h2 class="font-display font-semibold text-slate-900">Tren laporan 6 bulan</h2>
          <a href="{{ route('rekap.index') }}" class="text-xs text-violet-600 hover:underline font-medium">Rekap lengkap</a>
        </div>
        <div class="flex items-end gap-3 h-36">
          @foreach($chart as $c)
            <div class="flex-1 bg-gradient-to-t from-violet-600 to-violet-400 rounded-t-lg relative" style="height:{{ max(3,round($c['count']/$max*100)) }}%">
              <span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span>
            </div>
          @endforeach
        </div>
        <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
      </div>

      {{-- Per jenis sengketa --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Per Jenis Sengketa</h2>
        @foreach($byJenis as $row)
          @php $pct = $stats['total']>0 ? round($row->c/$stats['total']*100) : 0; @endphp
          <div class="flex items-center gap-3 py-1.5">
            <span class="text-xs text-slate-600 w-28 shrink-0 truncate">{{ $row->jenis ?: 'Belum ditentukan' }}</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-violet-500 rounded-full" style="width:{{ $pct }}%"></div>
            </div>
            <span class="text-xs font-medium text-slate-700 w-6 text-right">{{ $row->c }}</span>
          </div>
        @endforeach
      </div>
    </div>

    <div class="space-y-4">
      {{-- Laporan masuk --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
        <div class="px-5 py-3.5 border-b border-slate-100 flex items-center justify-between">
          <h2 class="font-display font-semibold text-slate-900">Laporan Baru</h2>
          <span class="text-xs bg-rose-100 text-rose-600 font-medium px-2 py-0.5 rounded-full">{{ $stats['baru'] }}</span>
        </div>
        @forelse($laporanMasuk as $r)
          <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
            <span class="w-1.5 h-1.5 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
            <div class="flex-1 min-w-0">
              <p class="text-sm text-slate-800 truncate font-medium">{{ $r->judul }}</p>
              <p class="text-xs text-slate-400 truncate">{{ $r->user->name }}</p>
            </div>
          </a>
        @empty<p class="px-5 py-6 text-center text-sm text-slate-400">Tidak ada laporan baru.</p>@endforelse
      </div>

      {{-- Mediasi --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi Mendatang</h2>
        @forelse($mediasiMendatang as $m)
          <a href="{{ route('reports.show',$m->report) }}" class="flex gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-violet-50 rounded-lg py-1">
              <p class="font-bold text-violet-700 leading-none">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0"><p class="text-sm text-slate-700 truncate">{{ $m->report->judul }}</p><p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}</p></div>
          </a>
        @empty<p class="text-sm text-slate-400 py-4 text-center">Tidak ada jadwal.</p>@endforelse
      </div>
    </div>
  </div>
  <script>function jamSimpati(){const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'],bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];return{jam:'00:00',detik:':00',tanggal:'',sapaan:'',tick(){const d=new Date(),p=n=>String(n).padStart(2,'0');this.jam=p(d.getHours())+':'+p(d.getMinutes());this.detik=':'+p(d.getSeconds());this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();const h=d.getHours();this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';},start(){this.tick();setInterval(()=>this.tick(),1000);}}}
  </script>
@endsection
