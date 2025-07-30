import 'package:flutter/material.dart';
import '../../models/shopping_list.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class CompletedListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final bool showTime;
  final int productCount;
  final VoidCallback onTap;
  final VoidCallback? onEditPrice;
  final VoidCallback? onDelete;

  const CompletedListCard({
    super.key,
    required this.shoppingList,
    required this.showTime,
    required this.productCount,
    required this.onTap,
    this.onEditPrice,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Crea una chiave unica per ogni istanza della card
    final popupKey = GlobalKey<PopupMenuButtonState<String>>();
    
    return Card(
      margin: EdgeInsets.zero, // Nessun margin, gestito dal parent
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          // Attiva il PopupMenuButton programmaticamente
          popupKey.currentState?.showButtonMenu();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              // Nome lista e data
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome della lista
                    Text(
                      shoppingList.name,
                      style: TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),

                    // Data/Ora
                    Text(
                      _formatDateTime(shoppingList.completedAt!),
                      style: TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Numero prodotti e prezzo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Numero prodotti
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingS,
                      vertical: AppConstants.paddingXS,
                    ),
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          color: AppColors.secondary,
                          size: AppConstants.iconS,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '$productCount',
                          style: TextStyle(
                            fontSize: AppConstants.fontM,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prezzo
                  if (shoppingList.totalCost != null) ...[
                    Text(
                      '€${shoppingList.totalCost!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: AppConstants.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '€---.--',
                      style: TextStyle(
                        fontSize: AppConstants.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),

              // Bottone menu contestuale
              if (onEditPrice != null || onDelete != null)
                PopupMenuButton<String>(
                  key: popupKey,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit_price':
                        onEditPrice?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEditPrice != null)
                      const PopupMenuItem<String>(
                        value: 'edit_price',
                        child: Row(
                          children: [
                            Icon(Icons.euro, color: AppColors.secondary),
                            SizedBox(width: AppConstants.spacingS),
                            Text('Modifica prezzo'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: AppConstants.spacingS),
                            Text('Elimina lista', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return showTime ? 'Oggi, ${_formatTime(dateTime)}' : 'Oggi';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return showTime ? 'Ieri, ${_formatTime(dateTime)}' : 'Ieri';
    } else {
      final formatted = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      return showTime ? '$formatted, ${_formatTime(dateTime)}' : formatted;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
