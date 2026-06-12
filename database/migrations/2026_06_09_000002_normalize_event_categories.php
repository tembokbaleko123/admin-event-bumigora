<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $map = [
            'Seminar' => 'SEMINAR',
            'Workshop' => 'WORKSHOP',
            'Kuliah Umum' => 'KULIAH',
            'Praktikum' => 'KULIAH',
            'UTS' => 'KULIAH',
            'UAS' => 'KULIAH',
        ];

        foreach ($map as $from => $to) {
            DB::table('events')->where('kategori', $from)->update(['kategori' => $to]);
        }

        DB::table('events')->where('kategori', 'Lainnya')->update(['kategori' => null]);
    }

    public function down(): void
    {
        // Keep canonical categories on rollback; old mixed labels were intentionally normalized.
    }
};
