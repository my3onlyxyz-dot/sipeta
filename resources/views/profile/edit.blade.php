@extends('layouts.app')
@section('title', 'Profil')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Profil & Keamanan</h1>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">{{ $errors->first() }}</div>@endif
  @php $inp='w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600'; $u=auth()->user(); @endphp
  <div class="grid lg:grid-cols-2 gap-4">
    <form method="POST" action="{{ route('profile.update') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">@csrf @method('PATCH')
      <h2 class="font-display font-semibold text-slate-700">Data diri</h2>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama</label><input name="name" value="{{ old('name',$u->name) }}" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email',$u->email) }}" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp',$u->no_hp) }}" required class="{{ $inp }}"></div>
      <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Simpan</button>
    </form>
    <form method="POST" action="{{ route('profile.password') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">@csrf @method('PATCH')
      <h2 class="font-display font-semibold text-slate-700">Ganti kata sandi</h2>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi saat ini</label><input name="current_password" type="password" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi baru</label><input name="password" type="password" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Ulangi sandi baru</label><input name="password_confirmation" type="password" required class="{{ $inp }}"></div>
      <button class="rounded-lg bg-slate-900 text-white px-5 py-2.5 text-sm font-medium">Perbarui sandi</button>
    </form>
  </div>
@endsection
