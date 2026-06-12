/// Input validators for forms
class Validators {
  Validators._();

  /// Email validation regex (RFC 5322 compliant)
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$",
  );

  static final RegExp _upperCase = RegExp(r'[A-Z]');
  static final RegExp _lowerCase = RegExp(r'[a-z]');
  static final RegExp _number = RegExp(r'[0-9]');
  static final RegExp _symbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email tidak valid';
    }
    return null;
  }

  /// Validate password for registration (full validation)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!_upperCase.hasMatch(value)) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!_lowerCase.hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!_number.hasMatch(value)) {
      return 'Password harus mengandung angka';
    }
    if (!_symbol.hasMatch(value)) {
      return 'Password harus mengandung simbol';
    }
    return null;
  }

  /// Validate password for login (minimal validation)
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String field = 'Field ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    return null;
  }
}