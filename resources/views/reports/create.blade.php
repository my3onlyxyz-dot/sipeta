@extends('layouts.app')
@section('title','Buat Laporan Sengketa')
@section('content')

<a href="{{ route('reports.index') }}" class="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
  <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clip-rule="evenodd"/></svg>
  Kembali
</a>

<div class="max-w-3xl">
  <h1 class="font-display text-xl font-bold text-slate-900">Buat Laporan Sengketa Tanah</h1>
  <p class="text-sm text-slate-500 mt-1 mb-6">Isi semua data dengan lengkap dan benar. Laporan yang lengkap akan mempercepat proses penanganan.</p>

  @if($errors->any())
    <div class="mb-5 rounded-xl bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm p-4">
      <p class="font-medium mb-1">Terdapat {{ $errors->count() }} kesalahan:</p>
      <ul class="list-disc pl-4 space-y-0.5">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
    </div>
  @endif

  <form method="POST" action="{{ route('reports.store') }}" enctype="multipart/form-data"
        x-data="laporanForm()" class="space-y-4">
    @csrf
    @php $inp='w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition'; @endphp

    {{-- === SEKSI 1: JUDUL & PRIORITAS === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
      <div class="px-5 py-4 border-b border-slate-100">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1.5">Judul Laporan <span class="text-rose-500">*</span></label>
          <input name="judul" value="{{ old('judul') }}" required placeholder="Contoh: Sengketa batas tanah dengan pihak X di Desa Y"
            class="{{ $inp }}">
        </div>
        <div class="grid sm:grid-cols-2 gap-3 mt-3">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Jenis Sengketa</label>
            <select name="jenis" class="{{ $inp }}">
              <option value="">— Pilih jenis sengketa —</option>
              @foreach(['Batas tanah','Kepemilikan / Sertifikat','Warisan / Pembagian harta','Jual beli bermasalah','Sewa / Perjanjian tanah','Tanah adat / Ulayat','Tanah negara / Fasilitas umum','Tumpang tindih sertifikat','Penggusuran / Pengambilalihan','Lainnya'] as $j)
                <option value="{{ $j }}" @selected(old('jenis')===$j)>{{ $j }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Prioritas <span class="text-rose-500">*</span></label>
            <select name="prioritas" class="{{ $inp }}">
              <option value="rendah" @selected(old('prioritas','sedang')==='rendah')>🟢 Rendah</option>
              <option value="sedang" @selected(old('prioritas','sedang')==='sedang')>🟡 Sedang</option>
              <option value="tinggi" @selected(old('prioritas')==='tinggi')>🔴 Tinggi / Mendesak</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 2: IDENTITAS PELAPOR (accordion) === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-emerald-50 text-emerald-700">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-5.5-2.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0zM10 12a5.99 5.99 0 00-4.793 2.39A6.483 6.483 0 0010 16.5a6.483 6.483 0 004.793-2.11A5.99 5.99 0 0010 12z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Identitas Pelapor</p>
            <p class="text-xs text-slate-400">NIK, KK, pekerjaan, alamat KTP</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Nama Lengkap Pelapor <span class="text-rose-500">*</span></label>
            <input name="nama_pelapor" value="{{ old('nama_pelapor',auth()->user()->name) }}" required class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. HP / WhatsApp <span class="text-rose-500">*</span></label>
            <input name="no_hp" value="{{ old('no_hp',auth()->user()->no_hp) }}" required class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">NIK (Nomor Induk Kependudukan)</label>
            <input name="nik_pelapor" value="{{ old('nik_pelapor') }}" maxlength="16" placeholder="16 digit sesuai KTP" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. Kartu Keluarga (KK)</label>
            <input name="no_kk" value="{{ old('no_kk') }}" maxlength="16" placeholder="16 digit" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Pekerjaan</label>
            <select name="pekerjaan" class="{{ $inp }}">
              <option value="">— Pilih pekerjaan —</option>
              @foreach(['Petani','Nelayan','Pedagang','PNS / ASN','TNI / Polri','Swasta','Wiraswasta','Pensiunan','Ibu Rumah Tangga','Pelajar / Mahasiswa','Tidak Bekerja','Lainnya'] as $p)
                <option value="{{ $p }}" @selected(old('pekerjaan')===$p)>{{ $p }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">RT / RW</label>
            <input name="rt_rw" value="{{ old('rt_rw') }}" placeholder="Contoh: 002/005" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Desa / Kelurahan (domisili)</label>
            <input name="desa_kelurahan" value="{{ old('desa_kelurahan') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Kecamatan (domisili)</label>
            <input name="kecamatan_pelapor" value="{{ old('kecamatan_pelapor') }}" class="{{ $inp }}">
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Alamat Sesuai KTP</label>
            <textarea name="alamat_ktp" rows="2" placeholder="Alamat lengkap sesuai KTP" class="{{ $inp }}">{{ old('alamat_ktp') }}</textarea>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 3: DATA SENGKETA & PIHAK TERLAPOR === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-rose-50 text-rose-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Data Sengketa & Pihak Terlapor</p>
            <p class="text-xs text-slate-400">Tanggal sengketa, pihak terlapor, saksi</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Tanggal Mulai Sengketa</label>
            <input name="tanggal_sengketa" type="date" value="{{ old('tanggal_sengketa') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Tanggal Kejadian / Peristiwa</label>
            <input name="tanggal_kejadian" type="date" value="{{ old('tanggal_kejadian') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Nama Pihak Terlapor</label>
            <input name="pihak_terlapor" value="{{ old('pihak_terlapor') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">NIK Pihak Terlapor</label>
            <input name="nik_terlapor" value="{{ old('nik_terlapor') }}" maxlength="16" placeholder="Jika diketahui" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Saksi 1</label>
            <input name="saksi_1" value="{{ old('saksi_1') }}" placeholder="Nama saksi pertama" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Saksi 2</label>
            <input name="saksi_2" value="{{ old('saksi_2') }}" placeholder="Nama saksi kedua" class="{{ $inp }}">
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Upaya Penyelesaian yang Sudah Ditempuh</label>
            <textarea name="upaya_sebelumnya" rows="2" placeholder="Contoh: Sudah musyawarah di tingkat RT, sudah lapor ke Kepala Desa, dll" class="{{ $inp }}">{{ old('upaya_sebelumnya') }}</textarea>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 4: LOKASI TANAH === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-sky-50 text-sky-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.273 1.765 11.842 11.842 0 00.976.544l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Lokasi Tanah yang Disengketakan</p>
            <p class="text-xs text-slate-400">Alamat, koordinat GPS, batas-batas tanah</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Alamat Lokasi Tanah <span class="text-rose-500">*</span></label>
            <textarea name="lokasi" rows="2" required placeholder="Jalan, Dusun, RT/RW, Desa, Kecamatan" class="{{ $inp }}">{{ old('lokasi') }}</textarea>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Desa / Kelurahan Lokasi Tanah</label>
            <input name="desa_lokasi" value="{{ old('desa_lokasi') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Kecamatan Lokasi Tanah</label>
            <input name="kecamatan" value="{{ old('kecamatan') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Luas Tanah Fisik (m²)</label>
            <input name="luas" type="number" step="0.01" value="{{ old('luas') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Luas Sesuai Dokumen (m²)</label>
            <input name="luas_dokumen" type="number" step="0.01" value="{{ old('luas_dokumen') }}" class="{{ $inp }}">
          </div>
        </div>
        {{-- Batas tanah --}}
        <div class="mt-3">
          <p class="text-xs font-medium text-slate-600 mb-2">Batas-Batas Tanah</p>
          <div class="grid grid-cols-2 gap-2">
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬆ Utara</label>
              <input name="batas_utara" value="{{ old('batas_utara') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬇ Selatan</label>
              <input name="batas_selatan" value="{{ old('batas_selatan') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">➡ Timur</label>
              <input name="batas_timur" value="{{ old('batas_timur') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬅ Barat</label>
              <input name="batas_barat" value="{{ old('batas_barat') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
          </div>
        </div>
        {{-- Koordinat GPS --}}
        <div class="mt-3 grid sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Latitude</label>
            <input name="latitude" x-ref="lat" value="{{ old('latitude') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Longitude</label>
            <input name="longitude" x-ref="lng" value="{{ old('longitude') }}" class="{{ $inp }}">
          </div>
        </div>
        <button type="button" @click="ambilGPS()"
          class="mt-2 inline-flex items-center gap-2 rounded-xl ring-1 ring-emerald-300 text-emerald-700 px-3.5 py-2 text-xs font-medium hover:bg-emerald-50 transition">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.273 1.765 11.842 11.842 0 00.976.544l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clip-rule="evenodd"/></svg>
          <span x-text="gpsLabel">Ambil lokasi GPS</span>
        </button>
      </div>
    </div>

    {{-- === SEKSI 5: DATA KEPEMILIKAN === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:false}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-amber-50 text-amber-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"/><path fill-rule="evenodd" d="M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a.75.75 0 101.06 1.06l1.261-1.26A4 4 0 108 10zm-2.5 4a2.5 2.5 0 115 0 2.5 2.5 0 01-5 0z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Data Kepemilikan Tanah</p>
            <p class="text-xs text-slate-400">Jenis hak, nomor sertifikat, cara perolehan <span class="text-slate-300">(opsional)</span></p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Jenis Hak Atas Tanah</label>
            <select name="jenis_hak" class="{{ $inp }}">
              <option value="">— Pilih jenis hak —</option>
              @foreach(['SHM (Sertifikat Hak Milik)','SHGB (Hak Guna Bangunan)','SHU (Hak Guna Usaha)','Girik / Petok D','Letter C','Eigendom Verponding','SPORADIK','Tanah Adat','Belum Bersertifikat','Lainnya'] as $h)
                <option value="{{ $h }}" @selected(old('jenis_hak')===$h)>{{ $h }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. Sertifikat / Girik / Letter C</label>
            <input name="no_sertifikat" value="{{ old('no_sertifikat') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Cara Perolehan Tanah</label>
            <select name="cara_perolehan" class="{{ $inp }}">
              <option value="">— Pilih cara perolehan —</option>
              @foreach(['Jual beli','Warisan','Hibah','Tukar menukar','Pemberian negara','Konsolidasi tanah','Redistribusi tanah','Lainnya'] as $c)
                <option value="{{ $c }}" @selected(old('cara_perolehan')===$c)>{{ $c }}</option>
              @endforeach
            </select>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 6: KRONOLOGI === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-violet-50 text-violet-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zm2.25 8.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zm0 3a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zM6 7.25a.75.75 0 01.75-.75h.5a.75.75 0 010 1.5h-.5A.75.75 0 016 7.25z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Kronologi Kejadian <span class="text-rose-500">*</span></p>
            <p class="text-xs text-slate-400">Ceritakan urutan peristiwa secara lengkap</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="mt-4">
          <textarea name="kronologi" rows="6" required
            placeholder="Ceritakan secara kronologis: kapan sengketa mulai terjadi, apa yang menjadi pokok permasalahan, tindakan apa yang sudah dilakukan oleh masing-masing pihak, siapa saja yang terlibat, dan apa yang diharapkan dari pelaporan ini."
            class="{{ $inp }}">{{ old('kronologi') }}</textarea>
          <p class="text-[11px] text-slate-400 mt-1">Semakin lengkap kronologi, semakin cepat laporan ditangani.</p>
        </div>
      </div>
    </div>

    {{-- === SEKSI 7: DOKUMEN === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-slate-100 text-slate-500">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3 3.5A1.5 1.5 0 014.5 2h6.879a1.5 1.5 0 011.06.44l4.122 4.12A1.5 1.5 0 0117 7.622V16.5a1.5 1.5 0 01-1.5 1.5h-11A1.5 1.5 0 013 16.5v-13z"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Dokumen & Foto Bukti</p>
            <p class="text-xs text-slate-400">Maks. 8 file · jpg/png/pdf · ≤ 5MB per file</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="mt-4">
          <div class="rounded-xl border-2 border-dashed border-slate-300 hover:border-emerald-400 transition p-6 text-center cursor-pointer" @click="$refs.fileinput.click()">
            <svg class="w-8 h-8 text-slate-300 mx-auto mb-2" viewBox="0 0 24 24" fill="none"><path d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" stroke="currentColor" stroke-width="1.5"/></svg>
            <p class="text-sm text-slate-500">Klik untuk pilih file atau seret ke sini</p>
            <p class="text-xs text-slate-400 mt-1">KTP, KK, sertifikat, foto tanah, dll</p>
          </div>
          <input x-ref="fileinput" type="file" name="dokumen[]" multiple accept=".jpg,.jpeg,.png,.pdf"
            @change="pilihFile($event)" class="hidden">
          <ul class="mt-3 space-y-1.5" x-show="files.length">
            <template x-for="f in files" :key="f">
              <li class="flex items-center gap-2 text-xs text-slate-600 bg-slate-50 rounded-lg px-3 py-2">
                <svg class="w-3.5 h-3.5 text-emerald-500 shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clip-rule="evenodd"/></svg>
                <span x-text="f"></span>
              </li>
            </template>
          </ul>
        </div>
      </div>
    </div>

    {{-- SUBMIT --}}
    <div class="flex items-center gap-3 pt-2">
      <button type="submit"
        class="inline-flex items-center gap-2 rounded-xl bg-emerald-700 text-white px-6 py-3 text-sm font-semibold hover:bg-emerald-800 transition shadow-sm shadow-emerald-200">
        <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3.105 2.289a.75.75 0 00-.826.95l1.414 4.925A1.5 1.5 0 005.135 9.25h6.115a.75.75 0 010 1.5H5.135a1.5 1.5 0 00-1.442 1.086l-1.414 4.926a.75.75 0 00.826.95 28.896 28.896 0 0015.293-7.154.75.75 0 000-1.115A28.897 28.897 0 003.105 2.289z"/></svg>
        Kirim Laporan
      </button>
      <a href="{{ route('reports.index') }}" class="rounded-xl ring-1 ring-slate-300 text-slate-600 px-5 py-3 text-sm hover:bg-slate-50 transition">Batal</a>
    </div>
  </form>
</div>

<script>
function laporanForm(){
  return {
    files: [],
    gpsLabel: 'Ambil lokasi GPS',
    pilihFile(e){ this.files = Array.from(e.target.files).map(f => f.name+' ('+Math.round(f.size/1024)+' KB)'); },
    ambilGPS(){
      if(!navigator.geolocation){ this.gpsLabel='GPS tidak tersedia'; return; }
      this.gpsLabel = 'Mengambil koordinat...';
      navigator.geolocation.getCurrentPosition(
        p => { this.$refs.lat.value=p.coords.latitude.toFixed(7); this.$refs.lng.value=p.coords.longitude.toFixed(7); this.gpsLabel='✓ Koordinat terisi'; },
        () => { this.gpsLabel='Gagal — isi manual'; }
      );
    },
  }
}
</script>
@endsection
