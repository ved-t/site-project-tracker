import 'package:flutter/material.dart';

Future<T?> showAnimatedDialog<T>(BuildContext context, Widget child) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, a1, a2) => child,
    transitionBuilder: (context, a1, a2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: a1, child: child),
      );
    },
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
  );
}
