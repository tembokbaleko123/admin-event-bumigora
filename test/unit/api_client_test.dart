import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kampus/core/network/api_client.dart';

void main() {
  group('ApiClient.extractList', () {
    test('extracts from direct list', () {
      final input = [
        {'id': 1, 'nama': 'Test'},
        {'id': 2, 'nama': 'Test2'},
      ];

      final result = ApiClient.extractList<Map<String, dynamic>>(
        input,
        (json) => json,
      );

      expect(result.length, 2);
    });

    test('extracts from nested data key', () {
      final input = {
        'data': [
          {'id': 1},
          {'id': 2},
        ],
      };

      final result = ApiClient.extractList<Map<String, dynamic>>(
        input,
        (json) => json,
      );

      expect(result.length, 2);
    });

    test('returns empty for null input', () {
      final result = ApiClient.extractList<Map<String, dynamic>>(
        null,
        (json) => json,
      );

      expect(result, isEmpty);
    });

    test('returns empty for non-list non-map input', () {
      final result = ApiClient.extractList<Map<String, dynamic>>(
        'string',
        (json) => json,
      );

      expect(result, isEmpty);
    });
  });

  group('ApiException', () {
    test('creates exception with message and status code', () {
      final ex = ApiException('Test error', statusCode: 404);
      expect(ex.message, 'Test error');
      expect(ex.statusCode, 404);
      expect(ex.toString(), 'Test error');
    });

    test('creates exception without status code', () {
      final ex = ApiException('Test error');
      expect(ex.statusCode, isNull);
    });
  });
}