import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kampus/func/scan_qr_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('ScanQrScreen renders with title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanQrScreen(
          eventId: 1,
          eventTitle: 'Test Event',
        ),
      ),
    );

    // Should show the event title
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.text('Scan QR Absensi'), findsOneWidget);
  });
}