import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/swipe_action_tile.dart';
import '../../models/list_item_with_product.dart';
import '../../providers/current_list_provider.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/universal_icon.dart';

class ProductListTile extends ConsumerStatefulWidget {
  final ListItemWithProduct item;
  final bool readOnly;

  const ProductListTile({super.key, required this.item, this.readOnly = false});

  @override
  ConsumerState<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends ConsumerState<ProductListTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return _buildReadOnlyTile(context);
    }

    return SwipeActionTile(
      key: Key('item_${widget.item.id}'),
      onCheck: () {
        ref
            .read(currentListProvider.notifier)
            .toggleItemChecked(widget.item.id!, true);
      },
      onUncheck: () {
        ref
            .read(currentListProvider.notifier)
            .toggleItemChecked(widget.item.id!, false);
      },
      onRemove: () {
        ref
            .read(currentListProvider.notifier)
            .removeProductFromList(widget.item.product.id!);
      },
      isChecked: widget.item.isChecked,
      child: ListTile(
        leading: _buildProductImage(),
        title: Text(
          widget.item.product.name,
          style: TextStyle(
            decoration: widget.item.isChecked
                ? TextDecoration.lineThrough
                : null,
            color: widget.item.isChecked
                ? AppColors.textSecondary(context)
                : null,
          ),
        ),
        trailing: widget.item.isChecked
            ? Icon(Icons.check_circle, color: AppColors.success)
            : Icon(
                Icons.swipe_right_alt,
                color: AppColors.textDisabled(context),
              ),
        onLongPress: () => _showRemoveDialog(context),
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
          widget.item.product.name,
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
      iconType: widget.item.product.iconType,
      iconValue: widget.item.product.iconValue,
      size: AppConstants.imageXL,
      fallbackIcon: Icons.shopping_basket,
    );
  }

  void _showRemoveDialog(BuildContext context) {
    if (widget.readOnly) return; // Non mostrare dialog se in modalità read-only

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi prodotto'),
        content: Text(
          'Vuoi rimuovere "${widget.item.product.name}" dalla lista?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(currentListProvider.notifier)
                  .removeProductFromList(widget.item.product.id!);
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
