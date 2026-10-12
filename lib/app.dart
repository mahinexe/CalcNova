import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/about/about_screen.dart';
import 'features/basic_calculator/basic_calculator_screen.dart';
import 'features/converters/conversion_units.dart';
import 'features/converters/converter_screen.dart';
import 'features/scientific_calculator/scientific_calculator_screen.dart';
import 'features/settings/settings_screen.dart';

class CalcNovaApp extends StatefulWidget {
  const CalcNovaApp({
    super.key,
    required this.preferences,
    this.initialThemeMode,
  });
  final SharedPreferences preferences;
  final ThemeMode? initialThemeMode;

  @override
  State<CalcNovaApp> createState() => _CalcNovaAppState();
}

class _CalcNovaAppState extends State<CalcNovaApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode =
        widget.initialThemeMode ??
        ThemeMode.values.firstWhere(
          (mode) => mode.name == widget.preferences.getString('theme'),
          orElse: () => ThemeMode.dark,
        );
  }

  void _setTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.preferences.setString('theme', mode.name);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CalcNova',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: _themeMode,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: child!,
    ),
    home: CalcNovaShell(
      preferences: widget.preferences,
      themeMode: _themeMode,
      onThemeChanged: _setTheme,
    ),
  );
}

class CalcNovaShell extends StatefulWidget {
  const CalcNovaShell({
    super.key,
    required this.preferences,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final SharedPreferences preferences;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<CalcNovaShell> createState() => _CalcNovaShellState();
}

class _CalcNovaShellState extends State<CalcNovaShell> {
  ToolDefinition _selected = tools.first;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _select(ToolDefinition tool) {
    setState(() => _selected = tool);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_selected.id) {
      'basic' => BasicCalculatorScreen(
        preferences: widget.preferences,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      'scientific' => ScientificCalculatorScreen(
        preferences: widget.preferences,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      _ => ConverterScreen(
        definition: _selected,
        preferences: widget.preferences,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    };
    return Scaffold(
      key: _scaffoldKey,
      drawer: _ToolDrawer(
        selected: _selected,
        onSelect: _select,
        onSettings: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                preferences: widget.preferences,
                themeMode: widget.themeMode,
                onThemeChanged: widget.onThemeChanged,
              ),
            ),
          );
        },
        onAbout: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          );
        },
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.035, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_selected.id), child: screen),
      ),
    );
  }
}

class _ToolDrawer extends StatelessWidget {
  const _ToolDrawer({
    required this.selected,
    required this.onSelect,
    required this.onSettings,
    required this.onAbout,
  });
  final ToolDefinition selected;
  final ValueChanged<ToolDefinition> onSelect;
  final VoidCallback onSettings;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'app_icon.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CalcNova',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _group(context, 'Calculators', tools.take(2)),
          const SizedBox(height: 16),
          _group(context, 'Unit converters', tools.skip(2)),
          const Divider(height: 36),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: onSettings,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About CalcNova'),
            onTap: onAbout,
          ),
        ],
      ),
    ),
  );

  Widget _group(
    BuildContext context,
    String title,
    Iterable<ToolDefinition> items,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      ...items.map(
        (tool) => ListTile(
          selected: selected.id == tool.id,
          selectedTileColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: .14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Icon(tool.icon),
          title: Text(tool.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => onSelect(tool),
        ),
      ),
    ],
  );
}
