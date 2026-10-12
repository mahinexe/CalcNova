import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../basic_calculator/basic_calculator_logic.dart';
import '../../core/utils/number_formatter.dart';
import '../shared/calculator_key_button.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({
    super.key,
    required this.preferences,
    required this.onMenu,
  });
  final SharedPreferences preferences;
  final VoidCallback onMenu;
  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  String _expression = '', _lastExpression = '', _result = '', _error = '';
  bool _degrees = true, _evaluated = false;
  void _press(String value) {
    setState(() {
      _error = '';
      if (_evaluated && RegExp(r'^[0-9.]$').hasMatch(value)) _expression = '';
      _evaluated = false;
      if (value == 'AC') {
        _expression = '';
        _lastExpression = '';
        _result = '';
      } else if (value == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          _lastExpression = _expression;
          final result = ExpressionParser(
            _expression,
            degrees: _degrees,
          ).parse();
          _result = formatNumber(result);
          _expression = _result;
          _evaluated = true;
        } on ExpressionException catch (e) {
          _error = e.message;
        }
      } else if (value == 'x²') {
        _expression = '($_expression)^2';
      } else if (value == 'x³') {
        _expression = '($_expression)^3';
      } else if (value == '√') {
        _expression += 'sqrt(';
      } else if (value == '∛') {
        _expression += 'cbrt(';
      } else if (value == 'xʸ') {
        _expression += '^';
      } else if (value == '1/x') {
        _expression += 'inv(';
      } else if (value == 'n!') {
        _expression += 'fact(';
      } else if (value == 'π') {
        _expression += 'pi';
      } else if (value == 'sin' ||
          value == 'cos' ||
          value == 'tan' ||
          value == 'asin' ||
          value == 'acos' ||
          value == 'atan' ||
          value == 'ln' ||
          value == 'log' ||
          value == 'abs' ||
          value == 'exp') {
        _expression += '$value(';
      } else {
        _lastExpression = '';
        _result = '';
        _expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Scientific calculator'),
      leading: IconButton(
        tooltip: 'Open menu',
        icon: const Icon(Icons.menu_rounded),
        onPressed: widget.onMenu,
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _degrees = !_degrees),
          child: Text(_degrees ? 'DEG' : 'RAD'),
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_error.isNotEmpty) ...[
                      Text(
                        _error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        _lastExpression,
                        key: ValueKey(_lastExpression),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 120),
                        child: FittedBox(
                          key: ValueKey(_expression),
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _result.isNotEmpty
                                ? _result
                                : (_expression.isEmpty ? '0' : _expression),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, keypadConstraints) => _scientificKeypad(
                    context,
                    keypadConstraints.maxWidth,
                    keypadConstraints.maxHeight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _scientificKeypad(BuildContext context, double width, double height) {
    const functions = [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log',
      '√',
      '∛',
      'x²',
      'x³',
      'xʸ',
      'n!',
      '1/x',
      'π',
      'e',
      'abs',
      'exp',
      '%',
      '(',
      ')',
    ];
    const operators = ['÷', '×', '-', '+', 'AC', '='];
    final functionKeys = [...functions, 'AC', 'DEL'];
    final lowerKeys = <String>[
      '7',
      '8',
      '9',
      operators[0],
      '4',
      '5',
      '6',
      operators[1],
      '1',
      '2',
      '3',
      operators[2],
      '.',
      '0',
      '00',
      operators[3],
      '',
      '',
      '',
      operators[5],
      '',
      '',
      '',
      '',
    ];
    final innerWidth = width - 24;
    final innerHeight = height - 20;
    final cellWidth = (innerWidth - calculatorKeyGap * 3) / 4;
    final sectionHeight = (innerHeight - calculatorKeyGap) / 2;
    final cellHeight = (sectionHeight - calculatorKeyGap * 5) / 6;
    final cellAspectRatio = cellWidth / cellHeight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: calculatorKeyGap,
              crossAxisSpacing: calculatorKeyGap,
              childAspectRatio: cellAspectRatio,
              children: functionKeys
                  .map((key) => _scientificKey(context, key))
                  .toList(),
            ),
          ),
          const SizedBox(height: calculatorKeyGap),
          Expanded(
            flex: 1,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: calculatorKeyGap,
              crossAxisSpacing: calculatorKeyGap,
              childAspectRatio: cellAspectRatio,
              children: lowerKeys
                  .map((key) => _scientificKey(context, key))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scientificKey(BuildContext context, String key) => key.isEmpty
      ? const SizedBox.expand()
      : CalculatorKeyButton(
          label: key,
          onPressed: () => _press(key),
          backgroundColor: _scientificButtonColor(context, key),
          foregroundColor: _scientificButtonForeground(context, key),
          icon: key == 'DEL' ? Icons.backspace_outlined : null,
        );

  Color _scientificButtonColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == '=') return const Color(0xffff8a3d);
    if (key == 'AC') return const Color(0xff16a34a);
    if (key == 'DEL') return const Color(0xffdc2626);
    if (_scientificKeys.contains(key)) {
      return colors.secondaryContainer;
    }
    if (_operatorKeys.contains(key)) return colors.primary;
    return colors.surfaceContainerHighest;
  }

  Color _scientificButtonForeground(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == '=' || key == 'AC' || key == 'DEL') return Colors.white;
    if (_scientificKeys.contains(key)) return colors.onSecondaryContainer;
    if (_operatorKeys.contains(key)) return colors.onPrimary;
    return colors.onSurface;
  }
}

const _scientificKeys = {
  'sin',
  'cos',
  'tan',
  'asin',
  'acos',
  'atan',
  'ln',
  'log',
  '√',
  '∛',
  'x²',
  'x³',
  'xʸ',
  'n!',
  '1/x',
  'π',
  'e',
  'abs',
  'exp',
  '%',
  '(',
  ')',
};

const _operatorKeys = {'÷', '×', '-', '+'};
