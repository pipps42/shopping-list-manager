import 'package:flutter/material.dart';
import '../../models/shopping_list.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class CompletedListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final bool showTime; // Se mostrare anche l'orario
  final int productCount;
  final VoidCallback onTap;

  const CompletedListCard({
    super.key,
    required this.shoppingList,
    required this.showTime,
    required this.productCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              // Icona e data
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingXS),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusS,
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: AppConstants.iconM,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        Expanded(
                          child: Text(
                            _formatDate(),
                            style: const TextStyle(
                              fontSize: AppConstants.fontL,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showTime) ...[
                      const SizedBox(height: AppConstants.spacingXS),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppConstants.paddingL,
                        ),
                        child: Text(
                          _formatTime(),
                          style: TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Statistiche
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Totale spesa
                    if (shoppingList.totalCost != null) ...[
                      Text(
                        '€${shoppingList.totalCost!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: AppConstants.fontXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                    ] else ...[
                      const SizedBox(height: AppConstants.spacingL),
                    ],

                    // Numero prodotti
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingS,
                        vertical: AppConstants.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusS,
                        ),
                        border: Border.all(
                          color: AppColors.border(context),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_basket,
                            size: AppConstants.iconS,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Text(
                            '$productCount',
                            style: TextStyle(
                              fontSize: AppConstants.fontM,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Freccia
              const SizedBox(width: AppConstants.spacingS),
              Icon(
                Icons.arrow_forward_ios,
                size: AppConstants.iconS,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    if (shoppingList.completedAt == null) return 'Data sconosciuta';

    final now = DateTime.now();
    final completedDate = shoppingList.completedAt!;
    final difference = now.difference(completedDate);

    // Oggi
    if (difference.inDays == 0) {
      return 'Oggi';
    }

    // Ieri
    if (difference.inDays == 1) {
      return 'Ieri';
    }

    // Questa settimana (ultimi 7 giorni)
    if (difference.inDays < 7) {
      final weekdays = [
        'Lunedì',
        'Martedì',
        'Mercoledì',
        'Giovedì',
        'Venerdì',
        'Sabato',
        'Domenica',
      ];
      return weekdays[completedDate.weekday - 1];
    }

    // Stesso anno
    if (completedDate.year == now.year) {
      final months = [
        'Gen',
        'Feb',
        'Mar',
        'Apr',
        'Mag',
        'Giu',
        'Lug',
        'Ago',
        'Set',
        'Ott',
        'Nov',
        'Dic',
      ];
      return '${completedDate.day} ${months[completedDate.month - 1]}';
    }

    // Anno diverso
    return '${completedDate.day}/${completedDate.month}/${completedDate.year}';
  }

  String _formatTime() {
    if (shoppingList.completedAt == null) return '';

    final time = shoppingList.completedAt!;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
