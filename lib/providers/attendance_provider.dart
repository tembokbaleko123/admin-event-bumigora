import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/models/attendance.dart';
import 'package:aplikasi_kampus/services/attendance_service.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Attendance provider with proper state management
class AttendanceProvider extends SafeChangeNotifier {
  final AttendanceService _attendanceService;

  AttendanceProvider(this._attendanceService);

  bool _isLoading = false;
  String? _error;
  final Map<int, bool> _attendanceStatus = {};
  ActiveQrToken? _activeQr;
  AttendanceSummary? _summary;
  List<Attendance> _attendances = [];
  Map<String, dynamic>? _lastScanResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ActiveQrToken? get activeQr => _activeQr;
  AttendanceSummary? get summary => _summary;
  List<Attendance> get attendances => _attendances;
  Map<String, dynamic>? get lastScanResult => _lastScanResult;

  bool hasAttended(int eventId) => _attendanceStatus[eventId] ?? false;

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }

  Future<bool> generateQr(int eventId, {int duration = 120}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      await _attendanceService.generateQr(eventId, duration: duration);
      await getActiveQr(eventId);

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

  Future<void> getActiveQr(int eventId) async {
    try {
      _activeQr = await _attendanceService.getActiveQr(eventId);
      notifyListenersImmediate();
    } on ApiException catch (e) {
      debugPrint('getActiveQr API error: $e');
      _activeQr = null;
    } catch (e) {
      debugPrint('getActiveQr error: $e');
      _activeQr = null;
    }
  }

  Future<bool> scanAttendance(int eventId, String qrToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      final response = await _attendanceService.scanAttendance(eventId, qrToken);
      _lastScanResult = response;
      _attendanceStatus[eventId] = true;

      _isLoading = false;
      notifyListenersImmediate();

      return response['status'] == true ||
          (response['data'] != null && response['data'] is Map && response['data']['status'] == true);
    } on ApiException catch (e) {
      _error = e.message;
      _lastScanResult = {'status': false, 'message': e.message};
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      final msg = ErrorParser.parse(e);
      _error = msg;
      _lastScanResult = {'status': false, 'message': msg};
      _isLoading = false;
      notifyListenersImmediate();
      return false;
    }
  }

  Future<bool> markManualAttendance(int eventId, int userId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      await _attendanceService.markManualAttendance(eventId, userId, status);

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

  Future<void> checkAttendance(int eventId) async {
    try {
      final response = await _attendanceService.checkAttendance(eventId);
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        _attendanceStatus[eventId] = data['has_attended'] ?? false;
      }
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  Future<List<int>?> exportCsv(int eventId, {DateTime? tanggalMulai, DateTime? tanggalSelesai}) async {
    try {
      return await _attendanceService.exportCsv(eventId, tanggalMulai: tanggalMulai, tanggalSelesai: tanggalSelesai);
    } catch (e) {
      debugPrint('exportCsv error: $e');
      return null;
    }
  }

  Future<void> loadReport(int eventId, {String? status, DateTime? tanggalMulai, DateTime? tanggalSelesai}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      _attendances = await _attendanceService.getAttendanceReport(
        eventId,
        status: status,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );

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
}
