import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department.dart';
import '../services/database_service.dart';
import 'current_list_provider.dart';
import 'database_provider.dart';
import 'products_provider.dart';

final departmentsProvider =
    StateNotifierProvider<DepartmentsNotifier, AsyncValue<List<Department>>>((
      ref,
    ) {
      return DepartmentsNotifier(ref.watch(databaseServiceProvider), ref);
    });

class DepartmentsNotifier extends StateNotifier<AsyncValue<List<Department>>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  DepartmentsNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    try {
      state = const AsyncValue.loading();
      final departments = await _databaseService.getAllDepartments();
      state = AsyncValue.data(departments);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addDepartment(String name) async {
    final currentDepartments = state.value ?? [];
    final newOrderIndex = currentDepartments.length + 1;

    final department = Department(name: name, orderIndex: newOrderIndex);

    await _databaseService.insertDepartment(department);
    await loadDepartments();
  }

  Future<void> updateDepartment(Department department) async {
    await _databaseService.updateDepartment(department);
    await loadDepartments();
  }

  Future<void> deleteDepartment(int id) async {
    await _databaseService.deleteDepartment(id);
    await loadDepartments();
    // Invalidate related providers to refresh data
    _ref.invalidate(productsProvider);
    _ref.invalidate(currentListProvider);
    _ref.invalidate(currentListProductIdsProvider);
  }

  Future<void> reorderDepartments(List<Department> reorderedDepartments) async {
    // Aggiorna l'ordine locale immediatamente per UI responsiva
    state = AsyncValue.data(reorderedDepartments);

    // Quindi salva nel database
    await _databaseService.reorderDepartments(reorderedDepartments);
  }
}
