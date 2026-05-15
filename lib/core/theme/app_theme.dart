import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blueAccent,
      // Glassmorphism and premium styling will be added here
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.amber,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
