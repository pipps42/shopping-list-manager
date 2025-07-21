import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import 'current_list_provider.dart';
import 'database_provider.dart';

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

  ProductsNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
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
    String? imagePath,
  ) async {
    final product = Product(
      name: name,
      departmentId: departmentId,
      imagePath: imagePath,
    );

    await _databaseService.insertProduct(product);
    await loadProducts();
    // Invalidate related providers to refresh data
    _ref.invalidate(productsByDepartmentProvider);
    _ref.invalidate(currentListProductIdsProvider);
  }

  Future<void> updateProduct(Product product) async {
    await _databaseService.updateProduct(product);
    await loadProducts();

    // Invalidate related providers to refresh data
    _ref.invalidate(currentListProvider);
    _ref.invalidate(currentListProductIdsProvider);
    _ref.invalidate(productsByDepartmentProvider);
  }

  Future<void> deleteProduct(int id) async {
    await _databaseService.deleteProduct(id);
    await loadProducts();
    // Invalidate related providers to refresh data
    _ref.invalidate(currentListProvider);
    _ref.invalidate(currentListProductIdsProvider);
    _ref.invalidate(productsByDepartmentProvider);
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
