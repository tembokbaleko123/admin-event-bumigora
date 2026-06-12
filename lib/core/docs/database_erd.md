# Entity Relationship Diagram (ERD) — Aplikasi Kampus (Flutter)

## Overview

Diagram ini menunjukkan relasi antara **model-model Flutter** di aplikasi (frontend) dengan **tabel-tabel database di Laravel backend** (API `http://127.0.0.1:8000/api/v1/...`).

```
┌──────────────────────────────────────────────┐
│              FLUTTER MODELS                   │
├──────────────────────────────────────────────┤
│                                                │
│  ┌──────────────┐         ┌──────────────────┐│
│  │   UserModel  │1───────*│   EventModel    ││
│  │  (users)     │         │  (events)        ││
│  └──────────────┘         └────────┬─────────┘│
│         │                          │          │
│         │1                         │1         │
│         │                          │          │
│         │         ┌────────────────▼────────┐ │
│         │         │    EventRegistration    │ │
│         │         │  (event_registrations)  │ │
│         │         └─────────────────────────┘ │
│         │                                     │
│         │1        ┌─────────────────────┐     │
│         ├────────*│  NotifikasiModel    │     │
│         │         │  (notifikasis)      │     │
│         │         └─────────────────────┘     │
│         │                                     │
│         │1        ┌─────────────────────┐     │
│         ├────────*│  InformasiModel     │     │
│         │         │  (informasis)       │     │
│         │         └─────────────────────┘     │
│         │                                     │
│         │1        ┌─────────────────────┐     │
│         └────────*│  BookmarkModel      │     │
│                   │  (bookmarks)        │     │
│                   └─────────────────────┘     │
│                                                │
│  ┌──────────────┐                              │
│  │  Attendance  │── references EventModel      │
│  │ (attendances)│── references UserModel       │
│  └──────────────┘                              │
│                                                │
│  ┌──────────────────┐                          │
│  │  EventAnalytics  │── derived from EventModel│
│  │  (analytics)     │                          │
│  └──────────────────┘                          │
│                                                │
│  ┌──────────────┐                              │
│  │   Creator    │── embedded in EventModel     │
│  │  (partial    │  (parsed from event data)    │
│  │   user data) │                              │
│  └──────────────┘                              │
└──────────────────────────────────────────────┘
```

## Model Relationships (Flutter → Backend)

| Flutter Model | Backend Table | Primary Key | Foreign Key (Flutter) | Relasi |
|--------------|---------------|-------------|----------------------|--------|
| `UserModel` | `users` | `id` | - | Entitas utama |
| `EventModel` | `events` | `id` | `createdBy` → `UserModel.id` | 1 User memiliki * Event |
| `InformasiModel` | `informasis` | `id` | `dibuatOleh` → `UserModel.id` | 1 User memiliki * Informasi |
| `NotifikasiModel` | `notifikasis` | `id` | `userId` → `UserModel.id`, `eventId` → `EventModel.id` | 1 User memiliki * Notifikasi |
| `BookmarkModel` | `bookmarks` | `id` | `userId` → `UserModel.id`, `eventId` → `EventModel.id` | 1 User memiliki * Bookmark |
| `EventRegistration` | `event_registrations` | `id` | `userId` → `UserModel.id`, `eventId` → `EventModel.id` | 1 User memiliki * Registrasi |
| `Attendance` | `attendances` | `id` | `userId` → `UserModel.id`, `eventId` → `EventModel.id` | 1 User memiliki * Attendance |
| `Creator` | (embedded) | - | - | Partial user data (nama) |
| `EventAnalytics` | (virtual) | - | - | Data agregasi dari Event + Attendance |

## Cardinality Diagram (Flutter Context)

