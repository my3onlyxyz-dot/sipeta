<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            abort_unless($request->user() && $request->user()->isAdmin(), 403);
            return $next($request);
        });
    }

    public function index(Request $request)
    {
        $users = User::when($request->query('q'), fn ($q, $s) => $q->where('name', 'like', "%$s%")->orWhere('email', 'like', "%$s%"))
            ->orderBy('name')->paginate(15)->withQueryString();
        return view('users.index', compact('users'));
    }

    public function create() { return view('users.create'); }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'no_hp' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:admin,petugas,warga'],
            'password' => ['required', 'min:6'],
        ]);
        User::create($data + ['is_active' => true]);
        return redirect()->route('users.index')->with('success', 'Pengguna ditambahkan.');
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'role' => ['required', 'in:admin,petugas,warga'],
            'is_active' => ['required', 'boolean'],
        ]);
        $user->update($data);
        return back()->with('success', 'Pengguna diperbarui.');
    }

    public function resetPassword(User $user)
    {
        $new = Str::password(10, true, true, false);
        $user->update(['password' => $new]);
        return back()->with('success', "Sandi {$user->name} direset menjadi: {$new}");
    }

    public function destroy(Request $request, User $user)
    {
        abort_if($user->id === $request->user()->id, 403, 'Tidak bisa menghapus akun sendiri.');
        $user->delete();
        return back()->with('success', 'Pengguna dihapus.');
    }
}
