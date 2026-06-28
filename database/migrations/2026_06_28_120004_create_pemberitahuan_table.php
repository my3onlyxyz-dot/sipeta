<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('pemberitahuan', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('judul');
            $t->text('isi')->nullable();
            $t->string('url')->nullable();
            $t->timestamp('dibaca_pada')->nullable();
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('pemberitahuan'); }
};