```
   ┌─────────────┐         ┌──────────────┐
   │  UserModel  │1────────*│  EventModel  │
   └──────┬──────┘         └──────────────┘
          │
          │1               ┌──────────────────┐
          ├───────────────*│  InformasiModel  │
          │                └──────────────────┘
          │
          │1               ┌──────────────────┐
          ├───────────────*│ NotifikasiModel  │
          │                └────────┬─────────┘
          │                         │*
          │                         │1
          │                ┌────────┴─────────┐
          │                │   EventModel     │
          │                └──────────────────┘
          │
          │1               ┌──────────────────┐
          ├───────────────*│  BookmarkModel   │
          │                └────────┬─────────┘
          │                         │*
          │                         │1
          │                ┌────────┴─────────┐
          │                │   EventModel     │
          │                └──────────────────┘
          │
          │1               ┌──────────────────────┐
          ├───────────────*│ EventRegistration    │
          │                └──────────┬───────────┘
          │                           │*
          │                           │1
          │                  ┌────────┴───────────┐
          │                  │   EventModel       │
          │                  └────────────────────┘
          │
          │1               ┌──────────────────┐
          ├───────────────*│  Attendance      │
          │                └────────┬─────────┘
          │                         │*
          │                         │1
          │                ┌────────┴─────────┐
          │                │   EventModel     │
          │                └──────────────────┘
          │
          │               ┌──────────────────┐
          └───────────────│    Creator       │
                          │ (partial User)   │
                          └──────────────────┘
```

## Integrity Constraints (Flutter Side)

### 1. Entity Integrity
- Setiap model memiliki field `id` (int) yang wajib diisi.
- `fromJson()` menyediakan default value (`?? 0`) untuk mencegah null safety error.

### 2. Referential Integrity
- `EventModel.createdBy` → merujuk ke `UserModel.id` (penulis event).
- `NotifikasiModel.userId` → merujuk ke `UserModel.id` (penerima notifikasi).
- `NotifikasiModel.eventId` → merujuk ke `EventModel.id` (event terkait).
- `BookmarkModel.userId` → merujuk ke `UserModel.id`.
- `BookmarkModel.eventId` → merujok ke `EventModel.id`.
- `EventRegistration.userId` → merujuk ke `UserModel.id`.
- `EventRegistration.eventId` → merujuk ke `EventModel.id`.
- `Attendance.userId` → merujuk ke `UserModel.id`.
- `Attendance.eventId` → merujuk ke `EventModel.id`.

### 3. Domain Integrity (Validasi Input)
- **Register/Login**: `email` valid (regex), `password` min 8 karakter, `nama` tidak kosong.
- **Event Form**: `judul` wajib, `tanggal` valid DateTime, `lokasi` tidak kosong.
- **Role**: hanya `'mahasiswa'`, `'dosen'`, `'admin'` (divalidasi via `UserModel.isMahasiswa`, `isDosen`, `isAdmin`).
- **Notifikasi status**: hanya `'read'` atau `'unread'`.

### 4. Data Integrity pada API
- Semua data dikirim/diterima dalam format JSON melalui API Service.
- `toJson()` → mengirim data ke backend.
- `fromJson()` → parsing respons dari backend.
- Semua service menggunakan `api_client.dart` dengan base URL `http://127.0.0.1:8000/api/v1/`.

## File Model Summary

| File Path | Model Class | Backend Table |
|-----------|-------------|---------------|
| `lib/models/user_model.dart` | `UserModel` | `users` |
| `lib/models/event_model.dart` | `EventModel` | `events` |
| `lib/models/informasi_model.dart` | `InformasiModel` | `informasis` |
| `lib/models/notifikasi_model.dart` | `NotifikasiModel` | `notifikasis` |
| `lib/models/bookmark.dart` | `BookmarkModel` | `bookmarks` |
| `lib/models/event_registration.dart` | `EventRegistration` | `event_registrations` |
| `lib/models/attendance.dart` | `Attendance` | `attendances` |
| `lib/models/creator.dart` | `Creator` | (embedded/partial users) |
| `lib/models/analytics.dart` | `EventAnalytics` | (derived/virtual) |