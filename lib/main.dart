import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'services/notifikasi_service.dart';
import 'services/informasi_service.dart';
import 'services/user_service.dart';
import 'services/attendance_service.dart';
import 'services/bookmark_service.dart';
import 'services/analytics_service.dart';
import 'services/recommendation_service.dart';
import 'services/push_notification_service.dart';

import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/informasi_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/theme_provider.dart';
import 'splash_screen.dart';
import 'core/widgets/offline_banner.dart';
import 'logReg/onboarding.dart';
import 'logReg/login_screen.dart';
import 'Navigation/main_navigation_mahasiswa.dart';
import 'Navigation/main_navigation_dosen.dart';
import 'admin/admin_navigation.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client with error handling
  ApiClient apiClient;
  try {
    apiClient = await ApiClient.init();
  } catch (e) {
    debugPrint('Failed to init ApiClient: $e');
    apiClient = ApiClient();
  }

  // Initialize all services
  final authService = AuthService(apiClient);
  final eventService = EventService(apiClient);
  final notifikasiService = NotifikasiService(apiClient);
  final informasiService = InformasiService(apiClient);
  final userService = UserService(apiClient);
  final attendanceService = AttendanceService(apiClient);
  final bookmarkService = BookmarkService(apiClient);
  final analyticsService = AnalyticsService(apiClient);
  final recommendationService = RecommendationService(apiClient);
  final pushNotificationService = PushNotificationService(apiClient);
  final themeProvider = ThemeProvider();

  // Check onboarding status
  bool onboardingComplete = false;
  try {
    onboardingComplete = await LocalStorage.isOnboardingComplete();
  } catch (e) {
    debugPrint('Failed to check onboarding status: $e');
  }

  // Initialize push notifications (non-blocking)
  try {
    await pushNotificationService.initialize();
  } catch (e) {
    debugPrint('Push notification init error: $e');
  }

  // Load theme preference
  try {
    await themeProvider.load();
  } catch (e) {
    debugPrint('Theme load error: $e');
  }

  // Run app
  runApp(
    MyApp(
      authService: authService,
      eventService: eventService,
      notifikasiService: notifikasiService,
      informasiService: informasiService,
      userService: userService,
      attendanceService: attendanceService,
      bookmarkService: bookmarkService,
      analyticsService: analyticsService,
      recommendationService: recommendationService,
      pushNotificationService: pushNotificationService,
      themeProvider: themeProvider,
      onboardingComplete: onboardingComplete,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final EventService eventService;
  final NotifikasiService notifikasiService;
  final InformasiService informasiService;
  final UserService userService;
  final AttendanceService attendanceService;
  final BookmarkService bookmarkService;
  final AnalyticsService analyticsService;
  final RecommendationService recommendationService;
  final PushNotificationService pushNotificationService;
  final ThemeProvider themeProvider;
  final bool onboardingComplete;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({
    super.key,
    required this.authService,
    required this.eventService,
    required this.notifikasiService,
    required this.informasiService,
    required this.userService,
    required this.attendanceService,
    required this.bookmarkService,
    required this.analyticsService,
    required this.recommendationService,
    required this.pushNotificationService,
    required this.themeProvider,
    required this.onboardingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => EventProvider(eventService)),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider(notifikasiService)),
        ChangeNotifierProvider(create: (_) => InformasiProvider(informasiService)),
        ChangeNotifierProvider(create: (_) => RegistrationProvider(eventService)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(attendanceService)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(bookmarkService)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(analyticsService)),
        ChangeNotifierProvider(create: (_) => RecommendationProvider(recommendationService)),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: 'SIPENDEKA - Informasi Pendidikan & Event Akademik',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.mode,
              home: SplashScreen(
                onComplete: () {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => _AppShell(
                        pushNotificationService: pushNotificationService,
                        userService: userService,
                        onboardingComplete: onboardingComplete,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  final PushNotificationService pushNotificationService;
  final UserService userService;
  final bool onboardingComplete;

  const _AppShell({
    required this.pushNotificationService,
    required this.userService,
    required this.onboardingComplete,
  });

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with WidgetsBindingObserver {
  AuthProvider? _auth;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeAuth();
    });
  }

  void _initializeAuth() {
    if (!mounted) return;

    _auth = context.read<AuthProvider>();
    _auth!.addListener(_onAuthChanged);
    widget.pushNotificationService.onUnreadCountChanged = (count) {
      if (mounted) {
        context.read<NotifikasiProvider>().setUnreadCount(count);
      }
    };

    ApiClient.onUnauthorized = () {
      if (mounted) {
        _auth?.logout();
      }
    };

    if (_auth!.status == AuthStatus.authenticated) {
      widget.pushNotificationService.startPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _auth?.removeListener(_onAuthChanged);
    widget.pushNotificationService.onUnreadCountChanged = null;
    widget.pushNotificationService.stopPolling();
    _auth = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.pushNotificationService.stopPolling();
    } else if (state == AppLifecycleState.resumed &&
        _auth?.status == AuthStatus.authenticated) {
      widget.pushNotificationService.startPolling();
    }
  }

  void _onAuthChanged() {
    final auth = _auth;
    if (auth == null || !mounted) return;

    if (auth.status == AuthStatus.authenticated && !_isNavigating) {
      _isNavigating = true;
      widget.pushNotificationService.startPolling();
      // Reset navigation flag after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _isNavigating = false;
      });
    } else if (auth.status == AuthStatus.unauthenticated) {
      widget.pushNotificationService.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final auth = context.watch<AuthProvider>();

        if (auth.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat...'),
                ],
              ),
            ),
          );
        }

        if (auth.status == AuthStatus.authenticated) {
          final role = auth.user?.role;
          if (role == 'admin') {
            return _AdminShell(userService: widget.userService);
          }
          if (role == 'dosen') {
            return const _DosenShell();
          }
          return const _MahasiswaShell();
        }

        return widget.onboardingComplete
            ? const LoginScreen()
            : const OnboardingScreen();
      },
    );
  }
}

/// Separate widget for mahasiswa navigation
/// Prevents mouse_tracker assertion on Flutter web
class _MahasiswaShell extends StatelessWidget {
  const _MahasiswaShell();

  @override
  Widget build(BuildContext context) {
    return const MainNavigationStudent();
  }
}

/// Separate widget for admin navigation
class _AdminShell extends StatelessWidget {
  final UserService userService;

  const _AdminShell({required this.userService});

  @override
  Widget build(BuildContext context) {
    return AdminNavigation(userService: userService);
  }
}

/// Separate widget for dosen navigation
class _DosenShell extends StatelessWidget {
  const _DosenShell();

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}
