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

  /// 🆕 LISTENER per cambiamenti tema sistema
  void _initSystemThemeListener() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
          WidgetsBinding.instance.handlePlatformBrightnessChanged();
          // Forza aggiornamento quando cambia tema sistema
          if (_initialized) {
            debugPrint('🎨 Tema sistema cambiato - aggiornamento automatico');
            notifyListeners();
          }
        };
  }

  /// Aggiorna il tema corrente (chiamato automaticamente da ThemeProvider)
  void updateTheme(BuildContext context) {
    final theme = Theme.of(context);
    final oldBrightness = _initialized ? _brightness : null;

    _colorScheme = theme.colorScheme;
    _cardColor = theme.cardColor;
    _dialogBackgroundColor = theme.dialogBackgroundColor;
    _dividerColor = theme.dividerColor;
    _iconColor = theme.iconTheme.color;
    _brightness = theme.brightness;

    if (!_initialized) {
      _initialized = true;
      _initSystemThemeListener(); // 🆕 Attiva listener
      debugPrint(
        '🎨 AppThemeManager inizializzato con tema ${_brightness.name}',
      );
    }

    // 🆕 Log cambiamenti tema
    if (oldBrightness != null && oldBrightness != _brightness) {
      debugPrint(
        '🎨 Tema cambiato da ${oldBrightness.name} a ${_brightness.name}',
      );
    }

    // 🆕 SEMPRE notifica (non solo alla prima inizializzazione)
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

  /// Metodo per verificare se è inizializzato (senza exception)
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

  /// Getters "safe" che non crashano se non inizializzato
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppThemeManager().updateTheme(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // 🆕 Aggiorna tema quando cambia quello del sistema
    AppThemeManager().updateTheme(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppThemeManager().updateTheme(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
