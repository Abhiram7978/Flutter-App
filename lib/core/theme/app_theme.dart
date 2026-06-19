import 'package:flutter/material.dart';

/// Centralised colour and theme definitions.
///
/// Colour choices are deliberate for a financial data app: green/red are
/// used exclusively for price direction (never decoratively elsewhere),
/// so the eye learns to trust them as a fast directional signal.
class AppColors {
  const AppColors._();

  static const Color bullish = Color(0xFF1B9E5A); // candle up / positive change
  static const Color bearish = Color(0xFFD64545); // candle down / negative change
  static const Color neutral = Color(0xFF6B7280);

  static const Color background = Color(0xFF0E1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF1F2630);

  static const Color primary = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFE0A93B);

  static const Color textPrimary = Color(0xFFE6E8EB);
  static const Color textSecondary = Color(0xFF9AA3AF);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.bearish,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  /// Returns [AppColors.bullish] / [AppColors.bearish] / [AppColors.neutral]
  /// based on sign of [changePct]. Centralised so the threshold logic for
  /// "neutral" (exactly zero) lives in one place.
  static Color colorForChange(double? changePct) {
    if (changePct == null || changePct == 0) return AppColors.neutral;
    return changePct > 0 ? AppColors.bullish : AppColors.bearish;
  }
}
