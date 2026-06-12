import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/event_model.dart';

class RecommendationService {
  final ApiClient _api;

  RecommendationService(this._api);

  Future<Map<String, dynamic>> getRecommendedEvents({int limit = 10}) async {
    final response = await _api.get('/recommendations/events',
        queryParams: {'limit': limit.toString()});
    return response['data'] ?? {};
  }

  Future<void> trackEventView(int eventId) async {
    try {
      await _api.post('/events/$eventId/track-view');
    } catch (_) {}
  }

  Future<List<EventModel>> getRecommendedEventList({int limit = 10}) async {
    try {
      final data = await getRecommendedEvents(limit: limit);
      final events = data['events'] as List? ?? [];
      return events
          .whereType<Map<String, dynamic>>()
          .map((e) {
            try {
              return EventModel.fromJson(e);
            } catch (err) {
              debugPrint('Error parsing recommended event: $err');
              return null;
            }
          })
          .whereType<EventModel>()
          .toList();
    } catch (e) {
      debugPrint('getRecommendedEventList error: $e');
      return [];
    }
  }

  Future<List<String>> getUserInterests() async {
    try {
      final response = await _api.get('/users/me/interests');
      final data = response['data'] as List? ?? [];
      return data
          .map((e) => (e as Map<String, dynamic>)['category']?.toString() ?? '')
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveInterests(List<String> categories) async {
    await _api.post('/users/me/interests', body: {'categories': categories});
  }
}