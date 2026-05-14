# Sistem Informasi Pendidikan & Event Akademik
## Universitas Bumigora

![Universitas Bumigora](https://bumigora.ac.id/wp-content/uploads/2022/11/Logo-Universitas-Bumigora.png)

Restful API backend + Admin Panel Web untuk **Sistem Informasi Pendidikan & Event Akademik** menggunakan Laravel 12. Dibangun untuk mendukung kegiatan akademik di **Universitas Bumigora**.

## Deskripsi Project

Aplikasi multi-platform untuk manajemen pendidikan dan event akademik:
- **Mobile App** — untuk Mahasiswa (lihat event, informasi, notifikasi)
- **Admin Panel Web** — Laravel Blade UI/UX modern untuk Admin & Dosen (dashboard, CRUD events, informasi, user management)
- **Database**: MySQL

## Tech Stack

- **Framework**: Laravel 12
- **PHP**: 8.2+
- **Database**: MySQL
- **Authentication**: Laravel Sanctum (token-based API) + Session-based Web
- **Frontend**: Bootstrap 5.3, Chart.js, Google Fonts Inter
- **Animasi**: CSS custom keyframes (fadeIn, slideDown, scaleIn, shimmer, pulseGlow, float, countUp)
- **API**: RESTful JSON API

## Fitur

### Role-Based Access Control

| Fitur | Mahasiswa | Dosen | Admin |
|-------|-----------|-------|-------|
| Lihat Event | ✓ | ✓ | ✓ |
| Buat Event | ✗ | ✓ | ✓ |
| Update Event | ✗ | ✓ | ✓ |
| Hapus Event | ✗ | ✓ | ✓ |
| Lihat Informasi | ✓ | ✓ | ✓ |
| Kelola Informasi | ✗ | ✗ | ✓ |
| Lihat Notifikasi | ✓ | ✗ | ✗ |
| Kelola User | ✗ | ✗ | ✓ |

### Modul

- **Authentication**: Login, Register, Logout (Sanctum API + Session Web)
- **Dashboard**: Statistik real-time (total users, events, informasi, notifikasi) + Chart.js
- **Event**: CRUD event dengan auto-notifikasi ke mahasiswa
- **Informasi**: CRUD informasi pendidikan
- **Notifikasi**: Sistem notifikasi untuk mahasiswa (mark read, unread)
- **User Management**: Manajemen user (Admin only)

### UI/UX Features

- Sidebar navigasi dengan animasi staggered
- Glassmorphism header dengan backdrop blur
- Stat cards dengan gradient shimmer & hover lift
- Table rows dengan fade-in staggered animation
- Buttons dengan ripple effect & spring transitions
- Form inputs dengan fokus translateY
- Alert dengan gradient & slide animation
- Pagination dengan hover lift effect
- Login page dengan animated background gradient, particle effects, card scale animation
- Responsive design (mobile sidebar collapse)

## Installation

### Prerequisites

- PHP 8.2+
- Composer 2.x
- MySQL 5.7+ atau MariaDB 10.3+
- Git

### Steps

```bash
# Clone repository
git clone https://github.com/tembokbaleko123/admin-event-bumigora.git
cd admin-event-bumigora

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Edit .env with your MySQL credentials:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=admin_event_bumigora
# DB_USERNAME=root
# DB_PASSWORD=

# Create MySQL database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS admin_event_bumigora;"

# Generate app key
php artisan key:generate

# Run migrations
php artisan migrate

# (Optional) Seed database with sample data
php artisan db:seed

# Start development server
php artisan serve
```

Server akan berjalan di `http://localhost:8000`

### Admin Panel Web

Akses panel admin di: **`http://localhost:8000/admin/login`**

## Sample Users

Setelah menjalankan seeder, data sample berikut tersedia:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | password |
| Dosen | dosen@example.com | password |
| Dosen | dosen2@example.com | password |
| Mahasiswa | mahasiswa@example.com | password |
| Mahasiswa | mahasiswa2@example.com | password |
| Mahasiswa | mahasiswa3@example.com | password |

## API Endpoints

### Authentication

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/register` | Register user baru |
| POST | `/api/login` | Login user |
| POST | `/api/logout` | Logout user |
| GET | `/api/me` | Get current user |

### Events

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/events` | All | List semua event |
| GET | `/api/events/{id}` | All | Detail event |
| POST | `/api/events` | Dosen, Admin | Buat event |
| PUT | `/api/events/{id}` | Dosen, Admin | Update event |
| DELETE | `/api/events/{id}` | Dosen, Admin | Hapus event |

### Informasi

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/informasis` | All | List semua informasi |
| GET | `/api/informasis/{id}` | All | Detail informasi |
| POST | `/api/informasis` | Admin | Buat informasi |
| PUT | `/api/informasis/{id}` | Admin | Update informasi |
| DELETE | `/api/informasis/{id}` | Admin | Hapus informasi |

### Notifikasi

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/notifikasis` | Mahasiswa | List notifikasi |
| GET | `/api/notifikasis/unread` | Mahasiswa | List unread |
| PUT | `/api/notifikasis/{id}/read` | Mahasiswa | Mark as read |
| PUT | `/api/notifikasis/read-all` | Mahasiswa | Mark all read |
| DELETE | `/api/notifikasis/{id}` | Mahasiswa | Hapus notifikasi |

### User Management

| Method | Endpoint | Role | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/users` | Admin | List semua user |
| GET | `/api/users/{id}` | Admin | Detail user |
| PUT | `/api/users/{id}` | Admin | Update user |
| DELETE | `/api/users/{id}` | Admin | Hapus user |

## API Response Format

### Success Response
```json
{
    "status": true,
    "message": "Operation successful",
    "data": { ... }
}
```

### Error Response
```json
{
    "status": false,
    "message": "Error description"
}
```

## Authentication

Semua endpoint API kecuali login & register memerlukan header:

```
Authorization: Bearer {token}
```

Token diperoleh dari response login.

## Postman Collection

Import file `postman_collection.json` ke Postman untuk testing semua endpoint API.

Variable yang digunakan:
- `{{BASE_URL}}` = `http://localhost:8000`
- `{{auth_token}}` = (auto-populated setelah login)

## Project Structure

```
admin-event-bumigora/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php              # API Auth
│   │   │   ├── EventController.php             # API Event
│   │   │   ├── InformasiController.php         # API Informasi
│   │   │   ├── NotifikasiController.php        # API Notifikasi
│   │   │   ├── UserController.php              # API User
│   │   │   └── Admin/
│   │   │       ├── AdminController.php         # Dashboard Web
│   │   │       ├── AuthController.php          # Login Web
│   │   │       ├── EventController.php         # Event CRUD Web
│   │   │       ├── InformasiController.php     # Informasi CRUD Web
│   │   │       └── UserController.php          # User Management Web
│   │   └── Middleware/
│   │       └── RoleMiddleware.php
│   └── Models/
│       ├── User.php
│       ├── Event.php
│       ├── Informasi.php
│       └── Notifikasi.php
├── bootstrap/
│   └── app.php
├── config/
├── database/
│   ├── migrations/
│   └── seeders/
│       └── DatabaseSeeder.php
├── resources/
│   └── views/
│       ├── layouts/
│       │   └── admin.blade.php                 # Layout utama dengan animasi
│       ├── auth/
│       │   └── login.blade.php                 # Halaman login premium
│       ├── dashboard/
│       │   └── index.blade.php                 # Dashboard dengan Chart.js
│       ├── events/                             # CRUD Event views
│       ├── informasis/                         # CRUD Informasi views
│       └── users/                              # User management views
├── routes/
│   ├── api.php                                 # 23 API endpoints
│   └── web.php                                 # 24 Web admin routes
└── postman_collection.json
```

## Data Models

### User
- `id`, `nama`, `email`, `password`, `role`
- Role: 'mahasiswa', 'dosen', 'admin'
- Methods: `login()`, `register()`, `isAdmin()`, `isDosen()`, `isMahasiswa()`

### Event
- `id`, `judul`, `tanggal`, `lokasi`, `deskripsi`, `created_by`
- Auto-notifikasi ke mahasiswa saat create/update/delete
- Relasi: `creator()`, `notifikasis()`

### Informasi
- `id`, `judul`, `isi`, `tanggal`, `dibuat_oleh`
- Relasi: `creator()`

### Notifikasi
- `id`, `user_id`, `event_id`, `pesan`, `status`
- Status: 'unread', 'read'
- Scopes: `unread()`, `read()`
- Methods: `kirimNotifikasi()`, `kirimNotifikasiKeRole()`

## Web Admin Panel Routes

| Method | Route | View | Deskripsi |
|--------|-------|------|-----------|
| GET | `/admin/login` | auth.login | Halaman login |
| POST | `/admin/login` | - | Proses login |
| POST | `/admin/logout` | - | Logout |
| GET | `/admin/dashboard` | dashboard.index | Dashboard utama |
| GET | `/admin/events` | events.index | Daftar events |
| GET | `/admin/events/create` | events.create | Form tambah event |
| POST | `/admin/events` | - | Simpan event baru |
| GET | `/admin/events/{id}` | events.show | Detail event |
| GET | `/admin/events/{id}/edit` | events.edit | Form edit event |
| PUT | `/admin/events/{id}` | - | Update event |
| DELETE | `/admin/events/{id}` | - | Hapus event |
| GET | `/admin/informasis` | informasis.index | Daftar informasi |
| GET | `/admin/informasis/create` | informasis.create | Form tambah informasi |
| POST | `/admin/informasis` | - | Simpan informasi baru |
| GET | `/admin/informasis/{id}` | informasis.show | Detail informasi |
| GET | `/admin/informasis/{id}/edit` | informasis.edit | Form edit informasi |
| PUT | `/admin/informasis/{id}` | - | Update informasi |
| DELETE | `/admin/informasis/{id}` | - | Hapus informasi |
| GET | `/admin/users` | users.index | Daftar users |
| GET | `/admin/users/{id}` | users.show | Detail user |
| GET | `/admin/users/{id}/edit` | users.edit | Form edit user |
| PUT | `/admin/users/{id}` | - | Update user |
| DELETE | `/admin/users/{id}` | - | Hapus user |

## Development Commands

```bash
# Start server
php artisan serve

# Run migrations
php artisan migrate

# Reset and reseed
php artisan migrate:fresh --seed

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Run tests
php artisan test
```

## Bug Fixes

Berikut bug yang telah diperbaiki selama development:

1. **Double hashing password** — `Hash::make()` manual di `User::register()` dan `UserController::update()` dihapus, biarkan `'hashed'` cast yang handle auto-hash
2. **Duplikasi route events** — Route POST/PUT/DELETE `/api/events` digabung dalam satu grup middleware `role:dosen,admin`
3. **GET /events & /informasis 403** — Route view events/informasis diperluas ke semua role (`mahasiswa,dosen,admin`)
4. **Missing vendor autoload** — `composer install` diperlukan
5. **Session/cache/queue database driver** — Diubah ke `file`/`sync` untuk API backend

## License

MIT License

## Author

**Universitas Bumigora**
- GitHub: [tembokbaleko123](https://github.com/tembokbaleko123)
- Website: [bumigora.ac.id](https://bumigora.ac.id)
