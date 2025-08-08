import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/icon_types.dart';
import '../../utils/color_palettes.dart';
import '../../utils/constants.dart';

/// Widget universale per renderizzare icone di tutti i tipi
class UniversalIcon extends StatelessWidget {
  final IconType iconType;
  final String? iconValue;
  final double size;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final BorderRadius? borderRadius;

  const UniversalIcon({
    super.key,
    required this.iconType,
    this.iconValue,
    this.size = AppConstants.imageM,
    this.fallbackIcon = Icons.shopping_basket,
    this.fallbackColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (iconValue == null) {
      return _buildFallbackIcon(context);
    }

    switch (iconType) {
      case IconType.emoji:
        return _buildEmojiIcon();
      case IconType.asset:
        return _buildAssetIcon();
      case IconType.custom:
        return _buildCustomIcon();
    }
  }

  Widget _buildEmojiIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        iconValue!,
        style: TextStyle(fontSize: size * 0.6), // Emoji size proporzionale
      ),
    );
  }

  Widget _buildAssetIcon() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
      child: Image.asset(
        iconValue!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: AppConstants.imageCacheWidth,
        cacheHeight: AppConstants.imageCacheHeight,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(context),
      ),
    );
  }

  Widget _buildCustomIcon() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
      child: Image.file(
        File(iconValue!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: AppConstants.imageCacheWidth,
        cacheHeight: AppConstants.imageCacheHeight,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(context),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (fallbackColor ?? AppColors.primary).withValues(alpha: 0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: fallbackColor ?? AppColors.primary,
      ),
    );
  }
}