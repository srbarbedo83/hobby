import 'package:flutter/material.dart';

/// Paleta "trading app": fundo quase preto, acento rosa (nod à marca
/// Uniswap), verde/âmbar para variações positivas/estado de atenção.
class AppColors {
  static const background = Color(0xFF0A0B0D);
  static const surface = Color(0xFF15171B);
  static const surfaceAlt = Color(0xFF1C1F24);
  static const border = Color(0xFF1F2227);
  static const textPrimary = Color(0xFFF2F3F5);
  static const textSecondary = Color(0xFF8A8F98);
  static const textTertiary = Color(0xFF5B6168);
  static const accent = Color(0xFFFF4FA3);
  static const positive = Color(0xFF33D17A);
  static const negative = Color(0xFFFF5C5C);
  static const warning = Color(0xFFFFB020);
}

class AppTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(surface: AppColors.surface, primary: AppColors.accent);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.16),
      ),
      textTheme:
          const TextTheme(bodyMedium: TextStyle(color: AppColors.textPrimary))
              .apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
    );
  }
}
