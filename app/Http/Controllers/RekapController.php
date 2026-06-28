<?php
namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;

class RekapController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isStaff(), 403);
        $byStatus = Report::selectRaw('status, count(*) c')->groupBy('status')->pluck('c', 'status');
        $byJenis  = Report::selectRaw('jenis, count(*) c')->groupBy('jenis')->orderByDesc('c')->get();
        $byKec    = Report::selectRaw('kecamatan, count(*) c')->whereNotNull('kecamatan')->groupBy('kecamatan')->orderByDesc('c')->limit(10)->get();
        $total    = Report::count();
        return view('rekap.index', compact('byStatus', 'byJenis', 'byKec', 'total'));
    }

    public function export(Request $request)
    {
        abort_unless($request->user()->isStaff(), 403);
        $rows = Report::with('user')->latest()->get();
        $callback = function () use ($rows) {
            $h = fopen('php://output', 'w');
            fputcsv($h, ['Nomor', 'Judul', 'Pelapor', 'Jenis', 'Prioritas', 'Lokasi', 'Kecamatan', 'Status', 'Tanggal']);
            foreach ($rows as $r) {
                fputcsv($h, [$r->nomor, $r->judul, $r->nama_pelapor, $r->jenis, $r->prioritasLabel(), $r->lokasi, $r->kecamatan, $r->statusLabel(), $r->created_at->format('Y-m-d H:i')]);
            }
            fclose($h);
        };
        return response()->stream($callback, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="rekap-laporan-' . now()->format('Ymd') . '.csv"',
        ]);
    }
}
