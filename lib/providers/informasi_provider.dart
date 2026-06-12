import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/services/informasi_service.dart';
import 'package:aplikasi_kampus/models/informasi_model.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Informasi provider with proper state management
class InformasiProvider extends SafeChangeNotifier {
  final InformasiService _informasiService;
  List<InformasiModel> _informasiList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  InformasiProvider(this._informasiService);

  List<InformasiModel> get informasiList => _informasiList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInformasi({bool force = false}) async {
    if (force) _currentPage = 1;
    _isLoading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _informasiList = await _informasiService.getInformasi(page: _currentPage);
      _hasMore = _informasiList.length >= 10;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = ErrorParser.parse(e);
    }

    _isLoading = false;
    notifyListenersImmediate();
  }

  Future<void> loadMoreInformasi() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListenersImmediate();

    try {
      _currentPage++;
      final more = await _informasiService.getInformasi(page: _currentPage);
      _hasMore = more.length >= 10;
      _informasiList.addAll(more);
    } on ApiException catch (e) {
      _currentPage--;
      _error = e.message;
    } catch (e) {
      _currentPage--;
      _error = ErrorParser.parse(e);
    }

    _isLoadingMore = false;
    notifyListenersImmediate();
  }

  Future<InformasiModel?> getDetail(int id) async {
    try {
      return await _informasiService.getInformasiDetail(id);
    } on ApiException catch (e) {
      debugPrint('getDetail API error: $e');
      _error = e.message;
      notifyListenersImmediate();
      return null;
    } catch (e) {
      debugPrint('getDetail error: $e');
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
      return null;
    }
  }

  Future<bool> createInformasi({
    required String judul,
    required String isi,
    required String tanggal,
  }) async {
    try {
      await _informasiService.createInformasi(
        judul: judul,
        isi: isi,
        tanggal: tanggal,
      );
      await loadInformasi();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
      return false;
    }
  }

  Future<bool> updateInformasi({
    required int id,
    String? judul,
    String? isi,
    String? tanggal,
  }) async {
    try {
      await _informasiService.updateInformasi(
        id: id,
        judul: judul,
        isi: isi,
        tanggal: tanggal,
      );
      await loadInformasi();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
      return false;
    }
  }

  Future<bool> deleteInformasi(int id) async {
    try {
      await _informasiService.deleteInformasi(id);
      _informasiList.removeWhere((i) => i.id == id);
      notifyListenersImmediate();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListenersImmediate();
      return false;
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}