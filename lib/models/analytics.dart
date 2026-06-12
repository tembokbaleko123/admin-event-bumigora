class AnalyticsSummary {
  final Map<String, dynamic> users;
  final Map<String, dynamic> events;
  final Map<String, dynamic> informasi;
  final Map<String, dynamic> attendance;
  final List<dynamic> popularEvents;
  final List<dynamic> categoryStats;
  final List<dynamic> eventMonthly;

  AnalyticsSummary({
    required this.users,
    required this.events,
    required this.informasi,
    required this.attendance,
    required this.popularEvents,
    required this.categoryStats,
    required this.eventMonthly,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      users: json['users'] ?? {},
      events: json['events'] ?? {},
      informasi: json['informasi'] ?? {},
      attendance: json['attendance'] ?? {},
      popularEvents: json['popular_events'] ?? [],
      categoryStats: json['category_stats'] ?? [],
      eventMonthly: json['event_monthly'] ?? [],
    );
  }

  int get totalUsers => users['total'] ?? 0;
  int get totalMahasiswa => users['mahasiswa'] ?? 0;
  int get totalDosen => users['dosen'] ?? 0;
  int get totalAdmin => users['admin'] ?? 0;
  int get totalEvents => events['total'] ?? 0;
  int get totalInformasi => informasi['total'] ?? 0;
  int get totalRegistrations => attendance['total_registrations'] ?? 0;
  int get totalAttended => attendance['total_attended'] ?? 0;
  double get avgAttendance => (attendance['avg_percentage'] ?? 0).toDouble();
}

class DashboardOverview {
  final String role;
  final String? serverTime;
  final Map<String, dynamic> events;
  final Map<String, dynamic> notifications;
  final Map<String, dynamic> student;
  final Map<String, dynamic> lecturer;
  final Map<String, dynamic> admin;

  DashboardOverview({
    required this.role,
    this.serverTime,
    required this.events,
    required this.notifications,
    required this.student,
    required this.lecturer,
    required this.admin,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      role: json['role'] as String? ?? 'mahasiswa',
      serverTime: json['server_time'] as String?,
      events: _asMap(json['events']),
      notifications: _asMap(json['notifications']),
      student: _asMap(json['student']),
      lecturer: _asMap(json['lecturer']),
      admin: _asMap(json['admin']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  int _intFrom(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int get totalEvents => _intFrom(events, 'total');
  int get todayEvents => _intFrom(events, 'today');
  int get upcomingEvents => _intFrom(events, 'upcoming');
  int get unreadNotifications => _intFrom(notifications, 'unread');

  int get registeredEvents => _intFrom(student, 'registered_events');
  int get attendedEvents => _intFrom(student, 'attended_events');
  int get bookmarks => _intFrom(student, 'bookmarks');
  Map<String, dynamic>? get nextRegisteredEvent =>
      student['next_registered_event'] is Map<String, dynamic>
          ? student['next_registered_event'] as Map<String, dynamic>
          : null;

  int get lecturerEvents => _intFrom(lecturer, 'my_events');
  int get lecturerPendingEvents => _intFrom(lecturer, 'pending_events');
  int get lecturerParticipants => _intFrom(lecturer, 'total_participants');
  int get lecturerPresent => _intFrom(lecturer, 'total_present');
  Map<String, dynamic>? get lecturerNextEvent =>
      lecturer['next_event'] is Map<String, dynamic>
          ? lecturer['next_event'] as Map<String, dynamic>
          : null;

  int get adminUsers => _intFrom(admin, 'users_total');
  int get adminMahasiswa => _intFrom(admin, 'mahasiswa_total');
  int get adminDosen => _intFrom(admin, 'dosen_total');
  int get adminInformasi => _intFrom(admin, 'informasi_total');
  int get adminPendingEvents => _intFrom(admin, 'pending_events');
  int get adminAuditToday => _intFrom(admin, 'audit_logs_today');

  double get studentAttendanceRate => registeredEvents > 0
      ? (attendedEvents / registeredEvents * 100)
      : 0;

  double get lecturerAttendanceRate => lecturerParticipants > 0
      ? (lecturerPresent / lecturerParticipants * 100)
      : 0;
}

class LecturerSummary {
  final int totalEvents;
  final int totalPendaftar;
  final int totalHadir;

  LecturerSummary({
    required this.totalEvents,
    required this.totalPendaftar,
    required this.totalHadir,
  });

  factory LecturerSummary.fromJson(Map<String, dynamic> json) {
    return LecturerSummary(
      totalEvents: json['total_events'] ?? 0,
      totalPendaftar: json['total_pendaftar'] ?? 0,
      totalHadir: json['total_hadir'] ?? 0,
    );
  }

  double get avgAttendance => totalPendaftar > 0
      ? (totalHadir / totalPendaftar * 100)
      : 0;
}

class EventAnalytics {
  final Map<String, dynamic> event;
  final double attendanceRate;
  final int? kapasitas;
  final int? sisaKuota;
  final int totalPendaftar;
  final int pendaftarAktif;
  final int totalHadir;
  final int totalTepat;
  final int totalTerlambat;

  EventAnalytics({
    required this.event,
    required this.attendanceRate,
    this.kapasitas,
    this.sisaKuota,
    this.totalPendaftar = 0,
    this.pendaftarAktif = 0,
    this.totalHadir = 0,
    this.totalTepat = 0,
    this.totalTerlambat = 0,
  });

  factory EventAnalytics.fromJson(Map<String, dynamic> json) {
    final eventData = json['event'] is Map<String, dynamic>
        ? json['event'] as Map<String, dynamic>
        : <String, dynamic>{};

    return EventAnalytics(
      event: eventData,
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
      kapasitas: json['kapasitas'] is int ? json['kapasitas'] as int : null,
      sisaKuota: json['sisa_kuota'] is int ? json['sisa_kuota'] as int : null,
      totalPendaftar: json['total_pendaftar'] ?? eventData['total_pendaftar'] ?? 0,
      pendaftarAktif: json['pendaftar_aktif'] ?? eventData['pendaftar_aktif'] ?? 0,
      totalHadir: json['total_hadir'] ?? 0,
      totalTepat: json['total_tepat'] ?? 0,
      totalTerlambat: json['total_terlambat'] ?? 0,
    );
  }
}
