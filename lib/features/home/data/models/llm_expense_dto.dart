class LLMExpenseDto {
  final String? title;
  final double? amount;
  final String? siteId;
  final String? categoryId;
  final String? vendorId;
  final DateTime? date;
  final String? remarks;

  LLMExpenseDto({
    this.title,
    this.amount,
    this.siteId,
    this.categoryId,
    this.vendorId,
    this.date,
    this.remarks,
  });

  factory LLMExpenseDto.fromJson(Map<String, dynamic> json) {
    return LLMExpenseDto(
      title: json['title'],
      amount: (json['amount'] as num?)?.toDouble(),
      siteId: json['site_id'],
      categoryId: json['category_id'],
      vendorId: json['vendor_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      remarks: json['remarks'],
    );
  }
}
