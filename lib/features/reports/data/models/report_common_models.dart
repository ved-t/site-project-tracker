class ReportTimeSeriesItemModel {
  final DateTime date;
  final double totalAmount;

  ReportTimeSeriesItemModel({required this.date, required this.totalAmount});

  factory ReportTimeSeriesItemModel.fromJson(Map<String, dynamic> json) {
    return ReportTimeSeriesItemModel(
      date: DateTime.parse(json['date']),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
}

class ReportCategorySpendModel {
  final String categoryId;
  final String? categoryName;
  final double totalAmount;

  ReportCategorySpendModel({
    required this.categoryId,
    this.categoryName,
    required this.totalAmount,
  });

  factory ReportCategorySpendModel.fromJson(Map<String, dynamic> json) {
    return ReportCategorySpendModel(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
}

class ReportVendorSpendModel {
  final String vendorName;
  final double totalAmount;
  final bool isMisc;

  ReportVendorSpendModel({
    required this.vendorName,
    required this.totalAmount,
    required this.isMisc,
  });

  factory ReportVendorSpendModel.fromJson(Map<String, dynamic> json) {
    return ReportVendorSpendModel(
      vendorName: json['vendor_name'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      isMisc: json['is_misc'] ?? false,
    );
  }
}

class ReportCategoryTimeSeriesModel {
  final String categoryId;
  final String? categoryName;
  final List<ReportTimeSeriesItemModel> series;

  ReportCategoryTimeSeriesModel({
    required this.categoryId,
    this.categoryName,
    required this.series,
  });

  factory ReportCategoryTimeSeriesModel.fromJson(Map<String, dynamic> json) {
    return ReportCategoryTimeSeriesModel(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      series: (json['series'] as List)
          .map((e) => ReportTimeSeriesItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ReportVendorTimeSeriesModel {
  final String vendorName;
  final bool isMisc;
  final List<ReportTimeSeriesItemModel> series;

  ReportVendorTimeSeriesModel({
    required this.vendorName,
    required this.isMisc,
    required this.series,
  });

  factory ReportVendorTimeSeriesModel.fromJson(Map<String, dynamic> json) {
    return ReportVendorTimeSeriesModel(
      vendorName: json['vendor_name'],
      isMisc: json['is_misc'] ?? false,
      series: (json['series'] as List)
          .map((e) => ReportTimeSeriesItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ReportSpendOverTimeModel {
  final List<ReportTimeSeriesItemModel> total;
  final List<ReportCategoryTimeSeriesModel> categories;
  final List<ReportVendorTimeSeriesModel> vendors;

  ReportSpendOverTimeModel({
    required this.total,
    required this.categories,
    required this.vendors,
  });

  factory ReportSpendOverTimeModel.fromJson(Map<String, dynamic> json) {
    return ReportSpendOverTimeModel(
      total: (json['total'] as List)
          .map((e) => ReportTimeSeriesItemModel.fromJson(e))
          .toList(),
      categories: (json['categories'] as List)
          .map((e) => ReportCategoryTimeSeriesModel.fromJson(e))
          .toList(),
      vendors: (json['vendors'] as List)
          .map((e) => ReportVendorTimeSeriesModel.fromJson(e))
          .toList(),
    );
  }
}
