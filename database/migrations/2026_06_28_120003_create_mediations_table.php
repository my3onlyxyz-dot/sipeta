<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('mediations', function (Blueprint $t) {
            $t->id();
            $t->foreignId('report_id')->constrained()->cascadeOnDelete();
            $t->foreignId('dijadwalkan_oleh')->nullable()->constrained('users')->nullOnDelete();
            $t->dateTime('tanggal');
            $t->string('tempat')->nullable();
            $t->text('agenda')->nullable();
            $t->text('hasil')->nullable();
            $t->string('status')->default('dijadwalkan'); // dijadwalkan | selesai | batal
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('mediations'); }
};
