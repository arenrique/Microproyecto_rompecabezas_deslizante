import 'package:flutter/material.dart';

class TemaAplicacion {
  TemaAplicacion._();

  static const Color _colorSemilla = Color(0xFF4F46E5);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(
      seedColor: _colorSemilla,
      brightness: brillo,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        elevation: 0,
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: esquema.onSurface,
        displayColor: esquema.onSurface,
      ),
    );
  }
}
