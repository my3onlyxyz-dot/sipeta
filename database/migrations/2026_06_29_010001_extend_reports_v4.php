<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('reports', function (Blueprint $t) {
            // Identitas pelapor
            if (!Schema::hasColumn('reports','nik_pelapor'))     $t->string('nik_pelapor',20)->nullable()->after('no_hp');
            if (!Schema::hasColumn('reports','no_kk'))           $t->string('no_kk',20)->nullable()->after('nik_pelapor');
            if (!Schema::hasColumn('reports','pekerjaan'))        $t->string('pekerjaan',100)->nullable()->after('no_kk');
            if (!Schema::hasColumn('reports','alamat_ktp'))       $t->text('alamat_ktp')->nullable()->after('pekerjaan');
            if (!Schema::hasColumn('reports','rt_rw'))            $t->string('rt_rw',20)->nullable()->after('alamat_ktp');
            if (!Schema::hasColumn('reports','desa_kelurahan'))   $t->string('desa_kelurahan',100)->nullable()->after('rt_rw');
            if (!Schema::hasColumn('reports','kecamatan_pelapor'))$t->string('kecamatan_pelapor',100)->nullable()->after('desa_kelurahan');
            // Data kepemilikan tanah
            if (!Schema::hasColumn('reports','jenis_hak'))        $t->string('jenis_hak',50)->nullable();
            if (!Schema::hasColumn('reports','no_sertifikat'))    $t->string('no_sertifikat',100)->nullable();
            if (!Schema::hasColumn('reports','cara_perolehan'))   $t->string('cara_perolehan',50)->nullable();
            if (!Schema::hasColumn('reports','luas_dokumen'))     $t->decimal('luas_dokumen',12,2)->nullable();
            if (!Schema::hasColumn('reports','batas_utara'))      $t->string('batas_utara')->nullable();
            if (!Schema::hasColumn('reports','batas_selatan'))    $t->string('batas_selatan')->nullable();
            if (!Schema::hasColumn('reports','batas_timur'))      $t->string('batas_timur')->nullable();
            if (!Schema::hasColumn('reports','batas_barat'))      $t->string('batas_barat')->nullable();
            if (!Schema::hasColumn('reports','desa_lokasi'))      $t->string('desa_lokasi',100)->nullable();
            // Data sengketa
            if (!Schema::hasColumn('reports','nik_terlapor'))     $t->string('nik_terlapor',20)->nullable();
            if (!Schema::hasColumn('reports','saksi_1'))          $t->string('saksi_1')->nullable();
            if (!Schema::hasColumn('reports','saksi_2'))          $t->string('saksi_2')->nullable();
            if (!Schema::hasColumn('reports','upaya_sebelumnya')) $t->text('upaya_sebelumnya')->nullable();
            if (!Schema::hasColumn('reports','tanggal_sengketa')) $t->date('tanggal_sengketa')->nullable();
        });
    }
    public function down(): void {}
};
