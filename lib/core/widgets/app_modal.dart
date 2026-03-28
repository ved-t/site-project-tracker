import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';

class AppModal extends StatelessWidget {
  final Widget child;
  final EdgeInsets? insetPadding;
  final double? borderRadius;
  final bool scrollable;

  const AppModal({
    super.key,
    required this.child,
    this.insetPadding,
    this.borderRadius,
    this.scrollable = true,
  });

  /// Static helper to show the modal using the app's animated dialog
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    EdgeInsets? insetPadding,
    double? borderRadius,
    bool scrollable = true,
  }) {
    return showAnimatedDialog<T>(
      context,
      AppModal(
        insetPadding: insetPadding,
        borderRadius: borderRadius,
        scrollable: scrollable,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (scrollable) {
      content = SingleChildScrollView(child: child);
    }

    return Dialog(
      insetPadding: insetPadding ?? const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
      ),
      child: content,
    );
  }
}
