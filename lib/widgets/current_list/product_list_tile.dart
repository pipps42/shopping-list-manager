import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/list_item.dart';
import '../../providers/current_list_provider.dart';

class ProductListTile extends ConsumerWidget {
  final ListItem item;

  const ProductListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('item_${item.id}'),
      background: _buildSwipeBackground(false),
      secondaryBackground: _buildSwipeBackground(true),
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
          color: item.isChecked ? Colors.grey[200] : Colors.white,
        ),
        child: ListTile(
          leading: _buildProductImage(),
          title: Text(
            item.productName ?? 'Prodotto sconosciuto',
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey[600] : null,
            ),
          ),
          trailing: item.isChecked
              ? Icon(Icons.check_circle, color: Colors.green[600])
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
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
          width: AppConstants.imageM,
          height: AppConstants.imageM,
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
      width: AppConstants.imageM,
      height: AppConstants.imageM,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: const Icon(Icons.shopping_basket, size: AppConstants.iconS),
    );
  }

  Widget _buildSwipeBackground(bool isSecondary) {
    return Container(
      color: isSecondary ? Colors.orange : Colors.green,
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Icon(
        isSecondary ? Icons.undo : Icons.check,
        color: Colors.white,
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppStrings.removeImage),
          ),
        ],
      ),
    );
  }
}
