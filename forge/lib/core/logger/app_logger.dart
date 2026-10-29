/// Core logger service for application-wide logging
class AppLogger {
  static const String _tag = 'AppLogger';

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[$_tag] DEBUG: $message');
    // ignore: avoid_print
    if (error != null) print('Error: $error');
    // ignore: avoid_print
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }

  /// Log info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[$_tag] INFO: $message');
    // ignore: avoid_print
    if (error != null) print('Error: $error');
    // ignore: avoid_print
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }

  /// Log warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[$_tag] WARNING: $message');
    // ignore: avoid_print
    if (error != null) print('Error: $error');
    // ignore: avoid_print
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[$_tag] ERROR: $message');
    // ignore: avoid_print
    if (error != null) print('Error: $error');
    // ignore: avoid_print
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }
}
