<!doctype html><html lang="id"><head><meta charset="utf-8"><title>Laporan {{ $report->nomor }}</title>
<style>
*{box-sizing:border-box}body{font-family:'Times New Roman',serif;color:#111;margin:0;padding:32px;line-height:1.5}
.sheet{max-width:720px;margin:0 auto}.kop{text-align:center;border-bottom:3px double #111;padding-bottom:10px;margin-bottom:18px}
.kop h1{font-size:18px;margin:0;text-transform:uppercase}.kop p{margin:2px 0;font-size:13px}
h2{font-size:15px;text-align:center;text-decoration:underline;margin:18px 0 4px}.meta{text-align:center;font-size:13px;margin-bottom:18px}
table{width:100%;border-collapse:collapse;font-size:14px}td{padding:4px 6px;vertical-align:top}td.l{width:160px;color:#333}td.s{width:14px}
.sec{margin-top:14px;font-size:14px}.sec b{display:block;margin-bottom:4px}.ttd{margin-top:48px;display:flex;justify-content:flex-end;text-align:center;font-size:14px}
.bar{position:fixed;top:0;left:0;right:0;background:#047857;color:#fff;padding:10px;text-align:center}
.bar button{background:#fff;color:#047857;border:0;padding:6px 14px;border-radius:6px;font-weight:600;cursor:pointer}
@media print{.bar{display:none}body{padding:0}}
</style></head><body>
<div class="bar">Simpan sebagai PDF &nbsp;<button onclick="window.print()">Cetak / Simpan PDF</button></div>
<div class="sheet" style="margin-top:48px">
  <div class="kop"><h1>Pemerintah Kabupaten</h1><p>Sistem Informasi Pelaporan Sengketa Tanah (SIPETA)</p></div>
  <h2>Laporan Sengketa Tanah</h2><p class="meta">Nomor: {{ $report->nomor }}</p>
  <table>
    <tr><td class="l">Judul</td><td class="s">:</td><td>{{ $report->judul }}</td></tr>
    <tr><td class="l">Nama Pelapor</td><td class="s">:</td><td>{{ $report->nama_pelapor }}</td></tr>
    <tr><td class="l">No. HP</td><td class="s">:</td><td>{{ $report->no_hp }}</td></tr>
    <tr><td class="l">Jenis Sengketa</td><td class="s">:</td><td>{{ $report->jenis ?: '-' }}</td></tr>
    <tr><td class="l">Prioritas</td><td class="s">:</td><td>{{ $report->prioritasLabel() }}</td></tr>
    <tr><td class="l">Pihak Terlapor</td><td class="s">:</td><td>{{ $report->pihak_terlapor ?: '-' }}</td></tr>
    <tr><td class="l">Lokasi Tanah</td><td class="s">:</td><td>{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</td></tr>
    <tr><td class="l">Luas</td><td class="s">:</td><td>{{ $report->luas ? number_format($report->luas,0,',','.').' m²' : '-' }}</td></tr>
    @if($report->latitude)<tr><td class="l">Koordinat</td><td class="s">:</td><td>{{ $report->latitude }}, {{ $report->longitude }}</td></tr>@endif
    <tr><td class="l">Petugas</td><td class="s">:</td><td>{{ $report->assignee?->name ?: '-' }}</td></tr>
    <tr><td class="l">Status</td><td class="s">:</td><td>{{ $report->statusLabel() }}</td></tr>
    <tr><td class="l">Tanggal Lapor</td><td class="s">:</td><td>{{ $report->created_at->format('d F Y') }}</td></tr>
  </table>
  <div class="sec"><b>Kronologi:</b>{{ $report->kronologi }}</div>
  @if($report->catatan_petugas)<div class="sec"><b>Catatan Petugas:</b>{{ $report->catatan_petugas }}</div>@endif
  <div class="ttd"><div><p>{{ $report->kecamatan ?: '....................' }}, {{ now()->format('d F Y') }}</p><p>Pelapor,</p><br><br><br><p>( {{ $report->nama_pelapor }} )</p></div></div>
</div></body></html>
