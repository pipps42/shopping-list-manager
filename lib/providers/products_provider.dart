import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.watch(databaseServiceProvider));
});

final productsByDepartmentProvider = StateNotifierProvider.family<ProductsByDepartmentNotifier, AsyncValue<List<Product>>, int>((ref, departmentId) {
  return ProductsByDepartmentNotifier(ref.watch(databaseServiceProvider), departmentId);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final DatabaseService _databaseService;

  ProductsNotifier(this._databaseService) : super(const AsyncValue.loading()) {
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

  Future<void> addProduct(String name, int departmentId, String? imagePath) async {
    final product = Product(
      name: name,
      departmentId: departmentId,
      imagePath: imagePath,
    );

    await _databaseService.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _databaseService.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _databaseService.deleteProduct(id);
    await loadProducts();
  }
}

class ProductsByDepartmentNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final DatabaseService _databaseService;
  final int departmentId;

  ProductsByDepartmentNotifier(this._databaseService, this.departmentId) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _databaseService.getProductsByDepartment(departmentId);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadProducts();
}