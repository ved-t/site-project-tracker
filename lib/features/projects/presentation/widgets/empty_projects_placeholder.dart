import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_arrow.dart';

class EmptyProjectsPlaceholder extends StatelessWidget {
  const EmptyProjectsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.apartment, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Add your first project',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create a site to start tracking expenses',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        Positioned(
          right: 24,
          bottom: 90,
          child: EmptyStateArrow(),
        ),
      ],
    );
  }
}
