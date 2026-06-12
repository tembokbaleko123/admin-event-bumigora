<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Adds performance indexes for common query patterns
     */
    public function up(): void
    {
        // Events table indexes
        Schema::table('events', function (Blueprint $table) {
            // Index for date-based queries (calendar view)
            $table->index('tanggal', 'idx_events_tanggal');

            // Index for location search
            $table->index('lokasi', 'idx_events_lokasi');

            // Index for category filtering
            $table->index('kategori', 'idx_events_kategori');

            // Composite index for common filter combinations
            $table->index(['tanggal', 'kategori'], 'idx_events_date_category');

            // Index for creator queries
            $table->index('created_by', 'idx_events_created_by');
        });

        // Informasis table indexes
        Schema::table('informasis', function (Blueprint $table) {
            // Index for date-based queries
            $table->index('tanggal', 'idx_informasis_tanggal');

            // Index for creator queries
            $table->index('dibuat_oleh', 'idx_informasis_dibuat_oleh');
        });

        // Notifikasis table indexes
        Schema::table('notifikasis', function (Blueprint $table) {
            // Index for user notification queries
            $table->index('user_id', 'idx_notifikasis_user_id');

            // Index for unread notification queries (using 'status' column)
            $table->index(['user_id', 'status'], 'idx_notifikasis_user_unread');

            // Index for event-related notifications
            $table->index('event_id', 'idx_notifikasis_event_id');
        });

        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            // Index for email lookups (login)
            $table->index('email', 'idx_users_email');

            // Index for role-based queries
            $table->index('role', 'idx_users_role');
        });

        // Personal access tokens indexes
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            // Index for token lookups
            $table->index('token', 'idx_tokens_token');
            $table->index(['tokenable_type', 'tokenable_id'], 'idx_tokens_owner');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Events table indexes
        Schema::table('events', function (Blueprint $table) {
            $table->dropIndex('idx_events_tanggal');
            $table->dropIndex('idx_events_lokasi');
            $table->dropIndex('idx_events_kategori');
            $table->dropIndex('idx_events_date_category');
            $table->dropIndex('idx_events_created_by');
        });

        // Informasis table indexes
        Schema::table('informasis', function (Blueprint $table) {
            $table->dropIndex('idx_informasis_tanggal');
            $table->dropIndex('idx_informasis_dibuat_oleh');
        });

        // Notifikasis table indexes
        Schema::table('notifikasis', function (Blueprint $table) {
            $table->dropIndex('idx_notifikasis_user_id');
            $table->dropIndex('idx_notifikasis_user_unread');
            $table->dropIndex('idx_notifikasis_event_id');
        });

        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_users_email');
            $table->dropIndex('idx_users_role');
        });

        // Personal access tokens indexes
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->dropIndex('idx_tokens_token');
            $table->dropIndex('idx_tokens_owner');
        });
    }
};
