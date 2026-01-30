class Formula {
  final String id;
  final String siteId;
  final String name;
  final String expression;
  final List<String> variables;
  final DateTime createdAt;

  Formula({
    required this.id,
    required this.siteId,
    required this.name,
    required this.expression,
    required this.variables,
    required this.createdAt,
  });
}
