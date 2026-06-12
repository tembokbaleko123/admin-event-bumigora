<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $driver = DB::getDriverName();

        if ($driver === 'mysql') {
            DB::statement('ALTER TABLE events MODIFY tanggal DATETIME NOT NULL');
        } elseif ($driver === 'pgsql') {
            DB::statement('ALTER TABLE events ALTER COLUMN tanggal TYPE TIMESTAMP(0) WITHOUT TIME ZONE USING tanggal::timestamp');
        }
        // SQLite: no-op — SQLite treats DATE/DATETIME/TIMESTAMP identically as TEXT affinity
    }

    public function down(): void
    {
        $driver = DB::getDriverName();

        if ($driver === 'mysql') {
            DB::statement('ALTER TABLE events MODIFY tanggal DATE NOT NULL');
        } elseif ($driver === 'pgsql') {
            DB::statement('ALTER TABLE events ALTER COLUMN tanggal TYPE DATE USING tanggal::date');
        }
        // SQLite: no-op
    }
};
