import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => _theme(Brightness.dark);
  static ThemeData get light => _theme(Brightness.light);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff8b5cf6),
      brightness: brightness,
      surface: dark ? const Color(0xff111827) : const Color(0xfff8fafc),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'monospace',
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xff0b1120)
          : const Color(0xfff8fafc),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
