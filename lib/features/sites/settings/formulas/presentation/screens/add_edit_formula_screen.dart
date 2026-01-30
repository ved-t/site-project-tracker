import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../../core/utils/formula_evaluator.dart';
import '../../domain/entities/formula.dart';
import '../../presentation/controllers/formulas_controller.dart';

class AddEditFormulaScreen extends ConsumerStatefulWidget {
  final String siteId;
  final Formula? formula;

  const AddEditFormulaScreen({super.key, required this.siteId, this.formula});

  @override
  ConsumerState<AddEditFormulaScreen> createState() =>
      _AddEditFormulaScreenState();
}

class _AddEditFormulaScreenState extends ConsumerState<AddEditFormulaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _expressionController;
  List<String> _variables = [];

  // For testing
  Map<String, TextEditingController> _testInputs = {};
  double? _testResult;
  String? _testError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.formula?.name ?? '');
    _expressionController = TextEditingController(
      text: widget.formula?.expression ?? '',
    );
    _variables = List.from(widget.formula?.variables ?? []);
    _updateTestInputs();
  }

  void _updateTestInputs() {
    // Keep existing controllers if possible, add new ones
    final newInputs = <String, TextEditingController>{};
    for (var v in _variables) {
      if (_testInputs.containsKey(v)) {
        newInputs[v] = _testInputs[v]!;
      } else {
        newInputs[v] = TextEditingController(text: '0');
      }
    }
    setState(() {
      _testInputs = newInputs;
    });
  }

  void _testCalculation() {
    setState(() {
      _testError = null;
      _testResult = null;
    });

    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      setState(() {
        _testError = 'Please enter a formula expression';
      });
      return;
    }

    try {
      final inputs = <String, double>{};
      for (var v in _variables) {
        final controller = _testInputs[v];
        if (controller != null) {
          final val = double.tryParse(controller.text);
          if (val == null) {
            setState(() {
              _testError = 'Invalid value for variable "$v"';
            });
            return;
          }
          inputs[v] = val;
        }
      }

      final result = FormulaEvaluator.evaluate(expression, inputs);
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      String errorMessage = 'Invalid formula. Please check the syntax.';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('empty') ||
          errorString.contains('formatexception')) {
        errorMessage = 'Formula syntax is incorrect or incomplete.';
      } else if (errorString.contains('variable') ||
          errorString.contains('not bound')) {
        errorMessage = 'One or more variables are not recognized.';
      }

      setState(() {
        _testError = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formula == null ? 'New Formula' : 'Edit Formula'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Formula Name',
                  // border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Variables',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._variables.map(
                    (v) => Chip(
                      label: Text(v),
                      deleteIcon: const Icon(LucideIcons.trash2, size: 16),
                      onDeleted: () {
                        setState(() {
                          _variables.remove(v);
                          _updateTestInputs();
                        });
                      },
                    ),
                  ),
                  ActionChip(
                    label: const Icon(Icons.add, size: 18),
                    onPressed: _addVariable,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expressionController,
                decoration: const InputDecoration(
                  labelText: 'Expression (use variables above)',
                  hintText: 'e.g. Length * Width * Thickness',
                  // border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (_) {
                  setState(() {
                    _testResult = null; // reset test on change
                  });
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Test Calculator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_testError != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _testError!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ..._variables.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _testInputs[v],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: v,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      // border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _testCalculation,
                child: const Text('Calculate'),
              ),
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Result: ${_testResult!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addVariable() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Variable'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Variable Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty && !_variables.contains(text)) {
                  setState(() {
                    _variables.add(text);
                    _updateTestInputs();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final formula = Formula(
        id: widget.formula?.id ?? const Uuid().v4(),
        siteId: widget.siteId,
        name: _nameController.text.trim(),
        expression: _expressionController.text.trim(),
        variables: _variables,
        createdAt: widget.formula?.createdAt ?? DateTime.now(),
      );

      ref.read(formulasProvider(widget.siteId).notifier).save(formula);
      Navigator.pop(context);
    }
  }
}
