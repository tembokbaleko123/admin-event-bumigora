import '../core/constants/app_strings.dart';

class NotifikasiModel {
  final int id;
  final int userId;
  final int? eventId;
  final String pesan;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final EventBrief? event;

  NotifikasiModel({
    required this.id,
    required this.userId,
    this.eventId,
    required this.pesan,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.event,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventId: json['event_id'],
      pesan: json['pesan'] ?? '',
      status: json['status'] ?? AppStrings.statusUnread,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      event: json['event'] is Map<String, dynamic>
          ? EventBrief.fromJson(json['event'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isUnread => status == AppStrings.statusUnread;
}

class EventBrief {
  final int id;
  final String judul;

  EventBrief({required this.id, required this.judul});

  factory EventBrief.fromJson(Map<String, dynamic> json) {
    return EventBrief(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
    );
  }
}
