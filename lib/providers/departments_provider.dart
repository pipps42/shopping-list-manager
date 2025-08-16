import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department.dart';
import '../models/department_event.dart';
import '../services/database_service.dart';
import 'database_provider.dart';
import 'products_provider.dart';
import 'department_events_provider.dart';

final departmentsProvider =
    StateNotifierProvider<DepartmentsNotifier, AsyncValue<List<Department>>>((
      ref,
    ) {
      return DepartmentsNotifier(ref.watch(databaseServiceProvider), ref);
    });

class DepartmentsNotifier extends StateNotifier<AsyncValue<List<Department>>> {
  final DatabaseService _databaseService;
  final Ref _ref;
  late final DepartmentEventBus _eventBus;

  DepartmentsNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    _eventBus = _ref.read(departmentEventBusProvider);
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

    final insertedId = await _databaseService.insertDepartment(department);
    final insertedDepartment = department.copyWith(id: insertedId);
    await loadDepartments();
    
    // Emetti evento di creazione dipartimento
    _eventBus.emit(DepartmentEvent.created(insertedDepartment));
    
    // Invalidate related providers to refresh data
    _ref.invalidate(productsByDepartmentProvider);
  }

  Future<void> updateDepartment(Department department) async {
    // Ottieni il dipartimento precedente per confrontare il nome
    final previousDepartments = state.asData?.value ?? [];
    final previousDepartment = previousDepartments.firstWhere(
      (d) => d.id == department.id,
      orElse: () => department,
    );
    final oldName = previousDepartment.name != department.name ? previousDepartment.name : null;

    await _databaseService.updateDepartment(department);
    await loadDepartments();

    // Emetti evento di aggiornamento dipartimento
    _eventBus.emit(DepartmentEvent.updated(department, oldName: oldName));
    
    // Invalidate related providers to refresh data
    _ref.invalidate(productsByDepartmentProvider);
    // currentListProvider ora si aggiorna automaticamente tramite eventi
  }

  Future<void> deleteDepartment(int id) async {
    await _databaseService.deleteDepartment(id);
    await loadDepartments();
    
    // Emetti evento di eliminazione dipartimento
    _eventBus.emit(DepartmentEvent.deleted(id));
    
    // Invalidate related providers to refresh data
    _ref.invalidate(productsProvider);
    // currentListProvider e currentListProductIdsProvider ora si aggiornano automaticamente tramite eventi
  }

  Future<void> reorderDepartments(List<Department> reorderedDepartments) async {
    // Aggiorna l'ordine locale immediatamente per UI responsiva
    state = AsyncValue.data(reorderedDepartments);

    // Quindi salva nel database
    await _databaseService.reorderDepartments(reorderedDepartments);
    
    // Per il reorder, i dipartimenti cambiano solo l'orderIndex
    // Emetto eventi di update per tutti i dipartimenti modificati
    for (final department in reorderedDepartments) {
      _eventBus.emit(DepartmentEvent.updated(department));
    }
    
    // Invalidate related providers to refresh data
    _ref.invalidate(productsProvider);
    // currentListProvider ora si aggiorna automaticamente tramite eventi
  }
}
