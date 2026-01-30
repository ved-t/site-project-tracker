class LLMExpenseDraft {
  final String? title;
  final double? amount;
  final String? siteId;
  final String? categoryId;
  final String? vendorId;
  final DateTime? date;
  final String? remarks;

  LLMExpenseDraft({
    this.title,
    this.amount,
    this.siteId,
    this.categoryId,
    this.vendorId,
    this.date,
    this.remarks,
  });

  bool get isComplete =>
      amount != null &&
      siteId != null &&
      categoryId != null &&
      vendorId != null;

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'site_id': siteId,
    'category_id': categoryId,
    'vendor_id': vendorId,
    'date': date?.toIso8601String(),
    'remarks': remarks,
  };
}
