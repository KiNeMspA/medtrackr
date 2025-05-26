import 'dart:developer';

class Logger {
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', error: error, stackTrace: stackTrace);
  }
}