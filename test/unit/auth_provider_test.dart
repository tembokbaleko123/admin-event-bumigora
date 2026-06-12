import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/services/auth_service.dart';
import 'package:aplikasi_kampus/models/user_model.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
      SharedPreferences.setMockInitialValues({});
    });

    test('initial status should be uninitialized', () {
      final provider = AuthProvider(AuthService(apiClient));
      expect(provider.status, AuthStatus.uninitialized);
    });

    test('isAuthenticated getter works', () {
      final provider = AuthProvider(AuthService(apiClient));
      expect(provider.isAuthenticated, false);
    });

    test('isUpdatingProfile defaults to false', () {
      final provider = AuthProvider(AuthService(apiClient));
      expect(provider.isUpdatingProfile, false);
    });

    test('KRITIS-4: logout should clear user and set unauthenticated', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'test_token',
        'user_data': '{"id":1,"nama":"Test","email":"test@test.com","role":"mahasiswa"}',
      });

      final provider = AuthProvider(AuthService(apiClient));
      await provider.logout();
      
      // Token should be cleared after logout
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);
    });

    // Test untuk KRITIS-1: auto-login handling dipindah ke integration test
    // karena membutuhkan HTTP mock server untuk menghindari timeout 30 detik
  });

  group('UserModel', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 1,
        'nama': 'Test User',
        'email': 'test@test.com',
        'role': 'mahasiswa',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-02',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.nama, 'Test User');
      expect(user.email, 'test@test.com');
      expect(user.role, 'mahasiswa');
      expect(user.isMahasiswa, true);
      expect(user.isDosen, false);
      expect(user.isAdmin, false);
    });

    test('fromJson with missing fields uses defaults', () {
      final json = <String, dynamic>{};

      final user = UserModel.fromJson(json);
      expect(user.id, 0);
      expect(user.nama, '');
      expect(user.email, '');
      expect(user.role, 'mahasiswa');
    });

    test('toJson returns correct map', () {
      final user = UserModel(
        id: 1,
        nama: 'Test',
        email: 'test@test.com',
        role: 'admin',
      );

      final json = user.toJson();
      expect(json['id'], 1);
      expect(json['role'], 'admin');
    });

    test('role getters work correctly', () {
      final mhs = UserModel(id: 1, nama: 'Mhs', email: 'm@t.com', role: 'mahasiswa');
      final dosen = UserModel(id: 2, nama: 'Dos', email: 'd@t.com', role: 'dosen');
      final admin = UserModel(id: 3, nama: 'Adm', email: 'a@t.com', role: 'admin');

      expect(mhs.isMahasiswa, true);
      expect(mhs.isDosen, false);
      expect(mhs.isAdmin, false);

      expect(dosen.isDosen, true);
      expect(dosen.isMahasiswa, false);

      expect(admin.isAdmin, true);
      expect(admin.isMahasiswa, false);
    });
  });
}