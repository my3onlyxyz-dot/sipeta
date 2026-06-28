<?php
namespace App\Http\Controllers;

use App\Models\Pemberitahuan;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $items = $request->user()->pemberitahuan()->latest()->paginate(20);
        return view('notifications.index', compact('items'));
    }

    public function open(Request $request, Pemberitahuan $pemberitahuan)
    {
        abort_unless($pemberitahuan->user_id === $request->user()->id, 403);
        $pemberitahuan->update(['dibaca_pada' => now()]);
        return redirect($pemberitahuan->url ?: route('dashboard'));
    }

    public function readAll(Request $request)
    {
        $request->user()->pemberitahuan()->whereNull('dibaca_pada')->update(['dibaca_pada' => now()]);
        return back()->with('success', 'Semua notifikasi ditandai dibaca.');
    }
}
