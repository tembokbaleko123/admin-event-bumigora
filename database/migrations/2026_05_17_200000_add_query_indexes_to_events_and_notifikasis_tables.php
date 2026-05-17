<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->index('tanggal', 'events_tanggal_index');
            $table->index('kategori', 'events_kategori_index');
        });

        Schema::table('notifikasis', function (Blueprint $table) {
            $table->index(['user_id', 'status'], 'notifikasis_user_status_index');
            $table->index(['event_id', 'created_at'], 'notifikasis_event_created_index');
        });
    }

    public function down(): void
    {
        Schema::table('notifikasis', function (Blueprint $table) {
            $table->dropIndex('notifikasis_user_status_index');
            $table->dropIndex('notifikasis_event_created_index');
        });

        Schema::table('events', function (Blueprint $table) {
            $table->dropIndex('events_tanggal_index');
            $table->dropIndex('events_kategori_index');
        });
    }
};
