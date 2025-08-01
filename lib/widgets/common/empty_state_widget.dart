import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcola dimensioni responsive basate sullo spazio disponibile
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // Calcola padding dinamico (min 16, max 32)
        final padding = (availableWidth * 0.05).clamp(16.0, 32.0);
        
        // Calcola dimensione icona dinamica
        final dynamicIconSize = iconSize ?? (availableHeight * 0.15).clamp(40.0, 80.0);
        
        // Calcola font size dinamici
        final titleFontSize = (availableHeight * 0.035).clamp(16.0, 24.0);
        final subtitleFontSize = (availableHeight * 0.025).clamp(14.0, 18.0);
        
        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: dynamicIconSize,
                  color: iconColor ?? AppColors.textDisabled(context),
                ),
                SizedBox(height: (availableHeight * 0.02).clamp(8.0, 16.0)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: (availableHeight * 0.01).clamp(4.0, 8.0)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (action != null) ...[
                  SizedBox(height: (availableHeight * 0.03).clamp(12.0, 24.0)),
                  action!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
