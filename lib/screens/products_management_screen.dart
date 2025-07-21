import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/departments_provider.dart';
import '../models/product.dart';
import '../models/department.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/products_management/product_filters.dart';
import '../widgets/products_management/product_tile.dart';
import '../widgets/products_management/product_form_dialog.dart';
import '../widgets/products_management/move_product_dialog.dart';
import '../widgets/products_management/delete_product_dialog.dart';

class ProductsManagementScreen extends ConsumerStatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  ConsumerState<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState
    extends ConsumerState<ProductsManagementScreen> {
  String _searchQuery = '';
  int? _selectedDepartmentId;

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final departmentsState = ref.watch(departmentsProvider);

    return GestureDetector(
      onTap: () => _clearFocus(),
      child: Scaffold(
        body: Column(
          children: [
            // Filtri e ricerca
            if (departmentsState.hasValue)
              ProductFiltersWidget(
                departments: departmentsState.value!,
                onSearchChanged: (query) =>
                    setState(() => _searchQuery = query),
                onDepartmentFilterChanged: (deptId) =>
                    setState(() => _selectedDepartmentId = deptId),
                initialSearchQuery: _searchQuery,
                initialSelectedDepartmentId: _selectedDepartmentId,
              ),

            // Lista prodotti
            Expanded(
              child: productsState.when(
                data: (products) =>
                    _buildProductsList(products, departmentsState.value ?? []),
                loading: () =>
                    const LoadingWidget(message: AppStrings.loadingProducts),
                error: (error, stack) => ErrorStateWidget(
                  message: 'Errore nel caricamento dei prodotti: $error',
                  onRetry: () => ref.invalidate(productsProvider),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "products_management_fab",
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary(context),
          onPressed: () {
            _clearFocus();
            _showAddProductDialog();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProductsList(
    List<Product> allProducts,
    List<Department> departments,
  ) {
    final filteredProducts = _filterProducts(allProducts);

    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(productsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingS,
          left: AppConstants.paddingS,
          right: AppConstants.paddingS,
          bottom: AppConstants.listBottomSpacing, // Spazio per il FAB
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final department = _findDepartment(departments, product.departmentId);

          return ProductTileWidget(
            product: product,
            department: department,
            onEdit: () => _showEditProductDialog(product, departments),
            onMove: () => _showMoveProductDialog(product, departments),
            onDelete: () => _showDeleteProductDialog(product),
          );
        },
      ),
    );
  }

  List<Product> _filterProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      // Filtro per reparto
      if (_selectedDepartmentId != null &&
          product.departmentId != _selectedDepartmentId) {
        return false;
      }

      // Filtro per ricerca
      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty || _selectedDepartmentId != null;

    return EmptyStateWidget(
      icon: hasFilters ? Icons.search_off : Icons.inventory_outlined,
      title: hasFilters ? 'Nessun prodotto trovato' : AppStrings.emptyProducts,
      subtitle: hasFilters
          ? 'Prova a modificare i filtri di ricerca'
          : AppStrings.emptyProductsSubtitle,
    );
  }

  Department _findDepartment(List<Department> departments, int departmentId) {
    return departments.firstWhere(
      (d) => d.id == departmentId,
      orElse: () =>
          Department(id: -1, name: 'Reparto sconosciuto', orderIndex: 0),
    );
  }

  void _clearFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Dialog Methods
  void _showAddProductDialog() {
    final departments = ref.read(departmentsProvider).value ?? [];

    if (departments.isEmpty) {
      _showNoDepartmentsWarning();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        departments: departments,
        onSave: (name, departmentId, imagePath) async {
          await ref
              .read(productsProvider.notifier)
              .addProduct(name, departmentId, imagePath);
        },
      ),
    );
  }

  void _showEditProductDialog(Product product, List<Department> departments) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        departments: departments,
        onSave: (name, departmentId, imagePath) async {
          await ref
              .read(productsProvider.notifier)
              .updateProduct(
                product.copyWith(
                  name: name,
                  departmentId: departmentId,
                  imagePath: imagePath,
                ),
              );
        },
      ),
    );
  }

  void _showMoveProductDialog(Product product, List<Department> departments) {
    showDialog(
      context: context,
      builder: (context) => MoveProductDialog(
        product: product,
        departments: departments,
        onMoveProduct: (department) async {
          await ref
              .read(productsProvider.notifier)
              .updateProduct(product.copyWith(departmentId: department.id));
        },
      ),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => DeleteProductDialog(
        product: product,
        onConfirmDelete: () async {
          await ref.read(productsProvider.notifier).deleteProduct(product.id!);
        },
      ),
    );
  }

  void _showNoDepartmentsWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nessun Reparto'),
        content: const Text(
          'Prima di aggiungere prodotti, devi creare almeno un reparto nella sezione "Gestione Reparti".',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}
