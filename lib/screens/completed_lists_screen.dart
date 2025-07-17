// lib/screens/completed_lists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../providers/completed_lists_provider.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
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
      appBar: AppBar(
        title: const Text('Ultime Liste'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: AppColors.textOnPrimary(context),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            try {
              Scaffold.of(context).openDrawer();
            } catch (e) {
              final scaffoldState = context
                  .findAncestorStateOfType<ScaffoldState>();
              scaffoldState?.openDrawer();
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: AppConstants.spacingS),
                    Text('Aggiorna'),
                  ],
                ),
              ),
              // 🔥 FUTURE: Analytics/Statistics
              // const PopupMenuItem(
              //   value: 'analytics',
              //   child: Row(
              //     children: [
              //       Icon(Icons.analytics),
              //       SizedBox(width: AppConstants.spacingS),
              //       Text('Statistiche'),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
      body: completedListsState.when(
        data: (lists) => _buildListView(context, ref, lists),
        loading: () =>
            const LoadingWidget(message: 'Caricamento ultime liste...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento delle liste: $error',
          onRetry: () => ref.invalidate(completedListsProvider),
        ),
      ),
    );
  }

  Widget _buildListView(
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

    // Raggruppa liste per data per determinare quando mostrare l'orario
    final listsWithTimeInfo = _prepareListsWithTimeInfo(listsWithCounts);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(completedListsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: listsWithTimeInfo.length,
        itemBuilder: (context, index) {
          final listInfo = listsWithTimeInfo[index];
          return CompletedListCard(
            shoppingList: listInfo.list,
            showTime: listInfo.showTime,
            productCount: listInfo.productCount,
            onTap: () => _navigateToDetail(context, listInfo.list),
          );
        },
      ),
    );
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
        final showTime = listsInSameDate.length > 1;

        result.add(
          _ListWithTimeInfo(
            list: listWithCount.list,
            showTime: showTime,
            productCount: listWithCount.productCount, // ← Usa conteggio reale
          ),
        );
      }
    }

    return result;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _navigateToDetail(BuildContext context, ShoppingList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedListDetailScreen(shoppingList: list),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'refresh':
        ref.invalidate(completedListsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liste aggiornate'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      // Future actions
      // case 'analytics':
      //   _showAnalytics(context, ref);
      //   break;
    }
  }
}

class _ListWithTimeInfo {
  final ShoppingList list;
  final bool showTime;
  final int productCount;

  _ListWithTimeInfo({
    required this.list,
    required this.showTime,
    required this.productCount,
  });
}
