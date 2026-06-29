@extends('layouts.app')
@section('title','Dashboard Warga')
@section('content')
  @php $u = auth()->user(); @endphp

  {{-- HERO --}}
  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#047857 0%,#065f46 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-48 h-48 rounded-full opacity-10" style="background:white;transform:translate(30%,-30%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-emerald-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold mt-0.5">{{ $u->name }}</h1>
        <p class="text-emerald-100/60 text-xs mt-0.5">Warga · SIMPATI</p>
        <a href="{{ route('reports.create') }}" class="mt-4 inline-flex items-center gap-2 bg-white/15 hover:bg-white/25 text-white text-sm font-medium px-4 py-2 rounded-xl transition">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z"/></svg>
          Buat Laporan Baru
        </a>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-emerald-300 text-3xl" x-text="detik"></span></p>
        <p class="text-emerald-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  {{-- STAT CARDS --}}
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
    @foreach([
      ['Total','total','#0ea5e9','M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25zM6.75 12h.008v.008H6.75V12zm0 3h.008v.008H6.75V15zm0 3h.008v.008H6.75V18z'],
      ['Baru','baru','#38bdf8','M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z'],
      ['Diproses','diproses','#f59e0b','M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z'],
      ['Selesai','selesai','#10b981','M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z'],
    ] as [$l,$k,$c,$p])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-4">
        <span class="inline-flex w-9 h-9 rounded-xl items-center justify-center mb-3" style="background:{{ $c }}20">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" style="color:{{ $c }}"><path d="{{ $p }}" stroke="currentColor" stroke-width="1.8"/></svg>
        </span>
        <p class="font-display text-3xl font-bold text-slate-900">{{ $stats[$k] }}</p>
        <p class="text-xs text-slate-500 mt-0.5">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    {{-- Laporan terbaru --}}
    <div class="lg:col-span-2 bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
      <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
        <h2 class="font-display font-semibold text-slate-900">Laporan Saya</h2>
        <a href="{{ route('reports.index') }}" class="text-xs text-emerald-700 font-medium hover:underline">Lihat semua</a>
      </div>
      @forelse($terbaru as $r)
        <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
          <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <span class="text-xs font-mono text-slate-400">{{ $r->nomor }}</span>
              <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
            </div>
            <p class="text-sm font-medium text-slate-800 truncate mt-0.5">{{ $r->judul }}</p>
          </div>
          <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->format('d/m/y') }}</span>
        </a>
      @empty
        <div class="px-5 py-12 text-center">
          <svg class="w-10 h-10 text-slate-200 mx-auto mb-3" viewBox="0 0 24 24" fill="none"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke="currentColor" stroke-width="1.5"/></svg>
          <p class="text-sm text-slate-400">Belum ada laporan.</p>
          <a href="{{ route('reports.create') }}" class="mt-2 inline-block text-sm text-emerald-700 font-medium hover:underline">Buat laporan pertama</a>
        </div>
      @endforelse
    </div>

    {{-- Mediasi + panduan --}}
    <div class="space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Jadwal Mediasi Saya</h2>
        @forelse($mediasi as $m)
          <div class="flex items-start gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-emerald-50 rounded-lg py-1">
              <p class="font-bold text-emerald-700 leading-none text-lg">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0">
              <p class="text-sm font-medium text-slate-700 truncate">{{ $m->report->judul }}</p>
              <p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}@if($m->tempat) · {{ $m->tempat }}@endif</p>
            </div>
          </div>
        @empty
          <p class="text-sm text-slate-400 text-center py-4">Tidak ada jadwal mediasi.</p>
        @endforelse
      </div>

      <div class="bg-emerald-50 rounded-2xl ring-1 ring-emerald-100 p-5">
        <h2 class="font-display font-semibold text-emerald-800 mb-3 flex items-center gap-2">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z" clip-rule="evenodd"/></svg>
          Panduan Pelaporan
        </h2>
        <ol class="space-y-2 text-xs text-emerald-700">
          @foreach(['Siapkan KTP, KK, dan dokumen tanah','Isi formulir laporan dengan lengkap','Upload bukti foto atau dokumen','Pantau status laporan secara berkala','Hadiri mediasi sesuai jadwal yang ditetapkan'] as $i=>$p)
            <li class="flex items-start gap-2"><span class="font-bold shrink-0">{{ $i+1 }}.</span>{{ $p }}</li>
          @endforeach
        </ol>
      </div>
    </div>
  </div>

  <script>
    function jamSimpati(){
      const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
      const bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
      return {
        jam:'00:00',detik:':00',tanggal:'',sapaan:'',
        tick(){
          const d=new Date(),p=n=>String(n).padStart(2,'0');
          this.jam=p(d.getHours())+':'+p(d.getMinutes());
          this.detik=':'+p(d.getSeconds());
          this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();
          const h=d.getHours();
          this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';
        },
        start(){this.tick();setInterval(()=>this.tick(),1000);}
      }
    }
  </script>
@endsection
