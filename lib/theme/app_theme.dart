import 'package:flutter/material.dart';

/// Paleta Solarized Light e Catppuccin Mocha Dark.
class AppColors {
  // --- Dark theme (Catppuccin Mocha) ---
  static const darkBase = Color(0xFF1E1E2E);
  static const darkMantle = Color(0xFF181825);
  static const darkSurface = Color(0xFF313244);
  static const darkMauve = Color(0xFFCBA6F7);
  static const darkLavender = Color(0xFFB4BEFE);
  static const darkText = Color(0xFFCDD6F4);
  static const darkSubtext = Color(0xFFA6ADC8);
  static const darkGreen = Color(0xFFA6E3A1);
  static const darkRed = Color(0xFFF38BA8);

  // --- Light theme (Solarized Light) ---
  static const lightBase = Color(0xFFFDF6E3); // fundo
  static const lightSurface = Color(0xFFEEE8D5); // cards / superfícies
  static const lightPrimary = Color(0xFF268BD2); // destaque azul
  static const lightSecondary = Color(0xFFB58900); // dourado
  static const lightText = Color(0xFF657B83); // corpo
  static const lightTitle = Color(0xFF586E75); // títulos
  static const lightGreen = Color(0xFF859900); // sucesso
  static const lightRed = Color(0xFFDC322F); // alerta
  static const lightOrange = Color(0xFFCB4B16); // warning
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      surface: AppColors.lightBase,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      error: AppColors.lightRed,
      onSurface: AppColors.lightText,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    );

    final textTheme = _textTheme(
      AppColors.lightText,
      AppColors.lightTitle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBase,
      cardColor: AppColors.lightSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBase,
        foregroundColor: AppColors.lightTitle,
        elevation: 0,
      ),
      textTheme: textTheme,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
      textTheme: _textTheme(AppColors.darkText, AppColors.darkText),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkMauve,
        foregroundColor: AppColors.darkBase,
      ),
    );
  }

  static TextTheme _textTheme(Color body, Color titles) {
    return TextTheme(
      titleLarge: TextStyle(
        color: titles,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: titles,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        color: titles,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(color: body, fontSize: 16),
      bodyMedium: TextStyle(color: body, fontSize: 14),
      bodySmall: TextStyle(color: body, fontSize: 12),
      labelSmall: TextStyle(color: body, fontSize: 11),
    );
  }

  /// Helper para usar em cards que precisam de cor de título distinta.
  static Color get lightTitleColor => AppColors.lightTitle;
  static Color get lightBodyColor => AppColors.lightText;
}
