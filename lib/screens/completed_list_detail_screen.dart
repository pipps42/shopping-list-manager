import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import '../models/shopping_list.dart';
import '../models/department_with_products.dart';
import '../providers/completed_lists_provider.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/current_list/department_card.dart';
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
            value: 'reorder',
            child: Row(
              children: [
                Icon(Icons.add_shopping_cart),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.buyAgain),
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(completedListDetailProvider(shoppingList.id!));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingM,
          left: AppConstants.paddingM,
          right: AppConstants.paddingM,
          bottom: AppConstants.paddingM,
        ),
        itemCount: departments.length,
        itemBuilder: (context, index) =>
            DepartmentCard(department: departments[index], readOnly: true),
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
      // Future actions
      // case 'reorder':
      //   _reorderItems(context, ref);
      //   break;
    }
  }
}
