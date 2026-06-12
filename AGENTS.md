# AGENTS.md — Aplikasi Kampus (Flutter)

## Goal
Improve the Flutter `aplikasi_kampus` app across all aspects — UI/UX, admin features, image handling, data validation, and API integration — without introducing bugs.

## Constraints & Preferences
- Must run on Chrome/web via `flutter run -d chrome`.
- `dart analyze lib/` must pass with zero issues (infos are acceptable).
- API contract uses `/api/v1/...`.
- Useful features only; no OAuth/social login, chat, payment, GPS, microservices.

## Progress

### Completed
| # | Task | Files Touched | Status |
|---|------|---------------|--------|
| R5 | Calendar Interaktif (`table_calendar`) | `calendar.dart` | ✅ |
| R6 | Visual Timeline Jadwal (`EventTimeline`) | `event_timeline.dart`, `dashboard_screen.dart`, `dashboard_mhs.dart` | ✅ |
| R8 | Filter Laporan per Periode | `AttendanceController.php`, `attendance_report_screen.dart`, `attendance_service.dart`, `attendance_provider.dart` | ✅ |
| #1 | Event image display (detail + form preview) | `event_detail.dart`, `events.dart`, `main_navigation_dosen.dart` | ✅ |
| #2 | Confirmation dialogs (bookmark delete, status change) | `bookmark_screen.dart`, `participants_screen.dart` | ✅ |
| #3 | PopScope protection for forms | `edit_profile.dart`, `register_screen.dart`, `events.dart`, `main_navigation_dosen.dart` | ✅ |
| #4 | Informasi CRUD (create/update/delete) | `manage_informasi.dart`, `informasi_service.dart`, `informasi_provider.dart` | ✅ |
| #5 | Search bars on admin screens | `manage_informasi.dart`, `manage_users.dart`, `participants_screen.dart`, `manage_events.dart` | ✅ |
| #6 | Admin user management (role filter + create user) | `manage_users.dart`, `user_service.dart` | ✅ |
| #9 | Form validation (event create + edit) | `main_navigation_dosen.dart`, `events.dart` | ✅ |
| #10 | Manage events sort + date range filter | `manage_events.dart` | ✅ |
| Toastification | Replace all SnackBars with animated toast notifications | `pubspec.yaml`, `main.dart`, `snackbar_helper.dart`, `manage_events.dart`, `participants_screen.dart`, `attendance_report_screen.dart`, `events.dart`, `main_navigation_dosen.dart`, `notification.dart` | ✅ |
| SweetAlert2 | Replace native confirm() + Bootstrap alerts with Swal popups in Blade admin | `admin.blade.php`, `events/index.blade.php`, `events/show.blade.php`, `informasis/index.blade.php`, `users/index.blade.php` | ✅ |

### Completed (additional)
| # | Task | Status |
|---|------|--------|
| #5c | Search bar di `bookmark_screen.dart` | ✅ Already had search field + filtering |
| #7 | ShimmerLoading (replace CircularProgressIndicator) | ✅ All page-level loading use ShimmerLoading; remaining CPIs are load-more/button spinners |
| #8 | EmptyStateWidget (replace plain text) | ✅ All screens use EmptyStateWidget; dashboard_screen fixed |
| #11 | Health check integration (splash screen) | ✅ Splash hits `GET /api/health`; Laravel has route returning `{"status":true}` |
| #12 | Event detail analytics screen | ✅ `EventAnalyticsScreen`, `EventAnalytics` model, `loadEventAnalytics` provider, button in `event_detail.dart` |

## Key Decisions
- Used `table_calendar` (well-maintained, animated) instead of manual month grid.
- Used `cached_network_image` for image cache + placeholder + error handling.
- PopScope with `Uint8List.fromList` for image preview (cross-platform/web safe).
- Manage users create dialog uses `UserService.createUser()` with `POST /api/v1/users`.
- Date formatting uses string interpolation (`${year}-${month.padLeft(2,'0')}-...`) instead of `intl` package.
- PHP 8.1 native enums (`EventStatus`, `RegistrationStatus`, `AttendanceStatus`, `UserRole`) replace all hardcoded strings across backend.

## Verification
- `dart analyze lib/` — **0 errors, 0 warnings, 6 infos** (pre-existing).
- `php artisan test` — **41/41 passed**, 166 assertions.

## Paths
- Laravel backend: `D:\xampp\htdocs\Mobile Computing\admin-event-bumigora`
- Flutter app: `D:\xampp\htdocs\Mobile Computing\aplikasi_kampus`
- API root: `http://127.0.0.1:8000/api/v1`
