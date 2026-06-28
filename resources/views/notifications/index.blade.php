@extends('layouts.app')
@section('title', 'Notifikasi')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Notifikasi</h1>
  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm divide-y divide-slate-50">
    @forelse($items as $n)
      <a href="{{ route('notif.open', $n) }}" class="block px-4 py-3 hover:bg-slate-50 {{ $n->dibaca_pada ? '' : 'bg-emerald-50/40' }}">
        <p class="text-sm font-medium text-slate-800">{{ $n->judul }}</p>
        <p class="text-xs text-slate-500">{{ $n->isi }}</p>
        <p class="text-[11px] text-slate-400 mt-0.5">{{ $n->created_at->diffForHumans() }}</p>
      </a>
    @empty<div class="px-4 py-12 text-center text-sm text-slate-400">Belum ada notifikasi.</div>@endforelse
  </div>
  <div class="mt-4">{{ $items->links() }}</div>
@endsection
