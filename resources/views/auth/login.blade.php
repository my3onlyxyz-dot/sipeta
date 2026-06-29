@extends('layouts.guest')
@section('title','Masuk')
@section('content')
  <div class="mb-6">
    <h1 class="font-display text-2xl font-bold text-slate-900">Selamat datang</h1>
    <p class="text-sm text-slate-500 mt-1">Masuk untuk mengakses sistem SIMPATI.</p>
  </div>
  @if($errors->any())
    <div class="mb-4 rounded-xl bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-4 py-3 flex items-center gap-2">
      <svg class="w-4 h-4 shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z" clip-rule="evenodd"/></svg>
      {{ $errors->first() }}
    </div>
  @endif
  <form method="POST" action="{{ route('login') }}" class="space-y-4">
    @csrf
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1.5">Alamat Email</label>
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3 4a2 2 0 00-2 2v1.161l8.441 4.221a1.25 1.25 0 001.118 0L19 7.162V6a2 2 0 00-2-2H3z"/><path d="M19 8.839l-7.77 3.885a2.75 2.75 0 01-2.46 0L1 8.839V14a2 2 0 002 2h14a2 2 0 002-2V8.839z"/></svg>
        </span>
        <input name="email" type="email" value="{{ old('email') }}" required autofocus
          class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-300 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition">
      </div>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1.5">Kata Sandi</label>
      <div class="relative" x-data="{show:false}">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd"/></svg>
        </span>
        <input :type="show?'text':'password'" name="password" required
          class="w-full pl-10 pr-10 py-2.5 rounded-xl border border-slate-300 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition">
        <button type="button" @click="show=!show" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
          <svg x-show="!show" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10 12.5a2.5 2.5 0 100-5 2.5 2.5 0 000 5z"/><path fill-rule="evenodd" d="M.664 10.59a1.651 1.651 0 010-1.186A10.004 10.004 0 0110 3c4.257 0 7.893 2.66 9.336 6.41.147.381.146.804 0 1.186A10.004 10.004 0 0110 17c-4.257 0-7.893-2.66-9.336-6.41zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/></svg>
          <svg x-show="show" x-cloak class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3.28 2.22a.75.75 0 00-1.06 1.06l14.5 14.5a.75.75 0 101.06-1.06l-1.745-1.745a10.029 10.029 0 003.3-4.38 1.651 1.651 0 000-1.185A10.004 10.004 0 009.999 3a9.956 9.956 0 00-4.744 1.194L3.28 2.22zM7.752 6.69l1.092 1.092a2.5 2.5 0 013.374 3.373l1.091 1.092a4 4 0 00-5.557-5.557z" clip-rule="evenodd"/><path d="M10.748 13.93l2.523 2.523a10.003 10.003 0 01-8.33-2.952l-.36-.359c-.17-.17-.34-.34-.5-.513A10.015 10.015 0 010 10c0-.36.02-.716.058-1.065l2.414 2.414a4 4 0 005.088 5.088 4 4 0 003.188-2.507z"/></svg>
        </button>
      </div>
    </div>
    <label class="flex items-center gap-2 text-sm text-slate-600 cursor-pointer">
      <input type="checkbox" name="remember" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500">
      Ingat saya di perangkat ini
    </label>
    <button class="w-full rounded-xl bg-emerald-700 text-white py-2.5 text-sm font-semibold hover:bg-emerald-800 transition shadow-sm shadow-emerald-200">
      Masuk ke SIMPATI
    </button>
  </form>
  <div class="mt-6 pt-5 border-t border-slate-100 text-center">
    <p class="text-sm text-slate-500">Belum punya akun? <a href="{{ route('register') }}" class="font-semibold text-emerald-700 hover:underline">Daftar sebagai warga</a></p>
  </div>
@endsection
