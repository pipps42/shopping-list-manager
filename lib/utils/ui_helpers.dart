import 'dart:io';
import 'package:flutter/material.dart';
import '../models/list_item.dart';
import 'constants.dart';

class UIHelpers {
  static Color getItemColor(ListItem item, BuildContext context) {
    if (item.isChecked) {
      return Colors.grey[200]!;
    }
    return Theme.of(context).cardColor;
  }
  
  static TextStyle getItemTextStyle(ListItem item, BuildContext context) {
    return TextStyle(
      decoration: item.isChecked ? TextDecoration.lineThrough : null,
      color: item.isChecked 
          ? Colors.grey[600] 
          : Theme.of(context).textTheme.bodyLarge?.color,
    );
  }
  
  static Widget buildImageWidget({
    required String? imagePath,
    required double size,
    required Widget fallback,
  }) {
    if (imagePath == null) return fallback;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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