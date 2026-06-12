# Sistem Informasi Pendidikan & Event Akademik
## Universitas Bumigora

![Universitas Bumigora](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmINwWvAoYHkJZlok2LNRoekRZKf4Lm-c2ew&s)

Backend REST API + Admin Panel Web berbasis Laravel 12 untuk manajemen event akademik, informasi kampus, notifikasi mahasiswa, dan manajemen user.

## Tech Stack

- Laravel 12
- PHP 8.2+
- MySQL / MariaDB
- Laravel Sanctum (token API)
- Blade + Bootstrap (Admin/Dosen web)

## Fitur Utama

- Autentikasi API: register, login, logout, current user
- Role-based access control: `mahasiswa`, `dosen`, `admin`
- Event akademik: CRUD + upload gambar + kategori + notifikasi otomatis ke mahasiswa
- Informasi pendidikan: CRUD + upload gambar
- Notifikasi mahasiswa: list, unread, unread count, mark read, mark all read, delete
- User management (admin): list, detail, update, delete
- Admin panel web: dashboard, CRUD event, CRUD informasi, user management

## Role Matrix

| Fitur | Mahasiswa | Dosen | Admin |
|------|-----------|-------|-------|
| Lihat Event | ✓ | ✓ | ✓ |
| Kelola Event | ✗ | ✓ (event sendiri) | ✓ |
| Lihat Informasi | ✓ | ✓ | ✓ |
| Kelola Informasi | ✗ | ✗ | ✓ |
| Kelola Notifikasi | ✓ | ✗ | ✗ |
| Kelola User | ✗ | ✗ | ✓ |

## Struktur Endpoint API

### Public
- `POST /api/register`
- `POST /api/login`

### Protected (Sanctum)
- `POST /api/logout`
- `GET /api/me`

### Event
- `GET /api/events`
- `GET /api/events/{id}`
- `POST /api/events` (dosen, admin)
- `PUT /api/events/{id}` (dosen, admin)
- `DELETE /api/events/{id}` (dosen, admin)

### Informasi
- `GET /api/informasis`
- `GET /api/informasis/{id}`
- `POST /api/informasis` (admin)
- `PUT /api/informasis/{id}` (admin)
- `DELETE /api/informasis/{id}` (admin)

### Notifikasi (mahasiswa)
- `GET /api/notifikasis`
- `GET /api/notifikasis/unread`
- `GET /api/notifikasis/unread/count`
- `PUT /api/notifikasis/{id}/read`
- `PUT /api/notifikasis/read-all`
- `DELETE /api/notifikasis/{id}`

### User Management (admin)
- `GET /api/users`
- `GET /api/users/{id}`
- `PUT /api/users/{id}`
- `DELETE /api/users/{id}`

## Response Format

### Success
```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

### Error
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

## Perubahan Terbaru

- Event support field `gambar` dan `kategori`
- Informasi support field `gambar`
- API event/informasi sudah sinkron dengan upload gambar dan `hapus_gambar`
- API search event/informasi menggunakan scope model
- `gambar_url` otomatis tampil di response JSON (`Event`, `Informasi`)
- Standardisasi response error API untuk `401`, `404`, `422`
- CORS API sudah mendukung preflight `OPTIONS` dan origin-aware response untuk Flutter web/mobile client
- Penambahan index query:
  - `events(tanggal)`
  - `events(kategori)`
  - `notifikasis(user_id,status)`
  - `notifikasis(event_id,created_at)`

## Integrasi Aplikasi Flutter

Client Flutter berada pada folder sibling `../aplikasi_kampus`.

Default base URL aplikasi:

| Platform Flutter | Base URL |
|------|----------|
| Android emulator | `http://10.0.2.2:8000/api` |
| Windows/iOS simulator/web lokal | `http://127.0.0.1:8000/api` |

Untuk device fisik, jalankan Flutter dengan IP komputer backend:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Catatan contract:
- `GET /api/events` mengembalikan pagination Laravel di `data.data`.
- `POST /api/events` dapat dipakai oleh role `dosen` dan `admin`; setelah event dibuat, backend otomatis mengirim notifikasi ke seluruh mahasiswa.
- Endpoint notifikasi hanya untuk role `mahasiswa`.
- `gambar_url` dapat berupa path relatif `/storage/...`; client Flutter sudah mengubahnya menjadi URL penuh berdasarkan host API.

## Testing

Test suite otomatis:
- Authorization event (`dosen` hanya bisa edit event sendiri)
- Validation error contract API (`422`)
- Error contract API (`401`, `403`, `404`)
- CORS preflight API
- Media upload/remove image flow (event & informasi)
- Notifikasi flow (unread count, mark all read)

Jalankan:
```bash
php artisan test
```

## Instalasi

```bash
git clone https://github.com/tembokbaleko123/admin-event-bumigora.git
cd admin-event-bumigora
composer install
cp .env.example .env
php artisan key:generate
```

Atur `.env` database:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=admin_event_bumigora
DB_USERNAME=root
DB_PASSWORD=
```

Lalu:
```bash
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

## Sample Users (Seeder)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | password |
| Dosen | dosen@example.com | password |
| Dosen | dosen2@example.com | password |
| Mahasiswa | mahasiswa@example.com | password |
| Mahasiswa | mahasiswa2@example.com | password |
| Mahasiswa | mahasiswa3@example.com | password |

## Postman Collection

File: `postman_collection.json`

Gunakan variabel:
- `BASE_URL = http://127.0.0.1:8000`
- `auth_token = <token dari login>`

Saran penting:
- Pastikan MySQL aktif sebelum test API
- Tambahkan header `Accept: application/json` saat run di Postman/Newman agar error response tetap JSON

### Newman (opsional)
Jika `newman` belum global:
```bash
npx -p @faker-js/faker -p newman newman run postman_collection.json --env-var BASE_URL=http://127.0.0.1:8000
```

## Admin Panel

Akses login admin/dosen:
- `http://127.0.0.1:8000/admin/login`

## License

MIT
