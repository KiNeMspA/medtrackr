// lib/core/utils/logger.dart
import 'dart:developer';

class Logger {
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', error: error, stackTrace: stackTrace);
  }

  static void logInfo(String message) {
    log('INFO: $message');
  }
}