import 'package:aplikasi_kampus/models/bookmark.dart';
import 'package:aplikasi_kampus/services/bookmark_service.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

/// Bookmark provider with proper state management
class BookmarkProvider extends SafeChangeNotifier {
  final BookmarkService _bookmarkService;

  BookmarkProvider(this._bookmarkService);

  final Map<String, bool> _bookmarkStatus = {};
  final Map<String, int> _bookmarkIds = {};
  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  Map<String, bool> get bookmarkStatus => _bookmarkStatus;
  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isBookmarked(String type, int id) {
    return _bookmarkStatus[_key(type, id)] ?? false;
  }

  String _key(String type, int id) => '${type}_$id';

  Future<void> checkStatus(String type, int id) async {
    try {
      final data = await _bookmarkService.checkStatus(type, id);
      _bookmarkStatus[_key(type, id)] = data['is_bookmarked'] ?? false;
      final bmId = data['bookmark_id'];
      if (bmId is num) {
        _bookmarkIds[_key(type, id)] = bmId.toInt();
      }
      notifyListenersImmediate();
    } catch (e) {
      _error = ErrorParser.parse(e);
      notifyListenersImmediate();
    }
  }

  Future<bool> toggle(String type, int id) async {
    final key = _key(type, id);
    final currentlyBookmarked = _bookmarkStatus[key] ?? false;

    try {
      if (currentlyBookmarked) {
        final bookmarkId = _bookmarkIds[key];
        if (bookmarkId != null) {
          await _bookmarkService.removeBookmark(bookmarkId);
        }
        _bookmarkStatus[key] = false;
        _bookmarkIds.remove(key);
      } else {
        // Call addBookmark which returns the bookmark data including ID
        await _bookmarkService.addBookmark(type, id);
        _bookmarkStatus[key] = true;
        // Fetch the bookmark ID from checkStatus to keep data in sync
        final data = await _bookmarkService.checkStatus(type, id);
        final bmId = data['bookmark_id'];
        if (bmId is num) {
          _bookmarkIds[key] = bmId.toInt();
        }
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

  Future<void> loadBookmarks({String? type}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListenersImmediate();

      _bookmarks = await _bookmarkService.getBookmarks(type: type);

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

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}