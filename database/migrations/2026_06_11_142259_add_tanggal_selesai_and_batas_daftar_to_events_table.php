<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dateTime('tanggal_selesai')->nullable()->after('tanggal');
            $table->dateTime('batas_daftar')->nullable()->after('tanggal_selesai');
        });
    }

    public function down(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn(['tanggal_selesai', 'batas_daftar']);
        });
    }
};
