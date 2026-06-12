import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/services/recommendation_service.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Recommendation provider with build-safe state management
class RecommendationProvider extends SafeChangeNotifier {
  final RecommendationService _service;
  List<EventModel> _recommendedEvents = [];
  List<String> _interests = [];
  bool _loading = false;
  String? _error;

  RecommendationProvider(this._service);

  List<EventModel> get recommendedEvents => _recommendedEvents;
  List<String> get interests => _interests;
  bool get loading => _loading;
  String? get error => _error;

  /// Load recommended events
  Future<void> loadRecommendedEvents({int limit = 10}) async {
    _loading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _recommendedEvents = await _service.getRecommendedEventList(limit: limit);
    } on ApiException catch (e) {
      _error = e.message;
      _recommendedEvents = [];
      debugPrint('loadRecommendedEvents API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      _recommendedEvents = [];
      debugPrint('loadRecommendedEvents error: $e');
    }

    _loading = false;
    notifyListenersImmediate();
  }

  /// Load user interests
  Future<void> loadInterests() async {
    try {
      _interests = await _service.getUserInterests();
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      _interests = [];
      notifyListenersImmediate();
    }
  }

  /// Save user interests
  Future<void> saveInterests(List<String> categories) async {
    try {
      await _service.saveInterests(categories);
      _interests = List.from(categories);
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  /// Track event view for recommendation algorithm
  Future<void> trackEventView(int eventId) async {
    try {
      await _service.trackEventView(eventId);
    } catch (e) {
      // Silent fail - tracking should not interrupt user flow
      debugPrint('trackEventView error: $e');
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}