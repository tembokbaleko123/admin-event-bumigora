# Admin Event Bumigora - Agent Documentation

## Project Overview

This is a Laravel 12 RESTful API backend application for **Sistem Informasi Pendidikan & Event Akademik** (Education Information & Academic Event System).

## Tech Stack

- **Framework**: Laravel 12
- **PHP**: 8.2+
- **Database**: MySQL
- **Authentication**: Laravel Sanctum (token-based API authentication)
- **Frontend**: Vite + Blade templates (Admin & Dosen Web App)

## System Requirements

- PHP 8.2+
- MySQL 5.7+ or MariaDB 10.3+
- Composer 2.x
- Git

## Directory Structure

```
admin-event-bumigora/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php         # Login, Register, Logout
│   │   │   ├── EventController.php       # CRUD Event
│   │   │   ├── InformasiController.php   # CRUD Informasi
│   │   │   ├── NotifikasiController.php  # Notifikasi management
│   │   │   └── UserController.php       # User management (Admin)
│   │   └── Middleware/
│   │       └── RoleMiddleware.php        # Role-based access control
│   ├── Models/
│   │   ├── User.php                      # User model with roles
│   │   ├── Event.php                    # Event model
│   │   ├── Informasi.php                  # Informasi model
│   │   └── Notifikasi.php                # Notifikasi model
│   └── Providers/
├── bootstrap/
│   └── app.php                           # App configuration with middleware
├── database/
│   ├── migrations/
│   │   ├── 0001_01_01_000000_create_users_table.php
│   │   ├── 2019_12_14_000001_create_personal_access_tokens_table.php (Sanctum)
│   │   ├── 2024_01_01_000001_create_events_table.php
│   │   ├── 2024_01_01_000002_create_informasis_table.php
│   │   └── 2024_01_01_000003_create_notifikasis_table.php
│   ├── factories/
│   │   └── UserFactory.php
│   └── seeders/
│       └── DatabaseSeeder.php
├── routes/
│   ├── api.php                           # API routes
│   ├── web.php                           # Web routes
│   └── console.php
├── storage/
│   └── logs/
│       └── laravel.log
├── tests/
├── .env                                  # Environment configuration (MySQL)
├── .env.example
├── composer.json
├── postman_collection.json               # Postman API collection
└── README.md
```

## Data Models

### User
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| nama | varchar(255) | Full name |
| email | varchar(255) | Unique email |
| password | varchar(255) | Hashed password |
| role | enum | 'mahasiswa', 'dosen', 'admin' |
| timestamps | | Created & updated at |

**Methods**: `login()`, `register()`, `isAdmin()`, `isDosen()`, `isMahasiswa()`

### Event
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| judul | varchar(255) | Event title |
| tanggal | date | Event date |
| lokasi | varchar(255) | Location |
| deskripsi | text | Description (nullable) |
| created_by | bigint | FK to users.id |
| timestamps | | Created & updated at |

**Methods**: `tambahEvent()`, `updateEvent()`, `hapusEvent()`, `creator()`, `notifikasis()`

### Informasi
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| judul | varchar(255) | Title |
| isi | text | Content |
| tanggal | date | Publication date |
| dibuat_oleh | bigint | FK to users.id |
| timestamps | | Created & updated at |

**Methods**: `tambahInformasi()`, `updateInformasi()`, `hapusInformasi()`, `creator()`

### Notifikasi
| Field | Type | Description |
|-------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | FK to users.id |
| event_id | bigint | FK to events.id (nullable) |
| pesan | varchar(255) | Notification message |
| status | enum | 'unread', 'read' |
| timestamps | | Created & updated at |

**Methods**: `kirimNotifikasi()`, `kirimNotifikasiKeRole()`, `markAsRead()`, `user()`, `event()`

## Relationships

```
User (1) ──► (*) Event      : created_by (User membuat Event)
User (1) ──► (*) Informasi   : dibuat_oleh (User mengelola Informasi)
User (1) ──► (*) Notifikasi : user_id (User menerima Notifikasi)
Event (1) ──► (*) Notifikasi : event_id (Event memicu Notifikasi)
```

## API Flow (Sequence)

1. Mobile/Web client sends HTTP Request (JSON) to Laravel API
2. Laravel API → Authentication Service (validates user via Sanctum)
3. Laravel API → Business Logic Layer (Model methods)
4. Business Logic → MySQL Database (CRUD via Eloquent)
5. Response returned to client

## Activity Flows

### Login Flow
```
User buka aplikasi → tampil halaman login → input email & password
    ↓
Jika valid → masuk dashboard
Jika tidak valid → tampilkan error
```

### Lihat Informasi
```
User login → pilih menu informasi → sistem ambil data dari DB → tampilkan
```

### Lihat Event
```
User login → pilih menu event → sistem ambil data event → tampilkan daftar
    ↓
user pilih → tampilkan detail
```

