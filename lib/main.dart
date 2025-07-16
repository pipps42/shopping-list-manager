import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/theme_aware_builder.dart';
import 'package:shopping_list_manager/utils/theme_manager.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: ThemeMode.system, // Segue tema sistema
          builder: (context, child) {
            return ThemeAwareBuilder(
              builder: (context) => child ?? const SizedBox(),
            );
          },
          home: const ThemeProvider(child: MainScreen()),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final brandPalette = BrandPaletteManager.current;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPalette.primary,
        brightness: brightness,
        primary: brandPalette.primary,
        secondary: brandPalette.secondary,
        tertiary: brandPalette.accent,
        error: AppUniversalColors.error,
      ),
      useMaterial3: true,

      // === APP BAR ===
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: AppConstants.cardElevation,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
          backgroundColor: brandPalette.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // === FAB ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandPalette.fabBackground,
        foregroundColor: Colors.white,
      ),

      // === INPUT FIELDS ===
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.accent),
        ),
      ),

      // === CHIP THEME ===
      chipTheme: ChipThemeData(
        selectedColor: brandPalette.chipSelected,
        checkmarkColor: brandPalette.primary,
      ),

      // === PROGRESS INDICATOR ===
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandPalette.progressIndicator,
      ),
    );
  }
}
