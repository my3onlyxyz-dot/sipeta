<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        if (! Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', fn (Blueprint $t) => $t->boolean('is_active')->default(true)->after('no_hp'));
        }
        Schema::table('reports', function (Blueprint $t) {
            if (! Schema::hasColumn('reports', 'assigned_to'))      $t->foreignId('assigned_to')->nullable()->after('user_id')->constrained('users')->nullOnDelete();
            if (! Schema::hasColumn('reports', 'prioritas'))        $t->string('prioritas')->default('sedang')->after('status');
            if (! Schema::hasColumn('reports', 'tanggal_kejadian')) $t->date('tanggal_kejadian')->nullable()->after('kronologi');
        });
    }
    public function down(): void {}
};
