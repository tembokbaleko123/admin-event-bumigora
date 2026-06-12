import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kampus/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('   '), isNotNull);
    });

    test('accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('user+tag@domain.co.id'), isNull);
      expect(Validators.email('user.name@sub.domain.ac.id'), isNull);
    });

    test('rejects invalid email', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@'), isNotNull);
      expect(Validators.email('@domain.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty password', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('rejects short password', () {
      expect(Validators.password('Ab1!'), isNotNull);
    });

    test('rejects password without uppercase', () {
      expect(Validators.password('abcdef1!@'), isNotNull);
    });

    test('rejects password without lowercase', () {
      expect(Validators.password('ABCDEF1!@'), isNotNull);
    });

    test('rejects password without number', () {
      expect(Validators.password('Abcdefg!@'), isNotNull);
    });

    test('rejects password without symbol', () {
      expect(Validators.password('Abcdefg1'), isNotNull);
    });

    test('accepts valid strong password', () {
      expect(Validators.password('Abcdef1!@'), isNull);
    });
  });

  group('Validators.loginPassword', () {
    test('rejects empty login password', () {
      expect(Validators.loginPassword(''), isNotNull);
      expect(Validators.loginPassword(null), isNotNull);
    });

    test('HIGH-5: rejects very short login password', () {
      expect(Validators.loginPassword('abc'), isNotNull);
    });

    test('accepts login password with 6+ chars', () {
      expect(Validators.loginPassword('abcdef'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects null/empty', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('accepts non-empty', () {
      expect(Validators.required('hello'), isNull);
    });

    test('uses custom field name', () {
      final result = Validators.required(null, 'Nama');
      expect(result, contains('Nama'));
    });
  });
}