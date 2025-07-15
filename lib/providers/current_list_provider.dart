import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_with_products.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final currentListProvider =
    StateNotifierProvider<
      CurrentListNotifier,
      AsyncValue<List<DepartmentWithProducts>>
    >((ref) {
      return CurrentListNotifier(ref.watch(databaseServiceProvider), ref);
    });

final currentListProductIdsProvider = FutureProvider<Set<int>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final departments = await databaseService.getCurrentListGroupedByDepartment();

  // Estrai tutti gli ID dei prodotti dalla lista corrente
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
  }

  Future<void> loadCurrentList() async {
    try {
      state = const AsyncValue.loading();
      final departmentsWithProducts = await _databaseService
          .getCurrentListGroupedByDepartment();
      state = AsyncValue.data(departmentsWithProducts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProductToList(int productId) async {
    try {
      final success = await _databaseService.addProductToCurrentList(productId);
      if (success) {
        await loadCurrentList();
        _ref.invalidate(currentListProductIdsProvider);
      }
      // Opzionalmente mostra messaggio di successo/errore
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Permetti al UI di gestire l'errore
    }
  }

  Future<void> removeItemFromList(int itemId) async {
    await _databaseService.deleteListItem(itemId);
    await loadCurrentList();
    _ref.invalidate(currentListProductIdsProvider);
  }

  Future<bool> isProductInList(int productId) async {
    return await _databaseService.isProductInCurrentList(productId);
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
      await _databaseService.clearCurrentList();
      await loadCurrentList();
      // Invalida il provider degli ID
      _ref.invalidate(currentListProductIdsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
