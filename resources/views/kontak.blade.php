@extends('layouts.app')
@section('title', 'Kontak & Bantuan')
@section('content')
  @php $wa = preg_replace('/\D/', '', config('kantor.telp')); @endphp
  <h1 class="font-display text-xl font-bold text-slate-900 mb-1">Kontak & Bantuan</h1>
  <p class="text-sm text-slate-500 mb-5">Hubungi {{ config('kantor.nama') }} untuk pertanyaan seputar laporan sengketa tanah.</p>

  <div class="grid sm:grid-cols-2 gap-4">
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">☏</div>
      <p class="text-xs text-slate-400">Telepon / WhatsApp</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.telp') }}</p>
      <div class="flex gap-2 mt-3">
        <a href="tel:+{{ $wa }}" class="rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Telepon</a>
        <a href="https://wa.me/{{ $wa }}" target="_blank" class="rounded-lg bg-emerald-700 text-white px-3 py-1.5 text-sm hover:bg-emerald-800">WhatsApp</a>
      </div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">✉</div>
      <p class="text-xs text-slate-400">Email</p>
      <p class="text-slate-800 font-medium break-all">{{ config('kantor.email') }}</p>
      <a href="mailto:{{ config('kantor.email') }}" class="inline-block mt-3 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Kirim Email</a>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">⚲</div>
      <p class="text-xs text-slate-400">Alamat Kantor</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.alamat') }}</p>
      <a href="https://www.google.com/maps/search/{{ urlencode(config('kantor.alamat')) }}" target="_blank" class="inline-block mt-3 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-1.5 text-sm hover:bg-slate-50">Lihat di Peta</a>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 grid place-items-center text-emerald-700 mb-3">◷</div>
      <p class="text-xs text-slate-400">Jam Pelayanan</p>
      <p class="text-slate-800 font-medium">{{ config('kantor.jam') }}</p>
    </div>
  </div>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 mt-4">
    <h2 class="font-display font-semibold text-slate-900 mb-3">Panduan singkat</h2>
    <ol class="list-decimal pl-5 space-y-1.5 text-sm text-slate-600">
      <li>Daftar / masuk menggunakan akun warga.</li>
      <li>Pilih <b>Buat Laporan</b>, isi data, lokasi/koordinat, dan unggah bukti.</li>
      <li>Pantau status laporan di menu <b>Laporan Saya</b> dan notifikasi.</li>
      <li>Petugas akan memproses, menjadwalkan mediasi bila perlu, hingga selesai.</li>
    </ol>
  </div>
@endsection
