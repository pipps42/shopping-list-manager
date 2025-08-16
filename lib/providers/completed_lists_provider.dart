import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../models/department.dart';
import '../models/list_item_with_product.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final completedListsProvider =
    StateNotifierProvider<
      CompletedListsNotifier,
      AsyncValue<List<CompletedListWithCount>>
    >((ref) {
      return CompletedListsNotifier(ref.watch(databaseServiceProvider));
    });

final completedListDetailProvider = StateNotifierProvider.family
    .autoDispose<
      CompletedListDetailNotifier,
      AsyncValue<Map<Department, List<ListItemWithProduct>>>,
      int
    >((ref, listId) {
      return CompletedListDetailNotifier(
        ref.watch(databaseServiceProvider),
        listId,
      );
    });

class CompletedListsNotifier
    extends StateNotifier<AsyncValue<List<CompletedListWithCount>>> {
  final DatabaseService _databaseService;

  CompletedListsNotifier(this._databaseService)
    : super(const AsyncValue.loading()) {
    loadCompletedLists();
  }

  Future<void> loadCompletedLists() async {
    try {
      state = const AsyncValue.loading();
      final lists = await _databaseService.getCompletedShoppingLists();

      // Ottieni i conteggi dei prodotti per tutte le liste
      final listIds = lists.map((list) => list.id!).toList();
      final productCounts = await _databaseService
          .getProductCountsForCompletedLists(listIds);

      // Combina liste con conteggi
      final listsWithCounts = lists
          .map(
            (list) => CompletedListWithCount(
              list: list,
              productCount: productCounts[list.id] ?? 0,
            ),
          )
          .toList();

      state = AsyncValue.data(listsWithCounts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadCompletedLists();

  Future<void> deleteCompletedList(int listId) async {
    try {
      await _databaseService.deleteCompletedList(listId);

      // Ricarica le liste per aggiornare la UI
      await loadCompletedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCompletedListPrice(int listId, double? totalCost) async {
    try {
      await _databaseService.updateCompletedListPrice(listId, totalCost);

      // Ricarica le liste per aggiornare la UI
      await loadCompletedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAllCompletedLists() async {
    try {
      await _databaseService.deleteAllCompletedLists();

      // Aggiorna immediatamente lo stato con una lista vuota
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

class CompletedListWithCount {
  final ShoppingList list;
  final int productCount;

  CompletedListWithCount({required this.list, required this.productCount});
}

class CompletedListDetailNotifier
    extends StateNotifier<AsyncValue<Map<Department, List<ListItemWithProduct>>>> {
  final DatabaseService _databaseService;
  final int listId;

  CompletedListDetailNotifier(this._databaseService, this.listId)
    : super(const AsyncValue.loading()) {
    loadCompletedListDetail();
  }

  Future<void> loadCompletedListDetail() async {
    try {
      state = const AsyncValue.loading();
      final departmentMap = await _databaseService
          .getCompletedListGroupedByDepartment(listId);
      state = AsyncValue.data(departmentMap);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadCompletedListDetail();
}
