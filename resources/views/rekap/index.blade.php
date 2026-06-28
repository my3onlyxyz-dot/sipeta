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
