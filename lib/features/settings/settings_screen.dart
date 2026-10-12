import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final SharedPreferences preferences;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _haptics, _sound;
  @override
  void initState() {
    super.initState();
    _haptics = widget.preferences.getBool('haptics') ?? true;
    _sound = widget.preferences.getBool('sound') ?? false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<ThemeMode>(
            groupValue: widget.themeMode,
            onChanged: (value) {
              if (value != null) {
                widget.onThemeChanged(value);
              }
            },
            child: Column(
              children: [
                const RadioListTile<ThemeMode>(
                  title: Text('System default'),
                  value: ThemeMode.system,
                ),
                const RadioListTile<ThemeMode>(
                  title: Text('Light'),
                  value: ThemeMode.light,
                ),
                const RadioListTile<ThemeMode>(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Feedback',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Haptic feedback'),
                subtitle: const Text('Vibrate lightly when tapping controls'),
                value: _haptics,
                onChanged: (value) {
                  setState(() => _haptics = value);
                  widget.preferences.setBool('haptics', value);
                },
              ),
              SwitchListTile(
                title: const Text('Sound feedback'),
                subtitle: const Text('Sound is off by default'),
                value: _sound,
                onChanged: (value) {
                  setState(() => _sound = value);
                  widget.preferences.setBool('sound', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const ListTile(title: Text('Version'), trailing: Text('1.0.0')),
        const SizedBox(height: 12),
        Text(
          'Calculations stay on your device. CalcNova requires no account, backend, or analytics.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
