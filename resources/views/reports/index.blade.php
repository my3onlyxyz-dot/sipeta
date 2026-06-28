@extends('layouts.app')
@section('title', 'Laporan')
@section('content')
  <div class="flex items-center justify-between gap-3 mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">{{ auth()->user()->isStaff() ? 'Semua Laporan' : 'Laporan Saya' }}</h1>
    @unless(auth()->user()->isStaff())
      <a href="{{ route('reports.create') }}" class="rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Buat</a>
    @endunless
  </div>

  <form method="GET" class="flex flex-wrap gap-2 mb-4">
    <input name="q" value="{{ request('q') }}" placeholder="Cari nomor / judul / lokasi" class="flex-1 min-w-[160px] rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
    <select name="status" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
      <option value="">Status</option>@foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)<option value="{{ $k }}" @selected(request('status')===$k)>{{ $v }}</option>@endforeach
    </select>
    <select name="prioritas" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
      <option value="">Prioritas</option>@foreach(['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'] as $k=>$v)<option value="{{ $k }}" @selected(request('prioritas')===$k)>{{ $v }}</option>@endforeach
    </select>
    @if(auth()->user()->isStaff())
      <label class="flex items-center gap-1.5 text-sm text-slate-600 px-2"><input type="checkbox" name="saya" value="1" @checked(request('saya')) class="rounded border-slate-300 text-emerald-600"> Tugas saya</label>
    @endif
    <button class="rounded-lg bg-slate-900 text-white px-4 py-2 text-sm">Filter</button>
  </form>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
    @forelse($reports as $r)
      <a href="{{ route('reports.show', $r) }}" class="flex items-center gap-3 px-4 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
        <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0" title="Prioritas {{ $r->prioritasLabel() }}"></span>
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2">
            <span class="text-xs font-mono text-slate-400">{{ $r->nomor }}</span>
            <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
          </div>
          <p class="text-sm font-medium text-slate-900 truncate mt-0.5">{{ $r->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $r->lokasi }}@if(auth()->user()->isStaff()) · {{ $r->user->name }}@if($r->assignee) → {{ $r->assignee->name }}@endif @endif</p>
        </div>
        <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->format('d/m/y') }}</span>
      </a>
    @empty
      <div class="px-4 py-12 text-center text-sm text-slate-400">Tidak ada laporan.</div>
    @endforelse
  </div>
  <div class="mt-4">{{ $reports->links() }}</div>
@endsection
