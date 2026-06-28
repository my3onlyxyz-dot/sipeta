<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Katalog Produk</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-gray-100 min-h-screen">
    <nav class="bg-white shadow px-6 py-4 flex justify-between items-center">
        <h1 class="text-xl font-bold text-green-600">🛍️ Toko UMKM</h1>
        <a href="/produk/create" class="bg-green-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-600">+ Tambah Produk</a>
    </nav>
    <div class="max-w-4xl mx-auto px-4 py-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Katalog Produk</h2>
        @if(session('success'))
            <div class="bg-green-100 text-green-700 px-4 py-3 rounded-lg mb-6">{{ session('success') }}</div>
        @endif
        @if($produks->isEmpty())
            <div class="text-center py-20 text-gray-400">
                <p class="text-5xl mb-4">📦</p>
                <p>Belum ada produk. Tambahkan sekarang!</p>
            </div>
        @else
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                @foreach($produks as $p)
                <div class="bg-white rounded-xl shadow-sm overflow-hidden hover:shadow-md transition">
                    @if($p->gambar)
                        <img src="/storage/{{ $p->gambar }}" class="w-full h-48 object-cover">
                    @else
                        <div class="w-full h-48 bg-gray-200 flex items-center justify-center text-gray-400 text-4xl">🖼️</div>
                    @endif
                    <div class="p-4">
                        <h3 class="font-bold text-lg text-gray-800">{{ $p->nama }}</h3>
                        <p class="text-gray-500 text-sm mt-1 line-clamp-2">{{ $p->deskripsi }}</p>
                        <p class="text-green-600 font-bold mt-2">Rp {{ number_format($p->harga, 0, ',', '.') }}</p>
                        <div class="flex gap-2 mt-4">
                            <a href="/produk/{{ $p->id }}" class="flex-1 text-center bg-blue-500 text-white py-2 rounded-lg text-sm hover:bg-blue-600">Detail</a>
                            <a href="/produk/{{ $p->id }}/edit" class="flex-1 text-center bg-yellow-400 text-white py-2 rounded-lg text-sm hover:bg-yellow-500">Edit</a>
                            <form action="/produk/{{ $p->id }}" method="POST">
                                @csrf @method('DELETE')
                                <button type="submit" class="bg-red-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-red-600">Hapus</button>
                            </form>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        @endif
    </div>
</body>
</html>
