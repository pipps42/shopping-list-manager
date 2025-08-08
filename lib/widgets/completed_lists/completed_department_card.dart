import 'package:flutter/material.dart';
import '../../models/department_with_products.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';
import '../../utils/icon_types.dart';
import '../common/universal_icon.dart';

class CompletedDepartmentCard extends StatelessWidget {
  final DepartmentWithProducts department;

  const CompletedDepartmentCard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final total = department.items.length;
    final checked = department.items.where((item) => item.isChecked).length;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del reparto
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusM),
                topRight: Radius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              children: [
                // Immagine del reparto
                _buildDepartmentImage(context),
                const SizedBox(width: AppConstants.spacingM),

                // Nome reparto
                Expanded(
                  child: Text(
                    department.department.name,
                    style: const TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Statistiche (prodotti presi/totali)
                _buildStats(context, checked, total),
              ],
            ),
          ),

          // Lista prodotti
          ...department.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == department.items.length - 1;

            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: AppColors.border(context),
                          width: 0.5,
                        ),
                      ),
              ),
              child: _buildProductTile(context, item),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDepartmentImage(BuildContext context) {
    return UniversalIcon(
      iconType: department.department.iconType,
      iconValue: department.department.iconValue,
      size: AppConstants.imageXL,
      fallbackIcon: Icons.store,
    );
  }

  Widget _buildStats(BuildContext context, int checked, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: AppConstants.iconS,
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            '$checked/$total',
            style: TextStyle(
              fontSize: AppConstants.fontM,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, item) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Row(
        children: [
          // Stato del prodotto (checkato o no)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isChecked ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: item.isChecked
                    ? AppColors.success
                    : AppColors.border(context),
                width: 2,
              ),
            ),
            child: item.isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: AppConstants.spacingM),

          // Icona prodotto
          UniversalIcon(
            iconType: item.productIconType != null
                ? IconType.fromString(item.productIconType!)
                : IconType.asset,
            iconValue: item.productIconValue,
            size: AppConstants.imageM,
            fallbackIcon: Icons.shopping_basket,
          ),
          const SizedBox(width: AppConstants.spacingM),

          // Nome prodotto
          Expanded(
            child: Text(
              item.productName ?? 'Prodotto sconosciuto',
              style: TextStyle(
                fontSize: AppConstants.fontL,
                fontWeight: FontWeight.w500,
                color: item.isChecked
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
                decoration: item.isChecked ? null : TextDecoration.lineThrough,
              ),
            ),
          ),

          // Icona stato
          Icon(
            item.isChecked ? Icons.shopping_bag : Icons.remove_circle_outline,
            color: item.isChecked
                ? AppColors.success
                : AppColors.textSecondary(context),
            size: AppConstants.iconM,
          ),
        ],
      ),
    );
  }
}
