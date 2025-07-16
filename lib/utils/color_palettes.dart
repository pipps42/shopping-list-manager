import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_manager.dart';
import 'dart:math' as math;

/// ===== LAYER 1: BRAND COLORS (quello che cambia tra brand) =====

abstract class AppBrandPalette {
  String get name;

  // Colori che caratterizzano il brand
  Color get primary; // Colore principale
  Color get secondary; // Colore secondario
  Color get accent; // Colore accento

  // Colori specifici del brand per elementi UI
  Color get headerGradientStart => primary;
  Color get headerGradientEnd => primary.withOpacity(0.8);
  Color get fabBackground => secondary;
  Color get chipSelected => accent.withOpacity(0.2);
  Color get progressIndicator => secondary;

  // Swipe actions (universali)
  Color get swipeComplete => const Color(0xFF4CAF50); // Verde universale
  Color get swipeDelete => const Color(0xFFE53935); // Rosso universale
}

/// ===== PALETTE FRESH MARKET - MODERNA E FUNZIONALE =====
class FreshMarketBrandPalette extends AppBrandPalette {
  @override
  String get name => 'Fresh Market';

  @override
  Color get primary => const Color(0xFF2E7D4A); // Verde foresta (reparti)
  @override
  Color get secondary => const Color(0xFF1976D2); // Blu moderno (prodotti/azioni)
  @override
  Color get accent => const Color(0xFFF57C00); // Arancione (accenti)
}

/// ===== PALETTE HIGH CONTRAST - PER DEBUG/ACCESSIBILITÀ =====
class HighContrastBrandPalette extends AppBrandPalette {
  @override
  String get name => 'High Contrast';

  @override
  Color get primary => const Color(0xFFE91E63); // Magenta forte
  @override
  Color get secondary => const Color(0xFF00BCD4); // Ciano forte
  @override
  Color get accent => const Color(0xFFFF5722); // Arancione forte
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

/// ===== LAYER 3: SYSTEM COLORS (ELEGANTI E FUNZIONALI!) =====

class AppSystemColors {
  static AppThemeManager get _theme => AppThemeManager();

  // 🎯 LIGHT THEME FALLBACKS - Eleganti e moderni
  static const Color _lightTextPrimary = Color(0xFF1A1A1A); // Quasi nero
  static const Color _lightTextSecondary = Color(0xFF6B7280); // Grigio medio
  static const Color _lightTextDisabled = Color(0xFF9CA3AF); // Grigio chiaro
  static const Color _lightBackground = Color(0xFFFAFAFA); // Grigio chiarissimo
  static const Color _lightSurface = Color(0xFFFFFFFF); // Bianco puro
  static const Color _lightCard = Color(0xFFFFFFFF); // Bianco puro
  static const Color _lightDialog = Color(0xFFFFFFFF); // Bianco puro
  static const Color _lightBorder = Color(0xFFE5E7EB); // Grigio bordi
  static const Color _lightIcon = Color(0xFF4B5563); // Grigio icone

  // 🌙 DARK THEME FALLBACKS - Material Design 3 inspired
  static const Color _darkTextPrimary = Color(0xFFF9FAFB); // Quasi bianco
  static const Color _darkTextSecondary = Color(0xFFD1D5DB); // Grigio chiaro
  static const Color _darkTextDisabled = Color(0xFF6B7280); // Grigio medio
  static const Color _darkBackground = Color(0xFF111827); // Quasi nero
  static const Color _darkSurface = Color(0xFF1F2937); // Grigio scurissimo
  static const Color _darkCard = Color(0xFF374151); // Grigio scuro
  static const Color _darkDialog = Color(0xFF4B5563); // Grigio medio scuro
  static const Color _darkBorder = Color(0xFF4B5563); // Grigio bordi scuri
  static const Color _darkIcon = Color(0xFFD1D5DB); // Grigio chiaro icone

  /// Helper per determinare se usare fallback dark o light
  static bool get _shouldUseDarkFallback =>
      _theme.isInitialized ? _theme.isDark : false;

  /// Colori di testo (ELEGANTI!)
  static Color get textPrimary {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkTextPrimary : _lightTextPrimary;
    }
    return _theme.colorScheme.onSurface;
  }

  static Color get textSecondary {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkTextSecondary : _lightTextSecondary;
    }
    return _theme.colorScheme.onSurface.withOpacity(0.6);
  }

  static Color get textDisabled {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkTextDisabled : _lightTextDisabled;
    }
    return _theme.colorScheme.onSurface.withOpacity(0.4);
  }

  static Color get textOnPrimary {
    if (!_theme.isInitialized) return Colors.white;
    return _theme.colorScheme.onPrimary;
  }

  /// Colori di background (ELEGANTI!)
  static Color get background {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkBackground : _lightBackground;
    }
    return _theme.colorScheme.background;
  }

  static Color get surface {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkSurface : _lightSurface;
    }
    return _theme.colorScheme.surface;
  }

  static Color get cardBackground {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkCard : _lightCard;
    }
    return _theme.cardColor;
  }

  static Color get dialogBackground {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkDialog : _lightDialog;
    }
    return _theme.dialogBackgroundColor;
  }

  /// Colori di bordi e divider (ELEGANTI!)
  static Color get border {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkBorder : _lightBorder;
    }
    return _theme.dividerColor;
  }

  static Color get divider {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkBorder : _lightBorder;
    }
    return _theme.dividerColor;
  }

  /// Colori icone (ELEGANTI!)
  static Color get iconPrimary {
    if (!_theme.isInitialized) {
      return _shouldUseDarkFallback ? _darkIcon : _lightIcon;
    }
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
  static AppBrandPalette _currentBrand =
      FreshMarketBrandPalette(); // 🆕 Fresh Market default

  static AppBrandPalette get current => _currentBrand;

  static List<AppBrandPalette> get availableBrands => [
    FreshMarketBrandPalette(), // 🆕 Nuova palette principale
    HighContrastBrandPalette(), // 🆕 Per debug/accessibilità
  ];

  static void setBrand(AppBrandPalette brand) {
    _currentBrand = brand;
    debugPrint('🎨 Brand cambiato a: ${brand.name}');
  }

  /// Shortcuts utili
  static void setFreshMarket() => setBrand(FreshMarketBrandPalette());
  static void enableHighContrast() => setBrand(HighContrastBrandPalette());
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

  // === SYSTEM COLORS (con fallback ELEGANTI!) ===
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

  // === HELPER PER ACCESSIBILITÀ ===

  /// Verifica se il contrasto tra due colori è sufficiente (WCAG AA)
  static bool hasGoodContrast(Color foreground, Color background) {
    return _calculateContrast(foreground, background) >= 4.5;
  }

  /// Calcola il rapporto di contrasto tra due colori
  static double _calculateContrast(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);
    final lightest = math.max(fgLuminance, bgLuminance);
    final darkest = math.min(fgLuminance, bgLuminance);
    return (lightest + 0.05) / (darkest + 0.05);
  }

  /// Calcola la luminanza relativa di un colore
  static double _getLuminance(Color color) {
    final r = _adjustColorValue(color.red / 255.0);
    final g = _adjustColorValue(color.green / 255.0);
    final b = _adjustColorValue(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _adjustColorValue(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }
}
