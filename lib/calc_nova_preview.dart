import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

@Preview(
  name: 'CalcNova - Android portrait',
  size: Size(390, 844),
  brightness: Brightness.dark,
)
Widget calcNovaAndroidPortrait() => const _CalcNovaPreview();

@Preview(
  name: 'CalcNova - Android light theme',
  size: Size(390, 844),
  brightness: Brightness.light,
)
Widget calcNovaAndroidLight() => const _CalcNovaPreview(light: true);

class _CalcNovaPreview extends StatefulWidget {
  const _CalcNovaPreview({this.light = false});
  final bool light;

  @override
  State<_CalcNovaPreview> createState() => _CalcNovaPreviewState();
}

class _CalcNovaPreviewState extends State<_CalcNovaPreview> {
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _preferences = preferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = _preferences;
    if (preferences == null) {
      return const ColoredBox(
        color: Color(0xff0b1120),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return CalcNovaApp(
      preferences: preferences,
      initialThemeMode: widget.light ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
