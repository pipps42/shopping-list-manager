import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/theme_manager.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,

      // === LIGHT THEME ===
      theme: _buildTheme(Brightness.light),

      // === DARK THEME ===
      darkTheme: _buildTheme(Brightness.dark),

      // === SEGUE IMPOSTAZIONI SISTEMA ===
      themeMode: ThemeMode.system,

      // === WRAPPA CON THEME PROVIDER ===
      home: const ThemeProvider(child: MainScreen()),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // 🎯 SOLUZIONE: Usa i brand colors direttamente, NON AppColors.xxx
    final brandPalette = BrandPaletteManager.current;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPalette.primary, // ✅ Usa brandPalette direttamente
        brightness: brightness,
        // Brand colors iniettati nel sistema Flutter
        primary: brandPalette.primary,
        secondary: brandPalette.secondary,
        tertiary: brandPalette.accent,
        error: AppUniversalColors.error, // ✅ Universal colors sono OK
      ),
      useMaterial3: true,

      // === APP BAR ===
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: AppConstants.cardElevation,
        backgroundColor: brandPalette.primary, // ✅ Usa brandPalette
        foregroundColor: Colors.white, // ✅ Hardcode semplice per il tema
      ),

      // === CARDS ===
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),

      // === BUTTONS ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPalette.primary, // ✅ Usa brandPalette
          foregroundColor: Colors.white, // ✅ Hardcode semplice
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // === FAB ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandPalette.fabBackground, // ✅ Usa brandPalette
        foregroundColor: Colors.white, // ✅ Hardcode semplice
      ),

      // === INPUT FIELDS ===
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: brandPalette.primary,
          ), // ✅ Usa brandPalette
        ),
      ),

      // === CHIP THEME ===
      chipTheme: ChipThemeData(
        selectedColor: brandPalette.chipSelected, // ✅ Usa brandPalette
        checkmarkColor: brandPalette.primary, // ✅ Usa brandPalette
      ),

      // === PROGRESS INDICATOR ===
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandPalette.progressIndicator, // ✅ Usa brandPalette
      ),
    );
  }
}
