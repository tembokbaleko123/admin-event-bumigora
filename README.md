# SIPENDEKA — Aplikasi Kampus (Flutter)

**SIPENDEKA** (Sistem Informasi Pendidikan & Event Akademik) is a Flutter-based mobile application for campus academic event management. It serves three user roles — **Mahasiswa (Student)**, **Dosen (Lecturer)**, and **Admin** — providing event discovery, registration, QR-based attendance, push notifications, analytics, and more.

> Built with Flutter 3.x + Dart SDK ^3.11.5  
> Backend: [admin-event-bumigora](https://github.com/tembokbaleko123/admin-event-bumigora) (Laravel API)

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Code Analysis](#code-analysis)
- [Project Structure](#project-structure)
- [Development Notes](#development-notes)
- [License](#license)

---

## Features

### Authentication & Onboarding
- Onboarding screen for first-time users
- Login/Register with role-based redirection (admin, dosen, mahasiswa)
- JWT-based auth with auto-refresh
- Offline-ready session via `SharedPreferences`

### Role-Based Dashboards
| Role | Home | Features |
|------|------|----------|
| **Mahasiswa** | `dashboard_mhs.dart` | Browse events, register, bookmark, scan QR, view timeline, see recommendations |
| **Dosen** | `dashboard_screen.dart` | Create/manage events, view event timeline, analytics, manage participants |
| **Admin** | `admin_navigation.dart` | Full CRUD events & informasi, manage users, attendance reports, platform analytics |

### Event Management
- **CRUD Events** — Create, edit, delete events with image upload, date/time, location, registration limits
- **Event Categories** — Filter by category, status, date range
- **Event Registration** — Students can register with approval workflow
- **QR Code Attendance** — Lecturers scan student QR codes; students show their QR
- **Registration Limits** — Admin sets max participants per event
- **Bookmark Events** — Students bookmark favorite events
- **Event Timelines** — Visual timeline of upcoming events on dashboard

### Attendance & Reporting
- QR-based attendance scanning (`mobile_scanner`)
- Attendance report with period filtering (daily, weekly, monthly, custom range)
- Export attendance data
- Real-time attendance status per event

### Notifications
- Push notifications via polling mechanism
- Web notification support (`Notification Web API`)
- Unread badge counter
- Notification list with read/unread status

### Information (Informasi)
- Admin can publish campus news/information
- Students/lecturers browse information list with detail view
- CRUD management for admin

### Analytics
- **Event Analytics** — Per-event: registrations, attendance rate, popular metrics
- **Lecturer Analytics** — Lecturer-specific event performance
- **Admin Analytics** — Platform-wide statistics (total events, users, registrations)

### Recommendation System
- Personalized event recommendations based on student interests
- Interest selection screen on first login
- `RecommendationService` powered by API

### UI/UX
- **Dark/Light Theme** toggle with persistent preference
- **Material 3 Design** with Poppins font (Google Fonts)
- **Shimmer Loading** placeholders for async data
- **Empty State Widgets** for no-data screens
- **Animated List Items** — Smooth fade/slide transitions
- **Toastification** animated toast notifications (replaces `SnackBar`)
- **Interactive Calendar** (`table_calendar`) for date-based event browsing
- **Confirmation Dialogs** on destructive actions (delete, status change)
- **PopScope Protection** prevents accidental back navigation on dirty forms
- **Form Validation** on event create/edit screens
- **Responsive Layout** utilities

### Admin-Only Features
- User management (role filter, create/edit users)
- Event management with search & date range filter
- Information (informasi) CRUD with search
- Participants screen per event with search
- Attendance reports with period filter
- Global platform analytics (SweetAlert2 popups in Blade admin)

---

## Tech Stack

| Category | Library / Tool |
|----------|----------------|
| **Framework** | Flutter 3.x |
| **State Management** | Provider ^6.1.5 |
| **Networking** | `http` ^1.6.0, `connectivity_plus` ^6.1.4 |
| **Local Storage** | `shared_preferences` ^2.5.5 |
| **Image Handling** | `cached_network_image` ^3.4.1, `image_picker` ^1.2.2 |
| **QR Code** | `mobile_scanner` ^6.0.6, `qr_flutter` ^4.1.0 |
| **Charts** | `fl_chart` ^0.70.2 |
| **Calendar** | `table_calendar` ^3.2.0 |
| **Shimmer** | `shimmer` ^3.0.0 |
| **Notifications** | `toastification` ^2.3.0 |
| **Sharing** | `share_plus` ^10.1.4 |
| **File System** | `path_provider` ^2.1.5 |
| **Date/Time** | `intl` ^0.20.2 |
| **Fonts** | `google_fonts` ^8.1.0 |
| **Icons** | `cupertino_icons` ^1.0.8 |

---

## Architecture

The app follows a **service-provider-ui** layered architecture:

```
UI Layer (Screens) 
    ↕ uses
Provider Layer (State Management - ChangeNotifier)
    ↕ calls
Service Layer (HTTP Client - API calls)
    ↕ communicates
API Client (HttpClient - centralized networking)
    ↕ 
Laravel Backend API (http://127.0.0.1:8000/api/v1/...)
```

### Key Architectural Decisions
- **Provider** for state management (lightweight, well-suited for this scope)
- **ApiClient** singleton with auto-retry, JWT header injection, 401 handling
- **DisposableNotifier** base class auto-disposes subscriptions
- **ConnectivityProvider** wraps `connectivity_plus` for offline banner
- **PushNotificationService** polls API for unread count with lifecycle-aware start/stop
- **Toastification** replaces all `SnackBar` calls via centralized `SnackbarHelper`

---

## Installation

### Prerequisites
- Flutter SDK >=3.11.5 ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK (bundled with Flutter)
- Laravel backend running at `http://127.0.0.1:8000` ([admin-event-bumigora](https://github.com/tembokbaleko123/admin-event-bumigora))

### Steps

```bash
# Clone the repository
git clone https://github.com/tembokbaleko123/admin-event-bumigora.git
cd admin-event-bumigora

# The Flutter app is on the flutter-integration branch
git checkout flutter-integration

# Install dependencies
flutter pub get

# Run on Chrome/web
flutter run -d chrome
```

---

## Configuration

### API Base URL

Configured in `lib/config/api_config.dart`:

| Environment | URL | Notes |
|-------------|-----|-------|
| Debug (web) | `http://127.0.0.1:8000/api` | Local dev |
| Debug (Android emulator) | `http://10.0.2.2:8000/api` | Android emulator loopback |
| Production | `http://127.0.0.1:8000/api` | Update before release |

Override at compile time:
```bash
flutter run --dart-define=API_BASE_URL=https://your-production.com/api
```

### Other Settings
- **Timeout**: 30s (120s for file uploads)
- **Max Retries**: 3
- **API Version**: `v1`
- **Health Endpoint**: `GET /api/health`

---

## Running the App

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run

# Build for production (web)
flutter build web

# Build for production (Android)
flutter build apk
```

### Development
```bash
# Run with dart-define for custom API
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.100:8000/api

# Profile build for performance testing
flutter run --profile
```

---

## Testing

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/

# Run widget tests only
flutter test test/widget/

# Run with coverage
flutter test --coverage
```

### Test Coverage
- **Unit Tests**: `api_client_test.dart`, `auth_provider_test.dart`, `validators_test.dart`
- **Widget Tests**: `widget_test.dart`, `scan_qr_screen_test.dart`

---

## Code Analysis

```bash
# Static analysis
dart analyze lib/

# Should output: 0 errors, 0 warnings (infos are acceptable)
```

The codebase passes `dart analyze lib/` with **0 errors, 0 warnings**.

---

## Project Structure

```
lib/
├── main.dart                      # App entry point, provider setup
├── splash_screen.dart             # Animated splash with health check
├── admin/
│   ├── admin_navigation.dart       # Admin bottom nav shell
│   ├── analytics_screen.dart       # Platform analytics
│   ├── attendance_report_screen.dart # Attendance with period filter
│   ├── manage_events.dart          # Event CRUD management
│   ├── manage_informasi.dart       # Information CRUD management
│   ├── manage_users.dart           # User management
│   └── participants_screen.dart    # Event participants
├── config/
│   └── api_config.dart             # API URL, timeouts, retries
├── core/
│   ├── base/
│   │   └── disposable_notifier.dart # Auto-dispose ChangeNotifier
│   ├── constants/
│   │   ├── app_colors.dart          # Color palette
│   │   └── app_strings.dart         # String constants
│   ├── network/
│   │   └── api_client.dart          # HTTP client with auth/retry
│   ├── storage/
│   │   └── local_storage.dart       # SharedPreferences wrapper
│   ├── theme/
│   │   ├── app_theme.dart           # Light/dark theme definitions
│   │   └── theme_extensions.dart    # Custom theme extensions
│   ├── utils/
│   │   ├── date_formatter.dart      # Date formatting helpers
│   │   ├── error_parser.dart        # Error message parsing
│   │   ├── responsive.dart          # Responsive breakpoints
│   │   ├── route_transitions.dart   # Page transition helpers
│   │   └── validators.dart          # Form validation rules
│   └── widgets/
│       ├── animated_list_item.dart  # Animated list entries
│       ├── date_badge.dart          # Date display badge
│       ├── empty_state_widget.dart  # Empty state placeholder
│       ├── error_display_widget.dart # Error display
│       ├── event_timeline.dart      # Visual event timeline
│       ├── offline_banner.dart      # Connectivity banner
│       ├── section_header.dart      # Section header widget
│       ├── shimmer_loading.dart     # Shimmer loading animation
│       ├── skeleton_card.dart       # Skeleton card loader
│       ├── skeleton_detail.dart     # Skeleton detail loader
│       ├── snackbar_helper.dart     # Toastification helper
│       ├── stat_item.dart           # Stat display item
│       └── widgets.dart             # Barrel export
├── func/
│   ├── bookmark_screen.dart         # Bookmarked events
│   ├── edit_profile.dart            # Edit user profile
│   ├── event_analytics_screen.dart  # Per-event analytics
│   ├── events.dart                  # Event creation/edit form
│   ├── informasi_detail.dart        # Information detail
│   ├── informasi_list.dart          # Information list
│   ├── interest_screen.dart         # Interest selection
│   ├── lecturer_analytics_screen.dart # Lecturer analytics
│   ├── notification.dart            # Notification list
│   ├── profile.dart                 # User profile screen
│   ├── scan_qr_screen.dart          # QR scanner (lecturer)
│   └── show_qr_screen.dart          # QR display (student)
├── InApp/
│   ├── dashboard_screen.dart        # Dosen dashboard
│   └── event_detail.dart            # Event detail view
├── logReg/
│   ├── login_screen.dart            # Login page
│   ├── onboarding.dart              # Onboarding carousel
│   └── register_screen.dart         # Registration page
├── mahasiswa/
│   ├── dashboard_mhs.dart           # Mahasiswa dashboard
│   └── my_events_screen.dart        # Student's registered events
├── models/
│   ├── analytics.dart               # Analytics data models
│   ├── attendance.dart              # Attendance model
│   ├── bookmark.dart                # Bookmark model
│   ├── creator.dart                 # Event creator model
│   ├── event_model.dart             # Event model
│   ├── event_registration.dart      # Registration model
│   ├── informasi_model.dart         # Information model
│   ├── notifikasi_model.dart        # Notification model
│   └── user_model.dart             # User model
├── Navigation/
│   ├── calendar.dart                # Interactive calendar
│   ├── event_card.dart              # Event card widget
│   ├── main_navigation_dosen.dart   # Dosen bottom nav
│   └── main_navigation_mahasiswa.dart # Mahasiswa bottom nav
├── providers/
│   ├── analytics_provider.dart      # Analytics state
│   ├── attendance_provider.dart     # Attendance state
│   ├── auth_provider.dart           # Authentication state
│   ├── bookmark_provider.dart       # Bookmark state
│   ├── event_provider.dart          # Event state
│   ├── informasi_provider.dart      # Information state
│   ├── notifikasi_provider.dart     # Notification state
│   ├── recommendation_provider.dart # Recommendation state
│   ├── registration_provider.dart   # Registration state
│   └── theme_provider.dart          # Theme toggle state
└── services/
    ├── analytics_service.dart       # Analytics API calls
    ├── attendance_service.dart      # Attendance API calls
    ├── auth_service.dart            # Auth API calls
    ├── bookmark_service.dart        # Bookmark API calls
    ├── event_service.dart           # Event API calls
    ├── informasi_service.dart       # Information API calls
    ├── notification_stub.dart       # Notification stub (non-web)
    ├── notification_web.dart        # Web Notification API
    ├── notifikasi_service.dart      # Notification API calls
    ├── push_notification_service.dart # Push notification poller
    ├── recommendation_service.dart  # Recommendation API calls
    └── user_service.dart            # User API calls
```

---

## API Endpoints

The app communicates with a Laravel backend at `/api/v1/...`. Key endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/v1/login` | Login |
| POST | `/api/v1/register` | Register |
| GET | `/api/v1/events` | List events |
| POST | `/api/v1/events` | Create event |
| GET | `/api/v1/events/{id}` | Event detail |
| PUT | `/api/v1/events/{id}` | Update event |
| DELETE | `/api/v1/events/{id}` | Delete event |
| GET | `/api/v1/informasi` | List information |
| POST | `/api/v1/informasi` | Create information |
| PUT | `/api/v1/informasi/{id}` | Update information |
| DELETE | `/api/v1/informasi/{id}` | Delete information |
| GET | `/api/v1/users` | List users (admin) |
| POST | `/api/v1/users` | Create user (admin) |
| POST | `/api/v1/attendance/scan` | Scan QR attendance |
| GET | `/api/v1/attendance/report` | Attendance report |
| GET | `/api/v1/analytics/events/{id}` | Event analytics |
| GET | `/api/v1/analytics/platform` | Platform analytics |
| GET | `/api/v1/recommendations` | Event recommendations |

---

## Development Notes

### Adding New Features
1. Create the model in `lib/models/`
2. Create the service in `lib/services/` for API calls
3. Create the provider in `lib/providers/` for state management
4. Create the UI screen in `lib/func/`, `lib/admin/`, or `lib/mahasiswa/`
5. Register the provider in `lib/main.dart` `MultiProvider`
6. Add navigation entry in the relevant shell widget

### Branching
- `flutter-integration` — Active Flutter development branch
- `master` — Laravel backend deployment branch
- `feat/api-integration` — Backend API integration branch

### Code Quality
- Run `dart analyze lib/` before committing
- Run `flutter test` to ensure all tests pass
- Follow the existing patterns (Provider, Service, Model layers)

### Backend
- The Laravel backend must be running on `http://127.0.0.1:8000`
- PHP 8.1+ is required (uses native enums: `EventStatus`, `RegistrationStatus`, `AttendanceStatus`, `UserRole`)
- Database migrations and seeders are in the backend repository

---

## License

This project is developed for academic purposes at **Universitas Bumigora**.