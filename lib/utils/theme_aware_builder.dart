import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/theme_manager.dart';

/// ===== THEME AWARE BUILDER (per Dialog/Modal) =====

class ThemeAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const ThemeAwareBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeManager(),
      builder: (context, child) => builder(context),
    );
  }
}

/// ===== DEBUG HELPER =====

class ColorDebugScreen extends StatelessWidget {
  const ColorDebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeAwareBuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Debug Colori Fresh Market'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.headerGradientStart,
                  AppColors.headerGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildColorSection('Fresh Market Colors', [
              ('Primary (Verde foresta)', AppColors.primary),
              ('Secondary (Blu moderno)', AppColors.secondary),
              ('Accent (Arancione)', AppColors.accent),
            ]),
            _buildColorSection('System Colors', [
              ('Text Primary', AppColors.textPrimary),
              ('Text Secondary', AppColors.textSecondary),
              ('Text Disabled', AppColors.textDisabled),
              ('Background', AppColors.background),
              ('Surface', AppColors.surface),
              ('Card Background', AppColors.cardBackground),
            ]),
            _buildColorSection('Universal Colors', [
              ('Success', AppColors.success),
              ('Error', AppColors.error),
              ('Warning', AppColors.warning),
              ('Info', AppColors.info),
            ]),
            const SizedBox(height: 20),
            Text(
              'Tema corrente: ${AppColors.isDark ? "Scuro" : "Chiaro"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => BrandPaletteManager.enableHighContrast(),
              child: const Text('Testa High Contrast'),
            ),
            ElevatedButton(
              onPressed: () => BrandPaletteManager.setFreshMarket(),
              child: const Text('Ripristina Fresh Market'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(String title, List<(String, Color)> colors) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...colors.map(
              (colorData) => _buildColorTile(colorData.$1, colorData.$2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  color.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
