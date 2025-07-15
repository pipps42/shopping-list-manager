import 'package:flutter/material.dart';

/// ===== LAYER 1: BRAND COLORS (quello che cambia tra brand) =====

abstract class AppBrandPalette {
  String get name;

  // Colori che caratterizzano il brand
  Color get primary; // Colore principale (verde Esselunga, blu Carrefour)
  Color get secondary; // Colore secondario (rosso Esselunga, rosso Carrefour)
  Color get accent; // Colore accento (giallo, bianco, ecc.)

  // Colori specifici del brand per elementi UI
  Color get headerGradientStart => primary;
  Color get headerGradientEnd => primary.withOpacity(0.8);
  Color get fabBackground => primary;
  Color get chipSelected => primary.withOpacity(0.2);
  Color get progressIndicator => primary;

  // Swipe actions (possono essere brand-specific)
  Color get swipeComplete => const Color(0xFF4CAF50); // Verde universale
  Color get swipeDelete => const Color(0xFFE53935); // Rosso universale
}

/// Palette Esselunga
class EsseLungaBrandPalette extends AppBrandPalette {
  @override
  String get name => 'Esselunga';

  @override
  Color get primary => const Color(0xFFFFD700); // Verde Esselunga
  @override
  Color get secondary => const Color(0xFFE31E24); // Rosso Esselunga
  @override
  Color get accent => const Color.fromARGB(255, 62, 139, 255); // Giallo oro
}

/// Palette Carrefour
class CarrefourBrandPalette extends AppBrandPalette {
  @override
  String get name => 'Carrefour';

  @override
  Color get primary => const Color(0xFF0066CC); // Blu Carrefour
  @override
  Color get secondary => const Color(0xFFE31E24); // Rosso Carrefour
  @override
  Color get accent => Colors.white; // Bianco
}

/// Palette Coop
class CoopBrandPalette extends AppBrandPalette {
  @override
  String get name => 'Coop';

  @override
  Color get primary => const Color(0xFFFF6B35); // Arancione Coop
  @override
  Color get secondary => const Color(0xFF004225); // Verde scuro Coop
  @override
  Color get accent => const Color(0xFFFFA500); // Arancione chiaro
}

/// ===== LAYER 2: UNIVERSAL COLORS (sempre uguali) =====

class AppUniversalColors {
  // Status colors (sempre uguali in tutto il mondo)
  static const Color success = Color(0xFF4CAF50); // Verde success
  static const Color error = Color(0xFFE53935); // Rosso error
  static const Color warning = Color(0xFFFF9800); // Arancione warning
  static const Color info = Color(0xFF2196F3); // Blu info

  // Neutral colors (per elementi che non dipendono da light/dark)
  static const Color transparent = Colors.transparent;
  static const Color shadow = Colors.black26;
  static const Color overlay = Colors.black54;

  // Completamento item (universale)
  static Color get completedOverlay => Colors.grey.withOpacity(0.3);
}

/// ===== LAYER 3: SYSTEM COLORS (gestiti da Flutter Theme) =====

class AppSystemColors {
  /// Colori di testo (dipendono da light/dark)
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

  static Color textOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  /// Colori di background (dipendono da light/dark)
  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.background;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).cardColor;

  static Color dialogBackground(BuildContext context) =>
      Theme.of(context).dialogBackgroundColor;

  /// Colori di bordi e divider (dipendono da light/dark)
  static Color border(BuildContext context) => Theme.of(context).dividerColor;

  static Color divider(BuildContext context) => Theme.of(context).dividerColor;

  /// Colori icone (dipendono da light/dark)
  static Color iconPrimary(BuildContext context) =>
      Theme.of(context).iconTheme.color ?? textPrimary(context);

  static Color iconSecondary(BuildContext context) =>
      iconPrimary(context).withOpacity(0.6);

  static Color iconDisabled(BuildContext context) =>
      iconPrimary(context).withOpacity(0.4);
}

/// ===== MANAGER E FACADE =====

class BrandPaletteManager {
  static AppBrandPalette _currentBrand = EsseLungaBrandPalette();

  static AppBrandPalette get current => _currentBrand;

  static List<AppBrandPalette> get availableBrands => [
    EsseLungaBrandPalette(),
    CarrefourBrandPalette(),
    CoopBrandPalette(),
  ];

  static void setBrand(AppBrandPalette brand) {
    _currentBrand = brand;
    // TODO: Notify listeners per rebuild UI
  }
}

/// ===== FACADE UNIFICATO (facile da usare) =====

class AppColors {
  static AppBrandPalette get _brand => BrandPaletteManager.current;

  // === BRAND COLORS ===
  static Color get primary => _brand.primary;
  static Color get secondary => _brand.secondary;
  static Color get accent => _brand.accent;
  static Color get headerGradientStart => _brand.headerGradientStart;
  static Color get headerGradientEnd => _brand.headerGradientEnd;
  static Color get fabBackground => _brand.fabBackground;
  static Color get chipSelected => _brand.chipSelected;
  static Color get progressIndicator => _brand.progressIndicator;
  static Color get swipeComplete => _brand.swipeComplete;
  static Color get swipeDelete => _brand.swipeDelete;

  // === UNIVERSAL COLORS ===
  static Color get success => AppUniversalColors.success;
  static Color get error => AppUniversalColors.error;
  static Color get warning => AppUniversalColors.warning;
  static Color get info => AppUniversalColors.info;
  static Color get transparent => AppUniversalColors.transparent;
  static Color get shadow => AppUniversalColors.shadow;
  static Color get overlay => AppUniversalColors.overlay;
  static Color get completedOverlay => AppUniversalColors.completedOverlay;

  // === SYSTEM COLORS (require context) ===
  static Color textPrimary(BuildContext context) =>
      AppSystemColors.textPrimary(context);
  static Color textSecondary(BuildContext context) =>
      AppSystemColors.textSecondary(context);
  static Color textDisabled(BuildContext context) =>
      AppSystemColors.textDisabled(context);
  static Color textOnPrimary(BuildContext context) =>
      AppSystemColors.textOnPrimary(context);

  static Color background(BuildContext context) =>
      AppSystemColors.background(context);
  static Color surface(BuildContext context) =>
      AppSystemColors.surface(context);
  static Color cardBackground(BuildContext context) =>
      AppSystemColors.cardBackground(context);
  static Color dialogBackground(BuildContext context) =>
      AppSystemColors.dialogBackground(context);

  static Color border(BuildContext context) => AppSystemColors.border(context);
  static Color divider(BuildContext context) =>
      AppSystemColors.divider(context);

  static Color iconPrimary(BuildContext context) =>
      AppSystemColors.iconPrimary(context);
  static Color iconSecondary(BuildContext context) =>
      AppSystemColors.iconSecondary(context);
  static Color iconDisabled(BuildContext context) =>
      AppSystemColors.iconDisabled(context);
}
