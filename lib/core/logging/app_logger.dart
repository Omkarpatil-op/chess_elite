import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static LogLevel minLevel = kReleaseMode ? LogLevel.warning : LogLevel.debug;

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;

    final sanitized = _redactSensitiveData(message);
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final tag = level.name.toUpperCase().padRight(5);

    debugPrint('[$timestamp][$tag] $sanitized');
    if (error != null) {
      debugPrint('   Error: $error');
    }
    if (stackTrace != null && level == LogLevel.error) {
      debugPrint('   StackTrace:\n$stackTrace');
    }
  }

  static String _redactSensitiveData(String input) {
    // Redact bearer tokens, passwords, API keys
    return input
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*'), 'Bearer [REDACTED]')
        .replaceAll(RegExp(r'password["\s:=]+[^\s,]+'), 'password: [REDACTED]')
        .replaceAll(RegExp(r'apiKey["\s:=]+[^\s,]+'), 'apiKey: [REDACTED]');
  }
}
