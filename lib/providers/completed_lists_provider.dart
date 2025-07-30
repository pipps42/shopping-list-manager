import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../models/department_with_products.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final completedListsProvider =
    StateNotifierProvider<
      CompletedListsNotifier,
      AsyncValue<List<CompletedListWithCount>>
    >((ref) {
      return CompletedListsNotifier(ref.watch(databaseServiceProvider), ref);
    });

final completedListDetailProvider = StateNotifierProvider.family
    .autoDispose<
      CompletedListDetailNotifier,
      AsyncValue<List<DepartmentWithProducts>>,
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
  final Ref _ref;

  CompletedListsNotifier(this._databaseService, this._ref)
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
    extends StateNotifier<AsyncValue<List<DepartmentWithProducts>>> {
  final DatabaseService _databaseService;
  final int listId;

  CompletedListDetailNotifier(this._databaseService, this.listId)
    : super(const AsyncValue.loading()) {
    loadCompletedListDetail();
  }

  Future<void> loadCompletedListDetail() async {
    try {
      state = const AsyncValue.loading();
      final departments = await _databaseService
          .getCompletedListGroupedByDepartment(listId);
      state = AsyncValue.data(departments);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadCompletedListDetail();
}
