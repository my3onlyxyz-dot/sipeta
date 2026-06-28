@extends('layouts.app')
@section('title', 'Manajemen Pengguna')
@section('content')
  <div class="flex items-center justify-between gap-3 mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">Manajemen Pengguna</h1>
    <a href="{{ route('users.create') }}" class="rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Tambah</a>
  </div>
  <form method="GET" class="mb-4"><input name="q" value="{{ request('q') }}" placeholder="Cari nama / email" class="w-full max-w-sm rounded-lg border border-slate-300 px-3 py-2 text-sm"></form>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm divide-y divide-slate-50">
    @foreach($users as $usr)
      <div class="flex items-center gap-3 px-4 py-3">
        <span class="grid place-items-center w-9 h-9 rounded-full bg-slate-100 text-slate-600 text-xs font-semibold shrink-0">{{ $usr->initials() }}</span>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-800 truncate">{{ $usr->name }} @unless($usr->is_active)<span class="text-xs text-rose-500">(nonaktif)</span>@endunless</p>
          <p class="text-xs text-slate-500 truncate">{{ $usr->email }}</p>
        </div>
        <form method="POST" action="{{ route('users.update', $usr) }}" class="hidden sm:flex items-center gap-2">@csrf @method('PATCH')
          <select name="role" class="rounded-lg border border-slate-300 px-2 py-1.5 text-xs">@foreach(['admin'=>'Admin','petugas'=>'Petugas','warga'=>'Warga'] as $k=>$v)<option value="{{ $k }}" @selected($usr->role===$k)>{{ $v }}</option>@endforeach</select>
          <select name="is_active" class="rounded-lg border border-slate-300 px-2 py-1.5 text-xs"><option value="1" @selected($usr->is_active)>Aktif</option><option value="0" @selected(!$usr->is_active)>Nonaktif</option></select>
          <button class="rounded-lg bg-slate-900 text-white px-2.5 py-1.5 text-xs">Simpan</button>
        </form>
        <form method="POST" action="{{ route('users.reset', $usr) }}">@csrf<button class="text-xs text-amber-600 hover:underline px-1">Reset sandi</button></form>
        @if($usr->id !== auth()->id())<form method="POST" action="{{ route('users.destroy', $usr) }}" onsubmit="return confirm('Hapus pengguna?')">@csrf @method('DELETE')<button class="text-xs text-rose-600 hover:underline px-1">Hapus</button></form>@endif
      </div>
    @endforeach
  </div>
  <div class="mt-4">{{ $users->links() }}</div>
@endsection
