<?php
namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = $user->isStaff() ? Report::query()->with('user', 'assignee') : $user->reports();

        if ($s = $request->query('status'))   $query->where('status', $s);
        if ($p = $request->query('prioritas')) $query->where('prioritas', $p);
        if ($request->query('saya') && $user->isStaff()) $query->where('assigned_to', $user->id);
        if ($q = $request->query('q')) {
            $query->where(fn ($w) => $w->where('judul', 'like', "%$q%")->orWhere('nomor', 'like', "%$q%")->orWhere('lokasi', 'like', "%$q%"));
        }

        $reports = $query->latest()->paginate(10)->withQueryString();
        return view('reports.index', compact('reports'));
    }

    public function create() { return view('reports.create'); }

    public function store(Request $request)
    {
        $data = $request->validate([
            'judul' => ['required', 'string', 'max:150'],
            'nama_pelapor' => ['required', 'string', 'max:255'],
            'no_hp' => ['required', 'string', 'max:20'],
            'jenis' => ['nullable', 'string', 'max:50'],
            'prioritas' => ['required', 'in:rendah,sedang,tinggi'],
            'lokasi' => ['required', 'string'],
            'kecamatan' => ['nullable', 'string', 'max:100'],
            'luas' => ['nullable', 'numeric', 'min:0'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'pihak_terlapor' => ['nullable', 'string', 'max:255'],
            'tanggal_kejadian' => ['nullable', 'date'],
            'kronologi' => ['required', 'string'],
            'dokumen' => ['nullable', 'array', 'max:6'],
            'dokumen.*' => ['file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'],
        ]);

        $report = $request->user()->reports()->create($data + ['status' => 'baru']);
        $report->update(['nomor' => 'TS-' . str_pad($report->id, 5, '0', STR_PAD_LEFT)]);

        foreach ((array) $request->file('dokumen') as $file) {
            $path = $file->store('dokumen', 'public');
            $report->documents()->create([
                'path' => $path, 'nama_asli' => $file->getClientOriginalName(),
                'mime' => $file->getMimeType(), 'ukuran' => $file->getSize(),
            ]);
        }

        $report->addActivity('dibuat', 'Laporan dibuat oleh ' . $request->user()->name);

        return redirect()->route('reports.show', $report)->with('success', 'Laporan terkirim. Nomor: ' . $report->nomor);
    }

    public function show(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user', 'assignee', 'activities.user', 'mediations.penjadwal');
        $petugasList = $request->user()->isStaff()
            ? User::whereIn('role', ['petugas', 'admin'])->where('is_active', true)->orderBy('name')->get()
            : collect();
        return view('reports.show', compact('report', 'petugasList'));
    }

    public function updateStatus(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'status' => ['required', 'in:baru,diproses,selesai,ditolak'],
            'catatan_petugas' => ['nullable', 'string'],
        ]);
        $old = $report->statusLabel();
        $report->update($data);
        $report->addActivity('status', "Status diubah: {$old} → {$report->statusLabel()}");
        $report->notifyOwner('Status laporan diperbarui', "{$report->nomor} kini berstatus {$report->statusLabel()}.");
        return back()->with('success', 'Status laporan diperbarui.');
    }

    public function assign(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate(['assigned_to' => ['nullable', 'exists:users,id']]);
        $report->update($data);
        $nama = $report->assignee?->name ?? '—';
        $report->addActivity('disposisi', "Laporan didisposisikan ke: {$nama}");
        if ($report->assigned_to) {
            \App\Models\Pemberitahuan::create([
                'user_id' => $report->assigned_to, 'judul' => 'Disposisi laporan baru',
                'isi' => "Anda ditugaskan menangani {$report->nomor}.", 'url' => route('reports.show', $report),
            ]);
        }
        return back()->with('success', 'Disposisi diperbarui.');
    }

    public function print(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user', 'assignee');
        return view('reports.print', compact('report'));
    }

    public function destroy(Request $request, Report $report)
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id === $user->id, 403);
        $report->delete();
        return redirect()->route('reports.index')->with('success', 'Laporan dihapus.');
    }

    private function authorizeView(Request $request, Report $report): void
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id === $user->id, 403);
    }
}
