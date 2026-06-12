import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/attendance_provider.dart';

/// QR Code display screen for event attendance
class ShowQrScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ShowQrScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  String? _qrToken;
  String? _expiredAt;
  int _duration = 120;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  Future<void> _loadQr() async {
    final attProv = context.read<AttendanceProvider>();
    await attProv.getActiveQr(widget.eventId);
    if (mounted) {
      final qr = attProv.activeQr;
      if (qr != null && qr.hasActiveQr && qr.token != null) {
        setState(() {
          _qrToken = qr.token;
          _expiredAt = qr.expiredAt;
        });
      }
    }
  }

  Future<void> _generateQr() async {
    setState(() => _generating = true);
    final attProv = context.read<AttendanceProvider>();
    final ok = await attProv.generateQr(widget.eventId, duration: _duration);
    if (mounted) {
      if (ok) {
        final qr = attProv.activeQr;
        setState(() {
          _qrToken = qr?.token;
          _expiredAt = qr?.expiredAt;
        });
        SnackbarHelper.show(context, AppStrings.successQRCode);
      } else {
        SnackbarHelper.show(
          context,
          attProv.error ?? AppStrings.errorGagalBuatQR,
          isError: true,
        );
      }
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: context.surfaceColor,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: context.onSurfaceColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "QR Absensi Event",
          style: TextStyle(
            color: context.onSurfaceColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.eventTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (_qrToken != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: context.onSurfaceColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: _qrToken!,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: context.surfaceColor,
                      ),
                      const SizedBox(height: 16),
                      if (_expiredAt != null)
                        Text(
                          "Berlaku sampai: ${_formatExpiry(_expiredAt!)}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _qrToken!));
                          SnackbarHelper.show(context, AppStrings.successTokenDisalin);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Salin Token",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const EmptyStateWidget(title: AppStrings.emptyQR, icon: Icons.qr_code_2),
              ],

              const SizedBox(height: 32),

              Row(
                children: [
                  const Text(
                    "Durasi aktif:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _duration,
                    items: const [
                      DropdownMenuItem(value: 30, child: Text("30 menit")),
                      DropdownMenuItem(value: 60, child: Text("1 jam")),
                      DropdownMenuItem(value: 120, child: Text("2 jam")),
                      DropdownMenuItem(value: 240, child: Text("4 jam")),
                      DropdownMenuItem(value: 480, child: Text("8 jam")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _duration = v);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generateQr,
                  icon: _generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _generating
                        ? "Membuat..."
                        : (_qrToken != null ? "Buat QR Baru" : "Buat QR Code"),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format expiry time to local timezone
  String _formatExpiry(String iso) {
    try {
      final utcDt = DateTime.parse(iso);
      // Convert UTC to local time if needed
      final localDt = utcDt.isUtc ? utcDt.toLocal() : utcDt;
      return "${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }
}