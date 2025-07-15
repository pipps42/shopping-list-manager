import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/departments_provider.dart';
import '../providers/products_provider.dart';
import '../providers/current_list_provider.dart';
import '../models/department.dart';
import '../models/product.dart';
import 'common/empty_state_widget.dart';
import 'common/error_state_widget.dart';
import 'common/loading_widget.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Function(int productId) onProductSelected;

  const AddProductDialog({super.key, required this.onProductSelected});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  Department? selectedDepartment;
  String searchQuery = '';
  bool _hasSearchText = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearFocus() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    final departmentsState = ref.watch(departmentsProvider);
    final productsState = ref.watch(productsProvider);

    return Dialog(
      child: GestureDetector(
        // Wrapper per tap fuori
        onTap: () => _clearFocus(),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      AppStrings.addProduct,
                      style: TextStyle(
                        fontSize: AppConstants.fontXXXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _clearFocus();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Barra di ricerca
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: AppStrings.searchProductPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _hasSearchText
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                            _clearFocus();
                          },
                          tooltip: 'Cancella ricerca',
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                onTapOutside: (event) => _clearFocus(),
                onEditingComplete: () => _clearFocus(),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Filtro per reparto
              departmentsState.when(
                data: (departments) => _buildDepartmentFilter(departments),
                loading: () => const LoadingWidget(
                  message: AppStrings.loadingDepartments,
                  size: AppConstants.iconS,
                ),
                error: (error, stack) => Padding(
                  padding: EdgeInsets.all(AppConstants.paddingS),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: AppConstants.iconS),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: Text(
                          'Errore reparti: $error',
                          style: TextStyle(color: Colors.red, fontSize: AppConstants.fontM),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Lista prodotti
              Expanded(
                child: productsState.when(
                  data: (products) => _buildProductsList(products),
                  loading: () =>
                      const LoadingWidget(message: AppStrings.loadingProducts),
                  error: (error, stack) => ErrorStateWidget(
                    message: 'Errore nel caricamento dei prodotti: $error',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentFilter(List<Department> departments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Opzione "Tutti"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tutti'),
              selected: selectedDepartment == null,
              onSelected: (selected) {
                setState(() {
                  selectedDepartment = null;
                });
              },
            ),
          ),
          // Reparti
          ...departments.map(
            (dept) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(dept.name),
                selected: selectedDepartment?.id == dept.id,
                onSelected: (selected) {
                  setState(() {
                    selectedDepartment = selected ? dept : null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> allProducts) {
    // Filtra prodotti (stesso codice di prima)
    List<Product> filteredProducts = allProducts.where((product) {
      if (selectedDepartment != null &&
          product.departmentId != selectedDepartment!.id) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: 'Nessun prodotto trovato',
        subtitle: 'Prova a modificare i filtri di ricerca',
        iconSize: AppConstants.iconXL,
      );
    }

    // Watch del provider qui per pre-caricare i dati
    final productIdsInList = ref.watch(currentListProductIdsProvider);

    return productIdsInList.when(
      data: (_) => ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductTile(product);
        },
      ),
      loading: () => const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppConstants.spacingM),
            Text('Caricamento stato prodotti...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red),
            Text('Errore nel caricamento: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(Product product) {
    final productIdsInList = ref.watch(currentListProductIdsProvider);

    return productIdsInList.when(
      data: (productIds) {
        final isInList = productIds.contains(product.id!);

        return ListTile(
          leading: _buildProductImage(product),
          title: Text(product.name),
          subtitle: _buildDepartmentName(product.departmentId),
          trailing: isInList
              ? Icon(Icons.check_circle, color: Colors.green[600])
              : const Icon(Icons.add_circle_outline),
          onTap: isInList ? null : () => widget.onProductSelected(product.id!),
          enabled: !isInList,
        );
      },
      loading: () => const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(AppStrings.loading),
      ),
      error: (error, stack) => ListTile(
        leading: Icon(Icons.error, color: Colors.red, size: 20),
        title: Text(
          'Errore',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(product.imagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_basket, size: 20),
    );
  }

  Widget _buildDepartmentName(int departmentId) {
    final departmentsState = ref.watch(departmentsProvider);

    return departmentsState.when(
      data: (departments) {
        final dept = departments.firstWhere(
          (d) => d.id == departmentId,
          orElse: () =>
              Department(id: -1, name: 'Reparto sconosciuto', orderIndex: 0),
        );
        return Text(
          dept.name,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      },
      loading: () => const LoadingWidget(message: '...'),
      error: (error, stack) => const Text('Errore'),
    );
  }
}
