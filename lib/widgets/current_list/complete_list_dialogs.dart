import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class CompleteListChoiceDialog extends StatelessWidget {
  final VoidCallback onMarkAll;
  final VoidCallback onKeepCurrent;

  const CompleteListChoiceDialog({
    super.key,
    required this.onMarkAll,
    required this.onKeepCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: AppConstants.iconL,
          ),
          const SizedBox(width: AppConstants.spacingM),
          const Text(AppStrings.completeList),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.howToComplete,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          _buildOption(
            context,
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            title: AppStrings.markAllAsTaken,
            subtitle: AppStrings.markAllAsTakenSubtitle,
            onTap: () {
              Navigator.pop(context);
              onMarkAll();
            },
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildOption(
            context,
            icon: Icons.checklist,
            iconColor: AppColors.primary,
            title: AppStrings.keepCurrentState,
            subtitle: AppStrings.keepCurrentStateSubtitle,
            onTap: () {
              Navigator.pop(context);
              onKeepCurrent();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context), width: 1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(icon, color: iconColor, size: AppConstants.iconL),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
          ],
        ),
      ),
    );
  }
}

class UnpurchasedItemsHandlingDialog extends StatelessWidget {
  final VoidCallback onRemoveItems;
  final VoidCallback onKeepItems;

  const UnpurchasedItemsHandlingDialog({
    super.key,
    required this.onRemoveItems,
    required this.onKeepItems,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: AppColors.primary,
            size: AppConstants.iconL,
          ),
          const SizedBox(width: AppConstants.spacingM),
          const Text(AppStrings.handleUnpurchasedItems),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.howToHandleUnpurchasedItems,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          _buildOption(
            context,
            icon: Icons.delete_outline,
            iconColor: AppColors.error,
            title: AppStrings.removeFromList,
            subtitle: AppStrings.removeFromListSubtitle,
            onTap: () {
              Navigator.pop(context);
              onRemoveItems();
            },
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildOption(
            context,
            icon: Icons.shopping_cart_outlined,
            iconColor: AppColors.success,
            title: AppStrings.keepForNextShopping,
            subtitle: AppStrings.keepForNextShoppingSubtitle,
            onTap: () {
              Navigator.pop(context);
              onKeepItems();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context), width: 1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(icon, color: iconColor, size: AppConstants.iconL),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
          ],
        ),
      ),
    );
  }
}

class TotalCostDialog extends StatefulWidget {
  final Function(double?) onSave;

  const TotalCostDialog({super.key, required this.onSave});

  @override
  State<TotalCostDialog> createState() => _TotalCostDialogState();
}

class _TotalCostDialogState extends State<TotalCostDialog> {
  final TextEditingController _costController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.euro, color: AppColors.primary, size: AppConstants.iconL),
          const SizedBox(width: AppConstants.spacingM),
          const Text(AppStrings.totalCost),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.enterTotalCost,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            AppStrings.totalCostHint,
            style: TextStyle(
              fontSize: AppConstants.fontM,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          TextField(
            controller: _costController,
            enabled: !_isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: AppStrings.amount,
              hintText: '0.00',
              prefixIcon: const Icon(Icons.euro),
              border: const OutlineInputBorder(),
              suffixText: '€',
              helperText: AppStrings.optional,
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => _saveWithoutCost(),
          child: const Text(AppStrings.skip),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary(context),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }

  void _saveWithoutCost() {
    Navigator.pop(context);
    widget.onSave(null);
  }

  void _saveCost() {
    final costText = _costController.text.trim();

    if (costText.isEmpty) {
      _saveWithoutCost();
      return;
    }

    final cost = double.tryParse(costText);
    if (cost == null || cost < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci un importo valido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Navigator.pop(context);
    widget.onSave(cost);
  }
}
