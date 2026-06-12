import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/user_model.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  void setToken(String? token) => _api.setToken(token);

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/login', body: {
      'email': email,
      'password': password,
    });
    return _parseAuthResponse(response, 'login');
  }

  Future<({UserModel user, String token})> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post('/register', body: {
      'nama': nama,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return _parseAuthResponse(response, 'registrasi');
  }

  Future<void> logout() async {
    await _api.post('/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _api.get('/me');
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Data user tidak ditemukan');
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    String? nama,
    String? email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final body = <String, dynamic>{};
    if (nama != null) body['nama'] = nama;
    if (email != null) body['email'] = email;
    if (currentPassword != null) body['current_password'] = currentPassword;
    if (password != null) body['password'] = password;
    if (passwordConfirmation != null) body['password_confirmation'] = passwordConfirmation;
    final response = await _api.put('/profile', body: body);
    final data = response['data'];
    if (data is! Map<String, dynamic>) throw ApiException('Data user tidak ditemukan');
    return UserModel.fromJson(data);
  }

  ({UserModel user, String token}) _parseAuthResponse(
    Map<String, dynamic> response,
    String action,
  ) {
    final data = response['data'];
    final authData = data is Map<String, dynamic> ? data : response;
    final userData = authData['user'];
    if (userData is! Map<String, dynamic>) {
      throw ApiException('Data user $action tidak valid');
    }

    final token = authData['token'] ??
        authData['access_token'] ??
        authData['plainTextToken'];
    if (token is! String || token.isEmpty) {
      throw ApiException('Token $action tidak ditemukan');
    }

    return (user: UserModel.fromJson(userData), token: token);
  }
}
