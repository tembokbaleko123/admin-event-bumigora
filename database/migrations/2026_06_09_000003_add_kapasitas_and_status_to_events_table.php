<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->integer('kapasitas')->nullable()->after('kategori');
            $table->enum('status', ['pending', 'draft', 'published', 'rejected', 'cancelled', 'completed'])
                  ->default('published')
                  ->after('kapasitas');
        });
    }

    public function down(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn(['kapasitas', 'status']);
        });
    }
};
