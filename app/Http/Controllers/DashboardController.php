<?php
namespace App\Http\Controllers;

use App\Models\{Mediation, Report, ReportActivity, User};
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        return match(true) {
            $user->isAdmin()   => $this->adminDashboard($user),
            $user->isStaff()   => $this->staffDashboard($user),
            default            => $this->wargaDashboard($user),
        };
    }

    private function wargaDashboard($user)
    {
        $laporan = $user->reports();
        $stats = [
            'total'    => (clone $laporan)->count(),
            'baru'     => (clone $laporan)->where('status','baru')->count(),
            'diproses' => (clone $laporan)->where('status','diproses')->count(),
            'selesai'  => (clone $laporan)->where('status','selesai')->count(),
        ];
        $terbaru = $user->reports()->with('activities')->latest()->limit(5)->get();
        $mediasi = Mediation::whereIn('report_id',$user->reports()->pluck('id'))
            ->where('status','dijadwalkan')->where('tanggal','>=',now())->orderBy('tanggal')->limit(3)->get();
        return view('dashboard.warga', compact('stats','terbaru','mediasi'));
    }

    private function staffDashboard($user)
    {
        $stats = [
            'total'    => Report::count(),
            'baru'     => Report::where('status','baru')->count(),
            'diproses' => Report::where('status','diproses')->count(),
            'selesai'  => Report::where('status','selesai')->count(),
            'ditolak'  => Report::where('status','ditolak')->count(),
            'tugas_ku' => Report::where('assigned_to',$user->id)->whereIn('status',['baru','diproses'])->count(),
        ];
        $chart = collect(range(5,0))->map(fn($i) => [
            'label' => now()->subMonths($i)->format('M'),
            'count' => Report::whereYear('created_at',now()->subMonths($i)->year)
                             ->whereMonth('created_at',now()->subMonths($i)->month)->count(),
        ]);
        $activities   = ReportActivity::with('report','user')->latest()->limit(8)->get();
        $mediasiMendatang = Mediation::with('report')->where('status','dijadwalkan')
            ->where('tanggal','>=',now()->startOfDay())->orderBy('tanggal')->limit(5)->get();
        $laporanMasuk = Report::with('user','assignee')->where('status','baru')->latest()->limit(5)->get();
        return view('dashboard.staff', compact('stats','chart','activities','mediasiMendatang','laporanMasuk'));
    }

    private function adminDashboard($user)
    {
        $stats = [
            'total'      => Report::count(),
            'baru'       => Report::where('status','baru')->count(),
            'diproses'   => Report::where('status','diproses')->count(),
            'selesai'    => Report::where('status','selesai')->count(),
            'ditolak'    => Report::where('status','ditolak')->count(),
            'pengguna'   => User::count(),
            'warga'      => User::where('role','warga')->count(),
            'petugas'    => User::where('role','petugas')->count(),
            'mediasi'    => Mediation::count(),
        ];
        $chart = collect(range(5,0))->map(fn($i) => [
            'label' => now()->subMonths($i)->format('M'),
            'count' => Report::whereYear('created_at',now()->subMonths($i)->year)
                             ->whereMonth('created_at',now()->subMonths($i)->month)->count(),
        ]);
        $activities   = ReportActivity::with('report','user')->latest()->limit(10)->get();
        $mediasiMendatang = Mediation::with('report')->where('status','dijadwalkan')
            ->where('tanggal','>=',now()->startOfDay())->orderBy('tanggal')->limit(5)->get();
        $laporanMasuk = Report::with('user','assignee')->where('status','baru')->latest()->limit(5)->get();
        $byJenis      = Report::selectRaw('jenis, count(*) c')->groupBy('jenis')->orderByDesc('c')->limit(6)->get();
        return view('dashboard.admin', compact('stats','chart','activities','mediasiMendatang','laporanMasuk','byJenis'));
    }
}
