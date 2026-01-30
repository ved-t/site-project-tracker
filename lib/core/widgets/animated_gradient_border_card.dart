// import 'dart:async';
// import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedGradientBorderCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double strokeWidth;
  final Duration animationDuration;
  final bool animate;
  final Color? color;

  const AnimatedGradientBorderCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.strokeWidth = 2,
    this.animationDuration = const Duration(milliseconds: 2200),
    this.animate = true,
    this.color,
  });

  @override
  State<AnimatedGradientBorderCard> createState() =>
      _AnimatedGradientBorderCardState();
}

class _AnimatedGradientBorderCardState extends State<AnimatedGradientBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Timer? _timer;
  // final _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.animate) {
      // _controller.forward();
      // _scheduleReplay();
    }
  }

  // void _scheduleReplay() {
  //   _timer?.cancel();
  //   // Random duration between 5 and 15 seconds
  //   // final seconds = 5 + _random.nextInt(11); // 5 to 15
  //   // _timer = Timer(Duration(seconds: seconds), () {
  //   //   if (mounted) {
  //   //     replay();
  //   //     _scheduleReplay();
  //   //   }
  //   // });
  // }

  @override
  void dispose() {
    // _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void replay() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BorderSweepPainter(
        animation: _controller,
        radius: widget.borderRadius,
        strokeWidth: widget.strokeWidth,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}

class _BorderSweepPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;
  final double strokeWidth;

  _BorderSweepPainter({
    required this.animation,
    required this.radius,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A8A), // Navy
          Color(0xFF60A5FA), // Light blue
        ],
      ).createShader(rect);

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(strokeWidth / 2),
          Radius.circular(radius),
        ),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
