import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/loyalty_card.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class LoyaltyCardTile extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoyaltyCardTile({
    super.key,
    required this.card,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Immagine della carta
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Immagine
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusM),
                      topRight: Radius.circular(AppConstants.radiusM),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                      ),
                      child: File(card.imagePath).existsSync()
                          ? Image.file(
                              File(card.imagePath),
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                              cacheHeight: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildErrorPlaceholder(),
                            )
                          : _buildErrorPlaceholder(),
                    ),
                  ),
                  // Menu opzioni
                  Positioned(
                    top: AppConstants.paddingXS,
                    right: AppConstants.paddingXS,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusS,
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: AppConstants.iconM,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: AppConstants.iconS),
                                SizedBox(width: AppConstants.spacingS),
                                Text('Modifica'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                  size: AppConstants.iconS,
                                ),
                                SizedBox(width: AppConstants.spacingS),
                                Text(
                                  'Elimina',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nome della carta
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingS),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      _formatDate(card.createdAt),
                      style: TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: AppConstants.iconXL,
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.spacingS),
          Text(
            'Immagine\nnon trovata',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: AppConstants.fontM),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
