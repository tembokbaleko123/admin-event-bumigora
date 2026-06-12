# Tabel Database & Integritas Data — Aplikasi Kampus (Flutter)

## Overview

Dokumentasi ini menjelaskan struktur data dari sisi **Flutter models** yang merepresentasikan tabel-tabel di **Laravel backend**. Relasi antara Flutter model dan backend API (`http://127.0.0.1:8000/api/v1/...`) dijaga melalui JSON serialization (`toJson`/`fromJson`).

---

## 1. Model `UserModel` → Backend Table `users`

### File: `lib/models/user_model.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik pengguna |
| `nama` | `String` | `nama` | VARCHAR(255) | NOT NULL | Nama lengkap |
| `email` | `String` | `email` | VARCHAR(255) | NOT NULL, UNIQUE | Email login |
| `password` | (tidak disimpan di model) | `password` | VARCHAR(255) | NOT NULL | Hanya dikirim saat register/login |
| `role` | `String` | `role` | ENUM('mahasiswa','dosen','admin') | NOT NULL, DEFAULT 'mahasiswa' | Role pengguna |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `updatedAt` | `String?` | `updated_at` | TIMESTAMP | NULLABLE | Waktu update |

### Helper Methods
- `isMahasiswa` → `role == 'mahasiswa'`
- `isDosen` → `role == 'dosen'`
- `isAdmin` → `role == 'admin'`

### Serialization
```dart
factory UserModel.fromJson(Map<String, dynamic> json) { ... }
Map<String, dynamic> toJson() { ... }
```

---

## 2. Model `EventModel` → Backend Table `events`

### File: `lib/models/event_model.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik event |
| `judul` | `String` | `judul` | VARCHAR(255) | NOT NULL | Judul event |
| `tanggal` | `String` | `tanggal` | DATETIME | NOT NULL | Tanggal & waktu |
| `tanggalSelesai` | `String?` | `tanggal_selesai` | DATETIME | NULLABLE | Waktu selesai |
| `batasDaftar` | `String?` | `batas_daftar` | DATETIME | NULLABLE | Batas pendaftaran |
| `lokasi` | `String` | `lokasi` | VARCHAR(255) | NOT NULL | Lokasi |
| `deskripsi` | `String?` | `deskripsi` | TEXT | NULLABLE | Deskripsi event |
| `gambar` | `String?` | `gambar` | VARCHAR(255) | NULLABLE | Path gambar |
| `gambarUrl` | `String?` | `gambar_url` | VARCHAR(255) | NULLABLE | URL gambar |
| `kategori` | `String?` | `kategori` | VARCHAR(100) | NULLABLE | Kategori event |
| `kapasitas` | `int?` | `kapasitas` | INT | NULLABLE | Kapasitas peserta |
| `status` | `String?` | `status` | ENUM | NULLABLE | Status event |
| `totalPendaftar` | `int?` | `total_pendaftar` | INT | NULLABLE | Total pendaftar |
| `pendaftarAktif` | `int?` | `pendaftar_aktif` | INT | NULLABLE | Pendaftar aktif |
| `sisaKuota` | `int?` | `sisa_kuota` | INT | NULLABLE | Sisa kuota |
| `createdBy` | `int` | `created_by` | BIGINT | NOT NULL, FK → users.id | Pembuat event |
| `creator` | `Creator?` | `creator` | - | - | Embedded Creator model |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `updatedAt` | `String?` | `updated_at` | TIMESTAMP | NULLABLE | Waktu update |

### Relasi
- **FK**: `createdBy` → `UserModel.id`
- **Embedded**: `Creator` (partial user data: `id`, `nama`)
- **Used by**: `EventRegistration`, `BookmarkModel`, `Attendance`, `NotifikasiModel`, `EventAnalytics`

---

## 3. Model `InformasiModel` → Backend Table `informasis`

