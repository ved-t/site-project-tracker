import 'package:flutter/material.dart';

class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine the border radius or default to 16
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(0.0, _isPressed ? -2.0 : 0.0), // Slight lift up
      decoration: BoxDecoration(
        color: widget.color ?? Colors.white,
        borderRadius: radius,
        border: widget.border,
        boxShadow:
            widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.05),
                blurRadius: _isPressed ? 16 : 10,
                offset: Offset(0, _isPressed ? 8 : 4),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          onHighlightChanged: (isHighlighted) {
            setState(() => _isPressed = isHighlighted);
          },
          child: widget.child,
        ),
      ),
    );
  }
}
