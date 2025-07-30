import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import '../models/shopping_list.dart';
import '../providers/completed_lists_provider.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/completed_lists/timeline_segment.dart';
import '../widgets/completed_lists/completed_list_card.dart';
import '../utils/constants.dart';
import '../utils/color_palettes.dart';
import 'completed_list_detail_screen.dart';

class CompletedListsScreen extends ConsumerWidget {
  const CompletedListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedListsState = ref.watch(completedListsProvider);

    return Scaffold(
      appBar: AppBarGradientWithPopupMenu<String>(
        title: AppStrings.lastLists,
        showDrawer: true,
        onDrawerPressed: () {
          final scaffoldState = context
              .findAncestorStateOfType<ScaffoldState>();
          scaffoldState?.openDrawer();
        },
        menuItems: [
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(Icons.upload, color: AppColors.secondary),
                SizedBox(width: AppConstants.spacingS),
                Text(AppStrings.export),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'clear_completed',
            child: Row(
              children: [
                Icon(Icons.delete_sweep, color: AppColors.error),
                SizedBox(width: AppConstants.spacingS),
                Text(
                  AppStrings.deleteLastLists,
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) => _handleMenuAction(context, ref, value),
      ),
      body: completedListsState.when(
        data: (lists) => _buildPixelPerfectTimeline(context, ref, lists),
        loading: () =>
            const LoadingWidget(message: 'Caricamento ultime liste...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento delle liste: $error',
          onRetry: () => ref.invalidate(completedListsProvider),
        ),
      ),
    );
  }

  Widget _buildPixelPerfectTimeline(
    BuildContext context,
    WidgetRef ref,
    List<CompletedListWithCount> listsWithCounts,
  ) {
    if (listsWithCounts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: 'Nessuna lista completata',
        subtitle:
            'Le tue liste completate appariranno qui.\nCompleta la prima lista dalla sezione "Lista Corrente"!',
      );
    }

    final flatItems = _prepareFlatItems(listsWithCounts);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(completedListsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: flatItems.length,
        // Rimosso itemExtent - altezza dinamica basata sul contenuto
        itemBuilder: (context, index) {
          final item = flatItems[index];
          final isFirst = index == 0;
          final isLast = index == flatItems.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline segment (si adatta all'altezza del contenuto)
                TimelineSegment(
                  isMonth: item is _MonthHeaderItem,
                  isFirst: isFirst,
                  isLast: isLast,
                ),

                // Contenuto senza padding fisso
                Expanded(child: _buildItemContent(context, item)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, _FlatItem item) {
    if (item is _MonthHeaderItem) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.timelineContentPadding,
          horizontal: 8,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            item.monthLabel,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
      );
    } else if (item is _ListCardItem) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.timelineContentPadding,
        ),
        child: CompletedListCard(
          shoppingList: item.list,
          showTime: item.showTime,
          productCount: item.productCount,
          onTap: () => _navigateToDetail(context, item.list),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  List<_FlatItem> _prepareFlatItems(
    List<CompletedListWithCount> listsWithCounts,
  ) {
    final List<_FlatItem> flatItems = [];
    final listsWithTimeInfo = _prepareListsWithTimeInfo(listsWithCounts);

    for (int i = 0; i < listsWithTimeInfo.length; i++) {
      final listInfo = listsWithTimeInfo[i];
      final currentMonthKey = _getMonthKey(listInfo.list.completedAt!);

      // Aggiungi la card della lista
      flatItems.add(
        _ListCardItem(
          list: listInfo.list,
          showTime: listInfo.showTime,
          productCount: listInfo.productCount,
        ),
      );

      // Controlla se la prossima lista è di un mese diverso
      // Se sì, inserisci separatore del mese corrente (che sta "finendo")
      if (i < listsWithTimeInfo.length - 1) {
        final nextListInfo = listsWithTimeInfo[i + 1];
        final nextMonthKey = _getMonthKey(nextListInfo.list.completedAt!);

        if (currentMonthKey != nextMonthKey) {
          // Inserisci separatore del mese che sta "finendo"
          flatItems.add(_MonthHeaderItem(currentMonthKey));
        }
      }
    }

    return flatItems;
  }

  List<_ListWithTimeInfo> _prepareListsWithTimeInfo(
    List<CompletedListWithCount> listsWithCounts,
  ) {
    // Raggruppa per data (senza orario)
    final Map<String, List<CompletedListWithCount>> groupedByDate = {};

    for (final listWithCount in listsWithCounts) {
      if (listWithCount.list.completedAt != null) {
        final dateKey = _getDateKey(listWithCount.list.completedAt!);
        groupedByDate.putIfAbsent(dateKey, () => []).add(listWithCount);
      }
    }

    // Prepara la lista con info su quando mostrare l'orario
    final List<_ListWithTimeInfo> result = [];

    for (final listWithCount in listsWithCounts) {
      if (listWithCount.list.completedAt != null) {
        final dateKey = _getDateKey(listWithCount.list.completedAt!);
        final listsInSameDate = groupedByDate[dateKey] ?? [];

        // Mostra l'orario solo se ci sono più liste nello stesso giorno
        final showTime = listsInSameDate.length > 1;

        result.add(
          _ListWithTimeInfo(
            list: listWithCount.list,
            productCount: listWithCount.productCount,
            showTime: showTime,
          ),
        );
      }
    }

    return result;
  }

  String _getMonthKey(DateTime dateTime) {
    final now = DateTime.now();
    final currentYear = now.year;

    final monthNames = [
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

    final monthName = monthNames[dateTime.month - 1];

    // Mostra l'anno solo se non è l'anno corrente
    if (dateTime.year != currentYear) {
      return '$monthName ${dateTime.year}';
    } else {
      return monthName;
    }
  }

  String _getDateKey(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'clear_completed':
        _showDeleteAllDialog(context, ref);
        break;
    }
  }

  void _navigateToDetail(BuildContext context, ShoppingList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedListDetailScreen(shoppingList: list),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancella tutte le liste'),
        content: const Text(
          'Sei sicuro di voler eliminare tutte le liste completate?\n\n'
          'Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllCompletedLists(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary(context),
            ),
            child: const Text('Cancella tutte'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllCompletedLists(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(completedListsProvider.notifier).deleteAllCompletedLists();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutte le liste sono state eliminate'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'eliminazione: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Classi helper per gli elementi della lista piatta
abstract class _FlatItem {}

class _MonthHeaderItem extends _FlatItem {
  final String monthLabel;
  _MonthHeaderItem(this.monthLabel);
}

class _ListCardItem extends _FlatItem {
  final ShoppingList list;
  final bool showTime;
  final int productCount;

  _ListCardItem({
    required this.list,
    required this.showTime,
    required this.productCount,
  });
}

class _ListWithTimeInfo {
  final ShoppingList list;
  final int productCount;
  final bool showTime;

  _ListWithTimeInfo({
    required this.list,
    required this.productCount,
    required this.showTime,
  });
}
