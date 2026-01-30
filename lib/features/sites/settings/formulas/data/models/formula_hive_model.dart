import 'package:hive/hive.dart';
import '../../domain/entities/formula.dart';

part 'formula_hive_model.g.dart';

@HiveType(typeId: 5)
class FormulaHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String siteId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String expression;

  @HiveField(4)
  final List<String> variables;

  @HiveField(5)
  final DateTime createdAt;

  FormulaHiveModel({
    required this.id,
    required this.siteId,
    required this.name,
    required this.expression,
    required this.variables,
    required this.createdAt,
  });

  factory FormulaHiveModel.fromEntity(Formula formula) => FormulaHiveModel(
    id: formula.id,
    siteId: formula.siteId,
    name: formula.name,
    expression: formula.expression,
    variables: formula.variables,
    createdAt: formula.createdAt,
  );

  Formula toEntity() => Formula(
    id: id,
    siteId: siteId,
    name: name,
    expression: expression,
    variables: variables,
    createdAt: createdAt,
  );
}