### File: `lib/models/informasi_model.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik informasi |
| `judul` | `String` | `judul` | VARCHAR(255) | NOT NULL | Judul |
| `isi` | `String` | `isi` | TEXT | NOT NULL | Konten |
| `tanggal` | `String` | `tanggal` | DATE | NOT NULL | Tanggal publikasi |
| `gambar` | `String?` | `gambar` | VARCHAR(255) | NULLABLE | Path gambar |
| `gambarUrl` | `String?` | `gambar_url` | VARCHAR(255) | NULLABLE | URL gambar |
| `dibuatOleh` | `int` | `dibuat_oleh` | BIGINT | NOT NULL, FK → users.id | Pembuat |
| `creator` | `Creator?` | `creator` | - | - | Embedded Creator model |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `updatedAt` | `String?` | `updated_at` | TIMESTAMP | NULLABLE | Waktu update |

### Relasi
- **FK**: `dibuatOleh` → `UserModel.id`
- **Embedded**: `Creator`

---

## 4. Model `NotifikasiModel` → Backend Table `notifikasis`

### File: `lib/models/notifikasi_model.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik |
| `userId` | `int` | `user_id` | BIGINT | NOT NULL, FK → users.id | Penerima |
| `eventId` | `int?` | `event_id` | BIGINT | NULLABLE, FK → events.id | Event terkait |
| `pesan` | `String` | `pesan` | VARCHAR(255) | NOT NULL | Isi pesan |
| `status` | `String` | `status` | ENUM('unread','read') | NOT NULL, DEFAULT 'unread' | Status baca |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `updatedAt` | `String?` | `updated_at` | TIMESTAMP | NULLABLE | Waktu update |
| `event` | `EventBrief?` | `event` | - | - | Embedded brief event |

### Helper
- `isUnread` → `status == 'unread'`

### Inner Class: `EventBrief`
| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `id` | `int` | `id` | ID event |
| `judul` | `String` | `judul` | Judul event |

### Relasi
- **FK**: `userId` → `UserModel.id`
- **FK**: `eventId` → `EventModel.id` (nullable)

---

## 5. Model `Bookmark` → Backend Table `bookmarks`

### File: `lib/models/bookmark.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik |
| `userId` | `int` | `user_id` | BIGINT | NOT NULL, FK → users.id | Pemilik bookmark |
| `bookmarkableId` | `int` | `bookmarkable_id` | BIGINT | NOT NULL | ID polymorphic |
| `type` | `BookmarkableType` | `bookmarkable_type` | VARCHAR | NOT NULL | 'App\Models\Event' atau 'App\Models\Informasi' |
| `createdAt` | `String` | `created_at` | TIMESTAMP | NOT NULL | Waktu dibuat |
| `bookmarkable` | `Map?` | `bookmarkable` | - | - | Polymorphic relation data |

### Enum: `BookmarkableType`
- `event`
- `informasi`

### Relasi
- **FK**: `userId` → `UserModel.id`
- **Polymorphic**: `bookmarkableId` + `bookmarkableType` → `events.id` atau `informasis.id`

---

## 6. Model `EventRegistration` → Backend Table `event_registrations`

### File: `lib/models/event_registration.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik |
| `eventId` | `int` | `event_id` | BIGINT | NOT NULL, FK → events.id | Event didaftar |
| `userId` | `int` | `user_id` | BIGINT | NOT NULL, FK → users.id | Pendaftar |
| `status` | `String` | `status` | ENUM | NOT NULL, DEFAULT 'registered' | Status: 'registered','cancelled','attended','absent' |
| `registeredAt` | `String?` | `registered_at` | TIMESTAMP | NULLABLE | Waktu daftar |
| `cancelledAt` | `String?` | `cancelled_at` | TIMESTAMP | NULLABLE | Waktu batal |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `updatedAt` | `String?` | `updated_at` | TIMESTAMP | NULLABLE | Waktu update |
| `event` | `EventModel?` | `event` | - | - | Embedded event data |
| `user` | `RegistrationUser?` | `user` | - | - | Embedded user data |

### Inner Class: `RegistrationUser`
| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `id` | `int` | `id` | ID user |
| `nama` | `String` | `nama` | Nama user |
| `email` | `String?` | `email` | Email user |

### Helpers
- `isRegistered` → `status == 'registered'`
- `isCancelled` → `status == 'cancelled'`
- `isAttended` → `status == 'attended'`
- `isAbsent` → `status == 'absent'`

