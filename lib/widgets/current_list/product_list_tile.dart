import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/list_item.dart';
import '../../providers/current_list_provider.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class ProductListTile extends ConsumerWidget {
  final ListItem item;

  const ProductListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Icons.radio_button_unchecked,
                  color: AppColors.textDisabled(context),
                ),
          onLongPress: () => _showRemoveDialog(context, ref),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (item.productImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(item.productImagePath!),
          width: AppConstants.imageL,
          height: AppConstants.imageL,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: AppConstants.imageL,
      height: AppConstants.imageL,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.2,
        ), // ✅ Brand primary con opacity
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Icon(
        Icons.shopping_basket,
        size: AppConstants.iconL,
        color: AppColors.primary, // ✅ Aggiungi colore icona
      ),
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
