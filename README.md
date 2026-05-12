# Sistem Informasi Pendidikan & Event Akademik

RESTful API backend untuk Sistem Informasi Pendidikan & Event Akademik menggunakan Laravel 12.

## Deskripsi Project

Backend API untuk aplikasi multi-platform:
- **Mobile App** (untuk Mahasiswa/Students)
- **Web App** menggunakan Laravel Blade (untuk Admin & Dosen/Lecturer)
- **Database**: MySQL

## Tech Stack

- **Framework**: Laravel 12
- **PHP**: 8.2+
- **Database**: MySQL
- **Authentication**: Laravel Sanctum (token-based)
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

- **Authentication**: Login, Register, Logout dengan Sanctum
- **Event**: CRUD event dengan auto-notifikasi ke mahasiswa
- **Informasi**: CRUD informasi pendidikan
- **Notifikasi**: Sistem notifikasi untuk mahasiswa
- **User Management**: Manajemen user (Admin only)

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

Semua endpoint kecuali login & register memerlukan header:

```
Authorization: Bearer {token}
```

Token diperoleh dari response login.

## Postman Collection

Import file `postman_collection.json` ke Postman untuk testing semua endpoint API.

## Project Structure

```
admin-event-bumigora/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php
│   │   │   ├── EventController.php
│   │   │   ├── InformasiController.php
│   │   │   ├── NotifikasiController.php
│   │   │   └── UserController.php
│   │   └── Middleware/
│   │       └── RoleMiddleware.php
│   └── Models/
│       ├── User.php
│       ├── Event.php
│       ├── Informasi.php
│       └── Notifikasi.php
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   └── api.php
└── postman_collection.json
```

## Data Models

### User
- `id`, `nama`, `email`, `password`, `role`
- Role: 'mahasiswa', 'dosen', 'admin'

### Event
- `id`, `judul`, `tanggal`, `lokasi`, `deskripsi`, `created_by`

### Informasi
- `id`, `judul`, `isi`, `tanggal`, `dibuat_oleh`

### Notifikasi
- `id`, `user_id`, `event_id`, `pesan`, `status`
- Status: 'unread', 'read'

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

# Run tests
php artisan test
```

## License

MIT License

## Author

GitHub: [tembokbaleko123](https://github.com/tembokbaleko123)
