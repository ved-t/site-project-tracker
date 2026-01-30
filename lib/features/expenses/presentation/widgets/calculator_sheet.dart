import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../sites/settings/formulas/domain/entities/formula.dart';
import '../../../sites/settings/formulas/presentation/widgets/formula_picker_sheet.dart';
import '../../../../../core/utils/dialog_utils.dart';
import '../../../../../core/widgets/bouncing_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CalculatorSheet extends StatefulWidget {
  final String siteId;
  final double? initialValue;
  final void Function(double value) onApply;

  const CalculatorSheet({
    super.key,
    required this.siteId,
    this.initialValue,
    required this.onApply,
  });

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _expression = '';
  Formula? _activeFormula;
  final Map<String, TextEditingController> _variableCtrls = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _expression = widget.initialValue!.toString();
    }
  }

  @override
  void dispose() {
    for (var controller in _variableCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        _expression += value;
      }
    });
  }

  void _activateFormula(Formula formula) {
    setState(() {
      _activeFormula = formula;
      _variableCtrls.clear();
      for (final v in formula.variables) {
        _variableCtrls[v] = TextEditingController();
        _variableCtrls[v]!.addListener(() => setState(() {}));
      }
    });
  }

  double? _evaluateExpression() {
    try {
      if (_expression.isEmpty) return null;
      final parser = Parser();
      final exp = parser.parse(
        _expression.replaceAll('×', '*').replaceAll('÷', '/'),
      );
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());
      return double.parse(result.toStringAsFixed(2));
    } catch (_) {
      return null;
    }
  }

  double? _evaluateFormula() {
    try {
      if (_activeFormula == null) return null;
      var expr = _activeFormula!.expression;

      for (final entry in _variableCtrls.entries) {
        final value = double.tryParse(entry.value.text) ?? 0;
        expr = expr.replaceAll(entry.key, value.toString());
      }

      final parser = Parser();
      final exp = parser.parse(expr);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());
      return double.parse(result.toStringAsFixed(2));
    } catch (_) {
      return null;
    }
  }

  double? _evaluate() {
    return _activeFormula == null ? _evaluateExpression() : _evaluateFormula();
  }

  @override
  Widget build(BuildContext context) {
    final result = _evaluate();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header with Formula Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeFormula == null ? 'Calculator' : _activeFormula!.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_activeFormula != null)
                TextButton.icon(
                  onPressed: () => setState(() => _activeFormula = null),
                  icon: const Icon(LucideIcons.calculator),
                  label: const Text('Keypad'),
                )
              else
                IconButton(
                  icon: const Icon(LucideIcons.sigma),
                  onPressed: () {
                    showAnimatedDialog(
                      context,
                      Dialog(
                        insetPadding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SingleChildScrollView(
                          child: FormulaPickerSheet(
                            siteId: widget.siteId,
                            onSelected: _activateFormula,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),

          /// Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _activeFormula == null
                      ? (_expression.isEmpty ? '0' : _expression)
                      : _activeFormula!.expression,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result == null ? '' : '= ₹ $result',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Input Method (Keypad or Variables)
          if (_activeFormula == null) _buildKeypad() else _buildFormulaInputs(),

          const SizedBox(height: 16),

          /// Apply
          SizedBox(
            width: double.infinity,
            child: BouncingButton(
              child: ElevatedButton(
                onPressed: result == null
                    ? null
                    : () {
                        widget.onApply(result);
                        Navigator.pop(context);
                      },
                child: const Text('Apply Amount'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '⌫', '+'],
      ['C'],
    ];

    final operatorColor = Theme.of(
      context,
    ).colorScheme.primary; // Indigo/Blue from theme
    const operatorTextColor = Colors.white;

    return Column(
      children: keys.map((row) {
        return Row(
          children: row.map((key) {
            // Specifically highlight math operators + C + Backspace, or just the main math ones?
            // "operator buttons (/, x, -, +)" was the request.
            // Let's stick to strict request for the "different color".
            // C and Backspace are technically editing actions.
            // I'll style /, x, -, + as Primary.
            // C and Backspace maybe just distinct or same?
            // Let's make logical operators Primary.
            final isMathOp = ['÷', '×', '-', '+'].contains(key);
            final isClear = key == 'C';
            final isBackspace = key == '⌫';

            Color? bgColor;
            Color? fgColor;

            if (isMathOp) {
              bgColor = operatorColor;
              fgColor = operatorTextColor;
            } else if (isClear || isBackspace) {
              // Maybe keep them subtle or slightly different?
              // Let's leave them lighter or default to distinguish from numbers?
              // Or make them red/orange for "action"?
              // Prompt said: "Make the operator buttons (/, x, -, +) a different color"
              // It didn't mention C/Backspace. I'll keep them default/subtle to focus on the request.
              bgColor = Colors.grey[200];
              fgColor = Colors.black87;
            } else {
              // Numbers
              bgColor = Colors.white;
              fgColor = Colors.black87;
            }

            // Adjust styles for specific keys if needed
            if (isMathOp) {
              // Strong emphasis
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: BouncingButton(
                  child: ElevatedButton(
                    onPressed: () => _onKeyTap(key),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: bgColor,
                      foregroundColor: fgColor,
                      elevation:
                          0, // Flat look or slight elevation? Default is usually fine.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        // side: BorderSide(color: Colors.grey[300]!), // Optional border
                      ),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isMathOp
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildFormulaInputs() {
    // Determine the bottom inset to handle keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: _activeFormula!.variables.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _variableCtrls[v],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: v.toUpperCase(),
                // border: const OutlineInputBorder(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
