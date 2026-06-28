<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('nomor')->nullable()->unique();
            $table->string('judul');
            $table->string('nama_pelapor');
            $table->string('no_hp');
            $table->string('jenis')->nullable();          // batas, kepemilikan, waris, dll
            $table->text('lokasi');                        // alamat tanah
            $table->string('kecamatan')->nullable();
            $table->decimal('luas', 12, 2)->nullable();    // m2
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('pihak_terlapor')->nullable();
            $table->text('kronologi');
            $table->string('status')->default('baru');     // baru | diproses | selesai | ditolak
            $table->text('catatan_petugas')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('reports'); }
};
