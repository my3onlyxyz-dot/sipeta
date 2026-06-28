@extends('layouts.guest')
@section('title', 'Masuk')
@section('content')
  <h1 class="font-display text-2xl font-bold text-slate-900 mb-1">Selamat datang</h1>
  <p class="text-sm text-slate-500 mb-6">Masuk untuk melanjutkan ke SIMPATI.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">{{ $errors->first() }}</div>@endif
  <form method="POST" action="{{ route('login') }}" class="space-y-4">
    @csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
      <input name="email" type="email" value="{{ old('email') }}" required autofocus class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label>
      <input name="password" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"></div>
    <label class="flex items-center gap-2 text-sm text-slate-600"><input type="checkbox" name="remember" class="rounded border-slate-300 text-emerald-600"> Ingat saya</label>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Masuk</button>
  </form>
  <p class="text-sm text-slate-500 text-center mt-6">Belum punya akun? <a href="{{ route('register') }}" class="text-emerald-700 font-medium hover:underline">Daftar sebagai warga</a></p>
@endsection
