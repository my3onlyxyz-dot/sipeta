<?php
namespace App\Http\Controllers;

use App\Models\Mediation;
use App\Models\Report;
use App\Models\ReportActivity;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $base = fn () => $user->isStaff() ? Report::query() : $user->reports();

        $stats = [
            'total'    => $base()->count(),
            'baru'     => $base()->where('status', 'baru')->count(),
            'diproses' => $base()->where('status', 'diproses')->count(),
            'selesai'  => $base()->where('status', 'selesai')->count(),
        ];

        $chart = collect(range(5, 0))->map(function ($i) use ($base) {
            $m = now()->subMonths($i);
            return ['label' => $m->format('M'), 'count' => $base()->whereYear('created_at', $m->year)->whereMonth('created_at', $m->month)->count()];
        });

        $ids = $base()->pluck('id');
        $activities = ReportActivity::with('report', 'user')->whereIn('report_id', $ids)->latest()->limit(8)->get();

        $mediasiMendatang = Mediation::with('report')->whereIn('report_id', $ids)
            ->where('status', 'dijadwalkan')->where('tanggal', '>=', now()->startOfDay())
            ->orderBy('tanggal')->limit(5)->get();

        return view('dashboard', compact('stats', 'chart', 'activities', 'mediasiMendatang'));
    }
}
