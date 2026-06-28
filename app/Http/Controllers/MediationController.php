<?php
namespace App\Http\Controllers;

use App\Models\Mediation;
use App\Models\Report;
use Illuminate\Http\Request;

class MediationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $q = Mediation::with('report', 'penjadwal');
        if (! $user->isStaff()) {
            $q->whereIn('report_id', $user->reports()->pluck('id'));
        }
        $mediations = $q->orderByDesc('tanggal')->paginate(15);
        return view('mediations.index', compact('mediations'));
    }

    public function store(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'tanggal' => ['required', 'date'],
            'tempat' => ['nullable', 'string', 'max:255'],
            'agenda' => ['nullable', 'string'],
        ]);
        $report->mediations()->create($data + ['dijadwalkan_oleh' => $request->user()->id, 'status' => 'dijadwalkan']);
        $report->addActivity('mediasi', 'Mediasi dijadwalkan: ' . \Illuminate\Support\Carbon::parse($data['tanggal'])->format('d M Y H:i'));
        $report->notifyOwner('Jadwal mediasi', "Mediasi {$report->nomor} dijadwalkan " . \Illuminate\Support\Carbon::parse($data['tanggal'])->format('d M Y H:i') . '.');
        return back()->with('success', 'Jadwal mediasi ditambahkan.');
    }

    public function update(Request $request, Mediation $mediation)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'status' => ['required', 'in:dijadwalkan,selesai,batal'],
            'hasil' => ['nullable', 'string'],
        ]);
        $mediation->update($data);
        $mediation->report->addActivity('mediasi', "Mediasi {$mediation->status}");
        return back()->with('success', 'Mediasi diperbarui.');
    }

    public function destroy(Request $request, Mediation $mediation)
    {
        abort_unless($request->user()->isStaff(), 403);
        $mediation->delete();
        return back()->with('success', 'Jadwal mediasi dihapus.');
    }
}
