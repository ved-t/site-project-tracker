class CategorySpendCalculator {
  static Map<String, double> compute(List expenses) {
    Map<String, double> result = {};

    for (var e in expenses) {
      final category = e.categoryId;

      result[category] = (result[category] ?? 0) + e.amount;
    }

    return result;
  }
}