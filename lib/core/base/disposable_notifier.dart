import 'package:flutter/foundation.dart';

/// Base class for all ChangeNotifier that is safe from dispose and build phase issues.
/// Prevents crash when notifyListeners() is called after widget is unmounted
/// and prevents setState() during build phase.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;
  bool _isNotifying = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;

    // Prevent re-entrant calls
    if (_isNotifying) return;

    _isNotifying = true;

    // Defer notification to avoid build phase conflicts
    Future.microtask(() {
      _isNotifying = false;
      if (!_disposed) {
        super.notifyListeners();
      }
    });
  }

  /// Notify listeners immediately without deferring.
  /// Use this only when you're sure you're not in build phase.
  void notifyListenersImmediate() {
    if (_disposed || _isNotifying) return;
    super.notifyListeners();
  }

  bool get isDisposed => _disposed;
}

/// Legacy alias for backward compatibility
typedef DisposableChangeNotifier = SafeChangeNotifier;