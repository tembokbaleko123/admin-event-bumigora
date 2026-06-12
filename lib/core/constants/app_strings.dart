class AppStrings {
  AppStrings._();

  // Roles
  static const String roleMhs = 'mahasiswa';
  static const String roleDosen = 'dosen';
  static const String roleAdmin = 'admin';
  static const List<String> allRoles = [roleMhs, roleDosen, roleAdmin];

  // Categories
  static const String catKuliah = 'KULIAH';
  static const String catWorkshop = 'WORKSHOP';
  static const String catSeminar = 'SEMINAR';
  static const String catMeeting = 'MEETING';
  static const String catUkm = 'UKM';
  static const List<String> allCategories = [catKuliah, catWorkshop, catSeminar, catMeeting, catUkm];

  // Event & attendance statuses
  static const String statusRegistered = 'registered';
  static const String statusAttended = 'attended';
  static const String statusAbsent = 'absent';
  static const String statusCancelled = 'cancelled';
  static const String statusValid = 'valid';
  static const String statusLate = 'late';
  static const String statusUnread = 'unread';
  static const String statusRead = 'read';
  static const String statusPublished = 'published';
  static const String statusPending = 'pending';
  static const String statusRejected = 'rejected';
  static const String statusDraft = 'draft';
  static const String statusCompleted = 'completed';

  // Bookmark types
  static const String bookmarkTypeEvent = 'event';
  static const String bookmarkTypeInformasi = 'informasi';

  // ── General UI ──
  static const String appName = 'SIPENDEKA';
  static const String appSubtitle = 'Informasi Pendidikan & Event Akademik';
  static const String appVersion = 'SIPENDEKA v1.0.0 — Universitas Bumigora';

  // ── Buttons ──
  static const String batal = 'Batal';
  static const String hapus = 'Hapus';
  static const String simpan = 'Simpan';
  static const String simpanPerubahan = 'Simpan Perubahan';
  static const String tutup = 'Tutup';
  static const String detail = 'Detail';
  static const String edit = 'Edit';
  static const String masuk = 'Masuk';
  static const String daftar = 'Daftar';
  static const String keluar = 'Keluar';
  static const String lanjutkanIsi = 'Lanjutkan Isi';
  static const String yaKembali = 'Ya, Kembali';
  static const String yaBatalkan = 'Ya, Batalkan';
  static const String yaUbah = 'Ya, Ubah';
  static const String lanjutkanEdit = 'Lanjutkan Edit';
  static const String cobaLagi = 'Coba Lagi';
  static const String selesai = 'Selesai';
  static const String muatLagi = 'Muat lagi';
  static const String tidak = 'Tidak';
  static const String ya = 'Ya';
  static const String lihatSemua = 'Lihat Semua';
  static const String tandaiHadir = 'Tandai Hadir';
  static const String tandaiTerlambat = 'Tandai Terlambat';
  static const String tandaiTidakHadir = 'Tandai Tidak Hadir';
  static const String ubahStatus = 'Ubah status';

  // ── Screen Titles ──
  static const String titleProfil = 'Profil';
  static const String titleEditProfil = 'Edit Profil';
  static const String titleNotifikasi = 'Notifikasi';
  static const String titleBookmark = 'Bookmark';
  static const String titleInformasi = 'Informasi & Pengumuman';
  static const String titleDetailInformasi = 'Detail Informasi';
  static const String titleDetailEvent = 'Detail Event';
  static const String titleScanQR = 'Scan QR Absensi';
  static const String titleCalendar = 'Semua Jadwal';
  static const String titleKelolaEvent = 'Kelola Event';
  static const String titleKelolaUser = 'Kelola Pengguna';
  static const String titleKelolaInfo = 'Kelola Informasi';
  static const String titlePeserta = 'Peserta Event';
  static const String titleLaporan = 'Laporan Absensi';
  static const String titleBuatEvent = 'Buat Event Baru';
  static const String titleEditEvent = 'Edit Event';

  // ── Dialog Titles ──
  static const String confirmHapus = 'Hapus';
  static const String confirmBatalkan = 'Batalkan?';
  static const String confirmKeluar = 'Keluar';
  static const String confirmBatalkanPendaftaran = 'Batalkan Pendaftaran';
  static const String confirmHapusBookmark = 'Hapus Bookmark';
  static const String confirmHapusNotifikasi = 'Hapus Notifikasi';
  static const String confirmHapusUser = 'Hapus User';
  static const String confirmHapusEvent = 'Hapus Event';
  static const String confirmHapusInformasi = 'Hapus Informasi';
  static const String confirmSetujuiEvent = 'Setujui Event';
  static const String confirmTolakEvent = 'Tolak Event';
  static const String confirmUbahRole = 'Ubah Role';
  static const String confirmUbahStatus = 'Ubah Status Kehadiran';
  static const String confirmBatalkanPerubahan = 'Batalkan Perubahan?';
  static const String confirmTambahUser = 'Tambah Pengguna';

  // ── Dialog Messages ──
  static const String msgYakinHapus = 'Yakin ingin menghapus';
  static const String msgYakinKeluar = 'Apakah kamu yakin ingin keluar?';
  static const String msgYakinBatalkanPendaftaran = 'Apakah kamu yakin ingin membatalkan pendaftaran?';
  static const String msgYakinHapusEvent = 'Yakin ingin menghapus event ini?';
  static const String msgYakinHapusBookmark = 'Apakah kamu yakin ingin menghapus bookmark ini?';
  static const String msgYakinHapusNotif = 'Yakin ingin menghapus notifikasi ini?';
  static const String msgPerubahanHilang = 'Perubahan yang sudah dibuat akan hilang. Yakin ingin menutup?';
  static const String msgPerubahanBelumSimpan = 'Ada perubahan yang belum disimpan. Yakin ingin meninggalkan halaman ini?';
  static const String msgDataHilang = 'Data yang sudah diisi akan hilang. Yakin ingin kembali?';
  static const String msgSemuaFieldWajib = 'Semua field wajib diisi';

  // ── Validation ──
  static const String valJudulLokasiWajib = 'Judul dan lokasi wajib diisi';
  static const String valJudulEventWajib = 'Judul event harus diisi';
  static const String valKapasitasMin1 = 'Kapasitas harus angka minimal 1';
  static const String valTanggalMasaLalu = 'Tanggal dan waktu event tidak boleh di masa lalu';
  static const String valGambarMax2MB = 'Ukuran gambar maksimal 2MB';
  static const String valPasswordMin8 = 'Password minimal 8 karakter';
  static const String valPasswordWajib = 'Password baru wajib diisi';
  static const String valKonfirmasiKosong = 'Konfirmasi password tidak boleh kosong';
  static const String valPasswordTidakCocok = 'Password tidak cocok';
  static const String valKonfirmasiTidakSama = 'Konfirmasi password tidak sama';
  static const String valJudulWajib = 'Judul wajib diisi';
  static const String valIsiWajib = 'Isi wajib diisi';

  // ── Success Messages ──
  static const String successProfilDiperbarui = 'Profil berhasil diperbarui';
  static const String successEventDibuat = 'Event berhasil dibuat!';
  static const String successEventDikirim = 'Event dikirim dan menunggu persetujuan admin';
  static const String successEventDiperbarui = 'Event diperbarui';
  static const String successEventDihapus = 'Event berhasil dihapus';
  static const String successPendaftaran = 'Pendaftaran event berhasil';
  static const String successPendaftaranDibatalkan = 'Pendaftaran dibatalkan';
  static const String successQRCode = 'QR Code berhasil dibuat';
  static const String successTokenDisalin = 'Token QR disalin';
  static const String successAbsensi = 'Absensi berhasil';
  static const String successStatusKehadiran = 'Status kehadiran diperbarui';
  static const String successUserDitambahkan = 'Pengguna berhasil ditambahkan';
  static const String successInformasiDibuat = 'Informasi berhasil dibuat';
  static const String successInformasiDiupdate = 'Informasi berhasil diperbarui';
  static const String successInformasiDihapus = 'Informasi berhasil dihapus';
  static const String successEventDisetujui = 'Event disetujui';
  static const String successEventDitolak = 'Event ditolak';
  static const String successEventDihapusSingkat = 'Event dihapus';

  // ── Error Messages ──
  static const String errorLogin = 'Login gagal';
  static const String errorRegistrasi = 'Registrasi gagal';
  static const String errorProfil = 'Gagal memperbarui profil';
  static const String errorGagalDaftar = 'Gagal mendaftar';
  static const String errorGagalBatalkan = 'Gagal membatalkan';
  static const String errorGagalEventDihapus = 'Gagal menghapus event';
  static const String errorGagalMembuatEvent = 'Gagal membuat event';
  static const String errorGagalMemperbaruiEvent = 'Gagal memperbarui event';
  static const String errorGagalMemprosesEvent = 'Gagal memproses event';
  static const String errorGagalHapusNotif = 'Gagal menghapus notifikasi';
  static const String errorGagalAbsensi = 'Gagal melakukan absensi';
  static const String errorGagalBuatQR = 'Gagal membuat QR';
  static const String errorGagalHapus = 'Gagal menghapus';
  static const String errorGagalSimpan = 'Gagal menyimpan informasi';
  static const String errorGagalKehadiran = 'Gagal memperbarui kehadiran';
  static const String errorGagalEkspor = 'Gagal mengekspor laporan';
  static const String errorGagalUser = 'Gagal menambahkan pengguna';
  static const String errorDetailEvent = 'Gagal memuat detail event';
  static const String errorTerjadiKesalahan = 'Terjadi kesalahan saat memuat event';

  // ── Empty States ──
  static const String emptyEvent = 'Belum ada event';
  static const String emptyJadwal = 'Belum ada jadwal';
  static const String emptyJadwalHariIni = 'Tidak ada jadwal hari ini';
  static const String emptyPeserta = 'Belum ada peserta';
  static const String emptyDataAbsensi = 'Belum ada data absensi';
  static const String emptyInformasi = 'Belum ada informasi';
  static const String emptyNotifikasi = 'Belum ada notifikasi';
  static const String emptyBookmark = 'Belum ada bookmark';
  static const String emptyQR = 'Belum ada QR Code aktif';
  static const String emptyUser = 'Tidak ada pengguna';
  static const String emptyCalendar = 'Tidak ada event pada tanggal ini';
  static const String emptyPilihMinat = 'Pilih minat untuk mendapatkan rekomendasi';

  // ── Labels ──
  static const String labelEmail = 'EMAIL';
  static const String labelPassword = 'PASSWORD';
  static const String labelNama = 'NAMA';
  static const String labelNamaLengkap = 'NAMA LENGKAP';
  static const String labelKonfirmasiPassword = 'KONFIRMASI PASSWORD';
  static const String labelPasswordSaatIni = 'PASSWORD SAAT INI';
  static const String labelPasswordBaru = 'PASSWORD BARU';
  static const String labelGantiPassword = 'Ganti Password';
  static const String labelAkun = 'Akun';
  static const String labelPreferensi = 'Preferensi';
  static const String labelModeGelap = 'Mode Gelap';
  static const String labelMendatang = 'Mendatang';
  static const String labelSelesai = 'Selesai';
  static const String labelSemua = 'Semua';
  static const String labelAdmin = 'Admin';
  static const String labelDosen = 'Dosen';
  static const String labelMahasiswa = 'Mahasiswa';
  static const String labelTerdaftar = 'Terdaftar';
  static const String labelHadir = 'Hadir';
  static const String labelTidakHadir = 'Tidak Hadir';
  static const String labelTerlambat = 'Terlambat';
  static const String labelTepatWaktu = 'Tepat Waktu';
  static const String labelPending = 'Pending';
  static const String labelPublished = 'Published';
  static const String labelDitolak = 'Ditolak';
  static const String labelDibatalkan = 'Dibatalkan';
  static const String labelBatal = 'Batal';
  static const String labelOnline = 'Online';
  static const String labelPendaftar = 'Pendaftar';
  static const String labelKuota = 'Kuota';
  static const String labelSisa = 'Sisa';
  static const String labelPeserta = 'Peserta';
  static const String labelEvent = 'Event';
  static const String labelInformasi = 'Informasi';
  static const String labelJudul = 'JUDUL';
  static const String labelTanggal = 'TANGGAL';
  static const String labelLokasi = 'LOKASI';
  static const String labelKategori = 'KATEGORI';
  static const String labelKapasitas = 'KAPASITAS';
  static const String labelDeskripsi = 'Deskripsi';
  static const String labelCatatan = 'CATATAN';
  static const String labelGambarEvent = 'GAMBAR EVENT';
  static const String labelWaktu = 'WAKTU';
  static const String labelTotalHadir = 'Total Hadir';
  static const String labelBeranda = 'Beranda';
  static const String labelEventSaya = 'Event Saya';
  static const String labelJadwal = 'Jadwal';
  static const String labelAnalytics = 'Analytics';
  static const String labelDashboard = 'Dashboard';
  static const String labelPengguna = 'Pengguna';
  static const String labelInfo = 'Info';
  static const String labelExportCSV = 'Export CSV';
  static const String labelReset = 'Reset';
  static const String labelCustom = 'Custom';
}
