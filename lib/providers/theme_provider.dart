import 'package:flutter/material.dart';
import 'package:aplikasi_kampus/core/base/disposable_notifier.dart';
import 'package:aplikasi_kampus/core/storage/local_storage.dart';

class ThemeProvider extends SafeChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    try {
      final stored = await LocalStorage.getThemeMode();
      if (stored == 'dark') {
        _mode = ThemeMode.dark;
        notifyListenersImmediate();
      }
    } catch (e) {
      debugPrint('ThemeProvider load error: $e');
    }
  }

  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListenersImmediate();
    await _persistMode();
  }

  Future<void> setDark(bool value) async {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListenersImmediate();
    await _persistMode();
  }

  Future<void> _persistMode() async {
    try {
      await LocalStorage.saveThemeMode(isDark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('ThemeProvider persist error: $e');
    }
  }
}