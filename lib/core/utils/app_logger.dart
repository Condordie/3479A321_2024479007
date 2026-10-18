import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Fachada estática centralizada para el registro de eventos y depuración.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) {
    if (kDebugMode) _logger.d(message);
  }

  static void info(String message) {
    if (kDebugMode) _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}