import 'package:intl/intl.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/attendance.dart';

class AttendanceService {
  final ApiClient _api;

  AttendanceService(this._api);

  Future<Map<String, dynamic>> generateQr(int eventId, {int duration = 120}) async {
    return _api.post('/events/$eventId/qr', body: {'duration': duration});
  }

  Future<ActiveQrToken> getActiveQr(int eventId) async {
    final response = await _api.get('/events/$eventId/qr');
    return ActiveQrToken.fromJson(response['data'] ?? {});
  }

  Future<Map<String, dynamic>> scanAttendance(int eventId, String qrToken) async {
    return _api.post('/events/$eventId/attendance/scan', body: {'qr_token': qrToken});
  }

  Future<Map<String, dynamic>> markManualAttendance(int eventId, int userId, String status) async {
    return _api.post('/events/$eventId/attendance/manual', body: {
      'user_id': userId,
      'status': status,
    });
  }

  Future<Map<String, dynamic>> checkAttendance(int eventId) async {
    return _api.get('/events/$eventId/attendance/check');
  }

  Future<List<int>> exportCsv(int eventId, {DateTime? tanggalMulai, DateTime? tanggalSelesai}) async {
    final queryParams = <String, String>{};
    if (tanggalMulai != null) queryParams['tanggal_mulai'] = DateFormat('yyyy-MM-dd').format(tanggalMulai);
    if (tanggalSelesai != null) queryParams['tanggal_selesai'] = DateFormat('yyyy-MM-dd').format(tanggalSelesai);
    final response = await _api.getRaw('/events/$eventId/attendance/csv', queryParams: queryParams);
    return response.bodyBytes.toList();
  }

  Future<List<Attendance>> getAttendanceReport(int eventId, {String? status, int perPage = 50, DateTime? tanggalMulai, DateTime? tanggalSelesai}) async {
    final queryParams = <String, String>{'per_page': perPage.toString()};
    if (status != null) queryParams['status'] = status;
    if (tanggalMulai != null) queryParams['tanggal_mulai'] = DateFormat('yyyy-MM-dd').format(tanggalMulai);
    if (tanggalSelesai != null) queryParams['tanggal_selesai'] = DateFormat('yyyy-MM-dd').format(tanggalSelesai);

    return _api.getAllPages('/events/$eventId/attendance',
        queryParams: queryParams, fromJson: Attendance.fromJson);
  }
}
