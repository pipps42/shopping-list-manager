import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
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

      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        // Brand colors iniettati nel sistema Flutter
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        error: AppColors.error,
      ),
      useMaterial3: true,

      // === APP BAR ===
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: AppConstants.cardElevation,
        backgroundColor: AppColors.primary,
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),

      // === FAB ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.fabBackground,
        foregroundColor: Colors.white,
      ),

      // === INPUT FIELDS ===
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),

      // === CHIP THEME ===
      chipTheme: ChipThemeData(
        selectedColor: AppColors.chipSelected,
        checkmarkColor: AppColors.primary,
      ),

      // === PROGRESS INDICATOR ===
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.progressIndicator,
      ),
    );
  }
}
