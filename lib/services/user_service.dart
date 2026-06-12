import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/user_model.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  Future<List<UserModel>> getUsers({
    String? search,
    String? role,
    int perPage = 50,
  }) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
    };
    if (search != null) queryParams['search'] = search;
    if (role != null) queryParams['role'] = role;

    return _api.getAllPages('/users', queryParams: queryParams, fromJson: UserModel.fromJson);
  }

  Future<UserModel> getUserDetail(int id) async {
    final response = await _api.get('/users/$id');
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Detail user tidak ditemukan');
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateUser(int id, {
    String? nama,
    String? email,
    String? role,
    String? password,
  }) async {
    final body = <String, dynamic>{};
    if (nama != null) body['nama'] = nama;
    if (email != null) body['email'] = email;
    if (role != null) body['role'] = role;
    if (password != null) body['password'] = password;

    final response = await _api.put('/users/$id', body: body);
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Gagal memperbarui user');
    return UserModel.fromJson(data);
  }

  Future<({List<UserModel> items, bool hasMore, int currentPage})> getUsersPage({
    String? search,
    String? role,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };
    if (search != null) queryParams['search'] = search;
    if (role != null) queryParams['role'] = role;

    final response = await _api.get('/users', queryParams: queryParams);
    final meta = response['meta'];
    return (
      items: ApiClient.extractList(response['data'], UserModel.fromJson),
      hasMore: meta is Map && meta['has_more'] == true,
      currentPage: meta is Map ? (meta['current_page'] as int? ?? page) : page,
    );
  }

  Future<UserModel> createUser({
    required String nama,
    required String email,
    required String password,
    String role = 'mahasiswa',
  }) async {
    final body = <String, dynamic>{
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    };
    final response = await _api.post('/users', body: body);
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Gagal membuat user');
    return UserModel.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await _api.delete('/users/$id');
  }
}
