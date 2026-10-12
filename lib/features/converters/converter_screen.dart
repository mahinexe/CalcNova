import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/number_formatter.dart';
import 'conversion_units.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.definition,
    required this.preferences,
    required this.onMenu,
  });
  final ToolDefinition definition;
  final SharedPreferences preferences;
  final VoidCallback onMenu;
  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late UnitDefinition _from, _to;
  final _controller = TextEditingController();
  String _output = '0', _error = '';

  @override
  void initState() {
    super.initState();
    _from = widget.definition.units.first;
    _to = widget.definition.units[1];
    _controller.addListener(_convert);
  }

  @override
  void didUpdateWidget(covariant ConverterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.id != widget.definition.id) {
      _from = widget.definition.units.first;
      _to = widget.definition.units[1];
      _output = '0';
      _error = '';
      _controller.removeListener(_convert);
      _controller.clear();
      _controller.addListener(_convert);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null) {
      final nextError = _controller.text.isEmpty ? '' : 'Enter a valid number';
      if (_output != '0' || _error != nextError) {
        setState(() {
          _output = '0';
          _error = nextError;
        });
      }
      return;
    }
    try {
      final nextOutput = formatNumber(
        convertValue(widget.definition, value, _from, _to),
      );
      if (_output == nextOutput && _error.isEmpty) return;
      setState(() {
        _output = nextOutput;
        _error = '';
      });
    } on FormatException catch (e) {
      if (_output == '—' && _error == e.message) return;
      setState(() {
        _output = '—';
        _error = e.message;
      });
    }
  }

  void _swap() {
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
    });
    _convert();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Result copied')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${widget.definition.title} converter'),
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
            'Convert instantly',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Accurate offline conversion with clear units.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: 'Value',
              suffixIcon: IconButton(
                tooltip: 'Clear input',
                onPressed: () => _controller.clear(),
                icon: const Icon(Icons.clear_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              _unitSelector('From unit', _from, (unit) {
                if (unit == null) return;
                setState(() => _from = unit);
                _convert();
              }),
              const SizedBox(height: 12),
              IconButton.filled(
                tooltip: 'Swap units',
                onPressed: _swap,
                icon: const Icon(Icons.swap_vert_rounded),
              ),
              const SizedBox(height: 12),
              _unitSelector('To unit', _to, (unit) {
                if (unit == null) return;
                setState(() => _to = unit);
                _convert();
              }),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESULT',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      '$_output ${_to.symbol}',
                      key: ValueKey('$_output-${_to.symbol}'),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Copy result',
                      onPressed: _output == '—' ? null : _copy,
                      icon: const Icon(Icons.copy_rounded),
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
  Widget _unitSelector(
    String label,
    UnitDefinition value,
    ValueChanged<UnitDefinition?> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      DropdownButtonFormField<UnitDefinition>(
        initialValue: value,
        isExpanded: true,
        menuMaxHeight: 360,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        items: widget.definition.units
            .map(
              (unit) => DropdownMenuItem(
                value: unit,
                child: Text(
                  '${unit.symbol}  ${unit.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ],
  );
}
