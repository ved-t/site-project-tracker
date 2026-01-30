import 'package:flutter/material.dart';

class EmptyStateArrow extends StatelessWidget {
  const EmptyStateArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _CurvedArrowPainter(),
      ),
    );
  }
}

class _CurvedArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    /// Start near top-left
    path.moveTo(size.width * 0.1, size.height * 0.2);

    /// Smooth curve toward bottom-right (FAB direction)
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.7,
    );

    canvas.drawPath(path, paint);

    /// Arrow head
    final arrowHeadPath = Path();
    arrowHeadPath.moveTo(size.width * 0.75, size.height * 0.7);
    arrowHeadPath.lineTo(size.width * 0.68, size.height * 0.62);
    arrowHeadPath.moveTo(size.width * 0.75, size.height * 0.7);
    arrowHeadPath.lineTo(size.width * 0.82, size.height * 0.62);

    canvas.drawPath(arrowHeadPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
