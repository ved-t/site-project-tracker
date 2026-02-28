import 'package:flutter/material.dart';

class SpendBarChart extends StatelessWidget {
  final dynamic data;

  const SpendBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // data is ReportSpendOverTimeModel (or dynamic for now)
    // we can access data.total (List<ReportTimeSeriesItemModel>)
    // For now, just showing placeholder
    return Card(
      child: SizedBox(height: 220, child: Center(child: Text("Bar Chart"))),
    );
  }
}
