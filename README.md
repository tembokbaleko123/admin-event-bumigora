# Sistem Informasi Pendidikan & Event Akademik
## Universitas Bumigora

[![Universitas Bumigora](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmINwWvAoYHkJZlok2LNRoekRZKf4Lm-c2ew&s)](https://university.universitasbumigora.ac.id)

Backend REST API + Admin Panel Web berbasis **Laravel 12** untuk manajemen event akademik, informasi kampus, notifikasi mahasiswa, manajemen user, pendaftaran event, dan absensi berbasis QR Code.

---

## 📋 Daftar Isi

- [Tech Stack](#tech-stack)
- [Fitur Utama](#fitur-utama)
- [Role Matrix](#role-matrix)
- [Data Models](#data-models)
- [API Documentation](#api-documentation)
  - [API Versioning](#api-versioning)
  - [Public Endpoints](#public-endpoints)
  - [Protected Endpoints](#protected-endpoints)
  - [Event Endpoints](#event-endpoints)
  - [Event Registration](#event-registration)
  - [QR Code Attendance](#qr-code-attendance)
  - [Informasi Endpoints](#informasi-endpoints)
  - [Notifikasi Endpoints](#notifikasi-endpoints)
  - [Bookmark Endpoints](#bookmark-endpoints)
  - [Recommendation Endpoints](#recommendation-endpoints)
  - [Analytics Endpoints](#analytics-endpoints)
  - [User Management (Admin)](#user-management-admin)
  - [Audit Log (Admin)](#audit-log-admin)
- [Response Format](#response-format)
- [Rate Limiting](#rate-limiting)
- [Admin Panel](#admin-panel)
- [Integrasi Aplikasi Flutter](#integrasi-aplikasi-flutter)
- [Testing](#testing)
- [Instalasi](#instalasi)
- [Sample Users (Seeder)](#sample-users-seeder)
- [Perubahan Terbaru](#perubahan-terbaru)
- [Postman Collection](#postman-collection)
- [License](#license)

---

## Tech Stack

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Laravel** | 12 | Framework Backend |
| **PHP** | 8.2+ | Bahasa Pemrograman |
| **MySQL / MariaDB** | 5.7+ / 10.3+ | Database |
| **Laravel Sanctum** | - | Token-based API Authentication |
| **Blade + Bootstrap 5** | - | Admin & Dosen Web Panel |
| **Laravel Livewire** | 3.x | Komponen Interaktif Admin Panel |

---

## Fitur Utama

### 🔐 Autentikasi & Keamanan
- Register & Login API
- Token-based authentication (Laravel Sanctum)
- Role-based access control: `mahasiswa`, `dosen`, `admin`
- Rate limiting per endpoint (login, register, API, admin)
- Password reset via email (lupa password)
- Token expiry middleware

### 📅 Event Akademik
- CRUD event dengan upload gambar
- Kategori event (otomatis dinormalisasi ke UPPERCASE)
- Kapasitas/kuota peserta
- Tanggal selesai event & batas pendaftaran
- Status event: `draft`, `pending`, `published`, `approved`, `rejected`, `cancelled`
- Workflow approval: event dari dosen masuk status `pending` → admin approve/reject
- Soft deletes (event dapat dipulihkan)
- Search & filter berdasarkan judul, lokasi, kategori, deskripsi

### 📢 Informasi Pendidikan
- CRUD informasi dengan upload gambar
- Soft deletes
- Search berdasarkan judul dan isi

### 🔔 Notifikasi
- Notifikasi otomatis saat event dibuat, diupdate, dibatalkan
- Notifikasi ke mahasiswa untuk event yang sudah `published`
- Notifikasi ke admin untuk event `pending` (butuh persetujuan)
- Mark as read, mark all read, unread count
- Hapus notifikasi

### 📝 Pendaftaran Event
- Mahasiswa dapat mendaftar & membatalkan pendaftaran event
- Cek status pendaftaran
- Daftar event yang diikuti mahasiswa
- Validasi kuota, batas pendaftaran, dan status event
- Dosen/Admin dapat lihat daftar peserta

### 📱 Absensi QR Code
- Generate QR Code untuk event (dengan durasi kadaluarsa)
- Scan QR Code untuk absensi (mahasiswa)
- Check status absensi
- Laporan absensi (JSON & CSV export)
- Manual attendance (admin/dosen)
- Riwayat QR Token per event

### ⭐ Bookmark
- Bookmark event atau informasi
- Cek status bookmark
- Hapus bookmark

### 🎯 Rekomendasi Event
- Rekomendasi event berdasarkan minat user
- Track event views
- Kelola minat user (kategori favorit)

### 📊 Analytics & Dashboard
- Dashboard overview (counts: events, users, informasi, registrations)
- Admin analytics summary (total events, users, registrations, attendance rate)
- Event detail analytics (pendaftar, absensi, popularitas)
- Lecturer analytics (event milik dosen tersebut)

### 👥 User Management (Admin)
- CRUD user
- Manajemen role
- Soft deletes

### 📋 Audit Log (Admin)
- Mencatat semua operasi CRUD (siapa, apa, kapan)
- Statistik aktivitas user
- Filter berdasarkan user, action, model

---

## Role Matrix

| Fitur | Mahasiswa | Dosen | Admin |
|-------|-----------|-------|-------|
| **Lihat Event & Detail** | ✅ | ✅ | ✅ |
| **Buat Event** | ❌ | ✅ (pending) | ✅ (published) |
| **Edit Event** | ❌ | ✅ (milik sendiri) | ✅ (semua) |
| **Hapus Event** | ❌ | ✅ (milik sendiri) | ✅ (semua) |
| **Approve/Reject Event** | ❌ | ❌ | ✅ |
| **Lihat Informasi** | ✅ | ✅ | ✅ |
| **Kelola Informasi** | ❌ | ❌ | ✅ |
| **Daftar Event** | ✅ | ❌ | ❌ |
| **Absensi QR Scan** | ✅ | ❌ | ❌ |
| **Generate QR Event** | ❌ | ✅ (milik sendiri) | ✅ (semua) |
| **Laporan Absensi** | ❌ | ✅ (milik sendiri) | ✅ (semua) |
| **Notifikasi** | ✅ | ✅ | ✅ |
| **Bookmark** | ✅ | ✅ | ✅ |
| **Rekomendasi Event** | ✅ | ✅ | ✅ |
| **Dashboard Overview** | ❌ | ✅ | ✅ |
| **Analytics** | ❌ | ✅ (event sendiri) | ✅ (semua) |
| **Kelola User** | ❌ | ❌ | ✅ |
| **Audit Log** | ❌ | ❌ | ✅ |

---

## Data Models

### User
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| nama | varchar(255) | Full name |
| email | varchar(255) | Unique email |
| password | varchar(255) | Hashed password |
| role | enum | `mahasiswa`, `dosen`, `admin` |
| foto | varchar(255) | Profile photo (nullable) |
| timestamps | | created_at, updated_at |

### Event
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| judul | varchar(255) | Event title |
| tanggal | datetime | Event start date/time |
| tanggal_selesai | datetime | Event end date/time (nullable) |
| batas_daftar | datetime | Registration deadline (nullable) |
| lokasi | varchar(255) | Location |
| deskripsi | text | Description (nullable) |
| gambar | varchar(255) | Image path (nullable) |
| kategori | varchar(255) | Category (nullable) |
| kapasitas | integer | Max participants (nullable) |
| status | enum | `draft`, `pending`, `published`, `approved`, `rejected`, `cancelled` |
| created_by | bigint | FK to users.id |
| deleted_at | timestamp | Soft delete |
| timestamps | | created_at, updated_at |

### Informasi
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| judul | varchar(255) | Title |
| isi | text | Content |
| tanggal | date | Publication date |
| gambar | varchar(255) | Image path (nullable) |
| dibuat_oleh | bigint | FK to users.id |
| deleted_at | timestamp | Soft delete |
| timestamps | | created_at, updated_at |

### Notifikasi
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | FK to users.id |
| event_id | bigint | FK to events.id (nullable) |
| pesan | varchar(255) | Notification message |
| status | enum | `unread`, `read` |
| timestamps | | created_at, updated_at |

### EventRegistration
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| event_id | bigint | FK to events.id |
| user_id | bigint | FK to users.id |
| status | enum | `registered`, `cancelled`, `attended`, `absent` |
| registered_at | datetime | Registration time |
| cancelled_at | datetime | Cancellation time (nullable) |
| timestamps | | created_at, updated_at |

### EventQrToken
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| event_id | bigint | FK to events.id |
| generated_by | bigint | FK to users.id |
| token | string(64) | Unique QR token |
| expired_at | datetime | Token expiry |
| is_active | boolean | Active flag |
| timestamps | | created_at, updated_at |

### Attendance
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| event_id | bigint | FK to events.id |
| user_id | bigint | FK to users.id |
| registration_id | bigint | FK to event_registrations.id |
| qr_token_id | bigint | FK to event_qr_tokens.id (nullable) |
| scanned_at | datetime | Scan time |
| status | enum | `present`, `absent`, `late`, `excused` |
| timestamps | | created_at, updated_at |

### Bookmark
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | FK to users.id |
| bookmarkable_type | string | Model type (Event/Informasi) |
| bookmarkable_id | bigint | Model ID |
| timestamps | | created_at, updated_at |

### UserInterest
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | FK to users.id |
| kategori | varchar(255) | Category name |
| timestamps | | created_at, updated_at |

### AuditLog
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | FK to users.id (nullable) |
| action | string | Action type (create/update/delete) |
| model_type | string | Model class name |
| model_id | bigint | Model ID |
| description | text | Log description |
| old_values | json | Previous values (nullable) |
| new_values | json | New values (nullable) |
| ip_address | string | IP address (nullable) |
| timestamps | | created_at, updated_at |

---

## API Documentation

Base URL: `http://127.0.0.1:8000/api`

### API Versioning

Semua endpoint API berada di bawah prefix `/api/v1/` untuk mendukung versioning.

| Endpoint | Deskripsi |
|----------|-----------|
| `GET /api/health` | Health check + status API |

### Public Endpoints

| Method | Endpoint | Rate Limit | Deskripsi |
|--------|----------|------------|-----------|
| `POST` | `/api/v1/login` | 5/menit | Login user |
| `POST` | `/api/v1/register` | 3/menit | Register user baru |

### Protected Endpoints (Sanctum Auth)

Semua endpoint di bawah membutuhkan header `Authorization: Bearer {token}`.

#### Auth & Profile

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `POST` | `/api/v1/logout` | All | Logout & hapus token |
| `GET` | `/api/v1/me` | All | Data user saat ini |
| `PUT` | `/api/v1/profile` | All | Update profil |
| `GET` | `/api/v1/dashboard/overview` | dosen, admin | Dashboard overview |

#### Event Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `GET` | `/api/v1/events` | mahasiswa, dosen, admin | List events (dengan pagination) |
| `GET` | `/api/v1/events/{id}` | mahasiswa, dosen, admin | Detail event |
| `POST` | `/api/v1/events` | dosen, admin | Buat event baru |
| `PUT` | `/api/v1/events/{id}` | dosen, admin | Update event |
| `DELETE` | `/api/v1/events/{id}` | dosen, admin | Hapus event |
| `PUT` | `/api/v1/events/{id}/approve` | admin | Approve event (pending → published) |
| `PUT` | `/api/v1/events/{id}/reject` | admin | Reject event (pending → rejected) |

**Query Parameters untuk GET /api/v1/events:**
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `search` | string | Cari berdasarkan judul, lokasi, deskripsi, kategori |
| `kategori` | string | Filter berdasarkan kategori |
| `status` | string | Filter berdasarkan status |
| `page` | integer | Halaman (default: 1) |
| `per_page` | integer | Items per halaman (default: 10) |

#### Event Registration

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `POST` | `/api/v1/events/{id}/register` | mahasiswa | Daftar event |
| `DELETE` | `/api/v1/events/{id}/register` | mahasiswa | Batalkan pendaftaran |
| `GET` | `/api/v1/events/{id}/check-registration` | all | Cek status pendaftaran |
| `GET` | `/api/v1/events/{id}/participants` | dosen, admin | Daftar peserta event |
| `GET` | `/api/v1/users/me/events` | all | Event yang saya ikuti |

#### QR Code Attendance

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `POST` | `/api/v1/events/{id}/qr` | dosen, admin | Generate QR Code untuk absensi |
| `GET` | `/api/v1/events/{id}/qr` | dosen, admin | Dapatkan QR Code aktif |
| `POST` | `/api/v1/events/{id}/attendance/scan` | mahasiswa | Scan QR untuk absensi |
| `GET` | `/api/v1/events/{id}/attendance/check` | mahasiswa | Cek status absensi |
| `GET` | `/api/v1/events/{id}/attendance` | dosen, admin | Laporan absensi (JSON) |
| `GET` | `/api/v1/events/{id}/attendance/csv` | dosen, admin | Export laporan absensi (CSV) |
| `POST` | `/api/v1/events/{id}/attendance/manual` | dosen, admin | Absensi manual |

#### Informasi Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `GET` | `/api/v1/informasis` | mahasiswa, dosen, admin | List informasi (pagination) |
| `GET` | `/api/v1/informasis/{id}` | mahasiswa, dosen, admin | Detail informasi |
| `POST` | `/api/v1/informasis` | admin | Buat informasi baru |
| `PUT` | `/api/v1/informasis/{id}` | admin | Update informasi |
| `DELETE` | `/api/v1/informasis/{id}` | admin | Hapus informasi |

#### Notifikasi Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `GET` | `/api/v1/notifikasis` | all | List notifikasi user |
| `GET` | `/api/v1/notifikasis/unread` | all | Notifikasi belum dibaca |
| `GET` | `/api/v1/notifikasis/unread/count` | all | Jumlah notifikasi belum dibaca |
| `PUT` | `/api/v1/notifikasis/{id}/read` | all | Tandai sudah dibaca |
| `PUT` | `/api/v1/notifikasis/read-all` | all | Tandai semua sudah dibaca |
| `DELETE` | `/api/v1/notifikasis/{id}` | all | Hapus notifikasi |

#### Bookmark Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `POST` | `/api/v1/bookmarks` | all | Tambah bookmark |
| `GET` | `/api/v1/bookmarks` | all | List bookmark user |
| `GET` | `/api/v1/bookmarks/check/{type}/{id}` | all | Cek status bookmark |
| `DELETE` | `/api/v1/bookmarks/{id}` | all | Hapus bookmark |

#### Recommendation Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `GET` | `/api/v1/recommendations/events` | all | Rekomendasi event |
| `POST` | `/api/v1/events/{id}/track-view` | all | Track view event |
| `GET` | `/api/v1/users/me/interests` | all | Lihat minat user |
| `POST` | `/api/v1/users/me/interests` | all | Simpan minat user |

#### Analytics Endpoints

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| `GET` | `/api/v1/admin/analytics/summary` | admin | Ringkasan analytics global |
| `GET` | `/api/v1/admin/analytics/events` | admin | Analytics event global |
| `GET` | `/api/v1/lecturer/analytics/events` | dosen | Analytics event dosen |
| `GET` | `/api/v1/events/{id}/analytics` | dosen, admin | Detail analytics per event |

#### User Management (Admin)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET` | `/api/v1/users` | List semua user |
| `POST` | `/api/v1/users` | Buat user baru |
| `GET` | `/api/v1/users/{id}` | Detail user |
| `PUT` | `/api/v1/users/{id}` | Update user |
| `DELETE` | `/api/v1/users/{id}` | Hapus user |

#### Audit Log (Admin)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET` | `/api/v1/admin/audit-logs` | List audit logs |
| `GET` | `/api/v1/admin/audit-logs/stats` | Statistik audit log |
| `GET` | `/api/v1/admin/audit-logs/{id}` | Detail audit log |

---

## Response Format

### Success (200)
```json
{
    "status": true,
    "message": "Operation successful",
    "data": {}
}
```

### Created (201)
```json
{
    "status": true,
    "message": "Data berhasil dibuat",
    "data": {}
}
```

### Error (400)
```json
{
    "status": false,
    "message": "Error description"
}
```

### Validation Error (422)
```json
{
    "status": false,
    "message": "Validation Error",
    "errors": {
        "field": ["The field is required."]
    }
}
```

### Unauthorized (401)
```json
{
    "status": false,
    "message": "Unauthorized"
}
```

### Forbidden (403)
```json
{
    "status": false,
    "message": "Anda tidak memiliki akses"
}
```

### Not Found (404)
```json
{
    "status": false,
    "message": "Data tidak ditemukan"
}
```

### Pagination Response
```json
{
    "status": true,
    "message": "Success",
    "data": [...],
    "meta": {
        "current_page": 1,
        "last_page": 5,
        "per_page": 10,
        "total": 50,
        "has_more": true
    }
}
```

---

## Rate Limiting

| Rate Limit Group | Limit | Endpoints |
|-----------------|-------|-----------|
| **login** | 5 requests / menit | `/api/v1/login` |
| **register** | 3 requests / menit | `/api/v1/register` |
| **api** | 60 requests / menit | Semua authenticated endpoints |
| **admin** | 120 requests / menit | Admin-only endpoints |

---

## Admin Panel

Akses login admin/dosen via browser:

| URL | Deskripsi |
|-----|-----------|
| `http://127.0.0.1:8000/admin/login` | Halaman login admin |
| `http://127.0.0.1:8000/admin/dashboard` | Dashboard utama |
| `http://127.0.0.1:8000/admin/events` | Manajemen Event (CRUD) |
| `http://127.0.0.1:8000/admin/calendar` | Kalender Event |
| `http://127.0.0.1:8000/admin/informasis` | Manajemen Informasi (Admin only) |
| `http://127.0.0.1:8000/admin/users` | Manajemen User (Admin only) |
| `http://127.0.0.1:8000/admin/profile` | Edit Profil & Password |

### Fitur Admin Panel
- Dashboard dengan statistik (jumlah event, user, informasi, pendaftaran)
- Manajemen event (CRUD) dengan upload gambar & kalender
- Manajemen informasi (CRUD) dengan upload gambar
- Manajemen user (list, edit, hapus)
- Edit profil & ganti password
- Forgot/reset password via email
- Animasi UI/UX modern

---

## Integrasi Aplikasi Flutter

Client Flutter berada pada folder sibling `../aplikasi_kampus`.

**Default base URL aplikasi:**

| Platform Flutter | Base URL |
|-----------------|----------|
| Android emulator | `http://10.0.2.2:8000/api` |
| Windows/iOS simulator/web lokal | `http://127.0.0.1:8000/api` |

Untuk device fisik, jalankan Flutter dengan IP komputer backend:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

**Catatan contract API:**
- `GET /api/v1/events` mengembalikan pagination Laravel di `data.data` + `meta`.
- `POST /api/v1/events` dapat dipakai oleh role `dosen` dan `admin`; setelah event dibuat, backend otomatis mengirim notifikasi.
- Event dari dosen masuk status `pending` menunggu approval admin.
- Endpoint notifikasi tersedia untuk semua role (`mahasiswa`, `dosen`, `admin`).
- `gambar_url` dapat berupa path relatif `/storage/...`; client Flutter harus mengubahnya menjadi URL penuh berdasarkan host API.
- Semua endpoint versi 1 berada di prefix `/api/v1/`.

---

## Testing

Test suite otomatis mencakup:
- Authorization event (dosen hanya bisa edit event sendiri)
- Validation error contract API (422)
- Error contract API (401, 403, 404)
- CORS preflight API
- Media upload/remove image flow (event & informasi)
- Notifikasi flow (unread count, mark all read)
- Event registration flow
- QR Code attendance flow
- Bookmark & recommendation flow
- Analytics & audit log flow
- Rate limiter middleware

Jalankan:
```bash
php artisan test
```

---

## Instalasi

### Prerequisites
- PHP 8.2+
- Composer 2.x
- MySQL 5.7+ or MariaDB 10.3+
- Git

### Langkah Instalasi

```bash
# Clone repository
git clone https://github.com/tembokbaleko123/admin-event-bumigora.git
cd admin-event-bumigora

# Install dependencies
composer install

# Copy environment
cp .env.example .env
```

### Konfigurasi Database (.env)

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=admin_event_bumigora
DB_USERNAME=root
DB_PASSWORD=
```

### Setup Aplikasi

```bash
# Generate app key
php artisan key:generate

# Buat storage link
php artisan storage:link

# Jalankan migrasi & seeder
php artisan migrate --seed

# Start development server
php artisan serve --host=127.0.0.1 --port=8000
```

### Development Commands

```bash
php artisan serve                          # Start server
php artisan migrate                        # Run migrations
php artisan migrate:fresh --seed           # Reset & reseed database
php artisan test                           # Run tests
php artisan cache:clear                    # Clear cache
php artisan config:clear                   # Clear config
php artisan route:clear                    # Clear routes
php artisan storage:link                   # Create storage symlink
```

---

## Sample Users (Seeder)

Setelah menjalankan `php artisan db:seed`, user berikut tersedia:

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@example.com | password |
| **Dosen** | dosen@example.com | password |
| **Dosen** | dosen2@example.com | password |
| **Mahasiswa** | mahasiswa@example.com | password |
| **Mahasiswa** | mahasiswa2@example.com | password |
| **Mahasiswa** | mahasiswa3@example.com | password |

---

## Perubahan Terbaru

### 🆕 Fitur Baru

- **Pendaftaran Event** — Mahasiswa dapat mendaftar & membatalkan pendaftaran event, dengan validasi kuota & batas pendaftaran.
- **Absensi QR Code** — Generate QR Code untuk absensi, scan QR, laporan absensi (JSON & CSV), absensi manual.
- **Bookmark** — Bookmark event/informasi favorit.
- **Rekomendasi Event** — Rekomendasi event berdasarkan minat user & track event views.
- **Analytics & Dashboard** — Dashboard overview, admin analytics summary, event detail analytics, lecturer analytics.
- **Event Approval Workflow** — Event dari dosen masuk status `pending` → admin approve/reject.
- **Audit Log** — Mencatat semua operasi CRUD dengan detail (siapa, aksi, model, data lama/baru, IP).
- **API Versioning** — Routes diorganisir per versi (`/api/v1/`), mendukung pengembangan versi baru.
- **Rate Limiting** — Pembatasan request per endpoint (login, register, API, admin).
- **Password Reset** — Lupa password via email (admin panel).
- **Soft Deletes** — Event & Informasi support soft delete.
- **Health Check** — Endpoint `GET /api/health` untuk monitoring.

### 🔧 Perbaikan & Optimasi

- Event support field `gambar` dan `kategori` (otomatis UPPERCASE)
- Informasi support field `gambar`
- API event/informasi sudah sinkron dengan upload gambar dan `hapus_gambar`
- API search event/informasi menggunakan scope model
- `gambar_url` otomatis tampil di response JSON (Event, Informasi)
- Standardisasi response error API untuk 401, 404, 422, 403
- CORS API mendukung preflight OPTIONS dan origin-aware response
- Penambahan index query untuk performa:
  - `events(tanggal)`, `events(kategori)`
  - `notifikasis(user_id,status)`, `notifikasis(event_id,created_at)`
  - `event_registrations(event_id,user_id)`, `event_registrations(event_id,status)`
  - `attendances(event_id,user_id)`, `attendances(event_id,status)`
  - Composite indexes untuk query performa tinggi
- Cache headers untuk GET endpoints (5 detik)

---

## Postman Collection

File: `postman_collection.json`

Gunakan variabel Postman:
- `BASE_URL = http://127.0.0.1:8000`
- `auth_token = <token dari login>`

**Tips Penting:**
- Pastikan MySQL aktif sebelum test API
- Tambahkan header `Accept: application/json` agar error response tetap JSON
- Untuk Newman, semua variabel environment sudah siap pakai

### Run dengan Newman

```bash
newman run postman_collection.json --env-var BASE_URL=http://127.0.0.1:8000
```

---

## License

MIT License — Lihat file [LICENSE](LICENSE) untuk detail lebih lanjut.

---

<div align="center">
  <sub>Built with ❤️ by Universitas Bumigora</sub>
  <br>
  <sub>© 2026 Universitas Bumigora. All rights reserved.</sub>
</div>
