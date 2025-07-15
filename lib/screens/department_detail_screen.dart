import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/departments_provider.dart';
import '../providers/image_provider.dart';
import '../models/department.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';

class DepartmentDetailScreen extends ConsumerWidget {
  final Department department;

  const DepartmentDetailScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(
      productsByDepartmentProvider(department.id!),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: productsState.when(
        data: (products) => _buildProductsList(context, ref, products),
        loading: () =>
            const LoadingWidget(message: 'Caricamento prodotti del reparto...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento dei prodotti: $error',
          onRetry: () =>
              ref.invalidate(productsByDepartmentProvider(department.id!)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "department_detail_fab",
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) {
    if (products.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inventory_outlined,
        title: 'Nessun prodotto',
        subtitle: 'Aggiungi il primo prodotto con il pulsante +',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductTile(context, ref, product);
      },
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildProductImage(product),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Reparto: ${department.name}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProductDialog(context, ref, product);
                break;
              case 'move':
                _showMoveProductDialog(context, ref, product);
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
                  Text('Sposta reparto'),
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
        onTap: () => _showEditProductDialog(context, ref, product),
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
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_basket, size: 24, color: Colors.green),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    _showProductDialog(context, ref, null);
  }

  void _showEditProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    _showProductDialog(context, ref, product);
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product? product,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    String? selectedImagePath = product?.imagePath;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Nuovo Prodotto' : 'Modifica Prodotto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome prodotto',
                  border: OutlineInputBorder(),
                ),
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
                      if (name.isEmpty) return;

                      if (product == null) {
                        // Nuovo prodotto
                        await ref
                            .read(productsProvider.notifier)
                            .addProduct(
                              name,
                              department.id!,
                              selectedImagePath,
                            );
                      } else {
                        // Modifica prodotto esistente
                        await ref
                            .read(productsProvider.notifier)
                            .updateProduct(
                              product.copyWith(
                                name: name,
                                imagePath: selectedImagePath,
                              ),
                            );
                      }

                      // Refresh della lista prodotti per questo reparto
                      ref.invalidate(
                        productsByDepartmentProvider(department.id!),
                      );
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
  ) {
    final departmentsState = ref.watch(departmentsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sposta Prodotto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sposta "${product.name}" in:'),
            const SizedBox(height: 16),
            departmentsState.when(
              data: (departments) => SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final dept = departments[index];
                    final isCurrentDept = dept.id == department.id;

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
                      enabled: !isCurrentDept,
                      onTap: isCurrentDept
                          ? null
                          : () async {
                              await ref
                                  .read(productsProvider.notifier)
                                  .updateProduct(
                                    product.copyWith(departmentId: dept.id),
                                  );
                              ref.invalidate(
                                productsByDepartmentProvider(department.id!),
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
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Errore: $error'),
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
              ref.invalidate(productsByDepartmentProvider(department.id!));
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
}
