import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_number_logic.dart';

class BaseConverterScreen extends StatefulWidget {
  const BaseConverterScreen({super.key, required this.onMenu});
  final VoidCallback onMenu;

  @override
  State<BaseConverterScreen> createState() => _BaseConverterScreenState();
}

class _BaseConverterScreenState extends State<BaseConverterScreen> {
  final _controller = TextEditingController();
  NumberBase _sourceBase = NumberBase.decimal;
  Map<NumberBase, String> _results = {};
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_convert);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _results = {};
        _error = '';
      });
      return;
    }
    try {
      final value = parseBaseNumber(_controller.text, _sourceBase);
      final results = {
        for (final base in NumberBase.values)
          base: formatBaseNumber(value, base),
      };
      setState(() {
        _results = results;
        _error = '';
      });
    } on BaseNumberException catch (error) {
      setState(() {
        _results = {};
        _error = error.message;
      });
    }
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _results = {};
      _error = '';
    });
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Result copied')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Base converter'),
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
            'Convert between bases',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Fractions are interpreted in their selected base.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Input value',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'For example, 101.11',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Clear input',
                    onPressed: _clear,
                    icon: const Icon(Icons.clear_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _baseSelector('Source base', _sourceBase, (base) {
            if (base == null) return;
            setState(() => _sourceBase = base);
            _convert();
          }),
          const SizedBox(height: 24),
          if (_error.isNotEmpty)
            _errorText(context, _error)
          else
            ...NumberBase.values.map((base) => _resultCard(context, base)),
        ],
      ),
    ),
  );

  Widget _baseSelector(
    String label,
    NumberBase value,
    ValueChanged<NumberBase?> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      DropdownButtonFormField<NumberBase>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        items: NumberBase.values
            .map(
              (base) => DropdownMenuItem(
                value: base,
                child: Text(
                  '${base.label}  (${base.name})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ],
  );

  Widget _resultCard(BuildContext context, NumberBase base) {
    final value = _results[base] ?? '—';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            base.label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        title: Text(base.name),
        subtitle: Text(value, style: Theme.of(context).textTheme.titleLarge),
        trailing: IconButton(
          tooltip: 'Copy ${base.label} result',
          onPressed: _results.containsKey(base) ? () => _copy(value) : null,
          icon: const Icon(Icons.copy_rounded),
        ),
      ),
    );
  }

  Widget _errorText(BuildContext context, String message) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