### Input Event (Admin/Dosen)
```
Login → pilih menu tambah event → input data → validasi
    ↓
Jika valid → simpan ke DB → event berhasil ditambahkan + kirim notifikasi
Jika tidak valid → tampilkan error
```

## Use Cases by Role

### Mahasiswa
- Login, Register
- Lihat Informasi Pendidikan
- Lihat Event Akademik
- Lihat Detail Event
- Terima Notifikasi Event

### Dosen
- Login
- Input Event
- Kelola Event (CRUD)

### Admin
- Login
- Kelola Data User
- Kelola Informasi
- Kelola Event (full CRUD)

## API Endpoints

### Authentication (Public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/register | Register new user |
| POST | /api/login | User login |

### Authenticated Routes (Protected by Sanctum)
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | /api/logout | All | Logout user |
| GET | /api/me | All | Get current user |

### Event Routes
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | /api/events | mahasiswa, dosen, admin | List all events |
| GET | /api/events/{id} | mahasiswa, dosen, admin | Get event detail |
| POST | /api/events | dosen, admin | Create event |
| PUT | /api/events/{id} | dosen, admin | Update event |
| DELETE | /api/events/{id} | dosen, admin | Delete event |

### Informasi Routes
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | /api/informasis | mahasiswa, dosen, admin | List all informasi |
| GET | /api/informasis/{id} | mahasiswa, dosen, admin | Get informasi detail |
| POST | /api/informasis | admin | Create informasi |
| PUT | /api/informasis/{id} | admin | Update informasi |
| DELETE | /api/informasis/{id} | admin | Delete informasi |

### Notifikasi Routes
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | /api/notifikasis | mahasiswa | List user notifications |
| GET | /api/notifikasis/unread | mahasiswa | List unread notifications |
| PUT | /api/notifikasis/{id}/read | mahasiswa | Mark as read |
| PUT | /api/notifikasis/read-all | mahasiswa | Mark all as read |
| DELETE | /api/notifikasis/{id} | mahasiswa | Delete notification |

### User Management Routes (Admin Only)
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | /api/users | admin | List all users |
| GET | /api/users/{id} | admin | Get user detail |
| PUT | /api/users/{id} | admin | Update user |
| DELETE | /api/users/{id} | admin | Delete user |

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

### HTTP Status Codes
- 200: Success
- 201: Created
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error

## Role-Based Access Control

| Feature | Mahasiswa | Dosen | Admin |
|---------|-----------|-------|-------|
| View Events | ✓ | ✓ | ✓ |
| Create Event | ✗ | ✓ | ✓ |
| Update Event | ✗ | ✓ | ✓ |
| Delete Event | ✗ | ✓ | ✓ |
| View Informasi | ✓ | ✓ | ✓ |
| Manage Informasi | ✗ | ✗ | ✓ |
| View Notifikasi | ✓ | ✗ | ✗ |
| Manage Users | ✗ | ✗ | ✓ |

## Middleware

### RoleMiddleware
Location: `app/Http/Middleware/RoleMiddleware.php`

Usage in routes:
```php
Route::middleware('role:dosen,admin')->group(function () {
    // Routes accessible by dosen and admin
});
```

## Installation

```bash
# Clone repository
git clone <repo-url>
cd admin-event-bumigora

# Install dependencies
composer install

# Setup environment
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

# Seed database (optional - creates sample users)
php artisan db:seed

# Start development server
php artisan serve
```

## Development Commands

```bash
# Start server
php artisan serve

# Run migrations
php artisan migrate

# Reset and reseed database
php artisan migrate:fresh --seed

# Run tests
php artisan test

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## Mobile App Integration

Mobile app (Mahasiswa) connects to these endpoints:
- POST /api/login
- POST /api/register
- GET /api/events
- GET /api/events/{id}
- GET /api/informasis
- GET /api/informasis/{id}
- GET /api/notifikasis
- GET /api/notifikasis/unread
- PUT /api/notifikasis/{id}/read
- PUT /api/notifikasis/read-all

## Sample Users (After Seeding)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | password |
| Dosen | dosen@example.com | password |
| Dosen | dosen2@example.com | password |
| Mahasiswa | mahasiswa@example.com | password |
| Mahasiswa | mahasiswa2@example.com | password |
| Mahasiswa | mahasiswa3@example.com | password |

## Postman Collection

Import `postman_collection.json` into Postman to test all API endpoints.

## Notes

- Authentication uses Laravel Sanctum (token-based)
- All protected routes require `Authorization: Bearer {token}` header
- Database uses MySQL
- Role field uses enum: 'mahasiswa', 'dosen', 'admin'
- When event is created/updated/deleted, notifications are automatically sent to mahasiswa
- Notifikasi model has event_id to link notifications to specific events
