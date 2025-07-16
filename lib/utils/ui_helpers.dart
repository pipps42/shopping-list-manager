import 'dart:io';
import 'package:flutter/material.dart';
import '../models/list_item.dart';
import 'constants.dart';
import 'color_palettes.dart';

class UIHelpers {
  static Color getItemColor(ListItem item, BuildContext context) {
    if (item.isChecked) {
      return AppColors.surface(context);
    }
    return AppColors.cardBackground(context);
  }

  static TextStyle getItemTextStyle(ListItem item, BuildContext context) {
    return TextStyle(
      decoration: item.isChecked ? TextDecoration.lineThrough : null,
      color: item.isChecked
          ? AppColors.textSecondary(context)
          : AppColors.textPrimary(context),
    );
  }

  static Widget buildImageWidget({
    required String? imagePath,
    required double size,
    required Widget fallback,
  }) {
    if (imagePath == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Image.file(
        File(imagePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: AppConstants.imageCacheWidth,
        cacheHeight: AppConstants.imageCacheHeight,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
