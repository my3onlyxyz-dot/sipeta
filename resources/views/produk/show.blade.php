<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $produk->nama }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-gray-100 min-h-screen">
    <nav class="bg-white shadow px-6 py-4">
        <a href="/produk" class="text-green-600 font-bold">← Katalog</a>
    </nav>
    <div class="max-w-lg mx-auto px-4 py-8">
        <div class="bg-white rounded-xl shadow overflow-hidden">
            @if($produk->gambar)
                <img src="/storage/{{ $produk->gambar }}" class="w-full h-64 object-cover">
            @else
                <div class="w-full h-64 bg-gray-200 flex items-center justify-center text-gray-400 text-6xl">🖼️</div>
            @endif
            <div class="p-6">
                <h1 class="text-2xl font-bold text-gray-800">{{ $produk->nama }}</h1>
                <p class="text-green-600 font-bold text-xl mt-2">Rp {{ number_format($produk->harga, 0, ',', '.') }}</p>
                <p class="text-gray-600 mt-4">{{ $produk->deskripsi }}</p>
                <div class="flex gap-2 mt-6">
                    <a href="/produk/{{ $produk->id }}/edit" class="flex-1 text-center bg-yellow-400 text-white py-2 rounded-lg hover:bg-yellow-500">Edit</a>
                    <form action="/produk/{{ $produk->id }}" method="POST" class="flex-1">
                        @csrf @method('DELETE')
                        <button type="submit" class="w-full bg-red-500 text-white py-2 rounded-lg hover:bg-red-600">Hapus</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
