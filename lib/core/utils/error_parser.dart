/// Centralized error parser for user-friendly error messages.
/// Eliminates duplicated _parseError methods across all providers.
class ErrorParser {
  ErrorParser._();

  /// Parse an exception to a user-friendly message
  static String parse(dynamic e) {
    if (e == null) return 'Terjadi kesalahan';
    
    final message = e.toString();
    
    // Network errors
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('socket')) {
      return 'Tidak ada koneksi internet';
    }
    
    // Timeout errors
    if (message.toLowerCase().contains('timeout')) {
      return 'Koneksi timeout, coba lagi';
    }
    
    // Authentication errors
    if (message.contains('401') ||
        message.toLowerCase().contains('sesi telah') ||
        message.toLowerCase().contains('unauthorized')) {
      return 'Sesi berakhir, silakan login ulang';
    }
    
    // Forbidden
    if (message.contains('403') || message.toLowerCase().contains('forbidden')) {
      return 'Anda tidak memiliki akses';
    }
    
    // Not found
    if (message.contains('404') || message.toLowerCase().contains('not found')) {
      return 'Data tidak ditemukan';
    }
    
    // Server errors
    if (message.toLowerCase().contains('500') ||
        message.toLowerCase().contains('server error') ||
        message.toLowerCase().contains('internal server')) {
      return 'Terjadi kesalahan server';
    }

    // Truncate very long messages
    if (message.length > 150) {
      return 'Terjadi kesalahan';
    }
    
    return message;
  }
}