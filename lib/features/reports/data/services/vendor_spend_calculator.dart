class VendorSpendCalculator {
  static Map<String, double> compute(List expenses) {
    Map<String, double> result = {};

    for (var e in expenses) {
      // Expense entity uses `vendor` (a String name), not `vendorId`
      final vendor = (e.vendor as String?) ?? 'Unknown';

      result[vendor] = (result[vendor] ?? 0) + (e.amount as double);
    }

    return result;
  }
}