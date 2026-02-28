import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final List<dynamic> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 220,
        child: Center(child: Text("Pie Chart (${data.length} categories)")),
      ),
    );
  }
}
