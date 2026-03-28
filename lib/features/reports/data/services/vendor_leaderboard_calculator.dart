class VendorLeaderboardCalculator {
  static List<MapEntry<String, double>> compute(List expenses) {
    Map<String, double> totals = {};

    for (var e in expenses) {
      // Expense entity uses `vendor` (a String name), not `vendorId`
      final vendor = (e.vendor as String?) ?? 'Unknown';

      totals[vendor] = (totals[vendor] ?? 0) + (e.amount as double);
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).toList();
  }
}