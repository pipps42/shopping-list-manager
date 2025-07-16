import 'package:flutter/material.dart';

/// ===== THEME MANAGER =====
/// Gestisce i valori correnti del tema senza bisogno di context

class AppThemeManager extends ChangeNotifier {
  static final AppThemeManager _instance = AppThemeManager._internal();
  factory AppThemeManager() => _instance;
  AppThemeManager._internal();

  // Valori correnti del tema (aggiornati automaticamente)
  late ColorScheme _colorScheme;
  late Color _cardColor;
  late Color _dialogBackgroundColor;
  late Color _dividerColor;
  late Color? _iconColor;
  late Brightness _brightness;

  bool _initialized = false;

  /// Aggiorna il tema corrente (chiamato automaticamente da ThemeProvider)
  void updateTheme(BuildContext context) {
    final theme = Theme.of(context);
    _colorScheme = theme.colorScheme;
    _cardColor = theme.cardColor;
    _dialogBackgroundColor = theme.dialogBackgroundColor;
    _dividerColor = theme.dividerColor;
    _iconColor = theme.iconTheme.color;
    _brightness = theme.brightness;

    if (!_initialized) {
      _initialized = true;
      debugPrint(
        '🎨 AppThemeManager inizializzato con tema ${_brightness.name}',
      );
    }

    notifyListeners();
  }

  /// Verifica che il tema sia stato inizializzato
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'AppThemeManager not initialized. Wrap your app with ThemeProvider!\n'
        'Probable cause: You\'re using AppColors.textPrimary (or similar) in theme creation.\n'
        'Solution: Use BrandPaletteManager.current.primary instead in _buildTheme().',
      );
    }
  }

  /// 🆕 Metodo per verificare se è inizializzato (senza exception)
  bool get isInitialized => _initialized;

  // === GETTERS PER I COLORI (senza context!) ===

  ColorScheme get colorScheme {
    _ensureInitialized();
    return _colorScheme;
  }

  Color get cardColor {
    _ensureInitialized();
    return _cardColor;
  }

  Color get dialogBackgroundColor {
    _ensureInitialized();
    return _dialogBackgroundColor;
  }

  Color get dividerColor {
    _ensureInitialized();
    return _dividerColor;
  }

  Color? get iconColor {
    _ensureInitialized();
    return _iconColor;
  }

  Brightness get brightness {
    _ensureInitialized();
    return _brightness;
  }

  bool get isDark => _initialized ? _brightness == Brightness.dark : false;
  bool get isLight => _initialized ? _brightness == Brightness.light : true;

  /// 🆕 Getters "safe" che non crashano se non inizializzato
  bool get isDarkSafe => _initialized && _brightness == Brightness.dark;
  bool get isLightSafe => !_initialized || _brightness == Brightness.light;
}

/// ===== WIDGET PROVIDER AUTOMATICO =====
/// Wrappa la tua app per aggiornare automaticamente il tema

class ThemeProvider extends StatefulWidget {
  final Widget child;

  const ThemeProvider({Key? key, required this.child}) : super(key: key);

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();
}

class _ThemeProviderState extends State<ThemeProvider>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🎯 Aggiorna il ThemeManager ogni volta che il tema cambia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppThemeManager().updateTheme(context);
      }
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Aggiorna quando l'utente cambia da light a dark mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppThemeManager().updateTheme(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 Aggiorna il ThemeManager anche al primo build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppThemeManager().updateTheme(context);
      }
    });

    return widget.child;
  }
}
