# Tabel Database & Integritas Data - Admin Event Bumigora

## 1. Tabel `users`

Database tabel untuk menyimpan data pengguna sistem (mahasiswa, dosen, admin).

### Struktur Kolom

| No | Kolom | Tipe Data | Panjang | Constraint | Keterangan |
|----|-------|-----------|---------|------------|------------|
| 1 | id | BIGINT | - | PRIMARY KEY, AUTO_INCREMENT | ID unik pengguna |
| 2 | nama | VARCHAR | 255 | NOT NULL | Nama lengkap pengguna |
| 3 | email | VARCHAR | 255 | NOT NULL, UNIQUE | Alamat email (login) |
| 4 | password | VARCHAR | 255 | NOT NULL | Password ter-hash (bcrypt) |
| 5 | role | ENUM | - | NOT NULL, DEFAULT 'mahasiswa' | Role: 'mahasiswa', 'dosen', 'admin' |
| 6 | created_at | TIMESTAMP | - | NULLABLE | Waktu pembuatan |
| 7 | updated_at | TIMESTAMP | - | NULLABLE | Waktu update terakhir |

### Indexes
- **PRIMARY KEY**: `id`
- **UNIQUE**: `email`

### SQL DDL
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('mahasiswa', 'dosen', 'admin') NOT NULL DEFAULT 'mahasiswa',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2. Tabel `events`

Database tabel untuk menyimpan data event akademik.

### Struktur Kolom

| No | Kolom | Tipe Data | Panjang | Constraint | Keterangan |
|----|-------|-----------|---------|------------|------------|
| 1 | id | BIGINT | - | PRIMARY KEY, AUTO_INCREMENT | ID unik event |
| 2 | judul | VARCHAR | 255 | NOT NULL | Judul event |
| 3 | tanggal | DATETIME | - | NOT NULL | Tanggal & waktu event |
| 4 | lokasi | VARCHAR | 255 | NOT NULL | Lokasi event |
| 5 | deskripsi | TEXT | - | NULLABLE | Deskripsi event (boleh kosong) |
| 6 | created_by | BIGINT | - | NOT NULL, FOREIGN KEY | ID user pembuat (FK → users.id) |
| 7 | created_at | TIMESTAMP | - | NULLABLE | Waktu pembuatan |
| 8 | updated_at | TIMESTAMP | - | NULLABLE | Waktu update terakhir |

### Indexes
- **PRIMARY KEY**: `id`
- **FOREIGN KEY**: `created_by` REFERENCES `users(id)` ON DELETE CASCADE
- **INDEX**: `created_by`

### Referential Integrity
- `created_by` → `users.id`: ON DELETE **CASCADE**
  - Jika user dihapus, semua event yang dibuat user tersebut ikut terhapus.

### SQL DDL
```sql
CREATE TABLE events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    tanggal DATETIME NOT NULL,
    lokasi VARCHAR(255) NOT NULL,
    deskripsi TEXT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    CONSTRAINT fk_events_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_events_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 3. Tabel `informasis`

Database tabel untuk menyimpan data informasi pendidikan.

### Struktur Kolom

| No | Kolom | Tipe Data | Panjang | Constraint | Keterangan |
|----|-------|-----------|---------|------------|------------|
| 1 | id | BIGINT | - | PRIMARY KEY, AUTO_INCREMENT | ID unik informasi |
| 2 | judul | VARCHAR | 255 | NOT NULL | Judul informasi |
| 3 | isi | TEXT | - | NOT NULL | Isi/konten informasi |
| 4 | tanggal | DATE | - | NOT NULL | Tanggal publikasi |
| 5 | dibuat_oleh | BIGINT | - | NOT NULL, FOREIGN KEY | ID user pembuat (FK → users.id) |
| 6 | created_at | TIMESTAMP | - | NULLABLE | Waktu pembuatan |
| 7 | updated_at | TIMESTAMP | - | NULLABLE | Waktu update terakhir |

### Indexes
- **PRIMARY KEY**: `id`
- **FOREIGN KEY**: `dibuat_oleh` REFERENCES `users(id)` ON DELETE CASCADE
- **INDEX**: `dibuat_oleh`

### Referential Integrity
- `dibuat_oleh` → `users.id`: ON DELETE **CASCADE**
  - Jika user dihapus, semua informasi yang dibuat user tersebut ikut terhapus.

### SQL DDL
```sql
CREATE TABLE informasis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    isi TEXT NOT NULL,
    tanggal DATE NOT NULL,
    dibuat_oleh BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    CONSTRAINT fk_informasis_dibuat_oleh FOREIGN KEY (dibuat_oleh) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_informasis_dibuat_oleh (dibuat_oleh)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 4. Tabel `notifikasis`

Database tabel untuk menyimpan data notifikasi event untuk mahasiswa.

### Struktur Kolom

| No | Kolom | Tipe Data | Panjang | Constraint | Keterangan |
|----|-------|-----------|---------|------------|------------|
| 1 | id | BIGINT | - | PRIMARY KEY, AUTO_INCREMENT | ID unik notifikasi |
| 2 | user_id | BIGINT | - | NOT NULL, FOREIGN KEY | ID user penerima (FK → users.id) |
| 3 | event_id | BIGINT | - | NULLABLE, FOREIGN KEY | ID event terkait (FK → events.id) |
| 4 | pesan | VARCHAR | 255 | NOT NULL | Isi pesan notifikasi |
| 5 | status | ENUM | - | NOT NULL, DEFAULT 'unread' | Status: 'unread', 'read' |
| 6 | created_at | TIMESTAMP | - | NULLABLE | Waktu pembuatan |
| 7 | updated_at | TIMESTAMP | - | NULLABLE | Waktu update terakhir |

