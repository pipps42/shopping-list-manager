import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_with_products.dart';
import '../models/list_item.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final currentListProvider = StateNotifierProvider<CurrentListNotifier, AsyncValue<List<DepartmentWithProducts>>>((ref) {
  return CurrentListNotifier(ref.watch(databaseServiceProvider));
});

class CurrentListNotifier extends StateNotifier<AsyncValue<List<DepartmentWithProducts>>> {
  final DatabaseService _databaseService;

  CurrentListNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    loadCurrentList();
  }

  Future<void> loadCurrentList() async {
    try {
      state = const AsyncValue.loading();
      final departmentsWithProducts = await _databaseService.getCurrentListGroupedByDepartment();
      state = AsyncValue.data(departmentsWithProducts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProductToList(int productId) async {
    await _databaseService.addProductToCurrentList(productId);
    await loadCurrentList(); // Refresh automatico
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

  Future<void> removeItemFromList(int itemId) async {
    await _databaseService.deleteListItem(itemId);
    await loadCurrentList();
  }

  Future<bool> isProductInList(int productId) async {
    return await _databaseService.isProductInCurrentList(productId);
  }
}