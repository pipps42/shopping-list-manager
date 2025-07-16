import 'package:flutter/material.dart';
import 'theme_manager.dart';

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
  Color get primary => const Color.fromARGB(255, 0, 203, 207); // Verde Esselunga
  @override
  Color get secondary => const Color.fromARGB(255, 216, 7, 209); // Rosso Esselunga
  @override
  Color get accent => const Color(0xFFFFD700); // Giallo oro
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

/// ===== LAYER 3: SYSTEM COLORS (SICURI e senza context!) =====

class AppSystemColors {
  static AppThemeManager get _theme => AppThemeManager();

  // 🎯 Fallback colors per quando il tema non è ancora inizializzato
  static const Color _fallbackTextPrimary = Colors.black87;
  static const Color _fallbackTextSecondary = Colors.black54;
  static const Color _fallbackTextDisabled = Colors.black38;
  static const Color _fallbackBackground = Colors.white;
  static const Color _fallbackSurface = Colors.white;
  static const Color _fallbackCard = Colors.white;
  static const Color _fallbackDialog = Colors.white;
  static const Color _fallbackBorder = Colors.grey;
  static const Color _fallbackIcon = Colors.black87;

  /// Colori di testo (SICURI!)
  static Color get textPrimary {
    if (!_theme.isInitialized) return _fallbackTextPrimary;
    return _theme.colorScheme.onSurface;
  }

  static Color get textSecondary {
    if (!_theme.isInitialized) return _fallbackTextSecondary;
    return _theme.colorScheme.onSurface.withOpacity(0.6);
  }

  static Color get textDisabled {
    if (!_theme.isInitialized) return _fallbackTextDisabled;
    return _theme.colorScheme.onSurface.withOpacity(0.4);
  }

  static Color get textOnPrimary {
    if (!_theme.isInitialized) return Colors.white;
    return _theme.colorScheme.onPrimary;
  }

  /// Colori di background (SICURI!)
  static Color get background {
    if (!_theme.isInitialized) return _fallbackBackground;
    return _theme.colorScheme.background;
  }

  static Color get surface {
    if (!_theme.isInitialized) return _fallbackSurface;
    return _theme.colorScheme.surface;
  }

  static Color get cardBackground {
    if (!_theme.isInitialized) return _fallbackCard;
    return _theme.cardColor;
  }

  static Color get dialogBackground {
    if (!_theme.isInitialized) return _fallbackDialog;
    return _theme.dialogBackgroundColor;
  }

  /// Colori di bordi e divider (SICURI!)
  static Color get border {
    if (!_theme.isInitialized) return _fallbackBorder;
    return _theme.dividerColor;
  }

  static Color get divider {
    if (!_theme.isInitialized) return _fallbackBorder;
    return _theme.dividerColor;
  }

  /// Colori icone (SICURI!)
  static Color get iconPrimary {
    if (!_theme.isInitialized) return _fallbackIcon;
    return _theme.iconColor ?? textPrimary;
  }

  static Color get iconSecondary {
    return iconPrimary.withOpacity(0.6);
  }

  static Color get iconDisabled {
    return iconPrimary.withOpacity(0.4);
  }

  /// Utility per conoscere il tema corrente (SICURE!)
  static bool get isDark => _theme.isDarkSafe;
  static bool get isLight => _theme.isLightSafe;
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
    debugPrint('🎨 Brand cambiato a: ${brand.name}');
    // TODO: Potresti integrare con Riverpod qui per notificare i cambi
  }
}

/// ===== FACADE UNIFICATO (SICURO!) =====

class AppColors {
  static AppBrandPalette get _brand => BrandPaletteManager.current;

  // === BRAND COLORS (sempre sicuri) ===
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

  // === UNIVERSAL COLORS (sempre sicuri) ===
  static const Color success = AppUniversalColors.success;
  static const Color error = AppUniversalColors.error;
  static const Color warning = AppUniversalColors.warning;
  static const Color info = AppUniversalColors.info;
  static const Color transparent = AppUniversalColors.transparent;
  static const Color shadow = AppUniversalColors.shadow;
  static const Color overlay = AppUniversalColors.overlay;
  static Color get completedOverlay => AppUniversalColors.completedOverlay;

  // === SYSTEM COLORS (con fallback sicuri!) ===
  static Color get textPrimary => AppSystemColors.textPrimary;
  static Color get textSecondary => AppSystemColors.textSecondary;
  static Color get textDisabled => AppSystemColors.textDisabled;
  static Color get textOnPrimary => AppSystemColors.textOnPrimary;

  static Color get background => AppSystemColors.background;
  static Color get surface => AppSystemColors.surface;
  static Color get cardBackground => AppSystemColors.cardBackground;
  static Color get dialogBackground => AppSystemColors.dialogBackground;

  static Color get border => AppSystemColors.border;
  static Color get divider => AppSystemColors.divider;

  static Color get iconPrimary => AppSystemColors.iconPrimary;
  static Color get iconSecondary => AppSystemColors.iconSecondary;
  static Color get iconDisabled => AppSystemColors.iconDisabled;

  // === UTILITY HELPERS ===
  static bool get isDark => AppSystemColors.isDark;
  static bool get isLight => AppSystemColors.isLight;
}
