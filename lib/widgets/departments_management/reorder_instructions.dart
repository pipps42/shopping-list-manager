import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class ReorderInstructionsWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const ReorderInstructionsWidget({
    super.key,
    this.text = AppStrings.reorderInstructions,
    this.icon = Icons.drag_handle,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.info.withOpacity(0.1);
    final txtColor = textColor ?? AppColors.info;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, color: txtColor),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: txtColor, fontSize: AppConstants.fontL),
            ),
          ),
        ],
      ),
    );
  }
}
