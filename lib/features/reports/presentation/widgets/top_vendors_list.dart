import 'package:flutter/material.dart';

class TopVendorsList extends StatelessWidget {
  final List<dynamic> data;

  const TopVendorsList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // data is List<ReportVendorSpendModel>
    // It's already sorted by backend

    return Card(
      child: Column(
        children: data.take(5).map((e) {
          // e is ReportVendorSpendModel
          // using dynamic access for now
          return ListTile(
            title: Text(e.vendorName),
            trailing: Text("₹${e.totalAmount.toStringAsFixed(0)}"),
          );
        }).toList(),
      ),
    );
  }
}
