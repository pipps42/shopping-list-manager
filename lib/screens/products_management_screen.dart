import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/departments_provider.dart';
import '../providers/image_provider.dart';
import '../models/product.dart';
import '../models/department.dart';
import '../utils/constants.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';

class ProductsManagementScreen extends ConsumerStatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  ConsumerState<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState
    extends ConsumerState<ProductsManagementScreen> {
  String searchQuery = '';
  int? selectedDepartmentId;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
    final productsState = ref.watch(productsProvider);
    final departmentsState = ref.watch(departmentsProvider);

    return GestureDetector(
      // Wrapper per tap fuori
      onTap: () => _clearFocus(),
      child: Scaffold(
        body: Column(
          children: [
            // Filtri e ricerca
            _buildFiltersSection(departmentsState.value ?? []),
            // Lista prodotti
            Expanded(
              child: productsState.when(
                data: (products) => _buildProductsList(
                  context,
                  ref,
                  products,
                  departmentsState.value ?? [],
                ),
                loading: () =>
                    const LoadingWidget(message: 'Caricamento prodotti...'),
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
          onPressed: () {
            _clearFocus();
            _showAddProductDialog(context, ref);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(List<Department> departments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Barra di ricerca
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: const InputDecoration(
              hintText: 'Cerca prodotti...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            onTapOutside: (event) => _clearFocus(),
            onEditingComplete: () => _clearFocus(),
          ),
          const SizedBox(height: 12),
          // Filtro reparti
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Opzione "Tutti"
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tutti'),
                    selected: selectedDepartmentId == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedDepartmentId = null;
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
                      selected: selectedDepartmentId == dept.id,
                      onSelected: (selected) {
                        setState(() {
                          selectedDepartmentId = selected ? dept.id : null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    WidgetRef ref,
    List<Product> allProducts,
    List<Department> departments,
  ) {
    // Filtra prodotti
    List<Product> filteredProducts = allProducts.where((product) {
      // Filtro per reparto
      if (selectedDepartmentId != null &&
          product.departmentId != selectedDepartmentId) {
        return false;
      }

      // Filtro per ricerca
      if (searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(searchQuery)) {
        return false;
      }

      return true;
    }).toList();

    // Ordina per nome
    filteredProducts.sort((a, b) => a.name.compareTo(b.name));

    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(productsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final department = departments.firstWhere(
            (d) => d.id == product.departmentId,
            orElse: () =>
                Department(id: -1, name: 'Reparto sconosciuto', orderIndex: 0),
          );
          return _buildProductTile(
            context,
            ref,
            product,
            department,
            departments,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = searchQuery.isNotEmpty || selectedDepartmentId != null;

    return EmptyStateWidget(
      icon: hasFilters ? Icons.search_off : Icons.inventory_outlined,
      title: hasFilters ? 'Nessun prodotto trovato' : 'Nessun prodotto',
      subtitle: hasFilters
          ? 'Prova a modificare i filtri di ricerca'
          : 'Aggiungi il primo prodotto con il pulsante +',
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    WidgetRef ref,
    Product product,
    Department department,
    List<Department> allDepartments,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildProductImage(product),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              department.name,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'ID: ${product.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProductDialog(context, ref, product, allDepartments);
                break;
              case 'move':
                _showMoveProductDialog(context, ref, product, allDepartments);
                break;
              case 'delete':
                _showDeleteConfirmation(context, ref, product);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifica'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz),
                  SizedBox(width: 8),
                  Text('Cambia reparto'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Elimina', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () =>
            _showEditProductDialog(context, ref, product, allDepartments),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(product.imagePath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultProductIcon(),
        ),
      );
    }
    return _buildDefaultProductIcon();
  }

  Widget _buildDefaultProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_basket, size: 24, color: Colors.orange),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final departmentsState = ref.watch(departmentsProvider);
    if (departmentsState.value?.isEmpty ?? true) {
      _showNoDepartmentsWarning(context);
      return;
    }
    _showProductDialog(context, ref, null, departmentsState.value!);
  }

  void _showEditProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    List<Department> departments,
  ) {
    _showProductDialog(context, ref, product, departments);
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product? product,
    List<Department> departments,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    int? selectedDepartmentId = product?.departmentId ?? departments.first.id;
    String? selectedImagePath = product?.imagePath;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Nuovo Prodotto' : 'Modifica Prodotto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome prodotto
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome prodotto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Selezione reparto
                DropdownButtonFormField<int>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Reparto',
                    border: OutlineInputBorder(),
                  ),
                  items: departments
                      .map(
                        (dept) => DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartmentId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Sezione immagine
                Row(
                  children: [
                    if (selectedImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(selectedImagePath!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          cacheWidth: AppConstants.imageCacheWidth,
                          cacheHeight: AppConstants.imageCacheHeight,
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_basket, size: 30),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final imagePath = await ref
                                        .read(imageServiceProvider)
                                        .pickAndSaveImage();
                                    if (imagePath != null) {
                                      selectedImagePath = imagePath;
                                    }
                                    setState(() => isLoading = false);
                                  },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Scegli immagine'),
                          ),
                          if (selectedImagePath != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => selectedImagePath = null);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Rimuovi',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty || selectedDepartmentId == null) return;

                      if (product == null) {
                        // Nuovo prodotto
                        await ref
                            .read(productsProvider.notifier)
                            .addProduct(
                              name,
                              selectedDepartmentId!,
                              selectedImagePath,
                            );
                      } else {
                        // Modifica prodotto esistente
                        await ref
                            .read(productsProvider.notifier)
                            .updateProduct(
                              product.copyWith(
                                name: name,
                                departmentId: selectedDepartmentId,
                                imagePath: selectedImagePath,
                              ),
                            );
                      }

                      Navigator.pop(context);
                    },
              child: Text(product == null ? 'Aggiungi' : 'Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    List<Department> departments,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambia Reparto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sposta "${product.name}" in:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final dept = departments[index];
                  final isCurrentDept = dept.id == product.departmentId;

                  return ListTile(
                    leading: dept.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(dept.imagePath!),
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              cacheWidth: AppConstants.imageCacheWidth,
                              cacheHeight: AppConstants.imageCacheHeight,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.store, size: 32),
                            ),
                          )
                        : const Icon(Icons.store, size: 32),
                    title: Text(dept.name),
                    trailing: isCurrentDept
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    enabled: !isCurrentDept,
                    onTap: isCurrentDept
                        ? null
                        : () async {
                            await ref
                                .read(productsProvider.notifier)
                                .updateProduct(
                                  product.copyWith(departmentId: dept.id),
                                );
                            Navigator.pop(context);

                            // Mostra snackbar di conferma
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} spostato in ${dept.name}',
                                ),
                              ),
                            );
                          },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Prodotto'),
        content: Text('Sei sicuro di voler eliminare "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(productsProvider.notifier)
                  .deleteProduct(product.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showNoDepartmentsWarning(BuildContext context) {
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
