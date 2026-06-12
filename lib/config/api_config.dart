import 'package:flutter/foundation.dart';

/// API Configuration for SIPENDEKA App
/// Supports both development and production environments
class ApiConfig {
  ApiConfig._();

  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// API root without version, for example `http://127.0.0.1:8000/api`.
  static String get baseUrl => _apiRoot(_configuredBaseUrl);

  /// Full versioned API URL, for example `http://127.0.0.1:8000/api/v1`.
  static String get apiUrl => _withApiVersion(baseUrl);

  /// API health endpoint used for local integration checks.
  static String get healthUrl => '$baseUrl/health';

  static String get _configuredBaseUrl {
    if (_baseUrlOverride.trim().isNotEmpty) {
      return _baseUrlOverride.trim();
    }

    if (!kDebugMode) {
      // TODO: Replace with the real HTTPS production API before release.
      return 'http://127.0.0.1:8000/api';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  /// Timeout dalam detik untuk setiap request HTTP
  static const int timeout = 30;

  /// Timeout untuk upload file (lebih lama karena ukuran lebih besar)
  static const int uploadTimeout = 120;

  /// Retry count untuk failed requests
  static const int maxRetries = 3;

  /// Check if current configuration uses HTTPS
  static bool get isSecure => baseUrl.startsWith('https');

  /// Get API version
  static const String apiVersion = 'v1';

  static String _apiRoot(String rawUrl) {
    final url = _trimTrailingSlash(rawUrl);
    if (url.endsWith('/api/$apiVersion')) {
      return url.substring(0, url.length - apiVersion.length - 1);
    }
    if (url.endsWith('/$apiVersion') && url.contains('/api/')) {
      return url.substring(0, url.length - apiVersion.length - 1);
    }
    if (url.endsWith('/api')) return url;
    return '$url/api';
  }

  static String _withApiVersion(String rawUrl) {
    final url = _trimTrailingSlash(rawUrl);
    if (url.endsWith('/$apiVersion')) return url;
    return '$url/$apiVersion';
  }

  static String _trimTrailingSlash(String value) {
    var output = value.trim();
    while (output.endsWith('/')) {
      output = output.substring(0, output.length - 1);
    }
    return output;
  }
}
