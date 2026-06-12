import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/services/analytics_service.dart';
import 'package:aplikasi_kampus/models/analytics.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Analytics provider with proper state management
class AnalyticsProvider extends SafeChangeNotifier {
  final AnalyticsService _service;
  bool _isLoading = false;
  bool _isOverviewLoading = false;
  AnalyticsSummary? _summary;
  DashboardOverview? _overview;
  LecturerSummary? _lecturerSummary;
  List<dynamic> _lecturerEvents = [];
  EventAnalytics? _eventAnalytics;
  bool _eventAnalyticsLoading = false;
  String? _error;

  AnalyticsProvider(this._service);

  bool get isLoading => _isLoading;
  EventAnalytics? get eventAnalytics => _eventAnalytics;
  bool get eventAnalyticsLoading => _eventAnalyticsLoading;
  bool get isOverviewLoading => _isOverviewLoading;
  AnalyticsSummary? get summary => _summary;
  DashboardOverview? get overview => _overview;
  LecturerSummary? get lecturerSummary => _lecturerSummary;
  List<dynamic> get lecturerEvents => _lecturerEvents;
  String? get error => _error;

  Future<void> loadDashboardOverview() async {
    _isOverviewLoading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _overview = await _service.getDashboardOverview();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Dashboard overview API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      debugPrint('Dashboard overview load error: $e');
    }

    _isOverviewLoading = false;
    notifyListenersImmediate();
  }

  Future<void> loadAdminSummary() async {
    _isLoading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _summary = await _service.getAdminSummary();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Admin summary load API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      debugPrint('Admin summary load error: $e');
    }

    _isLoading = false;
    notifyListenersImmediate();
  }

  Future<void> loadLecturerData() async {
    _isLoading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _lecturerSummary = await _service.getLecturerSummary();
      _lecturerEvents = await _service.getLecturerEvents();
    } on ApiException catch (e) {
      _error = e.message;
      _lecturerSummary = null;
      _lecturerEvents = [];
      debugPrint('Lecturer data load API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      _lecturerSummary = null;
      _lecturerEvents = [];
      debugPrint('Lecturer data load error: $e');
    }

    _isLoading = false;
    notifyListenersImmediate();
  }

  Future<void> loadEventAnalytics(int eventId) async {
    _eventAnalyticsLoading = true;
    _eventAnalytics = null;
    _error = null;
    notifyListenersImmediate();

    try {
      final data = await _service.getEventAnalytics(eventId);
      _eventAnalytics = EventAnalytics.fromJson(data);
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Event analytics API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      debugPrint('Event analytics load error: $e');
    }

    _eventAnalyticsLoading = false;
    notifyListenersImmediate();
  }

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}
