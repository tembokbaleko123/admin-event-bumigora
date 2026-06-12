import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'notification_web.dart' if (dart.library.io) 'notification_stub.dart';

class PushNotificationService {
  final ApiClient _apiClient;
  static const _lastNotifIdKey = 'last_notification_id';

  Timer? _pollTimer;
  int _lastNotifId = 0;
  bool _initialized = false;
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 5;
  void Function(int unreadCount)? onUnreadCountChanged;

  PushNotificationService(this._apiClient);

  /// Initialize push notification service
  /// Web: Use browser Notification API
  /// Desktop/Mobile: Returns false since web notifications are not supported
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastNotifId = prefs.getInt(_lastNotifIdKey) ?? 0;

      if (!kIsWeb) {
        debugPrint('PushNotificationService: Non-web mode - notifications not supported');
        return false;
      }

      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('PushNotificationService init error: $e');
      _initialized = true;
      return false;
    }
  }

  /// Start polling for new notifications
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollNotifications();
    });
    _pollNotifications();
  }

  /// Stop polling for notifications
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _consecutiveErrors = 0;
  }

  /// Poll for new notifications from server
  Future<void> _pollNotifications() async {
    try {
      final response = await _apiClient.get(
        '/notifikasis',
        queryParams: {
          'per_page': '10',
          'status': AppStrings.statusUnread,
        },
      );

      final data = response['data'];
      final unreadCount = response['unread_count'];
      if (unreadCount is int) {
        onUnreadCountChanged?.call(unreadCount);
      }
      if (data is! List) return;

      for (final item in data) {
        if (item is! Map) continue;
        final id = item['id'];
        if (id is! int) continue;
        if (id <= _lastNotifId) continue;

        final pesan = item['pesan'] is String ? item['pesan'] as String : 'Notifikasi baru';
        await _showNotification(id, 'SIPENDEKA', pesan);
      }

      // Update last notification ID
      if (data.isNotEmpty) {
        int latestId = _lastNotifId;
        for (final e in data) {
          if (e is Map) {
            final notifId = e['id'];
            if (notifId is int && notifId > latestId) {
              latestId = notifId;
            }
          }
        }

        if (latestId > _lastNotifId) {
          _lastNotifId = latestId;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_lastNotifIdKey, _lastNotifId);
        }
      }

      _consecutiveErrors = 0;
    } catch (e) {
      _consecutiveErrors++;
      debugPrint('Polling notifikasi error (#$_consecutiveErrors): $e');

      if (_consecutiveErrors >= _maxConsecutiveErrors) {
        debugPrint('Too many consecutive polling errors. Stopping polling.');
        stopPolling();
      }
    }
  }

  /// Show notification
  /// On web: Uses browser notification API if available
  Future<void> _showNotification(int id, String title, String body) async {
    if (kIsWeb) {
      await _showWebNotification(title, body);
    }
  }

  /// Show notification on web using browser API
  Future<void> _showWebNotification(String title, String body) async {
    try {
      final granted = await requestNotificationPermission();
      if (granted) {
        showBrowserNotification(title, body);
      }
      debugPrint('Web notification: $title - $body');
    } catch (e) {
      debugPrint('Web notification error: $e');
    }
  }

  /// Handle notification tap
  void onNotificationTap(String? payload) {
    if (payload == null) return;
    debugPrint('Notification tapped with payload: $payload');
  }

  /// Clean up resources
  void dispose() {
    stopPolling();
  }
}
