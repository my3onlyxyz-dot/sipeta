@extends('layouts.guest')
@section('title', 'Daftar')
@section('content')
  <h1 class="font-display text-2xl font-bold text-slate-900 mb-1">Buat akun warga</h1>
  <p class="text-sm text-slate-500 mb-6">Daftar untuk mengajukan laporan.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif
  <form method="POST" action="{{ route('register') }}" class="space-y-4">
    @csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama lengkap</label><input name="name" value="{{ old('name') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP / WhatsApp</label><input name="no_hp" value="{{ old('no_hp') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div class="grid grid-cols-2 gap-3">
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi</label><input name="password" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Ulangi</label><input name="password_confirmation" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    </div>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Daftar</button>
  </form>
  <p class="text-sm text-slate-500 text-center mt-6">Sudah punya akun? <a href="{{ route('login') }}" class="text-emerald-700 font-medium hover:underline">Masuk</a></p>
@endsection
