import '../../domain/entities/formula.dart';
import '../../domain/repositories/formulas_repository.dart';
import '../datasources/formulas_local_ds.dart';

class FormulasRepositoryImpl implements FormulasRepository {
  final FormulasLocalDataSource dataSource;

  FormulasRepositoryImpl(this.dataSource);

  @override
  Future<List<Formula>> getFormulas(String siteId) async {
    return await dataSource.getFormulas(siteId);
  }

  @override
  Future<void> saveFormula(Formula formula) async {
    await dataSource.saveFormula(formula);
  }

  @override
  Future<void> deleteFormula(String id) async {
    await dataSource.deleteFormula(id);
  }
}
