import 'package:flutter/material.dart';

/// Paleta inspirada no Catppuccin Mocha para o dark theme,
/// e um branco levemente amarelado ("cream") para o light theme.
class AppColors {
  // --- Dark theme (Catppuccin-like) ---
  static const darkBase = Color(0xFF1E1E2E); // fundo principal
  static const darkMantle = Color(0xFF181825); // fundo secundário / cards
  static const darkSurface = Color(0xFF313244); // superfícies elevadas
  static const darkMauve = Color(0xFFCBA6F7); // cor de destaque (roxo)
  static const darkLavender = Color(0xFFB4BEFE);
  static const darkText = Color(0xFFCDD6F4);
  static const darkSubtext = Color(0xFFA6ADC8);
  static const darkGreen = Color(0xFFA6E3A1); // sucesso / recompensa
  static const darkRed = Color(0xFFF38BA8); // alerta / atraso

  // --- Light theme (branco amarelado) ---
  static const lightBase = Color(0xFFFFF8E7); // fundo creme
  static const lightSurface = Color(0xFFFFF1CE); // cards
  static const lightPrimary = Color(0xFF8C6D4F); // marrom suave / destaque
  static const lightAccent =
      Color(0xFF9C7CC4); // toque roxo combinando com o dark
  static const lightText = Color(0xFF3D3428);
  static const lightSubtext = Color(0xFF7A6E5C);
  static const lightGreen = Color(0xFF5C9E62);
  static const lightRed = Color(0xFFC2564D);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      surface: AppColors.lightBase,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
      error: AppColors.lightRed,
      onSurface: AppColors.lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBase,
      cardColor: AppColors.lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBase,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),
      textTheme: _textTheme(AppColors.lightText, AppColors.lightSubtext),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      surface: AppColors.darkBase,
      primary: AppColors.darkMauve,
      secondary: AppColors.darkLavender,
      error: AppColors.darkRed,
      onSurface: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBase,
      cardColor: AppColors.darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBase,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
      textTheme: _textTheme(AppColors.darkText, AppColors.darkSubtext),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkMauve,
        foregroundColor: AppColors.darkBase,
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color subtext) {
    return TextTheme(
      titleLarge:
          TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 22),
      titleMedium:
          TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: TextStyle(color: text, fontSize: 16),
      bodyMedium: TextStyle(color: subtext, fontSize: 14),
    );
  }
}
