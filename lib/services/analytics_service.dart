import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/analytics.dart';

class AnalyticsService {
  final ApiClient _api;

  AnalyticsService(this._api);

  Future<DashboardOverview> getDashboardOverview() async {
    final response = await _api.get('/dashboard/overview');
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Data dashboard tidak valid');
    }
    return DashboardOverview.fromJson(data);
  }

  Future<AnalyticsSummary> getAdminSummary() async {
    final response = await _api.get('/admin/analytics/summary');
    return AnalyticsSummary.fromJson(response['data'] ?? {});
  }

  Future<List<dynamic>> getAdminEvents({int perPage = 50}) async {
    return _api.getAllPages('/admin/analytics/events',
        queryParams: {'per_page': perPage.toString()},
        fromJson: (json) => json);
  }

  Future<LecturerSummary> getLecturerSummary() async {
    final response = await _api.get('/lecturer/analytics/events');
    final summary = response['summary'] as Map<String, dynamic>? ?? {};
    return LecturerSummary.fromJson(summary);
  }

  Future<List<dynamic>> getLecturerEvents({int perPage = 50}) async {
    return _api.getAllPages('/lecturer/analytics/events',
        queryParams: {'per_page': perPage.toString()},
        fromJson: (json) => json);
  }

  Future<Map<String, dynamic>> getEventAnalytics(int eventId) async {
    final response = await _api.get('/events/$eventId/analytics');
    return response['data'] ?? {};
  }
}
