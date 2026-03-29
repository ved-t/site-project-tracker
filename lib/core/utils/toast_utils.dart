import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ToastUtils {
  static void show(String message, {bool isError = false, Duration? duration}) {
    final state = rootScaffoldMessengerKey.currentState;
    if (state == null) return;

    // Use a microtask/delay to ensure Scaffold registration has completed
    Future.microtask(() {
      if (!state.mounted) return;
      
      try {
        state.hideCurrentSnackBar();
        state.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: duration ?? const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        // This handles cases like the "no descendant Scaffolds" error gracefully
        // for cases where a toast is triggered but no Scaffold is currently on screen
        debugPrint('Could not show toast: $e');
      }
    });
  }
}
