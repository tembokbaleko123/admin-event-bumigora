import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_kampus/core/utils/validators.dart';

void main() {
  testWidgets('Validators work correctly', (tester) async {
    // Test that our validators are working
    expect(Validators.email('test@example.com'), isNull);
    expect(Validators.email('invalid'), isNotNull);
    expect(Validators.password('Abcdef1!@'), isNull);
    expect(Validators.password('short'), isNotNull);
    expect(Validators.loginPassword('abcdef'), isNull);
    expect(Validators.loginPassword(''), isNotNull);
    expect(Validators.required('hello'), isNull);
    expect(Validators.required(''), isNotNull);
  });
}