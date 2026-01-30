import '../entities/formula.dart';

abstract class FormulasRepository {
  Future<List<Formula>> getFormulas(String siteId);
  Future<void> saveFormula(Formula formula);
  Future<void> deleteFormula(String id);
}
