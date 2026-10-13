import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_number_logic.dart';

class BaseCalculatorScreen extends StatefulWidget {
  const BaseCalculatorScreen({super.key, required this.onMenu});
  final VoidCallback onMenu;

  @override
  State<BaseCalculatorScreen> createState() => _BaseCalculatorScreenState();
}

class _BaseCalculatorScreenState extends State<BaseCalculatorScreen> {
  final _firstController = TextEditingController();
  final _secondController = TextEditingController();
  NumberBase _firstBase = NumberBase.decimal;
  NumberBase _secondBase = NumberBase.decimal;
  NumberBase _outputBase = NumberBase.decimal;
  BaseOperation _operation = BaseOperation.add;
  String _result = '—';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _firstController.addListener(_calculate);
    _secondController.addListener(_calculate);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_firstController.text.trim().isEmpty ||
        _secondController.text.trim().isEmpty) {
      setState(() {
        _result = '—';
        _error = '';
      });
      return;
    }
    try {
      final result = calculateBaseNumber(
        first: _firstController.text,
        firstBase: _firstBase,
        second: _secondController.text,
        secondBase: _secondBase,
        outputBase: _outputBase,
        operation: _operation,
      );
      setState(() {
        _result = result;
        _error = '';
      });
    } on BaseNumberException catch (error) {
      setState(() {
        _result = '—';
        _error = error.message;
      });
    }
  }

  void _clear() {
    _firstController.clear();
    _secondController.clear();
    setState(() {
      _result = '—';
      _error = '';
    });
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Base calculator'),
      leading: IconButton(
        tooltip: 'Open menu',
        icon: const Icon(Icons.menu_rounded),
        onPressed: widget.onMenu,
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Calculate across bases',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Use a different base for every input and the result.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _operand(context, 'First operand', _firstController, _firstBase, (base) {
            if (base == null) return;
            setState(() => _firstBase = base);
            _calculate();
          }),
          const SizedBox(height: 14),
          _operationSelector(),
          const SizedBox(height: 14),
          _operand(context, 'Second operand', _secondController, _secondBase, (base) {
            if (base == null) return;
            setState(() => _secondBase = base);
            _calculate();
          }),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Output base',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              _baseSelector(_outputBase, (base) {
                if (base == null) return;
                setState(() => _outputBase = base);
                _calculate();
              }),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESULT  ${_outputBase.label}',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Clear calculator',
                          onPressed: _clear,
                          icon: const Icon(Icons.clear_rounded),
                        ),
                        IconButton(
                          tooltip: 'Copy result',
                          onPressed: _result == '—' ? null : _copyResult,
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _operand(
    BuildContext context,
    String label,
    TextEditingController controller,
    NumberBase base,
    ValueChanged<NumberBase?> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Enter value',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 132, child: _baseSelector(base, onChanged)),
        ],
      ),
    ],
  );

  Widget _baseSelector(
    NumberBase value,
    ValueChanged<NumberBase?> onChanged,
  ) => DropdownButtonFormField<NumberBase>(
    initialValue: value,
    isExpanded: true,
    decoration: const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    ),
    items: NumberBase.values
        .map((base) => DropdownMenuItem(
              value: base,
              child: Text(base.label, overflow: TextOverflow.ellipsis),
            ))
        .toList(),
    onChanged: onChanged,
  );

  Widget _operationSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Operation', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      DropdownButtonFormField<BaseOperation>(
        initialValue: _operation,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        items: BaseOperation.values
            .map((operation) => DropdownMenuItem(
                  value: operation,
                  child: Text(
                    '${operation.symbol}  ${operation.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (operation) {
          if (operation == null) return;
          setState(() => _operation = operation);
          _calculate();
        },
      ),
    ],
  );
}