### Indexes
- **PRIMARY KEY**: `id`
- **FOREIGN KEY**: `user_id` REFERENCES `users(id)` ON DELETE CASCADE
- **FOREIGN KEY**: `event_id` REFERENCES `events(id)` ON DELETE SET NULL
- **INDEX**: `user_id`
- **INDEX**: `event_id`

### Referential Integrity
1. `user_id` → `users.id`: ON DELETE **CASCADE**
   - Jika user dihapus, semua notifikasi user tersebut ikut terhapus.
2. `event_id` → `events.id`: ON DELETE **SET NULL**
   - Jika event dihapus, notifikasi tetap ada namun `event_id` menjadi NULL (tidak merujuk ke event yang sudah dihapus).

### SQL DDL
```sql
CREATE TABLE notifikasis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    event_id BIGINT UNSIGNED NULL,
    pesan VARCHAR(255) NOT NULL,
    status ENUM('unread', 'read') NOT NULL DEFAULT 'unread',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    CONSTRAINT fk_notifikasis_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_notifikasis_event_id FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL,
    INDEX idx_notifikasis_user_id (user_id),
    INDEX idx_notifikasis_event_id (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 5. Tabel `personal_access_tokens`

Database tabel untuk menyimpan token autentikasi (Laravel Sanctum).

### Struktur Kolom

| No | Kolom | Tipe Data | Panjang | Constraint | Keterangan |
|----|-------|-----------|---------|------------|------------|
| 1 | id | BIGINT | - | PRIMARY KEY, AUTO_INCREMENT | ID unik token |
| 2 | tokenable_type | VARCHAR | 255 | NOT NULL | Model class (App\Models\User) |
| 3 | tokenable_id | BIGINT | - | NOT NULL | ID model terkait |
| 4 | name | VARCHAR | 255 | NOT NULL | Nama token |
| 5 | token | VARCHAR | 64 | NOT NULL, UNIQUE | Token string (hash) |
| 6 | abilities | TEXT | - | NULLABLE | Kemampuan token |
| 7 | last_used_at | TIMESTAMP | - | NULLABLE | Waktu penggunaan terakhir |
| 8 | expires_at | TIMESTAMP | - | NULLABLE | Waktu kadaluarsa |
| 9 | created_at | TIMESTAMP | - | NULLABLE | Waktu pembuatan |
| 10 | updated_at | TIMESTAMP | - | NULLABLE | Waktu update terakhir |

### Indexes
- **PRIMARY KEY**: `id`
- **UNIQUE**: `token`
- **INDEX**: `tokenable_type`, `tokenable_id` (polymorphic)
- **INDEX**: `expires_at`

---

## Integritas Data (Ringkasan)

### Entity Integrity (Integritas Entitas)
- Setiap tabel memiliki PRIMARY KEY (`id`) yang unik dan tidak boleh NULL.
- Setiap baris data dapat diidentifikasi secara unik melalui PRIMARY KEY.

### Referential Integrity (Integritas Referensial)
| Foreign Key | Source → Target | On Delete | Efek |
|-------------|----------------|-----------|------|
| events.created_by | events → users | CASCADE | Hapus event jika user dihapus |
| informasis.dibuat_oleh | informasis → users | CASCADE | Hapus informasi jika user dihapus |
| notifikasis.user_id | notifikasis → users | CASCADE | Hapus notifikasi jika user dihapus |
| notifikasis.event_id | notifikasis → events | SET NULL | Set event_id menjadi NULL jika event dihapus |

### Domain Integrity (Integritas Domain)
- `users.role`: ENUM('mahasiswa', 'dosen', 'admin') — hanya 3 nilai yang valid
- `notifikasis.status`: ENUM('unread', 'read') — hanya 2 nilai yang valid
- `users.email`: VARCHAR(255) + UNIQUE — menjamin tidak ada duplikasi email
- `events.tanggal`: DATETIME — format tanggal & waktu valid
- `informasis.tanggal`: DATE — format tanggal valid

### User-Defined Integrity (Integritas Buatan)
- `events.deskripsi` boleh NULL (deskripsi bersifat opsional)
- `notifikasis.event_id` boleh NULL (notifikasi bisa dibuat tanpa event terkait, atau event dihapus)
- `users.role` memiliki default 'mahasiswa' (role standar saat registrasi)
- `notifikasis.status` memiliki default 'unread' (notifikasi baru selalu belum dibaca)

---

## Ringkasan Relasi

```
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE RELATIONSHIPS                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  users (1) ────────────── (*) events                              │
│       │                      ↑ created_by (FK)                    │
│       │                                                          │
│  users (1) ────────────── (*) informasis                         │
│       │                      ↑ dibuat_oleh (FK)                  │
│       │                                                          │
│  users (1) ────────────── (*) notifikasis                        │
│       │                      ↑ user_id (FK)                      │
│       │                                                          │
│  events (1) ───────────── (*) notifikasis                        │
│                               ↑ event_id (FK, NULLABLE)          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
