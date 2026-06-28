@extends('layouts.app')
@section('title', 'Jadwal Mediasi')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Jadwal Mediasi</h1>
  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
    @forelse($mediations as $m)
      <a href="{{ route('reports.show', $m->report) }}" class="flex items-center gap-3 px-4 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
        <div class="text-center shrink-0 w-12">
          <p class="font-display font-bold text-emerald-700 leading-none">{{ $m->tanggal->format('d') }}</p>
          <p class="text-[11px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-800 truncate">{{ $m->report->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $m->tanggal->format('H:i') }}@if($m->tempat) · {{ $m->tempat }}@endif · {{ $m->report->nomor }}</p>
        </div>
        <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $m->statusClasses() }} shrink-0">{{ ucfirst($m->status) }}</span>
      </a>
    @empty
      <div class="px-4 py-12 text-center text-sm text-slate-400">Belum ada jadwal mediasi.</div>
    @endforelse
  </div>
  <div class="mt-4">{{ $mediations->links() }}</div>
@endsection
