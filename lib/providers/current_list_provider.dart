import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_with_products.dart';
import '../services/database_service.dart';
import 'database_provider.dart';
import 'list_type_provider.dart';
import 'completed_lists_provider.dart';

final currentListProvider =
    StateNotifierProvider<
      CurrentListNotifier,
      AsyncValue<List<DepartmentWithProducts>>
    >((ref) {
      return CurrentListNotifier(ref.watch(databaseServiceProvider), ref);
    });

final currentListProductIdsProvider = FutureProvider<Set<int>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final currentListType = ref.watch(currentListTypeProvider);
  final departments = await databaseService.getCurrentListGroupedByDepartment(currentListType);

  // Estrai tutti gli ID dei prodotti dalla lista corrente
  final productIds = departments
      .expand((dept) => dept.items) // Flatten tutti gli items
      .map((item) => item.productId) // Estrai solo gli ID
      .toSet(); // Converti in Set per performance O(1) lookup

  return productIds;
});

// Provider per gli ID dei prodotti di una lista specifica
final listProductIdsProvider = FutureProvider.family<Set<int>, String>((ref, listType) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final departments = await databaseService.getCurrentListGroupedByDepartment(listType);

  // Estrai tutti gli ID dei prodotti dalla lista specifica
  final productIds = departments
      .expand((dept) => dept.items) // Flatten tutti gli items
      .map((item) => item.productId) // Estrai solo gli ID
      .toSet(); // Converti in Set per performance O(1) lookup

  return productIds;
});

class CurrentListNotifier
    extends StateNotifier<AsyncValue<List<DepartmentWithProducts>>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  CurrentListNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    loadCurrentList();
    
    // Ascolta i cambiamenti del tipo di lista
    _ref.listen<String>(currentListTypeProvider, (previous, next) {
      if (previous != next) {
        loadCurrentList(next);
      }
    });
  }

  Future<void> loadCurrentList([String? listType]) async {
    try {
      state = const AsyncValue.loading();
      final currentListType = listType ?? _ref.read(currentListTypeProvider);
      final departmentsWithProducts = await _databaseService
          .getCurrentListGroupedByDepartment(currentListType);
      state = AsyncValue.data(departmentsWithProducts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProductToList(int productId, [String? targetListType]) async {
    try {
      final String listType = targetListType ?? _ref.read(currentListTypeProvider);
      final success = await _databaseService.addProductToCurrentList(productId, listType);
      if (success) {
        // Solo ricarica se è la lista attualmente visualizzata
        final currentListType = _ref.read(currentListTypeProvider);
        if (listType == currentListType) {
          await loadCurrentList();
        }
        _ref.invalidate(currentListProductIdsProvider);
        _ref.invalidate(listProductIdsProvider(listType));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeItemFromList(int itemId) async {
    await _databaseService.deleteListItem(itemId);
    await loadCurrentList();
    _ref.invalidate(currentListProductIdsProvider);
  }

  Future<void> removeProductFromList(int productId, [String? targetListType]) async {
    final String listType = targetListType ?? _ref.read(currentListTypeProvider);
    await _databaseService.removeProductFromCurrentList(productId, listType);
    
    // Solo ricarica se è la lista attualmente visualizzata
    final currentListType = _ref.read(currentListTypeProvider);
    if (listType == currentListType) {
      await loadCurrentList();
    }
    
    _ref.invalidate(currentListProductIdsProvider);
    _ref.invalidate(listProductIdsProvider(listType));
  }

  Future<bool> isProductInList(int productId) async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.isProductInCurrentList(productId, currentListType);
  }

  Future<void> toggleItemChecked(int itemId, bool isChecked) async {
    // Aggiorna UI immediatamente
    final currentState = state.value;
    if (currentState != null) {
      final updatedDepartments = currentState.map((dept) {
        final updatedItems = dept.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isChecked: isChecked);
          }
          return item;
        }).toList();

        return DepartmentWithProducts(
          department: dept.department,
          items: updatedItems,
        );
      }).toList();

      state = AsyncValue.data(updatedDepartments);
    }

    // Quindi aggiorna il database
    await _databaseService.toggleItemChecked(itemId, isChecked);
  }

  Future<void> clearAllItems() async {
    try {
      final currentListType = _ref.read(currentListTypeProvider);
      await _databaseService.clearCurrentList(currentListType);
      await loadCurrentList();
      // Invalida il provider degli ID
      _ref.invalidate(currentListProductIdsProvider);
      _ref.invalidate(listProductIdsProvider(currentListType));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> completeCurrentList({
    required bool markAllAsChecked,
    double? totalCost,
  }) async {
    try {
      final currentListType = _ref.read(currentListTypeProvider);
      await _databaseService.completeCurrentList(
        markAllAsChecked: markAllAsChecked,
        totalCost: totalCost,
        listType: currentListType,
      );

      // Ricarica la lista corrente (che ora sarà vuota)
      await loadCurrentList();

      // Invalida il provider degli ID
      _ref.invalidate(currentListProductIdsProvider);
      _ref.invalidate(listProductIdsProvider(currentListType));
      
      // Invalida il provider delle liste completate per aggiornare automaticamente
      _ref.invalidate(completedListsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<bool> hasItemsInCurrentList() async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.hasItemsInCurrentList(currentListType);
  }

  Future<Map<String, int>> getCurrentListStats() async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.getCurrentListStats(currentListType);
  }
}
