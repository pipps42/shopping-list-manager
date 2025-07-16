import 'package:flutter/material.dart';

class AppColors {
  // === COLORI STATICI (sempre disponibili) ===
  static const Color primary = Color(0xFF2E7D4A);
  static const Color secondary = Color(0xFF1976D2);
  static const Color accent = Color(0xFFF57C00);

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
  static Color get completedOverlay => Colors.grey.withOpacity(0.2);

  // === COLORI DINAMICI ===

  // Text colors
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
  static Color textOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  static Color textOnSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;
  static Color textOnTertiary(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiary;

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
