import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/number_formatter.dart';
import 'basic_calculator_logic.dart';
import '../shared/calculator_key_button.dart';

class BasicCalculatorScreen extends StatefulWidget {
  const BasicCalculatorScreen({
    super.key,
    required this.preferences,
    required this.onMenu,
  });
  final SharedPreferences preferences;
  final VoidCallback onMenu;
  @override
  State<BasicCalculatorScreen> createState() => _BasicCalculatorScreenState();
}

class _BasicCalculatorScreenState extends State<BasicCalculatorScreen> {
  String _expression = '';
  String _lastExpression = '';
  String _result = '';
  String _error = '';
  bool _justEvaluated = false;

  void _press(String value) {
    setState(() {
      _error = '';
      if (_justEvaluated && RegExp(r'^[0-9.]$').hasMatch(value)) {
        _expression = '';
      }
      if (_justEvaluated &&
          !RegExp(r'^[0-9.]$').hasMatch(value) &&
          value != 'AC' &&
          value != 'X' &&
          value != '=') {
        _expression = _result;
      }
      if (value != '=') {
        _result = '';
        _lastExpression = '';
      }
      _justEvaluated = false;
      if (value == 'AC') {
        _expression = '';
        _lastExpression = '';
        _result = '';
        return;
      }
      if (value == 'X') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        return;
      }
      if (value == '=') {
        _evaluate();
        return;
      }
      if (value == '+/-') {
        _expression = _expression.startsWith('-')
            ? _expression.substring(1)
            : '-$_expression';
        return;
      }
      if (value == '%') {
        _expression += '/100';
        return;
      }
      _expression += value;
    });
  }

  void _evaluate() {
    try {
      final value = ExpressionParser(_expression).parse();
      _lastExpression = _expression;
      _result = formatNumber(value);
      _justEvaluated = true;
    } on ExpressionException catch (error) {
      _error = error.message;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Basic calculator'),
      leading: IconButton(
        tooltip: 'Open menu',
        icon: const Icon(Icons.menu_rounded),
        onPressed: widget.onMenu,
      ),
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final landscape = constraints.maxWidth > 600;
          return Flex(
            direction: landscape ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(flex: landscape ? 2 : 2, child: _display(context)),
              Expanded(
                flex: landscape ? 2 : 2,
                child: RepaintBoundary(child: _keypad(context)),
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _display(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_error.isNotEmpty) ...[
          Text(
            _error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _lastExpression,
            key: ValueKey(_lastExpression),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 8),
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
                    ?.copyWith(fontSize: 34, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _keypad(BuildContext context) {
    const rows = [
      ['AC', '%', 'X', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['.', '0', '00', '='],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = (constraints.maxWidth - calculatorKeyGap * 3) / 4;
          final cellHeight = (constraints.maxHeight - calculatorKeyGap * 4) / 5;
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: calculatorKeyGap,
            crossAxisSpacing: calculatorKeyGap,
            childAspectRatio: cellWidth / cellHeight,
            children: rows
                .expand(
                  (row) => row.map(
                    (key) => CalculatorKeyButton(
                      label: key,
                      icon: key == 'X' ? Icons.backspace_outlined : null,
                      backgroundColor: _buttonColor(context, key),
                      foregroundColor: _buttonForeground(context, key),
                      onPressed: () => _press(key),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Color _buttonColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == '=') return const Color(0xffff8a3d);
    if (key == 'AC') return const Color(0xff16a34a);
    if (key == 'X') return const Color(0xffdc2626);
    if (_operatorKeys.contains(key)) return colors.primary;
    return colors.surfaceContainerHighest;
  }

  Color _buttonForeground(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == '=' || key == 'AC' || key == 'X') return Colors.white;
    if (_operatorKeys.contains(key)) return colors.onPrimary;
    return colors.onSurface;
  }
}

const _operatorKeys = {'÷', '×', '-', '+'};
