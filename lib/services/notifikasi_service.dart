import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/notifikasi_model.dart';

class NotifikasiService {
  final ApiClient _api;

  NotifikasiService(this._api);

  Future<List<NotifikasiModel>> getNotifikasis({int perPage = 50}) async {
    return _api.getAllPages('/notifikasis', queryParams: {
      'per_page': perPage.toString(),
    }, fromJson: NotifikasiModel.fromJson);
  }

  Future<List<NotifikasiModel>> getUnreadNotifikasis({int perPage = 50}) async {
    return _api.getAllPages('/notifikasis/unread', queryParams: {
      'per_page': perPage.toString(),
    }, fromJson: NotifikasiModel.fromJson);
  }

  Future<int> getUnreadCount() async {
    final response = await _api.get('/notifikasis/unread/count');
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Format tidak valid');
    return (data['count'] as int?) ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _api.put('/notifikasis/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.put('/notifikasis/read-all');
  }

  Future<void> deleteNotifikasi(int id) async {
    await _api.delete('/notifikasis/$id');
  }
}
