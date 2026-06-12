# Entity Relationship Diagram (ERD) - Admin Event Bumigora

## Entity Relationship Diagram (Text-Based)

```
┌─────────────────────────────┐
│          USERS              │
├─────────────────────────────┤
│ PK │ id              BIGINT│
│    │ nama            VARCHAR│
│    │ email           VARCHAR│ ← UNIQUE
│    │ password        VARCHAR│
│    │ role            ENUM   │ ← 'mahasiswa','dosen','admin'
│    │ created_at      TIMESTAMP│
│    │ updated_at      TIMESTAMP│
└──────────┬──────────────────┘
           │
           │ 1
           │
           ├──────────────────────────────────────────────┐
           │                                              │
           │ *                                            │ *
           ▼                                              ▼
┌─────────────────────────┐              ┌─────────────────────────────┐
│        EVENTS           │              │        INFORMASIS           │
├─────────────────────────┤              ├─────────────────────────────┤
│ PK │ id          BIGINT│              │ PK │ id           BIGINT    │
│    │ judul       VARCHAR│              │    │ judul        VARCHAR    │
│    │ tanggal     DATE   │              │    │ isi          TEXT       │
│    │ lokasi      VARCHAR│              │    │ tanggal      DATE       │
│    │ deskripsi   TEXT   │ ← NULLABLE   │    │ dibuat_oleh  BIGINT    │ ← FK
│ FK │ created_by  BIGINT│ ──┐           │    │ created_at   TIMESTAMP │
│    │ created_at  TIMESTAMP│  │          │    │ updated_at   TIMESTAMP │
│    │ updated_at  TIMESTAMP│  │          └─────────────────────────────┘
└──────────┬──────────────┘  │
           │                 │
           │ 1               │ REFERENCES users(id)
           │                 │ ON DELETE CASCADE
           │                 │
           │ *               │
           ▼                 │
┌─────────────────────────┐  │
│      NOTIFIKASIS        │  │
├─────────────────────────┤  │
│ PK │ id          BIGINT│  │
│ FK │ user_id     BIGINT│──┼──────────────── REFERENCES users(id) ON DELETE CASCADE
│ FK │ event_id    BIGINT│──┘ ← NULLABLE, REFERENCES events(id) ON DELETE SET NULL
│    │ pesan       VARCHAR│
│    │ status      ENUM   │ ← 'unread','read'
│    │ created_at  TIMESTAMP│
│    │ updated_at  TIMESTAMP│
└─────────────────────────┘
```

## Relationship Summary

| Relation | Type | Source Table | Target Table | Foreign Key | Constraint |
|----------|------|-------------|-------------|-------------|------------|
| User membuat Event | One to Many | users | events | created_by | ON DELETE CASCADE |
| User membuat Informasi | One to Many | users | informasis | dibuat_oleh | ON DELETE CASCADE |
| User menerima Notifikasi | One to Many | users | notifikasis | user_id | ON DELETE CASCADE |
| Event memiliki Notifikasi | One to Many | events | notifikasis | event_id | ON DELETE SET NULL |

## Cardinality Diagram

```
   ┌─────────┐          ┌─────────┐
   │  USERS  │1────────*│  EVENTS │
   └─────────┘          └─────────┘
        │
        │1
        │
        │               ┌─────────────┐
        ├──────────────*│ INFORMASIS  │
        │               └─────────────┘
        │1
        │
        │               ┌──────────────┐
        └──────────────*│ NOTIFIKASIS  │
                        └──────────────┘
                              ↑*
                              │
                              │1
                           ┌─────────┐
                           │  EVENTS │
                           └─────────┘
```

## Integrity Constraints Summary

### Primary Keys (PK)
- `users.id`
- `events.id`
- `informasis.id`
- `notifikasis.id`

### Foreign Keys (FK)
- `events.created_by` → `users.id` (CASCADE on delete)
- `informasis.dibuat_oleh` → `users.id` (CASCADE on delete)
- `notifikasis.user_id` → `users.id` (CASCADE on delete)
- `notifikasis.event_id` → `events.id` (SET NULL on delete)

### Unique Constraints
- `users.email`

### NOT NULL Constraints
- Semua kolom wajib diisi kecuali yang ditandai NULLABLE:
  - `events.deskripsi` (NULLABLE)
  - `notifikasis.event_id` (NULLABLE)

### Default Values
- `users.role` → `'mahasiswa'`
- `notifikasis.status` → `'unread'`
