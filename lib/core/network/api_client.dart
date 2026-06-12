import 'dart:async' as dart_async;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/local_storage.dart';
import '../../config/api_config.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

/// HTTP API client with proper error handling and timeout management
class ApiClient {
  String? _token;
  bool _hasToken = false;
  static bool _isHandlingUnauthorized = false;
  static void Function()? onUnauthorized;

  void setToken(String? token) {
    _token = token;
    _hasToken = token != null && token.isNotEmpty;
  }

  bool get hasToken => _hasToken;

  /// Get HTTP headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_hasToken) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) {
    return _request('GET', endpoint, queryParams: queryParams);
  }

  /// GET raw response (for file downloads)
  Future<http.Response> getRaw(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams: queryParams);
    final headers = <String, String>{'Accept': 'application/json'};
    if (_hasToken) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return http
        .get(uri, headers: headers)
        .timeout(Duration(seconds: ApiConfig.timeout));
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool isFormData = false,
  }) {
    return _request('POST', endpoint, body: body, isFormData: isFormData);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool isFormData = false,
  }) {
    return _request('PUT', endpoint, body: body, isFormData: isFormData);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) {
    return _request('DELETE', endpoint);
  }

  /// Get all pages with pagination
  Future<List<T>> getAllPages<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
    int maxPages = 20,
  }) async {
    final items = <T>[];
    var page = 1;

    while (page <= maxPages) {
      final params = <String, String>{
        ...?queryParams,
        'page': page.toString(),
      };
      final response = await get(endpoint, queryParams: params);
      items.addAll(extractList(response['data'], fromJson));

      final meta = response['meta'];
      final hasMore = meta is Map && meta['has_more'] == true;
      if (!hasMore) break;
      page += 1;
    }

    return items;
  }

  /// Determine if a 401 response means session expired vs login failure.
  /// If we had no token, it's a login/register attempt → return the API error message.
  /// If we had a token, the session is expired → clear auth and notify.
  Future<String?> _handleUnauthorized(http.Response response) async {
    // Try to extract the actual error message from the response body first
    String? apiErrorMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        apiErrorMessage = decoded['message'] as String?;
      }
    } catch (_) {
      // Ignore parse errors, will use generic message
    }

    // If we didn't have a token, this is a login/register auth failure
    // Return the API error message so it can be shown to the user
    if (!_hasToken) {
      return apiErrorMessage ?? 'Email atau password salah';
    }

    // We had a token and got 401 - session expired
    if (_isHandlingUnauthorized) {
      return apiErrorMessage ?? 'Sesi telah berakhir, silakan login ulang';
    }

    // Clear session and notify
    _isHandlingUnauthorized = true;
    try {
      _token = null;
      _hasToken = false;
      await LocalStorage.clearAuth();
      ApiClient.onUnauthorized?.call();
      ApiClient.onUnauthorized = null;
    } finally {
      _isHandlingUnauthorized = false;
    }

    return 'Sesi telah berakhir. Silakan login ulang.';
  }

  /// Core request method with comprehensive error handling and retry logic
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool isFormData = false,
  }) async {
    final uri = _buildUri(endpoint, queryParams: queryParams);
    final headers = Map<String, String>.from(_headers);
    if (isFormData) headers.remove('Content-Type');

    var lastError = '';
    for (var attempt = 1; attempt <= ApiConfig.maxRetries; attempt++) {
      try {
        return await _executeRequest(method, uri, headers, body, isFormData);
      } on dart_async.TimeoutException {
        lastError = 'Koneksi timeout, coba lagi';
        if (attempt < ApiConfig.maxRetries) {
          await Future.delayed(Duration(milliseconds: 200 * attempt));
          continue;
        }
        throw ApiException(lastError);
      } on http.ClientException catch (e) {
        lastError = e.message;
        if (attempt < ApiConfig.maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
          continue;
        }
        throw ApiException(
          'Gagal terhubung ke server. Pastikan Laravel aktif di ${ApiConfig.apiUrl}.',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Terjadi kesalahan: $e');
      }
    }
    throw ApiException(lastError);
  }

  Future<Map<String, dynamic>> _executeRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    bool isFormData,
  ) async {
    http.Response response;

    if (method == 'GET') {
      response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeout));
    } else if (method == 'POST' && isFormData) {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      _attachFormData(request, body);
      response = await http.Response.fromStream(
        await request.send().timeout(
          Duration(seconds: ApiConfig.uploadTimeout),
        ),
      );
    } else if (method == 'PUT' && isFormData) {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      _attachFormData(request, {
        ...?body,
        '_method': 'PUT',
      });
      response = await http.Response.fromStream(
        await request.send().timeout(
          Duration(seconds: ApiConfig.uploadTimeout),
        ),
      );
    } else if (method == 'POST') {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.timeout));
    } else if (method == 'PUT') {
      response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.timeout));
    } else if (method == 'DELETE') {
      response = await http
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeout));
    } else {
      throw ApiException('Method $method tidak didukung');
    }

    // Parse response
    try {
      if (response.body.trim().isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'status': true, 'data': null};
        }
        throw ApiException(
          _messageForStatus(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          'Format respons tidak valid',
          statusCode: response.statusCode,
        );
      }

      // Handle 401 Unauthorized - distinguish login failure vs session expiry
      if (response.statusCode == 401) {
        final errorMessage = await _handleUnauthorized(response);
        throw ApiException(
          errorMessage ?? 'Sesi telah berakhir, silakan login ulang',
          statusCode: 401,
        );
      }

      // Handle error responses (non-401)
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['status'] == false) {
        String message = decoded['message'] as String? ?? 'Terjadi kesalahan';

        // Handle Laravel validation errors (422)
        if (response.statusCode == 422 && decoded['errors'] != null) {
          final errors = decoded['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          for (final entry in errors.entries) {
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            } else if (value is String && value.isNotEmpty) {
              errorMessages.add(value);
            } else if (value != null) {
              errorMessages.add(value.toString());
            }
          }
          if (errorMessages.isNotEmpty) {
            message = errorMessages.join('\n');
          }
        }

        throw ApiException(message, statusCode: response.statusCode);
      }

      return decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      // Handle JSON decode errors specifically
      if (e is FormatException) {
        throw ApiException(
          _messageForStatus(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }
  }

  Uri _buildUri(String endpoint, {Map<String, String>? queryParams}) {
    final path = endpoint.trim();
    final url = path.startsWith('http://') || path.startsWith('https://')
        ? path
        : '${ApiConfig.apiUrl}${path.startsWith('/') ? path : '/$path'}';
    final uri = Uri.parse(url);
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      },
    );
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 404) {
      return 'Endpoint API tidak ditemukan. Pastikan backend aktif dan prefix API memakai ${ApiConfig.apiUrl}.';
    }
    if (statusCode == 505) {
      return 'Server tidak mendukung versi HTTP yang digunakan. Coba update Apache/Nginx atau gunakan versi PHP lebih baru.';
    }
    if (statusCode >= 500) {
      return 'Server sedang bermasalah (${statusCode}). Coba lagi atau cek backend.';
    }
    if (statusCode >= 400) {
      return 'Request ditolak server ($statusCode).';
    }
    return 'Gagal memproses respons server: $statusCode';
  }

  /// Attach form data for multipart requests
  void _attachFormData(http.MultipartRequest request, Map<String, dynamic>? body) {
    if (body == null) return;
    for (final entry in body.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is List<int>) {
        request.files.add(http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'upload.jpg',
        ));
      } else if (value is Map || value is List) {
        request.fields[key] = jsonEncode(value);
      } else if (value != null) {
        request.fields[key] = value.toString();
      }
    }
  }

  /// Initialize API client with stored token
  static Future<ApiClient> init() async {
    final client = ApiClient();
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      client.setToken(token);
    }
    return client;
  }

  /// Extract list from response data
  static List<T> extractList<T>(
    dynamic rawData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (rawData is List) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => fromJson(e))
          .toList();
    }
    if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      return (rawData['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => fromJson(e))
          .toList();
    }
    return [];
  }
}

/// ApiClient timeout exception
class ApiTimeoutException implements Exception {
  final String message;
  ApiTimeoutException(this.message);
  @override
  String toString() => message;
}
