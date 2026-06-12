import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/providers/attendance_provider.dart';

class ScanQrScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ScanQrScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _showResult = false;
  bool _scanSuccess = false;
  String _resultMessage = '';

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _showResult) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _isProcessing = true;
    _scannerController.stop();
    _processScan(barcode!.rawValue!);
  }

  Future<void> _processScan(String qrToken) async {
    final attProv = context.read<AttendanceProvider>();
    final success = await attProv.scanAttendance(widget.eventId, qrToken);

    if (!mounted) return;

    final scanResult = attProv.lastScanResult;
    final message = scanResult?['message'] as String? ??
        (success ? AppStrings.successAbsensi : attProv.error ?? AppStrings.errorGagalAbsensi);

    setState(() {
      _showResult = true;
      _scanSuccess = success;
      _resultMessage = message;
    });
  }

  void _resetScanner() {
    setState(() {
      _showResult = false;
      _isProcessing = false;
      _scanSuccess = false;
      _resultMessage = '';
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(AppStrings.titleScanQR, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _showResult
                  ? _resultWidget()
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                          SizedBox(height: 16),
                          Text(
                            "Arahkan kamera ke QR Code",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              widget.eventTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _scanSuccess ? Icons.check_circle : Icons.cancel,
            color: _scanSuccess ? Colors.green : Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _resultMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _scanSuccess ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanSuccess ? () => Navigator.pop(context) : _resetScanner,
              icon: Icon(_scanSuccess ? Icons.check : Icons.refresh),
              label: Text(_scanSuccess ? AppStrings.selesai : AppStrings.cobaLagi),
              style: ElevatedButton.styleFrom(
                backgroundColor: _scanSuccess ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
