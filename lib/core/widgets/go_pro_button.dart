import 'package:flutter/material.dart';
import 'bouncing_button.dart';

class GoProButton extends StatelessWidget {
  final VoidCallback onTap;

  const GoProButton({super.key, required this.onTap});

  static const bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: BouncingButton(
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(2), // Border thickness
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC371), Color(0xFFFF5F6D), Color(0xFF845EC2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F1F1F), Color(0xFF2C2C2C)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text(
                  'Go Pro',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
