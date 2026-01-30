import 'package:math_expressions/math_expressions.dart';

class FormulaEvaluator {
  static double evaluate(
    String expressionString,
    Map<String, double> variables,
  ) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expressionString);
      ContextModel cm = ContextModel();

      variables.forEach((key, value) {
        cm.bindVariable(Variable(key), Number(value));
      });

      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval;
    } catch (e) {
      throw Exception('Invalid formula: $e');
    }
  }

  static bool validate(String expressionString, List<String> variableNames) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expressionString);
      // We can't easily valid variables binding without values,
      // but parsing checks syntax.
      // To check if variables match, we could attempt to verify undefined vars,
      // but math_expressions might just fail or not complain until eval.
      return true;
    } catch (e) {
      return false;
    }
  }
}
