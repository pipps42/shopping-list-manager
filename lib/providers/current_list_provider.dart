import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/models/department.dart';
import '../models/list_item.dart';
import '../models/list_item_with_product.dart';
import '../models/product_event.dart';
import '../models/department_event.dart';
import '../services/database_service.dart';
import 'database_provider.dart';
import 'list_type_provider.dart';
import 'completed_lists_provider.dart';
import 'product_events_provider.dart';
import 'department_events_provider.dart';

/// Provider principale per la lista corrente raggruppata per dipartimento
final currentListProvider =
    StateNotifierProvider<
      CurrentListNotifier,
      AsyncValue<Map<Department, List<ListItemWithProduct>>>
    >((ref) {
      return CurrentListNotifier(ref.watch(databaseServiceProvider), ref);
    });

/// Provider derivato per gli ID dei prodotti nella lista corrente
final currentListProductIdsProvider = Provider<AsyncValue<Set<int>>>((ref) {
  final mapAsync = ref.watch(currentListProvider);
  return mapAsync.when(
    data: (departmentMap) => AsyncValue.data(
      departmentMap.values
          .expand((items) => items)
          .map((item) => item.product.id!)
          .toSet(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider per gli ID dei prodotti di una lista specifica
final listProductIdsProvider = FutureProvider.family<Set<int>, String>((
  ref,
  listType,
) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final items = await databaseService.getCurrentListItems(listType);

  final productIds = items.map((item) => item.product.id!).toSet();

  return productIds;
});

/// Notifier per la gestione della lista corrente
class CurrentListNotifier
    extends
        StateNotifier<AsyncValue<Map<Department, List<ListItemWithProduct>>>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  CurrentListNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    // Carica la lista iniziale
    loadCurrentList();

    // Ascolta i cambiamenti del tipo di lista
    _ref.listen<String>(currentListTypeProvider, (previous, next) {
      if (previous != next) {
        loadCurrentList();
      }
    });

    // Ascolta gli eventi dei prodotti per aggiornamenti reattivi
    _listenToProductEvents();

    // Ascolta gli eventi dei dipartimenti per aggiornamenti reattivi
    _listenToDepartmentEvents();
  }

  // ================== METODI PRINCIPALI ==================

  /// Carica la lista corrente dal database
  Future<void> loadCurrentList() async {
    try {
      state = const AsyncValue.loading();
      final currentListType = _ref.read(currentListTypeProvider);
      final groupedMap = await _databaseService
          .getCurrentListGroupedByDepartment(currentListType);
      state = AsyncValue.data(groupedMap);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Aggiunge un prodotto alla lista corrente
  Future<void> addProductToList(int productId, [String? targetListType]) async {
    try {
      final String listType =
          targetListType ?? _ref.read(currentListTypeProvider);
      final addedItem = await _databaseService.addProductToCurrentListDetailed(
        productId,
        listType,
      );

      if (addedItem != null) {
        final currentListType = _ref.read(currentListTypeProvider);

        // Se è la lista attualmente visualizzata, aggiorna atomicamente
        if (listType == currentListType) {
          await _addItemToState(addedItem);
        }

        // Invalida altri provider secondari se necessario
        _ref.invalidate(listProductIdsProvider(listType));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Rimuove un prodotto dalla lista corrente
  Future<void> removeProductFromList(
    int productId, [
    String? targetListType,
  ]) async {
    try {
      final String listType =
          targetListType ?? _ref.read(currentListTypeProvider);
      await _databaseService.removeProductFromCurrentList(productId, listType);

      final currentListType = _ref.read(currentListTypeProvider);

      // Se è la lista attualmente visualizzata, aggiorna atomicamente
      if (listType == currentListType) {
        _removeProductFromState(productId);
      }

      // Invalida altri provider secondari se necessario
      _ref.invalidate(listProductIdsProvider(listType));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Aggiunge multipli prodotti alla lista
  Future<void> addMultipleProductsToList(
    List<int> productIds, [
    String? targetListType,
  ]) async {
    for (final productId in productIds) {
      await addProductToList(productId, targetListType);
    }
  }

  /// Toggla lo stato checked di un item
  Future<void> toggleItemChecked(int itemId, bool isChecked) async {
    // Aggiorna UI immediatamente per reattività
    _updateItemCheckedInState(itemId, isChecked);

    // Quindi aggiorna il database
    try {
      await _databaseService.toggleItemChecked(itemId, isChecked);
    } catch (error) {
      // Se fallisce, ripristina lo stato e propaga l'errore
      _updateItemCheckedInState(itemId, !isChecked);
      debugPrint('❌ Errore toggle item checked: $error');
      rethrow;
    }
  }

  /// Svuota completamente la lista corrente
  Future<void> clearAllItems() async {
    try {
      final currentListType = _ref.read(currentListTypeProvider);
      await _databaseService.clearCurrentList(currentListType);

      // Aggiorna lo stato a lista vuota
      state = const AsyncValue.data({});

      _ref.invalidate(listProductIdsProvider(currentListType));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Completa la lista corrente
  Future<void> completeCurrentList({
    required bool markAllAsChecked,
    required bool keepUncheckedItems,
    double? totalCost,
  }) async {
    try {
      final currentListType = _ref.read(currentListTypeProvider);
      await _databaseService.completeCurrentList(
        markAllAsChecked: markAllAsChecked,
        keepUncheckedItems: keepUncheckedItems,
        totalCost: totalCost,
        listType: currentListType,
      );

      // Ricarica la lista corrente (potrebbe non essere vuota)
      await loadCurrentList();

      _ref.invalidate(listProductIdsProvider(currentListType));
      _ref.invalidate(completedListsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // ================== METODI DI UTILITÀ ==================

  /// Controlla se ci sono item nella lista corrente
  Future<bool> hasItemsInCurrentList() async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.hasItemsInCurrentList(currentListType);
  }

  /// Ottiene statistiche della lista corrente
  Future<Map<String, int>> getCurrentListStats() async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.getCurrentListStats(currentListType);
  }

  /// Controlla se un prodotto è nella lista
  Future<bool> isProductInList(int productId) async {
    final currentListType = _ref.read(currentListTypeProvider);
    return await _databaseService.isProductInCurrentList(
      productId,
      currentListType,
    );
  }

  /// Controlla velocemente se un prodotto è nella lista corrente (dallo stato)
  bool _isProductInCurrentList(int? productId) {
    if (productId == null) return false;
    final currentMap = state.asData?.value;
    if (currentMap == null) return false;

    return currentMap.values
        .expand((items) => items)
        .any((item) => item.product.id == productId);
  }

  /// Controlla velocemente se un dipartimento è nella lista corrente (dallo stato)
  bool _isDepartmentInCurrentList(int? departmentId) {
    if (departmentId == null) return false;
    final currentMap = state.asData?.value;
    if (currentMap == null) return false;

    return currentMap.keys.any((dept) => dept.id == departmentId);
  }

  // ================== LISTENERS EVENTI ==================

  /// Ascolta gli eventi dei prodotti per aggiornamenti reattivi
  void _listenToProductEvents() {
    _ref.listen<AsyncValue<ProductEvent>>(productEventsProvider, (
      previous,
      next,
    ) {
      next.whenData((event) {
        switch (event.type) {
          case ProductEventType.created:
            // I nuovi prodotti non vengono aggiunti automaticamente alle liste
            break;
          case ProductEventType.updated:
          case ProductEventType.deleted:
            // Se il prodotto è nella lista corrente, ricarica tutto
            if (_isProductInCurrentList(event.productId ?? event.product?.id)) {
              loadCurrentList();
            }
            break;
        }
      });
    });
  }

  /// Ascolta gli eventi dei dipartimenti per aggiornamenti reattivi
  void _listenToDepartmentEvents() {
    _ref.listen<AsyncValue<DepartmentEvent>>(departmentEventsProvider, (
      previous,
      next,
    ) {
      next.whenData((event) {
        switch (event.type) {
          case DepartmentEventType.created:
            // I nuovi dipartimenti non influenzano le liste esistenti
            break;
          case DepartmentEventType.updated:
          case DepartmentEventType.deleted:
            // Se il dipartimento ha prodotti nella lista corrente, ricarica tutto
            if (_isDepartmentInCurrentList(
              event.departmentId ?? event.department?.id,
            )) {
              loadCurrentList();
            }
            break;
        }
      });
    });
  }

  // ================== AGGIORNAMENTI ATOMICI ==================

  /// Aggiunge atomicamente un ListItem allo stato corrente
  Future<void> _addItemToState(ListItem newItem) async {
    final currentMap = state.asData?.value;
    if (currentMap == null) return;

    try {
      // Ottieni le informazioni complete del prodotto e del dipartimento
      final product = await _databaseService.getProductById(newItem.productId);
      final department = await _databaseService.getDepartmentById(
        product.departmentId,
      );

      // Crea il nuovo ListItemWithProduct
      final newItemWithProduct = ListItemWithProduct(
        id: newItem.id,
        listId: newItem.listId,
        product: product,
        isChecked: newItem.isChecked,
        addedAt: newItem.addedAt,
      );

      // Crea una copia della Map per l'aggiornamento atomico
      final updatedMap = Map<Department, List<ListItemWithProduct>>.from(
        currentMap,
      );

      // Trova il dipartimento esistente nella Map usando firstWhere
      Department? existingDept;
      try {
        existingDept = updatedMap.keys.firstWhere((dept) => dept.id == department.id);
      } catch (_) {
        // Dipartimento non trovato
        existingDept = null;
      }

      if (existingDept != null) {
        // Dipartimento trovato: aggiungi l'item alla sua lista
        updatedMap[existingDept] = [
          ...updatedMap[existingDept]!,
          newItemWithProduct,
        ];
      } else {
        // Dipartimento non trovato: aggiungilo alla Map
        updatedMap[department] = [newItemWithProduct];
      }

      state = AsyncValue.data(updatedMap);
      debugPrint(
        '📋 CurrentList: Aggiunto atomicamente ${product.name} in ${department.name}',
      );
    } catch (e) {
      debugPrint('❌ Errore durante aggiunta atomica: $e');
      // Fallback: ricarica la lista completa
      await loadCurrentList();
    }
  }

  /// Rimuove atomicamente un prodotto dallo stato corrente
  void _removeProductFromState(int productId) {
    final currentMap = state.asData?.value;
    if (currentMap == null) return;

    // Prima trova il dipartimento che contiene il prodotto
    Department? targetDepartment;
    List<ListItemWithProduct>? targetItems;
    
    for (final entry in currentMap.entries) {
      if (entry.value.any((item) => item.product.id == productId)) {
        targetDepartment = entry.key;
        targetItems = entry.value;
        break; // Trovato! Esci dal loop
      }
    }

    if (targetDepartment == null || targetItems == null) {
      return; // Prodotto non trovato
    }

    // Crea una copia della Map e aggiorna solo il dipartimento target
    final updatedMap = Map<Department, List<ListItemWithProduct>>.from(currentMap);
    
    // Filtra gli items rimuovendo il prodotto specificato
    final filteredItems = targetItems
        .where((item) => item.product.id != productId)
        .toList();

    if (filteredItems.isNotEmpty) {
      // Aggiorna il dipartimento con la lista filtrata
      updatedMap[targetDepartment] = filteredItems;
    } else {
      // Rimuovi completamente il dipartimento se non ha più items
      updatedMap.remove(targetDepartment);
    }

    state = AsyncValue.data(updatedMap);
    debugPrint('📋 CurrentList: Rimosso atomicamente prodotto ID $productId');
  }

  /// Aggiorna atomicamente lo stato checked di un item
  void _updateItemCheckedInState(int itemId, bool isChecked) {
    final currentMap = state.asData?.value;
    if (currentMap == null) return;

    // Prima trova il dipartimento che contiene l'item
    Department? targetDepartment;
    List<ListItemWithProduct>? targetItems;
    int? itemIndex;
    
    for (final entry in currentMap.entries) {
      final index = entry.value.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        targetDepartment = entry.key;
        targetItems = entry.value;
        itemIndex = index;
        break; // Trovato! Esci dal loop
      }
    }

    if (targetDepartment == null || targetItems == null || itemIndex == null) {
      return; // Item non trovato
    }

    // Crea una copia della Map e aggiorna solo il dipartimento target
    final updatedMap = Map<Department, List<ListItemWithProduct>>.from(currentMap);
    
    // Aggiorna solo l'item specificato
    final updatedItems = List<ListItemWithProduct>.from(targetItems);
    updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
      isChecked: isChecked,
    );
    
    updatedMap[targetDepartment] = updatedItems;
    state = AsyncValue.data(updatedMap);
  }
}
