@extends('layouts.app')
@section('title', 'Buat Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <h1 class="font-display text-xl font-bold text-slate-900 mt-2 mb-1">Buat Laporan Sengketa Tanah</h1>
  <p class="text-sm text-slate-500 mb-5">Lengkapi data agar mudah ditindaklanjuti petugas.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

  <form method="POST" action="{{ route('reports.store') }}" enctype="multipart/form-data" x-data="reportForm()" class="space-y-5">
    @csrf
    @php $inp = 'w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100'; @endphp

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Data Pelapor & Perkara</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Judul laporan</label><input name="judul" value="{{ old('judul') }}" required placeholder="Cth: Sengketa batas tanah dengan tetangga" class="{{ $inp }}"></div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama pelapor</label><input name="nama_pelapor" value="{{ old('nama_pelapor', auth()->user()->name) }}" required class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp', auth()->user()->no_hp) }}" required class="{{ $inp }}"></div>
      </div>
      <div class="grid sm:grid-cols-3 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Jenis sengketa</label>
          <select name="jenis" class="{{ $inp }}"><option value="">— pilih —</option>@foreach(['Batas tanah','Kepemilikan','Warisan','Jual beli','Sewa','Lainnya'] as $j)<option value="{{ $j }}" @selected(old('jenis')===$j)>{{ $j }}</option>@endforeach</select></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Prioritas</label>
          <select name="prioritas" class="{{ $inp }}">@foreach(['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'] as $k=>$v)<option value="{{ $k }}" @selected(old('prioritas','sedang')===$k)>{{ $v }}</option>@endforeach</select></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Tanggal kejadian</label><input name="tanggal_kejadian" type="date" value="{{ old('tanggal_kejadian') }}" class="{{ $inp }}"></div>
      </div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Pihak terlapor (opsional)</label><input name="pihak_terlapor" value="{{ old('pihak_terlapor') }}" class="{{ $inp }}"></div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Lokasi Tanah</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Alamat / letak tanah</label><textarea name="lokasi" rows="2" required class="{{ $inp }}">{{ old('lokasi') }}</textarea></div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Kecamatan</label><input name="kecamatan" value="{{ old('kecamatan') }}" class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Luas (m²)</label><input name="luas" type="number" step="0.01" value="{{ old('luas') }}" class="{{ $inp }}"></div>
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Latitude</label><input name="latitude" x-ref="lat" value="{{ old('latitude') }}" class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Longitude</label><input name="longitude" x-ref="lng" value="{{ old('longitude') }}" class="{{ $inp }}"></div>
      </div>
      <button type="button" @click="ambilLokasi()" class="inline-flex items-center gap-2 rounded-lg ring-1 ring-emerald-300 text-emerald-700 px-3 py-2 text-sm hover:bg-emerald-50">
        <svg viewBox="0 0 24 24" class="w-4 h-4" fill="none"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg><span x-text="locLabel"></span>
      </button>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Kronologi & Bukti</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Kronologi kejadian</label><textarea name="kronologi" rows="5" required class="{{ $inp }}">{{ old('kronologi') }}</textarea></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Dokumen / foto bukti (maks 6, jpg/png/pdf ≤5MB)</label>
        <input type="file" name="dokumen[]" multiple accept=".jpg,.jpeg,.png,.pdf" @change="pickFiles($event)" class="block w-full text-sm text-slate-600 file:mr-3 file:rounded-lg file:border-0 file:bg-emerald-50 file:text-emerald-700 file:px-3 file:py-2">
        <ul class="mt-2 space-y-1" x-show="files.length"><template x-for="f in files" :key="f"><li class="text-xs text-slate-500">• <span x-text="f"></span></li></template></ul>
      </div>
    </div>

    <div class="flex gap-3">
      <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Kirim Laporan</button>
      <a href="{{ route('reports.index') }}" class="rounded-lg ring-1 ring-slate-300 text-slate-600 px-5 py-2.5 text-sm hover:bg-slate-50">Batal</a>
    </div>
  </form>

  <script>
    function reportForm(){
      return {
        files: [], locLabel: 'Ambil lokasi saya (GPS)',
        pickFiles(e){ this.files = Array.from(e.target.files).map(f => f.name + ' (' + Math.round(f.size/1024) + ' KB)'); },
        ambilLokasi(){
          if(!navigator.geolocation){ this.locLabel='GPS tidak didukung'; return; }
          this.locLabel='Mengambil lokasi...';
          navigator.geolocation.getCurrentPosition(
            p => { this.$refs.lat.value=p.coords.latitude.toFixed(7); this.$refs.lng.value=p.coords.longitude.toFixed(7); this.locLabel='Lokasi terisi ✓'; },
            () => { this.locLabel='Gagal — isi manual'; });
        },
      }
    }
  </script>
@endsection
