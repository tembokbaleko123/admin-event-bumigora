<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }

        DB::statement("ALTER TABLE events MODIFY status ENUM('pending', 'draft', 'published', 'rejected', 'cancelled', 'completed') NOT NULL DEFAULT 'published'");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }

        DB::table('events')->where('status', 'pending')->update(['status' => 'draft']);
        DB::table('events')->where('status', 'rejected')->update(['status' => 'cancelled']);
        DB::statement("ALTER TABLE events MODIFY status ENUM('draft', 'published', 'cancelled', 'completed') NOT NULL DEFAULT 'published'");
    }
};
