import 'package:flutter/foundation.dart';

/// Fachada estática centralizada para el registro de eventos y depuración.
class AppLogger {

  static void debug(String message) {
    if (kDebugMode) AppLogger.debug(message);
  }

  static void info(String message) {
    if (kDebugMode) AppLogger.info(message);
  }

  static void warning(String message) {
    AppLogger.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('ERROR: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}