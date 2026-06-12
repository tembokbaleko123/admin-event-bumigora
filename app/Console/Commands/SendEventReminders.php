<?php

namespace App\Console\Commands;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\Notifikasi;
use Illuminate\Console\Command;

class SendEventReminders extends Command
{
    protected $signature = 'notifications:send-reminders';
    protected $description = 'Send H-1 and 1-hour reminders for upcoming events';

    public function handle(): int
    {
        $now = now();
        $sent = 0;
        $today = $now->format('Y-m-d');

        // H-1 Reminder: events happening tomorrow
        $tomorrowStart = $now->copy()->addDay()->startOfDay();
        $tomorrowEnd = $now->copy()->addDay()->endOfDay();

        $tomorrowEvents = Event::with(['registrations' => function ($q) {
            $q->where('status', RegistrationStatus::Registered->value)->with('user');
        }])
            ->whereBetween('tanggal', [$tomorrowStart, $tomorrowEnd])
            ->where('status', EventStatus::Published->value)
            ->get();

        if ($tomorrowEvents->isNotEmpty()) {
            $existingH1 = Notifikasi::whereIn('event_id', $tomorrowEvents->pluck('id'))
                ->where('pesan', 'like', '%H-1%')
                ->whereDate('created_at', $today)
                ->get()
                ->groupBy(fn($n) => $n->user_id . '_' . $n->event_id);

            foreach ($tomorrowEvents as $event) {
                foreach ($event->registrations as $reg) {
                    $key = $reg->user_id . '_' . $event->id;
                    if (!isset($existingH1[$key])) {
                        Notifikasi::kirimNotifikasi(
                            $reg->user,
                            "H-1 Event: {$event->judul} besok pada {$event->tanggal->format('H:i')} WIB di {$event->lokasi}",
                            $event
                        );
                        $sent++;
                    }
                }
            }
        }

        // 1-hour reminder: events starting in ~1 hour
        $oneHourFromNow = $now->copy()->addHour();
        $oneHourStart = $oneHourFromNow->copy()->subMinutes(5);
        $oneHourEnd = $oneHourFromNow->copy()->addMinutes(5);

        $hourEvents = Event::with(['registrations' => function ($q) {
            $q->where('status', RegistrationStatus::Registered->value)->with('user');
        }])
            ->whereBetween('tanggal', [$oneHourStart, $oneHourEnd])
            ->where('status', EventStatus::Published->value)
            ->get();

        if ($hourEvents->isNotEmpty()) {
            $existingHour = Notifikasi::whereIn('event_id', $hourEvents->pluck('id'))
                ->where('pesan', 'like', '%1 jam%')
                ->whereDate('created_at', $today)
                ->get()
                ->groupBy(fn($n) => $n->user_id . '_' . $n->event_id);

            foreach ($hourEvents as $event) {
                foreach ($event->registrations as $reg) {
                    $key = $reg->user_id . '_' . $event->id;
                    if (!isset($existingHour[$key])) {
                        Notifikasi::kirimNotifikasi(
                            $reg->user,
                            "Reminder: {$event->judul} akan dimulai 1 jam lagi di {$event->lokasi}",
                            $event
                        );
                        $sent++;
                    }
                }
            }
        }

        $this->info("Sent {$sent} reminder notifications");
        return Command::SUCCESS;
    }
}
