import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure local storage service with proper error handling.
/// Uses SharedPreferences with encryption consideration.
/// For production, consider using flutter_secure_storage for sensitive data.
class LocalStorage {
  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'user_data';
  static const _onboardingKey = 'onboarding_complete';
  static const _themeModeKey = 'theme_mode';

  LocalStorage._();

  static SharedPreferences? _prefsInstance;
  static bool _isInitializing = false;
  static final List<Completer<void>> _pendingInit = [];

  static Future<SharedPreferences> get _prefs async {
    if (_prefsInstance != null) return _prefsInstance!;
    
    if (_isInitializing) {
      // Wait for the ongoing initialization to complete
      final completer = Completer<void>();
      _pendingInit.add(completer);
      await completer.future;
      return _prefsInstance!;
    }
    
    _isInitializing = true;
    try {
      _prefsInstance = await SharedPreferences.getInstance();
      // Resolve all pending waiters
      for (final c in _pendingInit) {
        if (!c.isCompleted) c.complete();
      }
      _pendingInit.clear();
      return _prefsInstance!;
    } catch (e) {
      // Also resolve pending waiters with error
      for (final c in _pendingInit) {
        if (!c.isCompleted) c.completeError(e);
      }
      _pendingInit.clear();
      debugPrint('SharedPreferences init error: $e');
      throw LocalStorageException('Gagal mengakses penyimpanan lokal');
    } finally {
      _isInitializing = false;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('saveToken error: $e');
      throw LocalStorageException('Gagal menyimpan token');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('getToken error: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('removeToken error: $e');
    }
  }

  static Future<void> saveUserData(String data) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_userDataKey, data);
    } catch (e) {
      debugPrint('saveUserData error: $e');
    }
  }

  static Future<String?> getUserData() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_userDataKey);
    } catch (e) {
      debugPrint('getUserData error: $e');
      return null;
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_onboardingKey);
    } catch (e) {
      debugPrint('clearAll error: $e');
    }
  }

  static Future<void> clearAuth() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
    } catch (e) {
      debugPrint('clearAuth error: $e');
    }
  }

  static Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('isOnboardingComplete error: $e');
      return false;
    }
  }

  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      debugPrint('setOnboardingComplete error: $e');
    }
  }

  /// Force re-initialization (useful after app restore from background)
  static Future<String?> getThemeMode() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_themeModeKey);
    } catch (e) {
      debugPrint('getThemeMode error: $e');
      return null;
    }
  }

  static Future<void> saveThemeMode(String mode) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_themeModeKey, mode);
    } catch (e) {
      debugPrint('saveThemeMode error: $e');
    }
  }

  static Future<void> reset() async {
    _prefsInstance = null;
    _isInitializing = false;
    _pendingInit.clear();
    await _prefs;
  }
}

/// Exception class for local storage errors
class LocalStorageException implements Exception {
  final String message;
  LocalStorageException(this.message);

  @override
  String toString() => message;
}