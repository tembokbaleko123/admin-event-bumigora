import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'event_registration.dart';

class Attendance {
  final int id;
  final int eventId;
  final int userId;
  final int? registrationId;
  final int? qrTokenId;
  final String scannedAt;
  final String status;
  final String? createdAt;
  final RegistrationUser? user;

  Attendance({
    required this.id,
    required this.eventId,
    required this.userId,
    this.registrationId,
    this.qrTokenId,
    required this.scannedAt,
    required this.status,
    this.createdAt,
    this.user,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      registrationId: json['registration_id'],
      qrTokenId: json['qr_token_id'],
      scannedAt: json['scanned_at'] ?? '',
      status: json['status'] ?? AppStrings.statusValid,
      createdAt: json['created_at'],
      user: json['user'] is Map<String, dynamic>
          ? RegistrationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isValid => status == AppStrings.statusValid;
  bool get isLate => status == AppStrings.statusLate;
}

class ActiveQrToken {
  final bool hasActiveQr;
  final int? id;
  final String? token;
  final String? expiredAt;
  final bool? isExpired;

  ActiveQrToken({
    required this.hasActiveQr,
    this.id,
    this.token,
    this.expiredAt,
    this.isExpired,
  });

  factory ActiveQrToken.fromJson(Map<String, dynamic> json) {
    return ActiveQrToken(
      hasActiveQr: json['has_active_qr'] ?? false,
      id: json['id'],
      token: json['token'],
      expiredAt: json['expired_at'],
      isExpired: json['is_expired'],
    );
  }
}

class AttendanceSummary {
  final int totalRegistered;
  final int totalAttended;
  final int totalValid;
  final int totalLate;
  final double attendancePercentage;

  AttendanceSummary({
    required this.totalRegistered,
    required this.totalAttended,
    required this.totalValid,
    required this.totalLate,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalRegistered: json['total_registered'] ?? 0,
      totalAttended: json['total_attended'] ?? 0,
      totalValid: json['total_valid'] ?? 0,
      totalLate: json['total_late'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0).toDouble(),
    );
  }
}
