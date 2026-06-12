<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('event_registrations', function (Blueprint $table) {
            $table->index(['event_id', 'status'], 'idx_event_reg_event_status');
            $table->index(['user_id', 'status'], 'idx_event_reg_user_status');
            $table->index(['user_id', 'created_at'], 'idx_event_reg_user_created');
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->index(['event_id', 'status'], 'idx_attendance_event_status');
            $table->index(['event_id', 'scanned_at'], 'idx_attendance_event_scanned');
        });

        Schema::table('events', function (Blueprint $table) {
            $table->index(['status', 'tanggal'], 'idx_events_status_tanggal');
            $table->index(['created_by', 'status', 'tanggal'], 'idx_events_creator_status_tanggal');
            $table->index(['created_by', 'created_at'], 'idx_events_creator_created');
        });

        Schema::table('notifikasis', function (Blueprint $table) {
            $table->dropIndex('idx_notifikasis_user_unread');
            $table->index(['user_id', 'status', 'created_at'], 'idx_notif_user_status_created');
            $table->index(['event_id', 'created_at'], 'idx_notif_event_created');
        });

        Schema::table('user_interests', function (Blueprint $table) {
            $table->index(['user_id', 'score'], 'idx_user_interest_score');
        });
    }

    public function down(): void
    {
        Schema::table('event_registrations', function (Blueprint $table) {
            $table->dropIndex('idx_event_reg_event_status');
            $table->dropIndex('idx_event_reg_user_status');
            $table->dropIndex('idx_event_reg_user_created');
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropIndex('idx_attendance_event_status');
            $table->dropIndex('idx_attendance_event_scanned');
        });

        Schema::table('events', function (Blueprint $table) {
            $table->dropIndex('idx_events_status_tanggal');
            $table->dropIndex('idx_events_creator_status_tanggal');
            $table->dropIndex('idx_events_creator_created');
        });

        Schema::table('notifikasis', function (Blueprint $table) {
            $table->dropIndex('idx_notif_user_status_created');
            $table->dropIndex('idx_notif_event_created');
            $table->index(['user_id', 'status'], 'idx_notifikasis_user_unread');
        });

        Schema::table('user_interests', function (Blueprint $table) {
            $table->dropIndex('idx_user_interest_score');
        });
    }
};
