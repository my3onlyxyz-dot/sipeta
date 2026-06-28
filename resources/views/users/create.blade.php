@extends('layouts.app')
@section('title', 'Tambah Pengguna')
@section('content')
  <a href="{{ route('users.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <h1 class="font-display text-xl font-bold text-slate-900 mt-2 mb-4">Tambah Pengguna</h1>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif
  @php $inp='w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600'; @endphp
  <form method="POST" action="{{ route('users.store') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4 max-w-lg">@csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama</label><input name="name" value="{{ old('name') }}" required class="{{ $inp }}"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email') }}" required class="{{ $inp }}"></div>
    <div class="grid grid-cols-2 gap-3">
      <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp') }}" class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Role</label><select name="role" class="{{ $inp }}">@foreach(['petugas'=>'Petugas','admin'=>'Admin','warga'=>'Warga'] as $k=>$v)<option value="{{ $k }}" @selected(old('role')===$k)>{{ $v }}</option>@endforeach</select></div>
    </div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label><input name="password" type="text" required class="{{ $inp }}"></div>
    <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Simpan</button>
  </form>
@endsection
