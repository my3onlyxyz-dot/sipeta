@extends('layouts.app')
@section('title', 'Detail Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <div class="flex flex-wrap items-start justify-between gap-3 mt-2 mb-4">
    <div>
      <div class="flex items-center gap-2 flex-wrap">
        <span class="text-xs font-mono text-slate-400">{{ $report->nomor }}</span>
        <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
        <span class="inline-flex items-center gap-1 text-xs text-slate-500"><span class="w-1.5 h-1.5 rounded-full {{ $report->prioritasDot() }}"></span>Prioritas {{ $report->prioritasLabel() }}</span>
      </div>
      <h1 class="font-display text-xl font-bold text-slate-900 mt-1">{{ $report->judul }}</h1>
      <p class="text-sm text-slate-500">Diajukan {{ $report->created_at->format('d M Y, H:i') }} oleh {{ $report->user->name }}</p>
    </div>
    <a href="{{ route('reports.print', $report) }}" target="_blank" class="inline-flex items-center gap-2 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-2 text-sm hover:bg-slate-50">🖨 Cetak / PDF</a>
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Rincian</h2>
        <dl class="grid sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
          <div><dt class="text-slate-400">Pelapor</dt><dd class="text-slate-800">{{ $report->nama_pelapor }} · {{ $report->no_hp }}</dd></div>
          <div><dt class="text-slate-400">Jenis</dt><dd class="text-slate-800">{{ $report->jenis ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Pihak terlapor</dt><dd class="text-slate-800">{{ $report->pihak_terlapor ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Luas</dt><dd class="text-slate-800">{{ $report->luas ? number_format($report->luas,0,',','.').' m²' : '—' }}</dd></div>
          <div><dt class="text-slate-400">Tanggal kejadian</dt><dd class="text-slate-800">{{ $report->tanggal_kejadian?->format('d M Y') ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Petugas penanganan</dt><dd class="text-slate-800">{{ $report->assignee?->name ?: 'Belum didisposisi' }}</dd></div>
          <div class="sm:col-span-2"><dt class="text-slate-400">Lokasi</dt><dd class="text-slate-800">{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</dd></div>
          @if($report->latitude && $report->longitude)
            <div class="sm:col-span-2"><dt class="text-slate-400">Koordinat</dt><dd><a class="text-emerald-700 hover:underline" target="_blank" href="https://www.google.com/maps?q={{ $report->latitude }},{{ $report->longitude }}">{{ $report->latitude }}, {{ $report->longitude }} (peta)</a></dd></div>
          @endif
        </dl>
      </div>

      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-2">Kronologi</h2>
        <p class="text-sm text-slate-700 whitespace-pre-line">{{ $report->kronologi }}</p>
      </div>

      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Dokumen / Bukti</h2>
        @forelse($report->documents as $doc)
          <a href="{{ asset('storage/'.$doc->path) }}" target="_blank" class="flex items-center gap-3 py-2 border-b border-slate-50 last:border-0 hover:bg-slate-50 -mx-1 px-1 rounded">
            @if($doc->isImage())<img src="{{ asset('storage/'.$doc->path) }}" class="w-10 h-10 rounded object-cover ring-1 ring-slate-200">@else<span class="grid place-items-center w-10 h-10 rounded bg-rose-50 text-rose-600 text-xs font-medium">PDF</span>@endif
            <span class="text-sm text-slate-700 truncate">{{ $doc->nama_asli }}</span>
          </a>
        @empty<p class="text-sm text-slate-400">Tidak ada dokumen.</p>@endforelse
      </div>

      <!-- TIMELINE -->
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-4">Riwayat / Timeline</h2>
        <div class="relative pl-4 space-y-4 before:absolute before:left-1 before:top-1 before:bottom-1 before:w-px before:bg-slate-200">
          @foreach($report->activities as $a)
            <div class="relative">
              <span class="absolute -left-[13px] top-1 w-2.5 h-2.5 rounded-full ring-4 ring-white {{ $a->dotColor() }}"></span>
              <p class="text-sm text-slate-700">{{ $a->deskripsi }}</p>
              <p class="text-xs text-slate-400">{{ $a->user?->name ?? 'Sistem' }} · {{ $a->created_at->format('d M Y H:i') }}</p>
            </div>
          @endforeach
        </div>
      </div>
    </div>

    <div class="space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Status</h2>
        <span class="inline-block text-sm px-3 py-1 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
        @if($report->catatan_petugas)<div class="mt-3 text-sm text-slate-600 bg-slate-50 rounded-lg p-3"><p class="text-xs text-slate-400 mb-1">Catatan petugas</p>{{ $report->catatan_petugas }}</div>@endif
      </div>

      @if(auth()->user()->isStaff())
        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Disposisi</h2>
          <form method="POST" action="{{ route('reports.assign', $report) }}" class="flex gap-2">@csrf
            <select name="assigned_to" class="flex-1 rounded-lg border border-slate-300 px-3 py-2 text-sm">
              <option value="">— belum —</option>
              @foreach($petugasList as $p)<option value="{{ $p->id }}" @selected($report->assigned_to==$p->id)>{{ $p->name }} ({{ $p->roleLabel() }})</option>@endforeach
            </select>
            <button class="rounded-lg bg-slate-900 text-white px-3 py-2 text-sm">Set</button>
          </form>
        </div>

        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Ubah Status</h2>
          <form method="POST" action="{{ route('reports.status', $report) }}" class="space-y-3">@csrf @method('PATCH')
            <select name="status" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">@foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)<option value="{{ $k }}" @selected($report->status===$k)>{{ $v }}</option>@endforeach</select>
            <textarea name="catatan_petugas" rows="3" placeholder="Catatan untuk pelapor" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">{{ $report->catatan_petugas }}</textarea>
            <button class="w-full rounded-lg bg-emerald-700 text-white py-2 text-sm hover:bg-emerald-800">Simpan</button>
          </form>
        </div>

        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Jadwalkan Mediasi</h2>
          <form method="POST" action="{{ route('mediations.store', $report) }}" class="space-y-2">@csrf
            <input type="datetime-local" name="tanggal" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <input name="tempat" placeholder="Tempat" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <textarea name="agenda" rows="2" placeholder="Agenda" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"></textarea>
            <button class="w-full rounded-lg ring-1 ring-emerald-300 text-emerald-700 py-2 text-sm hover:bg-emerald-50">+ Tambah jadwal</button>
          </form>
        </div>
      @endif

      @if($report->mediations->count())
        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Mediasi</h2>
          <div class="space-y-3">
            @foreach($report->mediations as $m)
              <div class="border border-slate-100 rounded-lg p-3">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-slate-800">{{ $m->tanggal->format('d M Y · H:i') }}</p>
                  <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $m->statusClasses() }}">{{ ucfirst($m->status) }}</span>
                </div>
                @if($m->tempat)<p class="text-xs text-slate-500">📍 {{ $m->tempat }}</p>@endif
                @if($m->agenda)<p class="text-xs text-slate-500 mt-1">{{ $m->agenda }}</p>@endif
                @if($m->hasil)<p class="text-xs text-emerald-700 mt-1">Hasil: {{ $m->hasil }}</p>@endif
                @if(auth()->user()->isStaff())
                  <form method="POST" action="{{ route('mediations.update', $m) }}" class="mt-2 flex gap-2">@csrf @method('PATCH')
                    <select name="status" class="rounded-lg border border-slate-300 px-2 py-1 text-xs">@foreach(['dijadwalkan'=>'Dijadwalkan','selesai'=>'Selesai','batal'=>'Batal'] as $k=>$v)<option value="{{ $k }}" @selected($m->status===$k)>{{ $v }}</option>@endforeach</select>
                    <input name="hasil" value="{{ $m->hasil }}" placeholder="Hasil" class="flex-1 rounded-lg border border-slate-300 px-2 py-1 text-xs">
                    <button class="rounded-lg bg-slate-900 text-white px-2 py-1 text-xs">OK</button>
                  </form>
                @endif
              </div>
            @endforeach
          </div>
        </div>
      @endif

      @if(auth()->user()->isStaff() || $report->user_id === auth()->id())
        <form method="POST" action="{{ route('reports.destroy', $report) }}" onsubmit="return confirm('Hapus laporan ini?')">@csrf @method('DELETE')
          <button class="w-full rounded-lg ring-1 ring-rose-300 text-rose-600 py-2 text-sm hover:bg-rose-50">Hapus laporan</button>
        </form>
      @endif
    </div>
  </div>
@endsection
