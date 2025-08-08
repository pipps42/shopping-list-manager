import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/list_item.dart';
import '../../providers/current_list_provider.dart';
import '../../utils/icon_types.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/universal_icon.dart';

class ProductListTile extends ConsumerWidget {
  final ListItem item;
  final bool readOnly;

  const ProductListTile({super.key, required this.item, this.readOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (readOnly) {
      return _buildReadOnlyTile(context);
    }

    return Dismissible(
      key: Key('item_${item.id}'),
      background: _buildSwipeBackground(context, false),
      secondaryBackground: _buildSwipeBackground(context, true),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ref
              .read(currentListProvider.notifier)
              .toggleItemChecked(item.id!, true);
        } else if (direction == DismissDirection.endToStart) {
          ref
              .read(currentListProvider.notifier)
              .toggleItemChecked(item.id!, false);
        }
        return false; // Non rimuovere l'item, solo aggiorna lo stato
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: item.isChecked
              ? AppColors.completedOverlay
              : AppColors.cardBackground(context),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
        child: ListTile(
          leading: _buildProductImage(),
          title: Text(
            item.productName ?? 'Prodotto sconosciuto',
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? AppColors.textSecondary(context) : null,
            ),
          ),
          trailing: item.isChecked
              ? Icon(Icons.check_circle, color: AppColors.success)
              : Icon(
                  Icons.swipe_right_alt,
                  color: AppColors.textDisabled(context),
                ),
          onLongPress: () => _showRemoveDialog(context, ref),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.cardBackground(context)),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: ListTile(
        leading: _buildProductImage(),
        title: Text(
          item.productName ?? 'Prodotto sconosciuto',
          style: TextStyle(
            fontSize: AppConstants.fontL,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return UniversalIcon(
      iconType: IconType.fromString(item.productIconType ?? 'asset'),
      iconValue: item.productIconValue,
      size: AppConstants.imageXL,
      fallbackIcon: Icons.shopping_basket,
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isSecondary) {
    return Container(
      color: isSecondary ? AppColors.swipeDelete : AppColors.success,
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Icon(
        isSecondary ? Icons.undo : Icons.check,
        color: AppColors.textOnPrimary(context),
        size: AppConstants.iconL,
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref) {
    if (readOnly) return; // Non mostrare dialog se in modalità read-only

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi prodotto'),
        content: Text('Vuoi rimuovere "${item.productName}" dalla lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(currentListProvider.notifier)
                  .removeItemFromList(item.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary(context),
            ),
            child: Text(AppStrings.removeImage),
          ),
        ],
      ),
    );
  }
}
