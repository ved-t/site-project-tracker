import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/formula.dart';
import '../../data/datasources/formulas_local_ds.dart';

final formulasLocalDsProvider = Provider((_) => FormulasLocalDataSource());

final formulasProvider =
    StateNotifierProvider.family<FormulasController, List<Formula>, String>(
      (ref, siteId) =>
          FormulasController(ref.read(formulasLocalDsProvider), siteId),
    );

class FormulasController extends StateNotifier<List<Formula>> {
  final FormulasLocalDataSource local;
  final String siteId;

  FormulasController(this.local, this.siteId) : super([]) {
    load();
  }

  Future<void> load() async {
    final formulas = await local.getFormulas(siteId);
    state = formulas;
  }

  Future<void> save(Formula formula) async {
    await local.saveFormula(formula);
    await load();
  }

  Future<void> delete(String id) async {
    await local.deleteFormula(id);
    await load();
  }
}
