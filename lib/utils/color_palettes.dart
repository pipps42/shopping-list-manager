import 'package:flutter/material.dart';

/// ===== SISTEMA IBRIDO SEMPLICE =====

class AppColors {
  // === COLORI STATICI (sempre disponibili) ===
  static const Color primary = Color(0xFF2E7D4A); // Verde foresta
  static const Color secondary = Color(0xFF1976D2); // Blu moderno
  static const Color accent = Color(0xFFF57C00); // Arancione

  // Universal colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Swipe actions
  static const Color swipeComplete = Color(0xFF4CAF50);
  static const Color swipeDelete = Color(0xFFE53935);

  // Neutral
  static const Color transparent = Colors.transparent;
  static const Color shadow = Colors.black26;
  static const Color overlay = Colors.black54;
  static Color get completedOverlay => Colors.grey.withOpacity(0.3);

  // === COLORI DINAMICI (con fallback eleganti) ===

  // Text colors
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
  static Color textOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  // Background colors
  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.background;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).cardColor;
  static Color dialogBackground(BuildContext context) =>
      Theme.of(context).dialogBackgroundColor;

  // Border colors
  static Color border(BuildContext context) => Theme.of(context).dividerColor;
  static Color divider(BuildContext context) => Theme.of(context).dividerColor;

  // Icon colors
  static Color iconPrimary(BuildContext context) =>
      Theme.of(context).iconTheme.color ?? textPrimary(context);
  static Color iconSecondary(BuildContext context) =>
      iconPrimary(context).withOpacity(0.6);
  static Color iconDisabled(BuildContext context) =>
      iconPrimary(context).withOpacity(0.4);

  // === HELPER SENZA CONTEXT (con fallback) ===

  // Per quando NON hai context disponibile
  static const Color textPrimaryFallback = Color(
    0xFF1A1A1A,
  ); // Dark text per light theme
  static const Color textSecondaryFallback = Color(0xFF6B7280); // Gray text
  static const Color textDisabledFallback = Color(0xFF9CA3AF); // Light gray
  static const Color backgroundFallback = Color(0xFFFAFAFA); // Light background
  static const Color surfaceFallback = Color(0xFFFFFFFF); // White surface
  static const Color cardBackgroundFallback = Color(0xFFFFFFFF); // White card
  static const Color borderFallback = Color(0xFFE5E7EB); // Light border
  static const Color iconPrimaryFallback = Color(0xFF4B5563); // Dark icon

  // Utility
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;
}

/// ===== EXTENSION PER COMODITÀ =====
extension AppColorsExtension on BuildContext {
  // Accesso comodo ai colori: context.colors.textPrimary
  AppColorsHelper get colors => AppColorsHelper(this);
}

class AppColorsHelper {
  final BuildContext context;
  AppColorsHelper(this.context);

  Color get textPrimary => AppColors.textPrimary(context);
  Color get textSecondary => AppColors.textSecondary(context);
  Color get textDisabled => AppColors.textDisabled(context);
  Color get textOnPrimary => AppColors.textOnPrimary(context);

  Color get background => AppColors.background(context);
  Color get surface => AppColors.surface(context);
  Color get cardBackground => AppColors.cardBackground(context);
  Color get dialogBackground => AppColors.dialogBackground(context);

  Color get border => AppColors.border(context);
  Color get divider => AppColors.divider(context);

  Color get iconPrimary => AppColors.iconPrimary(context);
  Color get iconSecondary => AppColors.iconSecondary(context);
  Color get iconDisabled => AppColors.iconDisabled(context);
}