### Relasi
- **FK**: `eventId` → `EventModel.id`
- **FK**: `userId` → `UserModel.id`

---

## 7. Model `Attendance` → Backend Table `attendances`

### File: `lib/models/attendance.dart`

### Field Mapping

| Field (Dart) | Tipe Dart | JSON Key | Tipe DB | Constraint | Keterangan |
|-------------|-----------|----------|---------|------------|------------|
| `id` | `int` | `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | ID unik |
| `eventId` | `int` | `event_id` | BIGINT | NOT NULL, FK → events.id | Event |
| `userId` | `int` | `user_id` | BIGINT | NOT NULL, FK → users.id | Peserta |
| `registrationId` | `int?` | `registration_id` | BIGINT | NULLABLE, FK → event_registrations.id | Registrasi terkait |
| `qrTokenId` | `int?` | `qr_token_id` | BIGINT | NULLABLE | QR token |
| `scannedAt` | `String` | `scanned_at` | TIMESTAMP | NOT NULL | Waktu scan |
| `status` | `String` | `status` | ENUM('valid','late') | NOT NULL, DEFAULT 'valid' | Status kehadiran |
| `createdAt` | `String?` | `created_at` | TIMESTAMP | NULLABLE | Waktu dibuat |
| `user` | `RegistrationUser?` | `user` | - | - | Embedded user data |

### Helpers
- `isValid` → `status == 'valid'`
- `isLate` → `status == 'late'`

### Additional Models in File

#### `ActiveQrToken`
| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `hasActiveQr` | `bool` | `has_active_qr` | Status QR aktif |
| `id` | `int?` | `id` | ID QR token |
| `token` | `String?` | `token` | Token string |
| `expiredAt` | `String?` | `expired_at` | Waktu kadaluarsa |
| `isExpired` | `bool?` | `is_expired` | Status expired |

#### `AttendanceSummary`
| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `totalRegistered` | `int` | `total_registered` | Total terdaftar |
| `totalAttended` | `int` | `total_attended` | Total hadir |
| `totalValid` | `int` | `total_valid` | Total tepat waktu |
| `totalLate` | `int` | `total_late` | Total terlambat |
| `attendancePercentage` | `double` | `attendance_percentage` | Persentase kehadiran |

### Relasi
- **FK**: `eventId` → `EventModel.id`
- **FK**: `userId` → `UserModel.id`
- **FK**: `registrationId` → `EventRegistration.id` (nullable)

---

## 8. Model `Creator` → Embedded (Partial Data)

### File: `lib/models/creator.dart`

| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `id` | `int` | `id` | ID user |
| `nama` | `String` | `nama` | Nama user |

- Digunakan sebagai embedded data dalam `EventModel` dan `InformasiModel`
- Tidak memiliki tabel sendiri — data berasal dari relasi `users` table

---

## 9. Model `EventAnalytics` → Derived/Computed

### File: `lib/models/analytics.dart` (bagian dari `AnalyticsSummary` dan `DashboardOverview`)

| Field | Tipe | JSON Key | Keterangan |
|-------|------|----------|------------|
| `event` | `Map` | `event` | Data event |
| `attendanceRate` | `double` | `attendance_rate` | Persentase kehadiran |
| `kapasitas` | `int?` | `kapasitas` | Kapasitas |
| `sisaKuota` | `int?` | `sisa_kuota` | Sisa kuota |
| `totalPendaftar` | `int` | `total_pendaftar` | Total pendaftar |
| `pendaftarAktif` | `int` | `pendaftar_aktif` | Pendaftar aktif |
| `totalHadir` | `int` | `total_hadir` | Total hadir |
| `totalTepat` | `int` | `total_tepat` | Total tepat waktu |
| `totalTerlambat` | `int` | `total_terlambat` | Total terlambat |

- Tidak memiliki tabel dedicated — data dihitung dari agregasi `events` + `attendances` + `event_registrations`

---

## Integrity Constraints (Flutter Side)

### 1. Entity Integrity
Setiap model Flutter memiliki field `id` bertipe `int` (non-nullable), dengan default value `0` di `fromJson()` untuk mencegah null safety.

### 2. Referential Integrity via API
Flutter tidak memiliki foreign key constraint secara langsung, namun relasi dijaga melalui:

| Model | Foreign Key Field | Reference Target |
|-------|------------------|-----------------|
| `EventModel` | `createdBy` | `UserModel.id` |
| `InformasiModel` | `dibuatOleh` | `UserModel.id` |
| `NotifikasiModel` | `userId` | `UserModel.id` |
| `NotifikasiModel` | `eventId` | `EventModel.id` |
| `BookmarkModel` | `userId` | `UserModel.id` |
| `BookmarkModel` | `bookmarkableId` | `EventModel.id` / `InformasiModel.id` |
| `EventRegistration` | `eventId` | `EventModel.id` |
| `EventRegistration` | `userId` | `UserModel.id` |
| `Attendance` | `eventId` | `EventModel.id` |
| `Attendance` | `userId` | `UserModel.id` |

### 3. Domain Integrity (Form Validation)

| Screen/Action | Validation Rule |
|--------------|----------------|
| **Register** | `email` valid format regex, `password` min 8 karakter, `nama` tidak kosong |
| **Login** | `email` valid format, `password` tidak kosong |
| **Event Create/Edit** | `judul` wajib, `tanggal` valid DateTime, `lokasi` tidak kosong |
| **Role** | Hanya `'mahasiswa'`, `'dosen'`, `'admin'` (validated by UserModel helpers) |
| **Notifikasi Status** | Hanya `'read'` atau `'unread'` |

### 4. Data Integrity via Serialization
- `toJson()` → mengkonversi object Dart ke Map untuk dikirim ke backend via HTTP POST/PUT
- `fromJson()` → memparsing respons JSON dari backend menjadi object Dart
- Default values (`?? 0`, `?? ''`) mencegah runtime error saat data null dari API
- Semua API call melalui `api_client.dart` dengan base URL `http://127.0.0.1:8000/api/v1/`

