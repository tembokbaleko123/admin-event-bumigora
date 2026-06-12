import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/services/event_service.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

enum LoadState { idle, loading, loaded, error }

/// Event provider with proper state management and error handling
class EventProvider extends SafeChangeNotifier {
  final EventService _eventService;
  List<EventModel> _events = [];
  List<EventModel> _allEvents = [];
  LoadState _state = LoadState.idle;
  String? _error;
  String _searchQuery = '';
  int _requestId = 0;
  String? _activeSearch;
  String? _activeKategori;
  String? _activeStatus;
  String? _activeTanggalMulai;
  String? _activeTanggalSelesai;
  String? _activeSortBy;
  String? _activeSortOrder;
  int _currentPage = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  bool _detailLoading = false;

  EventProvider(this._eventService);

  List<EventModel> get events => _events;
  List<EventModel> get allEvents =>
      _allEvents.isNotEmpty ? _allEvents : _events;
  LoadState get state => _state;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get detailLoading => _detailLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListenersImmediate();
  }

  /// Load events with caching and deduplication
  Future<void> loadEvents({
    String? search,
    String? kategori,
    String? status,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? sortBy,
    String? sortOrder,
    bool force = false,
  }) async {
    final effectiveSearch = search ?? _searchQuery;

    if (!force &&
        _activeSearch == effectiveSearch &&
        _activeKategori == kategori &&
        _activeStatus == status &&
        _activeTanggalMulai == tanggalMulai &&
        _activeTanggalSelesai == tanggalSelesai &&
        _activeSortBy == sortBy &&
        _activeSortOrder == sortOrder &&
        (_state == LoadState.loading || _state == LoadState.loaded)) {
      return;
    }

    final requestId = ++_requestId;
    _activeSearch = effectiveSearch;
    _activeKategori = kategori;
    _activeStatus = status;
    _activeTanggalMulai = tanggalMulai;
    _activeTanggalSelesai = tanggalSelesai;
    _activeSortBy = sortBy;
    _activeSortOrder = sortOrder;
    _state = LoadState.loading;
    _error = null;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getEventsPage(
        search: effectiveSearch,
        kategori: kategori,
        status: status,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (requestId != _requestId) return;

      _events = result.items;
      _currentPage = result.currentPage;
      _hasMore = result.hasMore;
      if (effectiveSearch.isEmpty && kategori == null && status == null && tanggalMulai == null && tanggalSelesai == null) {
        _allEvents = List.from(result.items);
      }
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      if (requestId != _requestId) return;
      _error = e.message;
      _state = LoadState.error;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = ErrorParser.parse(e);
      _state = LoadState.error;
    }
    notifyListenersImmediate();
  }

  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore || _state == LoadState.loading) return;

    _isLoadingMore = true;
    notifyListenersImmediate();

    try {
      final result = await _eventService.getEventsPage(
        search: _activeSearch,
        kategori: _activeKategori,
        status: _activeStatus,
        tanggalMulai: _activeTanggalMulai,
        tanggalSelesai: _activeTanggalSelesai,
        sortBy: _activeSortBy,
        sortOrder: _activeSortOrder,
        page: _currentPage + 1,
      );

      _events = [..._events, ...result.items];
      _currentPage = result.currentPage;
      _hasMore = result.hasMore;
      if ((_activeSearch ?? '').isEmpty && _activeKategori == null && _activeStatus == null) {
        _allEvents = List.from(_events);
      }
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (e) {
      _error = ErrorParser.parse(e);
      _state = LoadState.error;
    } finally {
      _isLoadingMore = false;
      notifyListenersImmediate();
    }
  }

  Future<EventModel?> getDetail(int id) async {
    _detailLoading = true;
    notifyListenersImmediate();
    try {
      final result = await _eventService.getEventDetail(id);
      return result;
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
    } finally {
      _detailLoading = false;
      notifyListenersImmediate();
    }
  }

  Future<bool> createEvent({
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
    try {
      await _eventService.createEvent(
        judul: judul,
        tanggal: tanggal,
        lokasi: lokasi,
        deskripsi: deskripsi,
        kategori: kategori,
        kapasitas: kapasitas,
        tanggalSelesai: tanggalSelesai,
        batasDaftar: batasDaftar,
        gambar: gambar,
      );
      await loadEvents(force: true);
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

  Future<bool> updateEvent({
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
    try {
      await _eventService.updateEvent(
        id: id,
        judul: judul,
        tanggal: tanggal,
        tanggalSelesai: tanggalSelesai,
        batasDaftar: batasDaftar,
        lokasi: lokasi,
        deskripsi: deskripsi,
        kategori: kategori,
        kapasitas: kapasitas,
        gambar: gambar,
        hapusGambar: hapusGambar,
      );
      await loadEvents(
        search: _activeSearch,
        kategori: _activeKategori,
        status: _activeStatus,
        force: true,
      );
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

  Future<bool> deleteEvent(int id) async {
    try {
      await _eventService.deleteEvent(id);
      _events.removeWhere((e) => e.id == id);
      _allEvents.removeWhere((e) => e.id == id);
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

  Future<bool> approveEvent(int id) async {
    try {
      await _eventService.approveEvent(id);
      await loadEvents(
        search: _activeSearch,
        kategori: _activeKategori,
        status: _activeStatus,
        force: true,
      );
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

  Future<bool> rejectEvent(int id) async {
    try {
      await _eventService.rejectEvent(id);
      await loadEvents(
        search: _activeSearch,
        kategori: _activeKategori,
        status: _activeStatus,
        force: true,
      );
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

  List<EventModel> eventsForDate(DateTime date) {
    return _events.where((e) {
      try {
        final eventDate = DateTime.parse(e.tanggal);
        return eventDate.year == date.year &&
            eventDate.month == date.month &&
            eventDate.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}
