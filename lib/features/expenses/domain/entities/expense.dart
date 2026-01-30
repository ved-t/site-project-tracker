class Expense {
  final String id;
  final String siteId;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String vendor;
  final String? remarks;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.siteId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.vendor,
    this.remarks,
    required this.createdAt,
  });
}
