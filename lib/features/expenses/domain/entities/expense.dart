class Expense {
  final String id;
  final String siteId;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String vendor;
  final bool isPaymentCompleted;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;

  Expense({
    required this.id,
    required this.siteId,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.vendor,
    this.isPaymentCompleted = false,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  String toString() {
    return 'Expense(id: $id, siteId: $siteId, title: $title, amount: $amount, date: $date, categoryId: $categoryId, vendor: $vendor, isPaymentCompleted: $isPaymentCompleted, remarks: $remarks, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId)';
  }
}
