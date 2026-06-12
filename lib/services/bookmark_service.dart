import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/bookmark.dart';

class BookmarkService {
  final ApiClient _api;

  BookmarkService(this._api);

  Future<List<Bookmark>> getBookmarks({String? type, int perPage = 50}) async {
    final queryParams = <String, String>{'per_page': perPage.toString()};
    if (type != null) queryParams['type'] = type;

    return _api.getAllPages('/bookmarks',
        queryParams: queryParams, fromJson: Bookmark.fromJson);
  }

  Future<void> addBookmark(String type, int id) async {
    await _api.post('/bookmarks', body: {
      'bookmarkable_type': type,
      'bookmarkable_id': id,
    });
  }

  Future<void> removeBookmark(int bookmarkId) async {
    await _api.delete('/bookmarks/$bookmarkId');
  }

  Future<Map<String, dynamic>> checkStatus(String type, int id) async {
    final response = await _api.get('/bookmarks/check/$type/$id');
    return response['data'] ?? {};
  }
}
