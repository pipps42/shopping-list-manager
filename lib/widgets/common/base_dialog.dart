import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

enum DialogActionType { cancel, delete, save, skip, custom }

class DialogAction {
  final DialogActionType? type;
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DialogAction({
    this.type,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  // Factory constructors per azioni comuni
  factory DialogAction.cancel({VoidCallback? onPressed}) => DialogAction(
        type: DialogActionType.cancel,
        text: AppStrings.cancel,
        onPressed: onPressed,
      );

  factory DialogAction.delete({required VoidCallback onPressed}) => DialogAction(
        type: DialogActionType.delete,
        text: AppStrings.delete,
        onPressed: onPressed,
      );

  factory DialogAction.save({
    required VoidCallback onPressed,
    bool isLoading = false,
    String? text,
  }) =>
      DialogAction(
        type: DialogActionType.save,
        text: text ?? AppStrings.save,
        onPressed: onPressed,
        isLoading: isLoading,
      );

  factory DialogAction.skip({required VoidCallback onPressed}) => DialogAction(
        type: DialogActionType.skip,
        text: AppStrings.skip,
        onPressed: onPressed,
      );
}

class BaseDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final Widget content;
  final List<DialogAction> actions;
  final bool hasColoredHeader;
  final double? width;
  final double? height;

  const BaseDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.titleIconColor,
    required this.content,
    this.actions = const [],
    this.hasColoredHeader = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.9,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with optional colored background
            _buildHeader(context),
            
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingL,
                  AppConstants.paddingM,
                  AppConstants.paddingL,
                  AppConstants.paddingM,
                ),
                child: content,
              ),
            ),
            
            // Actions
            if (actions.isNotEmpty) _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bottomPadding = hasColoredHeader ? AppConstants.paddingL : AppConstants.paddingM;
    
    final headerChild = Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        AppConstants.paddingL,
        AppConstants.paddingL,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with optional icon
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(
                  titleIcon!,
                  color: titleIconColor ?? 
                         (hasColoredHeader ? AppColors.textOnPrimary(context) : AppColors.primary),
                  size: AppConstants.iconL,
                ),
                const SizedBox(width: AppConstants.spacingM),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppConstants.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: hasColoredHeader ? AppColors.textOnPrimary(context) : null,
                  ),
                ),
              ),
            ],
          ),
          
          // Optional subtitle
          if (subtitle != null) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: AppConstants.fontL,
                color: hasColoredHeader 
                    ? AppColors.textOnPrimary(context).withValues(alpha: 0.8)
                    : AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );

    if (hasColoredHeader) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadius),
            topRight: Radius.circular(AppConstants.borderRadius),
          ),
        ),
        child: headerChild,
      );
    }
    
    return headerChild;
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        0,
        AppConstants.paddingL,
        AppConstants.paddingL,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions.map((action) => _buildActionButton(context, action)).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, DialogAction action) {
    final isElevated = action.type == DialogActionType.save || action.type == DialogActionType.delete;
    
    Color? backgroundColor;
    Color? foregroundColor;
    
    // Determine colors based on action type
    switch (action.type) {
      case DialogActionType.delete:
        backgroundColor = action.backgroundColor ?? AppColors.error;
        foregroundColor = action.foregroundColor ?? AppColors.textOnPrimary(context);
        break;
      case DialogActionType.save:
        backgroundColor = action.backgroundColor ?? AppColors.primary;
        foregroundColor = action.foregroundColor ?? AppColors.textOnPrimary(context);
        break;
      default:
        backgroundColor = action.backgroundColor;
        foregroundColor = action.foregroundColor;
        break;
    }

    final button = isElevated
        ? ElevatedButton(
            onPressed: action.isLoading ? null : action.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
            child: action.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? AppColors.textOnPrimary(context),
                      ),
                    ),
                  )
                : Text(action.text),
          )
        : TextButton(
            onPressed: action.isLoading ? null : action.onPressed,
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
            child: action.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Text(action.text),
          );

    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingS),
      child: button,
    );
  }
}

// Dialog semplice per conferme/eliminazioni
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onConfirm;
  final String confirmText;
  final DialogActionType confirmType;
  final bool hasColoredHeader;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    required this.onConfirm,
    this.confirmText = 'Conferma',
    this.confirmType = DialogActionType.delete,
    this.hasColoredHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      titleIcon: icon,
      titleIconColor: iconColor,
      hasColoredHeader: hasColoredHeader,
      content: Text(
        message,
        style: const TextStyle(fontSize: AppConstants.fontL),
      ),
      actions: [
        DialogAction.cancel(
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          type: confirmType,
          text: confirmText,
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}