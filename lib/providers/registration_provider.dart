import 'package:aplikasi_kampus/models/event_registration.dart';
import 'package:aplikasi_kampus/services/event_service.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Registration provider with proper state management
class RegistrationProvider extends SafeChangeNotifier {
  final EventService _eventService;

  RegistrationProvider(this._eventService);

  final Map<int, bool> _registrationStatus = {};
  final Map<int, String?> _registrationStatusText = {};
  final Map<int, EventRegistration?> _registrations = {};
  bool _isLoading = false;
  String? _error;
  List<EventRegistration> _myEvents = [];
  List<EventRegistration> _participants = [];
  int _participantsCurrentPage = 1;
  bool _participantsHasMore = false;
  bool _participantsLoadingMore = false;
  int _myEventsCurrentPage = 1;
  bool _myEventsHasMore = false;
  bool _myEventsLoadingMore = false;

  Map<int, bool> get registrationStatus => _registrationStatus;
  Map<int, String?> get registrationStatusText => _registrationStatusText;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EventRegistration> get myEvents => _myEvents;
  List<EventRegistration> get participants => _participants;
  bool get participantsHasMore => _participantsHasMore;
  bool get participantsLoadingMore => _participantsLoadingMore;
  bool get myEventsHasMore => _myEventsHasMore;
  bool get myEventsLoadingMore => _myEventsLoadingMore;

  bool isRegistered(int eventId) => _registrationStatus[eventId] ?? false;
  String? registrationStatusFor(int eventId) => _registrationStatusText[eventId];

  Future<bool> register(int eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      await _eventService.registerEvent(eventId);
      _registrationStatus[eventId] = true;
      _registrationStatusText[eventId] = AppStrings.statusRegistered;

      _isLoading = false;
      notifyListenersImmediate();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      _error = ErrorParser.parse(e);
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    }
  }

  Future<bool> cancel(int eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      await _eventService.cancelRegistration(eventId);
      _registrationStatus[eventId] = false;
      _registrationStatusText[eventId] = AppStrings.statusCancelled;

      _isLoading = false;
      notifyListenersImmediate();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      _error = ErrorParser.parse(e);
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    }
  }

  Future<void> checkRegistration(int eventId) async {
    try {
      final response = await _eventService.checkRegistration(eventId);
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        _registrationStatus[eventId] = data['is_registered'] ?? false;
        _registrationStatusText[eventId] = data['status']?.toString();
        if (data['registration'] != null && data['registration'] is Map<String, dynamic>) {
          _registrations[eventId] = EventRegistration.fromJson(data['registration']);
        }
      }
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  Future<void> loadMyEvents() async {
    _isLoading = true;
    _error = null;
    _myEventsLoadingMore = false;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getMyEventsPage();
      _myEvents = result.items;
      _myEventsCurrentPage = result.currentPage;
      _myEventsHasMore = result.hasMore;
      _isLoading = false;
      notifyListenersImmediate();
    } on ApiException catch (e) {
      _error = e.message;
      _myEventsHasMore = false;
      _isLoading = false;
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      _myEventsHasMore = false;
      _isLoading = false;
      notifyListenersImmediate();
    }
  }

  Future<void> loadMoreMyEvents() async {
    if (_myEventsLoadingMore || !_myEventsHasMore || _isLoading) return;

    _myEventsLoadingMore = true;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getMyEventsPage(page: _myEventsCurrentPage + 1);
      _myEvents = [..._myEvents, ...result.items];
      _myEventsCurrentPage = result.currentPage;
      _myEventsHasMore = result.hasMore;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = ErrorParser.parse(e);
    } finally {
      _myEventsLoadingMore = false;
      notifyListenersImmediate();
    }
  }

  Future<void> loadParticipants(int eventId, {String? status}) async {
    _isLoading = true;
    _error = null;
    _participantsCurrentPage = 1;
    _participantsHasMore = false;
    _participantsLoadingMore = false;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getParticipantsPage(eventId, status: status);
      _participants = result.items;
      _participantsCurrentPage = result.currentPage;
      _participantsHasMore = result.hasMore;
      _isLoading = false;
      notifyListenersImmediate();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      _isLoading = false;
      notifyListenersImmediate();
    }
  }

  Future<void> loadMoreParticipants(int eventId, {String? status}) async {
    if (_participantsLoadingMore || !_participantsHasMore || _isLoading) return;

    _participantsLoadingMore = true;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getParticipantsPage(eventId, status: status, page: _participantsCurrentPage + 1);
      _participants = [..._participants, ...result.items];
      _participantsCurrentPage = result.currentPage;
      _participantsHasMore = result.hasMore;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = ErrorParser.parse(e);
    } finally {
      _participantsLoadingMore = false;
      notifyListenersImmediate();
    }
  }

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}
