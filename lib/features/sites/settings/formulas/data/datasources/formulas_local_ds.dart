import 'package:hive/hive.dart';
import 'package:site_project_tracker/core/constants/hive_constants.dart';
import '../../domain/entities/formula.dart';
import '../models/formula_hive_model.dart';

class FormulasLocalDataSource {
  Future<Box<FormulaHiveModel>> _openBox() async {
    return Hive.openBox<FormulaHiveModel>(HiveBoxes.formulas);
  }

  Future<List<Formula>> getFormulas(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((f) => f.siteId == siteId)
        .map((e) => e.toEntity())
        .toList();
  }

  Future<void> saveFormula(Formula formula) async {
    final box = await _openBox();
    final hiveModel = FormulaHiveModel.fromEntity(formula);
    await box.put(formula.id, hiveModel);
  }

  Future<void> deleteFormula(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
