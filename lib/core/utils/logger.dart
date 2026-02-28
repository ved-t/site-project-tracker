import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(message, name: name ?? 'DEBUG');
    }
  }

  static void info(String message, {String? name}) {
    developer.log(message, name: name ?? 'INFO');
  }

  static void warning(String message, {String? name}) {
    developer.log('⚠️ $message', name: name ?? 'WARNING');
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? name,
  }) {
    developer.log(
      '❌ $message',
      name: name ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void sync(String message) {
    developer.log('🔄 $message', name: 'SYNC');
  }
}
