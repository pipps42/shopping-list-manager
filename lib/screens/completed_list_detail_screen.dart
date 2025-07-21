import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import '../models/shopping_list.dart';
import '../models/department_with_products.dart';
import '../providers/completed_lists_provider.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/completed_lists/completed_department_card.dart';
import '../utils/constants.dart';
import '../utils/color_palettes.dart';

class CompletedListDetailScreen extends ConsumerWidget {
  final ShoppingList shoppingList;

  const CompletedListDetailScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      completedListDetailProvider(shoppingList.id!),
    );

    return Scaffold(
      appBar: AppBarGradientWithPopupMenu<String>(
        title: Text(
          _formatAppBarTitle(),
          style: const TextStyle(fontSize: AppConstants.fontXL),
        ),
        subtitle: shoppingList.totalCost != null
            ? Text(
                '€${shoppingList.totalCost!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.textOnPrimary(context).withOpacity(0.8),
                  fontWeight: FontWeight.normal,
                ),
              )
            : null,
        menuItems: [
          const PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.refresh),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'reorder',
            child: Row(
              children: [
                Icon(Icons.add_shopping_cart),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.buyAgain),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.share),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) => _handleMenuAction(context, ref, value),
      ),
      body: detailState.when(
        data: (departments) => _buildDetailView(context, ref, departments),
        loading: () =>
            const LoadingWidget(message: 'Caricamento dettagli lista...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento dei dettagli: $error',
          onRetry: () =>
              ref.invalidate(completedListDetailProvider(shoppingList.id!)),
        ),
      ),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    WidgetRef ref,
    List<DepartmentWithProducts> departments,
  ) {
    if (departments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_basket_outlined,
        title: AppStrings.emptyList,
        subtitle: 'Questa lista non contiene prodotti.',
      );
    }

    // Calcola statistiche
    final totalProducts = departments.expand((dept) => dept.items).length;
    final checkedProducts = departments
        .expand((dept) => dept.items)
        .where((item) => item.isChecked)
        .length;

    return Column(
      children: [
        // Header con statistiche
        _buildStatsHeader(context, totalProducts, checkedProducts),

        // Lista reparti
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(completedListDetailProvider(shoppingList.id!));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 0,
                left: AppConstants.paddingM,
                right: AppConstants.paddingM,
                bottom: AppConstants.paddingM,
              ),
              itemCount: departments.length,
              itemBuilder: (context, index) =>
                  CompletedDepartmentCard(department: departments[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    int totalProducts,
    int checkedProducts,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: AppConstants.iconL,
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.listCompleted,
                  style: TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  '$checkedProducts su $totalProducts prodotti acquistati',
                  style: TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          // Badge con percentuale
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Text(
              '${((checkedProducts / totalProducts) * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppConstants.fontM,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAppBarTitle() {
    if (shoppingList.completedAt == null) return AppStrings.listCompleted;

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

    // Questa settimana
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
        'Gennaio',
        'Febbraio',
        'Marzo',
        'Aprile',
        'Maggio',
        'Giugno',
        'Luglio',
        'Agosto',
        'Settembre',
        'Ottobre',
        'Novembre',
        'Dicembre',
      ];
      return '${completedDate.day} ${months[completedDate.month - 1]}';
    }

    // Anno diverso
    return '${completedDate.day}/${completedDate.month}/${completedDate.year}';
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'refresh':
        ref.invalidate(completedListDetailProvider(shoppingList.id!));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dettagli aggiornati'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      // Future actions
      // case 'reorder':
      //   _reorderItems(context, ref);
      //   break;
      // case 'share':
      //   _shareList(context);
      //   break;
    }
  }
}
