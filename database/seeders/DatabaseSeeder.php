<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Event;
use App\Models\Informasi;
use App\Models\Notifikasi;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ==================== CREATE SAMPLE USERS ====================

        // Admin
        $admin = User::create([
            'nama' => 'Budi Santoso',
            'email' => 'admin@example.com',
            'password' => 'password',
            'role' => 'admin',
        ]);

        // Dosen
        $dosen1 = User::create([
            'nama' => 'Dr. Ahmad Wijaya',
            'email' => 'dosen@example.com',
            'password' => 'password',
            'role' => 'dosen',
        ]);

        $dosen2 = User::create([
            'nama' => 'Siti Rahayu, M.Kom',
            'email' => 'dosen2@example.com',
            'password' => 'password',
            'role' => 'dosen',
        ]);

        // Mahasiswa
        $mhs1 = User::create([
            'nama' => 'Rizky Pratama',
            'email' => 'mahasiswa@example.com',
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);

        $mhs2 = User::create([
            'nama' => 'Anisa Putri',
            'email' => 'mahasiswa2@example.com',
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);

        $mhs3 = User::create([
            'nama' => 'Dewi Lestari',
            'email' => 'mahasiswa3@example.com',
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);

        // ==================== CREATE SAMPLE EVENTS ====================

        $event1 = Event::create([
            'judul' => 'Seminar Teknologi Kecerdasan Buatan',
            'tanggal' => now()->addDays(7),
            'lokasi' => 'Aula Utama Lt. 3',
            'deskripsi' => 'Seminar tentang perkembangan AI dan Machine Learning di era digital. Hadir sebagai pembicara adalah praktisi industri dari perusahaan teknologi terkemuka.',
            'created_by' => $dosen1->id,
        ]);

        $event2 = Event::create([
            'judul' => 'Workshop Pengembangan Web dengan Laravel',
            'tanggal' => now()->addDays(14),
            'lokasi' => 'Lab Komputer Gedung B',
            'deskripsi' => 'Workshop praktis pengembangan web menggunakan Laravel 12. Peserta akan membuat project CRUD lengkap dengan autentikasi.',
            'created_by' => $dosen2->id,
        ]);

        $event3 = Event::create([
            'judul' => 'Talkshow Karir di Dunia IT',
            'tanggal' => now()->addDays(21),
            'lokasi' => 'Aula Barat',
            'deskripsi' => 'Talkshow dengan alumni yang telah sukses di dunia teknologi informasi. Berbagi pengalaman dan tips persiapan karir.',
            'created_by' => $admin->id,
        ]);

        $event4 = Event::create([
            'judul' => 'Kompetisi Programming Challenge',
            'tanggal' => now()->addDays(30),
            'lokasi' => 'Lab Sistem C1',
            'deskripsi' => 'Kompetisi programming untuk menguji kemampuan algoritma dan problem solving. Hadiah menarik untuk para pemenang!',
            'created_by' => $dosen1->id,
        ]);

        $event5 = Event::create([
            'judul' => 'Webinar Cybersecurity Awareness',
            'tanggal' => now()->subDays(3),
            'lokasi' => 'Online via Zoom',
            'deskripsi' => 'Webinar tentang kesadaran keamanan siber untuk mahasiswa. Pembahasan tentang ancaman cyber dan cara melindungi data pribadi.',
            'created_by' => $dosen2->id,
        ]);

        // ==================== CREATE SAMPLE INFORMASI ====================

        Informasi::create([
            'judul' => 'Pengumuman Libur Semester Genap',
            'isi' => 'Libur semester genap akan dimulai pada tanggal 20 Juni 2024 hingga 15 Juli 2024. Seluruh aktivitas perkuliahan akan dilanjutkan pada tanggal 16 Juli 2024. Selamat berlibur!',
            'tanggal' => now(),
            'dibuat_oleh' => $admin->id,
        ]);

        Informasi::create([
            'judul' => 'Jadwal Ujian Akhir Semester (UAS)',
            'isi' => 'Jadwal UAS semester genap tahun ajaran 2023/2024 telah diterbitkan. Silakan cek portal mahasiswa untuk melihat jadwal lengkap dan ruangan ujian masing-masing.',
            'tanggal' => now()->addDays(3),
            'dibuat_oleh' => $admin->id,
        ]);

        Informasi::create([
            'judul' => 'Pendaftaran Beasiswa Unggulan 2024',
            'isi' => 'Pendaftaran beasiswa unggulan untuk semester ganjil tahun ajaran 2024/2025 telah dibuka. Persyaratan dan formulir dapat diunduh di portal akademik.',
            'tanggal' => now()->addDays(-5),
            'dibuat_oleh' => $admin->id,
        ]);

        Informasi::create([
            'judul' => 'Maintenance Server',
            'isi' => 'Akan dilakukan maintenance server pada hari Sabtu, 25 Mei 2024 pukul 22.00 - 24.00 WITA. Sistem tidak tersedia sementara waktu.',
            'tanggal' => now()->addDays(-2),
            'dibuat_oleh' => $admin->id,
        ]);

        Informasi::create([
            'judul' => 'Workshop Pemrograman Python untuk Pemula',
            'isi' => 'Workshop pemrograman Python akan diadakan untuk mahasiswa semester 1 dan 2. Pendaftaran dibuka hingga tanggal 30 Mei 2024.',
            'tanggal' => now()->addDays(-7),
            'dibuat_oleh' => $dosen1->id,
        ]);

        // ==================== CREATE SAMPLE NOTIFIKASI ====================

        // Notifikasi untuk mahasiswa tentang event yang akan datang
        Notifikasi::create([
            'user_id' => $mhs1->id,
            'event_id' => $event1->id,
            'pesan' => 'Event baru: Seminar Teknologi Kecerdasan Buatan pada ' . $event1->tanggal->format('d M Y') . ' di ' . $event1->lokasi,
            'status' => 'unread',
        ]);

        Notifikasi::create([
            'user_id' => $mhs1->id,
            'event_id' => $event2->id,
            'pesan' => 'Event baru: Workshop Pengembangan Web dengan Laravel pada ' . $event2->tanggal->format('d M Y') . ' di ' . $event2->lokasi,
            'status' => 'unread',
        ]);

        Notifikasi::create([
            'user_id' => $mhs2->id,
            'event_id' => $event1->id,
            'pesan' => 'Event baru: Seminar Teknologi Kecerdasan Buatan pada ' . $event1->tanggal->format('d M Y') . ' di ' . $event1->lokasi,
            'status' => 'unread',
        ]);

        Notifikasi::create([
            'user_id' => $mhs2->id,
            'event_id' => $event3->id,
            'pesan' => 'Event baru: Talkshow Karir di Dunia IT pada ' . $event3->tanggal->format('d M Y') . ' di ' . $event3->lokasi,
            'status' => 'read',
        ]);

        Notifikasi::create([
            'user_id' => $mhs3->id,
            'event_id' => $event4->id,
            'pesan' => 'Event baru: Kompetisi Programming Challenge pada ' . $event4->tanggal->format('d M Y') . ' di ' . $event4->lokasi,
            'status' => 'unread',
        ]);

        // Notifikasi tanpa event (informasi umum)
        Notifikasi::create([
            'user_id' => $mhs1->id,
            'event_id' => null,
            'pesan' => 'Pengumuman: Libur semester genap akan segera dimulai. Periksa jadwal UAS Anda!',
            'status' => 'unread',
        ]);

        Notifikasi::create([
            'user_id' => $mhs2->id,
            'event_id' => null,
            'pesan' => 'Pengumuman: Pendaftaran beasiswa unggulan 2024 telah dibuka.',
            'status' => 'read',
        ]);

        Notifikasi::create([
            'user_id' => $mhs3->id,
            'event_id' => null,
            'pesan' => 'Pengumuman: Jadwal UAS telah diterbitkan. Segera cek portal mahasiswa!',
            'status' => 'unread',
        ]);

        // ==================== SEEDER SUMMARY ====================
        $this->command->info('Database seeded successfully!');
        $this->command->info('Sample Users:');
        $this->command->info('  Admin: admin@example.com / password');
        $this->command->info('  Dosen: dosen@example.com / password');
        $this->command->info('  Mahasiswa: mahasiswa@example.com / password');
    }
}
