import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/product_event.dart';
import '../services/database_service.dart';
import '../utils/icon_types.dart';
import 'current_list_provider.dart';
import 'database_provider.dart';
import 'recipes_provider.dart';
import 'product_events_provider.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
      return ProductsNotifier(ref.watch(databaseServiceProvider), ref);
    });

final productsByDepartmentProvider = StateNotifierProvider.family
    .autoDispose<ProductsByDepartmentNotifier, AsyncValue<List<Product>>, int>((
      ref,
      departmentId,
    ) {
      return ProductsByDepartmentNotifier(
        ref.watch(databaseServiceProvider),
        departmentId,
      );
    });

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final DatabaseService _databaseService;
  final Ref _ref;
  late final ProductEventBus _eventBus;

  ProductsNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    _eventBus = _ref.read(productEventBusProvider);
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _databaseService.getAllProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProduct(
    String name,
    int departmentId,
    IconType iconType,
    String? iconValue,
  ) async {
    final product = Product(
      name: name,
      departmentId: departmentId,
      iconType: iconType,
      iconValue: iconValue,
    );

    final insertedId = await _databaseService.insertProduct(product);
    final insertedProduct = product.copyWith(id: insertedId);
    await loadProducts();
    
    // Emetti evento di creazione prodotto
    _eventBus.emit(ProductEvent.created(insertedProduct));
    
    // Invalidate related providers to refresh data
    _ref.invalidate(productsByDepartmentProvider);
    _ref.invalidate(currentListProductIdsProvider);
  }

  Future<void> updateProduct(Product product) async {
    // Ottieni il prodotto precedente per confrontare il nome
    final previousProducts = state.asData?.value ?? [];
    final previousProduct = previousProducts.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product, // Fallback se non trovato
    );
    final oldName = previousProduct.name != product.name ? previousProduct.name : null;

    await _databaseService.updateProduct(product);
    await loadProducts();

    // Emetti evento di aggiornamento prodotto
    _eventBus.emit(ProductEvent.updated(product, oldName: oldName));

    // Invalidate related providers to refresh data
    _ref.invalidate(currentListProvider);
    _ref.invalidate(currentListProductIdsProvider);
    _ref.invalidate(productsByDepartmentProvider);
    
    // Invalidate recipe providers since product data changed
    _ref.invalidate(recipesWithIngredientsProvider);
    _ref.invalidate(recipeWithIngredientsProvider);
    _ref.invalidate(recipeIngredientsProvider);
    _ref.invalidate(recipeIngredientProductIdsProvider);
  }

  Future<void> deleteProduct(int id) async {
    await _databaseService.deleteProduct(id);
    await loadProducts();
    
    // Emetti evento di eliminazione prodotto
    _eventBus.emit(ProductEvent.deleted(id));
    
    // Invalidate related providers to refresh data
    _ref.invalidate(currentListProvider);
    _ref.invalidate(currentListProductIdsProvider);
    _ref.invalidate(productsByDepartmentProvider);
    
    // Invalidate recipe providers since product was deleted
    _ref.invalidate(recipesWithIngredientsProvider);
    _ref.invalidate(recipeWithIngredientsProvider);
    _ref.invalidate(recipeIngredientsProvider);
    _ref.invalidate(recipeIngredientProductIdsProvider);
  }
}

class ProductsByDepartmentNotifier
    extends StateNotifier<AsyncValue<List<Product>>> {
  final DatabaseService _databaseService;
  final int departmentId;

  ProductsByDepartmentNotifier(this._databaseService, this.departmentId)
    : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _databaseService.getProductsByDepartment(
        departmentId,
      );
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadProducts();
}
