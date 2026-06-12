import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:aplikasi_kampus/models/user_model.dart';
import 'package:aplikasi_kampus/services/auth_service.dart';
import 'package:aplikasi_kampus/core/storage/local_storage.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/utils/error_parser.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

/// Authentication state management provider with proper error handling.
class AuthProvider extends SafeChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _error;
  bool _isUpdatingProfile = false;
  final AuthService _authService;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider(this._authService) {
    _tryAutoLogin();
  }

  /// Attempt auto-login using stored token
  Future<void> _tryAutoLogin() async {
    try {
      final token = await LocalStorage.getToken();
      if (token == null) {
        _status = AuthStatus.unauthenticated;
        notifyListenersImmediate();
        return;
      }

      _authService.setToken(token);

      final userData = await LocalStorage.getUserData();
      if (userData != null) {
        try {
          _user = UserModel.fromJson(
              jsonDecode(userData) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Failed to parse cached user data: $e');
          _user = null;
        }
      }

      try {
        final freshUser = await _authService.getCurrentUser();
        _user = freshUser;
        if (_user == null) return;
        await LocalStorage.saveUserData(jsonEncode(_user!.toJson()));
        _status = AuthStatus.authenticated;
      } catch (e) {
        debugPrint('AutoLogin API verification failed: $e');
        if (_user == null) {
          await LocalStorage.clearAuth();
          _status = AuthStatus.unauthenticated;
        } else {
          // Use cached user data if API verification fails
          _status = AuthStatus.authenticated;
        }
      }
    } catch (e) {
      debugPrint('AutoLogin failed completely: $e');
      await LocalStorage.clearAuth();
      _status = AuthStatus.unauthenticated;
    }
    notifyListenersImmediate();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListenersImmediate();

    try {
      final result = await _authService.login(email: email, password: password);
      _user = result.user;
      _authService.setToken(result.token);
      await LocalStorage.saveToken(result.token);
      await LocalStorage.saveUserData(jsonEncode(result.user.toJson()));
      _status = AuthStatus.authenticated;
      notifyListenersImmediate();
      return true;
    } catch (e) {
      _error = ErrorParser.parse(e);
      _status = AuthStatus.unauthenticated;
      notifyListenersImmediate();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListenersImmediate();

    try {
      final result = await _authService.register(
        nama: nama,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _user = result.user;
      _authService.setToken(result.token);
      await LocalStorage.saveToken(result.token);
      await LocalStorage.saveUserData(jsonEncode(result.user.toJson()));
      _status = AuthStatus.authenticated;
      notifyListenersImmediate();
      return true;
    } catch (e) {
      _error = ErrorParser.parse(e);
      _status = AuthStatus.unauthenticated;
      notifyListenersImmediate();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? nama,
    String? email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    _isUpdatingProfile = true;
    _error = null;
    notifyListenersImmediate();

    try {
      final updatedUser = await _authService.updateProfile(
        nama: nama,
        email: email,
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _user = updatedUser;
      if (_user == null) return false;
      await LocalStorage.saveUserData(jsonEncode(_user!.toJson()));
      return true;
    } catch (e) {
      _error = ErrorParser.parse(e);
      return false;
    } finally {
      _isUpdatingProfile = false;
      notifyListenersImmediate();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout server error (continuing): $e');
    }

    _authService.setToken(null);
    _user = null;
    _status = AuthStatus.unauthenticated;
    await LocalStorage.clearAuth();
    notifyListenersImmediate();
  }

  void clearError() {
    _error = null;
    notifyListenersImmediate();
  }
}
