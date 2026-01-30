import 'package:flutter/material.dart';

class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;

  const SuccessCheckmark({super.key, this.size = 24, this.color});

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CheckmarkPainter(
              progress: _animation.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Start slightly left of center
    final start = Offset(size.width * 0.2, size.height * 0.5);
    // Bottom pivot
    final mid = Offset(size.width * 0.45, size.height * 0.75);
    // End top right
    final end = Offset(size.width * 0.8, size.height * 0.25);

    if (progress > 0) {
      path.moveTo(start.dx, start.dy);
      // First leg
      final p1 = progress * 1.5; // Draw first leg faster
      if (p1 <= 1.0) {
        path.lineTo(
          start.dx + (mid.dx - start.dx) * p1,
          start.dy + (mid.dy - start.dy) * p1,
        );
      } else {
        path.lineTo(mid.dx, mid.dy);
        // Second leg
        final p2 = (progress - 0.66) * 3;
        if (p2 > 0) {
          path.lineTo(
            mid.dx + (end.dx - mid.dx) * p2,
            mid.dy + (end.dy - mid.dy) * p2,
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
