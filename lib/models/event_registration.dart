import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'event_model.dart';

class RegistrationUser {
  final int id;
  final String nama;
  final String? email;

  RegistrationUser({required this.id, required this.nama, this.email});

  factory RegistrationUser.fromJson(Map<String, dynamic> json) {
    return RegistrationUser(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'],
    );
  }
}

class EventRegistration {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String? registeredAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;
  final EventModel? event;
  final RegistrationUser? user;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.registeredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.event,
    this.user,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? AppStrings.statusRegistered,
      registeredAt: json['registered_at'],
      cancelledAt: json['cancelled_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      event: json['event'] is Map<String, dynamic>
          ? EventModel.fromJson(json['event'] as Map<String, dynamic>)
          : null,
      user: json['user'] is Map<String, dynamic>
          ? RegistrationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isRegistered => status == AppStrings.statusRegistered;
  bool get isCancelled => status == AppStrings.statusCancelled;
  bool get isAttended => status == AppStrings.statusAttended;
  bool get isAbsent => status == AppStrings.statusAbsent;
}
