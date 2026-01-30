import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Duration duration;
  final List<Color> colors;
  final List<BoxShadow>? boxShadow;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.duration = const Duration(seconds: 12),
    this.colors = const [
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
      Color(0xFF7C3AED),
    ],
    this.boxShadow,
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // Continuous loop without reversing
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Calculate alignment based on controller value (0.0 to 1.0)
        // representing angle 0 to 2*pi
        final double t = _controller.value;
        final double angle = t * 2 * pi;

        final begin = Alignment(cos(angle), sin(angle));

        // End alignment is opposite to begin
        final end = Alignment(-begin.x, -begin.y);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: widget.colors,
            ),
            boxShadow: widget.boxShadow,
          ),
          child: widget.child,
        );
      },
    );
  }
}
