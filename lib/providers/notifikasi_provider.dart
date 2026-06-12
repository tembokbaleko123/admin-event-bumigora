import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/models/notifikasi_model.dart';
import 'package:aplikasi_kampus/services/notifikasi_service.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Notifikasi provider with proper state management
class NotifikasiProvider extends SafeChangeNotifier {
  final NotifikasiService _service;
  List<NotifikasiModel> _notifikasis = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  NotifikasiProvider(this._service);

  List<NotifikasiModel> get notifikasis => _notifikasis;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListenersImmediate();

    try {
      _notifikasis = await _service.getNotifikasis();
      _unreadCount = await _service.getUnreadCount();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Notifikasi load API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      debugPrint('Notifikasi load error: $e');
    }

    _loading = false;
    notifyListenersImmediate();
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
      notifyListenersImmediate();
    } on ApiException catch (e) {
      _error = e.message;
      debugPrint('Unread count API error: $e');
    } catch (e) {
      _error = ErrorParser.parse(e);
      debugPrint('Unread count error: $e');
    }
  }

  void setUnreadCount(int count) {
    if (_unreadCount == count) return;
    _unreadCount = count;
    notifyListenersImmediate();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      await load();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      await load();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  Future<bool> delete(int id) async {
    try {
      NotifikasiModel? deleted;
      for (final n in _notifikasis) {
        if (n.id == id) {
          deleted = n;
          break;
        }
      }
      await _service.deleteNotifikasi(id);
      _notifikasis.removeWhere((n) => n.id == id);
      if (deleted?.isUnread == true && _unreadCount > 0) {
        _unreadCount -= 1;
      }
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
