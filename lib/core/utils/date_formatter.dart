import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static final _days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  static final _shortDays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  static String dayName(DateTime date) => _days[date.weekday % 7];
  static String shortDayName(DateTime date) => _shortDays[date.weekday % 7];
  static String monthName(int month) => _months[month - 1];

  static String fullDate(DateTime date) {
    return '${date.day} ${monthName(date.month)} ${date.year}';
  }

  static String fullDateTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${fullDate(date)} $h:$m';
  }

  static String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static List<DateTime> weekFromToday() {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  static List<DateTime> monthsFromNow(int count) {
    final now = DateTime.now();
    return List.generate(count, (i) => DateTime(now.year, now.month + i, 1));
  }

  static String formatTime(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return tanggal;
    }
  }

  static String formatRelative(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return _relativeTime(dt, DateTime.now());
    } catch (_) {
      return iso;
    }
  }

  static String formatDuration(DateTime start, DateTime? end) {
    if (end == null) return formatTime(start.toIso8601String());
    final diff = end.difference(start);
    if (diff.inHours >= 1) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    }
    return '${diff.inMinutes}m';
  }

  static String countdown(DateTime target) {
    final now = DateTime.now();
    if (target.isBefore(now)) return 'Sudah lewat';
    final diff = target.difference(now);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bulan lagi';
    if (diff.inDays > 0) return '${diff.inDays} hari lagi';
    if (diff.inHours > 0) return '${diff.inHours} jam lagi';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lagi';
    return 'Sebentar lagi';
  }

  static String _relativeTime(DateTime dt, DateTime now) {
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
