import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import '../providers/current_list_provider.dart';
import '../providers/list_type_provider.dart';
import '../models/department.dart';
import '../models/list_item_with_product.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/current_list/department_card.dart';
import '../widgets/current_list/complete_list_dialogs.dart';
import '../providers/voice_recognition_provider.dart';
import '../models/product.dart';

class CurrentListScreen extends ConsumerWidget {
  const CurrentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentListState = ref.watch(currentListProvider);
    final currentListType = ref.watch(currentListTypeProvider);
    final listTypeName = getListTypeName(currentListType);

    return Scaffold(
      appBar: AppBarGradientWithPopupMenu<String>(
        title: listTypeName,
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
        data: (departmentMap) =>
            _buildListView(context, ref, departmentMap),
        loading: () => const LoadingWidget(message: AppStrings.loadingList),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento della lista: $error',
          onRetry: () => ref.invalidate(currentListProvider),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(context, ref),
    );
  }

  Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    Map<Department, List<ListItemWithProduct>> departmentMap,
  ) {
    if (departmentMap.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: AppStrings.emptyList,
        subtitle: AppStrings.emptyListSubtitle,
      );
    }

    // Converti la Map in lista ordinata per department.orderIndex
    final sortedDepartments = departmentMap.entries.toList()
      ..sort((a, b) => a.key.orderIndex.compareTo(b.key.orderIndex));

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
        itemCount: sortedDepartments.length,
        itemBuilder: (context, index) {
          final entry = sortedDepartments[index];
          final department = entry.key;
          final items = entry.value;
          
          return DepartmentCard(
            department: department,
            items: items,
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog.forCurrentList(
        onProductSelected: (productId) {
          ref.read(currentListProvider.notifier).addProductToList(productId);
        },
        onProductRemoved: (productId) {
          ref
              .read(currentListProvider.notifier)
              .removeProductFromList(productId);
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
            onMarkAll: () => _showTotalCostDialog(
              context,
              ref,
              markAllAsChecked: true,
              keepUncheckedItems: false,
            ),
            onKeepCurrent: () => _validateAndShowUnpurchasedItemsDialog(
              context,
              ref,
              stats: stats,
            ),
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

  Future<void> _validateAndShowUnpurchasedItemsDialog(
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

    // Se ci sono prodotti checkati, mostra dialog per gestire quelli non acquistati
    _showUnpurchasedItemsHandlingDialog(context, ref);
  }

  Future<void> _showUnpurchasedItemsHandlingDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => UnpurchasedItemsHandlingDialog(
          onRemoveItems: () => _showTotalCostDialog(
            context,
            ref,
            markAllAsChecked: false,
            keepUncheckedItems: false,
          ),
          onKeepItems: () => _showTotalCostDialog(
            context,
            ref,
            markAllAsChecked: false,
            keepUncheckedItems: true,
          ),
        ),
      );
    }
  }

  Future<void> _showTotalCostDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool markAllAsChecked,
    required bool keepUncheckedItems,
  }) async {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => TotalCostDialog(
          onSave: (totalCost) => _completeList(
            context,
            ref,
            markAllAsChecked: markAllAsChecked,
            keepUncheckedItems: keepUncheckedItems,
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
    required bool keepUncheckedItems,
    double? totalCost,
  }) async {
    try {
      await ref
          .read(currentListProvider.notifier)
          .completeCurrentList(
            markAllAsChecked: markAllAsChecked,
            keepUncheckedItems: keepUncheckedItems,
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

  // ==================== FLOATING ACTION BUTTONS ====================

  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceRecognitionProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // FAB per cancellazione (visibile solo durante l'ascolto)
        if (voiceState.isListening) ...[
          FloatingActionButton(
            heroTag: "cancel_voice_fab",
            onPressed: () => _cancelVoiceRecognition(ref),
            backgroundColor: AppColors.error.withValues(alpha: 0.2),
            foregroundColor: AppColors.error,
            child: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: AppConstants.spacingS),
        ],

        // FAB per riconoscimento vocale/stop
        FloatingActionButton(
          heroTag: "voice_recognition_fab",
          onPressed: voiceState.isListening
              ? () => _stopVoiceRecognition(ref)
              : () => _startVoiceRecognition(context, ref),
          backgroundColor: voiceState.isListening
              ? AppColors.error
              : AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary(context),
          child: voiceState.isListening
              ? const Icon(Icons.stop)
              : const Icon(Icons.mic),
        ),

        const SizedBox(width: AppConstants.spacingS),

        // FAB per aggiunta manuale prodotto
        FloatingActionButton(
          heroTag: "current_list_add_fab",
          onPressed: () => _showAddProductDialog(context, ref),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary(context),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  // ==================== VOICE RECOGNITION METHODS ====================

  void _startVoiceRecognition(BuildContext context, WidgetRef ref) {
    final voiceNotifier = ref.read(voiceRecognitionProvider.notifier);

    voiceNotifier.startListening(
      onResult: (products) => _handleVoiceResult(context, ref, products),
      context: context,
    );
  }

  void _stopVoiceRecognition(WidgetRef ref) {
    final voiceNotifier = ref.read(voiceRecognitionProvider.notifier);
    voiceNotifier.stopListening(); // Processa i risultati accumulati
  }

  void _cancelVoiceRecognition(WidgetRef ref) {
    final voiceNotifier = ref.read(voiceRecognitionProvider.notifier);
    voiceNotifier.cancelListening(); // Ignora completamente i risultati
  }

  void _handleVoiceResult(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nessun prodotto riconosciuto'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Aggiungi i prodotti alla lista corrente
    final currentListNotifier = ref.read(currentListProvider.notifier);
    final productIds = products.map((p) => p.id!).toList();

    currentListNotifier
        .addMultipleProductsToList(productIds)
        .then((_) {
          // Mostra messaggio di successo
          final productNames = products.map((p) => p.name).join(', ');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aggiunti: $productNames'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppColors.textOnPrimary(context),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ),
          );
        })
        .catchError((error) {
          // Mostra messaggio di errore
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore aggiunta prodotti: $error'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        });
  }
}
