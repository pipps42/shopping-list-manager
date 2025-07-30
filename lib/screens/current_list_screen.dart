import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import '../providers/current_list_provider.dart';
import '../models/department_with_products.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/current_list/department_card.dart';
import '../widgets/current_list/complete_list_dialogs.dart';

class CurrentListScreen extends ConsumerWidget {
  const CurrentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentListState = ref.watch(currentListProvider);

    return Scaffold(
      appBar: AppBarGradientWithPopupMenu<String>(
        title: AppStrings.currentList,
        showDrawer: true,
        onDrawerPressed: () {
          final scaffoldState = context
              .findAncestorStateOfType<ScaffoldState>();
          scaffoldState?.openDrawer();
        },
        menuItems: [
          const PopupMenuItem(
            value: 'complete_list',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.completeList),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'clear_all',
            child: Row(
              children: [
                Icon(Icons.clear_all, color: AppColors.error),
                SizedBox(width: AppConstants.spacingS),
                Text(
                  AppStrings.clearList,
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) => _handleMenuAction(context, ref, value),
      ),
      body: currentListState.when(
        data: (departmentsWithProducts) =>
            _buildListView(context, ref, departmentsWithProducts),
        loading: () => const LoadingWidget(message: AppStrings.loadingList),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento della lista: $error',
          onRetry: () => ref.invalidate(currentListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "current_list_fab",
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary(context),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    List<DepartmentWithProducts> departments,
  ) {
    if (departments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: AppStrings.emptyList,
        subtitle: AppStrings.emptyListSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingM,
          left: AppConstants.paddingM,
          right: AppConstants.paddingM,
          bottom: AppConstants.listBottomSpacing, // Spazio per il FAB
        ),
        itemCount: departments.length,
        itemBuilder: (context, index) =>
            DepartmentCard(department: departments[index]),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductSelected: (productId) {
          ref.read(currentListProvider.notifier).addProductToList(productId);
        },
      ),
    );
  }

  // ==================== GESTIONE MENU ====================

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'complete_list':
        _showCompleteListFlow(context, ref);
        break;
      case 'clear_all':
        _showClearAllDialog(context, ref);
        break;
    }
  }

  // ==================== COMPLETAMENTO LISTA ====================

  Future<void> _showCompleteListFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Controlla se ci sono items nella lista
      final hasItems = await ref
          .read(currentListProvider.notifier)
          .hasItemsInCurrentList();

      if (!hasItems) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.listIsEmpty),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Ottieni le statistiche della lista per la validazione
      final stats = await ref
          .read(currentListProvider.notifier)
          .getCurrentListStats();

      // Mostra dialog per scegliere come completare
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => CompleteListChoiceDialog(
            onMarkAll: () =>
                _showTotalCostDialog(context, ref, markAllAsChecked: true),
            onKeepCurrent: () =>
                _validateAndShowTotalCostDialog(context, ref, stats: stats),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _validateAndShowTotalCostDialog(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, int> stats,
  }) async {
    // Controlla se ci sono prodotti checkati
    final checkedCount = stats['checked'] ?? 0;

    if (checkedCount == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.noItemsSelected),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Se ci sono prodotti checkati, procedi normalmente
    _showTotalCostDialog(context, ref, markAllAsChecked: false);
  }

  Future<void> _showTotalCostDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool markAllAsChecked,
  }) async {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => TotalCostDialog(
          onSave: (totalCost) => _completeList(
            context,
            ref,
            markAllAsChecked: markAllAsChecked,
            totalCost: totalCost,
          ),
        ),
      );
    }
  }

  Future<void> _completeList(
    BuildContext context,
    WidgetRef ref, {
    required bool markAllAsChecked,
    double? totalCost,
  }) async {
    try {
      await ref
          .read(currentListProvider.notifier)
          .completeCurrentList(
            markAllAsChecked: markAllAsChecked,
            totalCost: totalCost,
          );

      if (context.mounted) {
        final costText = totalCost != null
            ? ' (€${totalCost.toStringAsFixed(2)})'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.listCompleted}$costText'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.completionError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ==================== CANCELLAZIONE LISTA ====================

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearList),
        content: const Text(
          'Sei sicuro di voler rimuovere tutti i prodotti dalla lista corrente?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCurrentList(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary(context),
            ),
            child: const Text(AppStrings.clearList),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCurrentList(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(currentListProvider.notifier).clearAllItems();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.listCleared),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