---

## Summary: Flutter Models ↔ Backend Tables

| Flutter Model (File) | DB Table | Primary Key | Foreign Keys |
|---------------------|----------|-------------|-------------|
| `UserModel` (`user_model.dart`) | `users` | `id` | - |
| `EventModel` (`event_model.dart`) | `events` | `id` | `created_by` → users |
| `InformasiModel` (`informasi_model.dart`) | `informasis` | `id` | `dibuat_oleh` → users |
| `NotifikasiModel` (`notifikasi_model.dart`) | `notifikasis` | `id` | `user_id` → users, `event_id` → events |
| `Bookmark` (`bookmark.dart`) | `bookmarks` | `id` | `user_id` → users, `bookmarkable_id` polymorphic |
| `EventRegistration` (`event_registration.dart`) | `event_registrations` | `id` | `event_id` → events, `user_id` → users |
| `Attendance` (`attendance.dart`) | `attendances` | `id` | `event_id` → events, `user_id` → users |
| `Creator` (`creator.dart`) | (embedded) | - | - |
| `EventAnalytics` (`analytics.dart`) | (derived) | - | - |

## State Management & API Service Files

| File | Class/Fungsi | Keterangan |
|------|-------------|------------|
| `lib/core/network/api_client.dart` | `ApiClient` | HTTP client wrapper base URL `http://127.0.0.1:8000/api/v1/` |
| `lib/providers/auth_provider.dart` | `AuthProvider` | Login, register, logout, get user profile |
| `lib/providers/event_provider.dart` | `EventProvider` | CRUD events, list events, detail event |
| `lib/providers/informasi_provider.dart` | `InformasiProvider` | CRUD informasi |
| `lib/providers/notifikasi_provider.dart` | `NotifikasiProvider` | Get, mark read notifications |
| `lib/providers/bookmark_provider.dart` | `BookmarkProvider` | Add/remove/list bookmarks |
| `lib/providers/registration_provider.dart` | `RegistrationProvider` | Register/cancel event registration |
| `lib/providers/attendance_provider.dart` | `AttendanceProvider` | Scan QR, attendance history |
| `lib/providers/analytics_provider.dart` | `AnalyticsProvider` | Dashboard overview, event analytics |
| `lib/services/recommendation_service.dart` | `RecommendationService` | Event recommendations |