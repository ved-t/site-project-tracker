class SiteReport {
  final String siteId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalAmountSpent;
  final double todayExpense;
  final double avgExpensePerDay;
  final List<dynamic>
  categoryWiseSpent; // Using dynamic here to avoid importing data models in domain layer. ideally should be entity models
  final List<dynamic> vendorWiseSpent;
  final dynamic spendOverTime;

  const SiteReport({
    required this.siteId,
    this.startDate,
    this.endDate,
    required this.totalAmountSpent,
    required this.todayExpense,
    required this.avgExpensePerDay,
    required this.categoryWiseSpent,
    required this.vendorWiseSpent,
    required this.spendOverTime,
  });
}
