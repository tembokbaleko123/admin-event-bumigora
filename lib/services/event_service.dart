import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/models/event_registration.dart';

class EventService {
  final ApiClient _api;

  EventService(this._api);

  Future<({List<EventModel> items, bool hasMore, int currentPage})> getEventsPage({
    String? search,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? lokasi,
    String? kategori,
    String? status,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };
    if (search != null) queryParams['search'] = search;
    if (tanggalMulai != null) queryParams['tanggal_mulai'] = tanggalMulai;
    if (tanggalSelesai != null) queryParams['tanggal_selesai'] = tanggalSelesai;
    if (lokasi != null) queryParams['lokasi'] = lokasi;
    if (kategori != null) queryParams['kategori'] = kategori;
    if (status != null) queryParams['status'] = status;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;

    final response = await _api.get('/events', queryParams: queryParams);
    final meta = response['meta'];
    return (
      items: ApiClient.extractList(response['data'], EventModel.fromJson),
      hasMore: meta is Map && meta['has_more'] == true,
      currentPage: meta is Map ? (meta['current_page'] as int? ?? page) : page,
    );
  }

  Future<EventModel> getEventDetail(int id) async {
    final response = await _api.get('/events/$id');
    final data = response['data'];
    if (data == null) throw ApiException('Detail event tidak ditemukan');
    return EventModel.fromJson(data);
  }

  Future<EventModel> createEvent({
    required String judul,
    required String tanggal,
    required String lokasi,
    String? deskripsi,
    String? kategori,
    int? kapasitas,
    String? tanggalSelesai,
    String? batasDaftar,
    List<int>? gambar,
  }) async {
    final body = <String, dynamic>{
      'judul': judul,
      'tanggal': tanggal,
      'lokasi': lokasi,
    };
    if (deskripsi != null) body['deskripsi'] = deskripsi;
    if (kategori != null) body['kategori'] = kategori;
    if (kapasitas != null) body['kapasitas'] = kapasitas;
    if (tanggalSelesai != null) body['tanggal_selesai'] = tanggalSelesai;
    if (batasDaftar != null) body['batas_daftar'] = batasDaftar;

    final hasGambar = gambar != null && gambar.isNotEmpty;
    if (gambar != null) body['gambar'] = gambar;

    final response = await _api.post('/events', body: body, isFormData: hasGambar);
    final data = response['data'];
    if (data == null) throw ApiException('Gagal membuat event');
    return EventModel.fromJson(data);
  }

  Future<EventModel> updateEvent({
    required int id,
    String? judul,
    String? tanggal,
    String? tanggalSelesai,
    String? batasDaftar,
    String? lokasi,
    String? deskripsi,
    String? kategori,
    int? kapasitas,
    List<int>? gambar,
    bool hapusGambar = false,
  }) async {
    final body = <String, dynamic>{};
    if (judul != null) body['judul'] = judul;
    if (tanggal != null) body['tanggal'] = tanggal;
    if (lokasi != null) body['lokasi'] = lokasi;
    if (deskripsi != null) body['deskripsi'] = deskripsi;
    if (kategori != null) body['kategori'] = kategori;
    if (kapasitas != null) body['kapasitas'] = kapasitas;
    if (tanggalSelesai != null) body['tanggal_selesai'] = tanggalSelesai;
    if (batasDaftar != null) body['batas_daftar'] = batasDaftar;

    final hasGambar = gambar != null && gambar.isNotEmpty;
    if (gambar != null) body['gambar'] = gambar;
    if (hapusGambar) body['hapus_gambar'] = true;

    final response = await _api.put('/events/$id', body: body, isFormData: hasGambar);
    final data = response['data'];
    if (data == null) throw ApiException('Gagal mengupdate event');
    return EventModel.fromJson(data);
  }

  Future<void> deleteEvent(int id) async {
    await _api.delete('/events/$id');
  }

  Future<EventModel> approveEvent(int id) async {
    final response = await _api.put('/events/$id/approve');
    final data = response['data'];
    if (data == null) throw ApiException('Gagal menyetujui event');
    return EventModel.fromJson(data);
  }

  Future<EventModel> rejectEvent(int id) async {
    final response = await _api.put('/events/$id/reject');
    final data = response['data'];
    if (data == null) throw ApiException('Gagal menolak event');
    return EventModel.fromJson(data);
  }

  Future<Map<String, dynamic>> registerEvent(int eventId) async {
    final response = await _api.post('/events/$eventId/register');
    return response;
  }

  Future<void> cancelRegistration(int eventId) async {
    await _api.delete('/events/$eventId/register');
  }

  Future<Map<String, dynamic>> checkRegistration(int eventId) async {
    final response = await _api.get('/events/$eventId/check-registration');
    return response;
  }

  Future<({List<EventRegistration> items, bool hasMore, int currentPage})> getMyEventsPage({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _api.get('/users/me/events', queryParams: {
      'per_page': perPage.toString(),
      'page': page.toString(),
    });
    final meta = response['meta'];
    return (
      items: ApiClient.extractList(response['data'], EventRegistration.fromJson),
      hasMore: meta is Map && meta['has_more'] == true,
      currentPage: meta is Map ? (meta['current_page'] as int? ?? page) : page,
    );
  }

  Future<({List<EventRegistration> items, bool hasMore, int currentPage})> getParticipantsPage(
    int eventId, {
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _api.get('/events/$eventId/participants', queryParams: queryParams);
    final meta = response['meta'];
    return (
      items: ApiClient.extractList(response['data'], EventRegistration.fromJson),
      hasMore: meta is Map && meta['has_more'] == true,
      currentPage: meta is Map ? (meta['current_page'] as int? ?? page) : page,
    );
  }

  Future<List<EventRegistration>> getParticipants(int eventId,
      {String? status, int perPage = 50}) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
    };
    if (status != null) queryParams['status'] = status;

    return _api.getAllPages('/events/$eventId/participants',
        queryParams: queryParams, fromJson: EventRegistration.fromJson);
  }
}
