import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/departments_provider.dart';
import '../providers/products_provider.dart';
import '../providers/current_list_provider.dart';
import '../models/department.dart';
import '../models/product.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Function(int productId) onProductSelected;

  const AddProductDialog({
    super.key,
    required this.onProductSelected,
  });

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  Department? selectedDepartment;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departmentsState = ref.watch(departmentsProvider);
    final productsState = ref.watch(productsProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Aggiungi Prodotto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra di ricerca
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cerca prodotto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),

            // Filtro per reparto
            departmentsState.when(
              data: (departments) => _buildDepartmentFilter(departments),
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text('Errore caricamento reparti: $error'),
            ),
            const SizedBox(height: 16),

            // Lista prodotti
            Expanded(
              child: productsState.when(
                data: (products) => _buildProductsList(products),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Errore caricamento prodotti: $error'),
                ),
              ),
            ),
          ],
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
          ...departments.map((dept) => Padding(
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
          )),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> allProducts) {
    // Filtra prodotti in base ai criteri
    List<Product> filteredProducts = allProducts.where((product) {
      // Filtro per reparto
      if (selectedDepartment != null && product.departmentId != selectedDepartment!.id) {
        return false;
      }
      
      // Filtro per ricerca
      if (searchQuery.isNotEmpty && !product.name.toLowerCase().contains(searchQuery)) {
        return false;
      }
      
      return true;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nessun prodotto trovato',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductTile(product);
      },
    );
  }

  Widget _buildProductTile(Product product) {
    return FutureBuilder<bool>(
      future: ref.read(currentListProvider.notifier).isProductInList(product.id!),
      builder: (context, snapshot) {
        final isInList = snapshot.data ?? false;
        
        return ListTile(
          leading: _buildProductImage(product),
          title: Text(product.name),
          subtitle: _buildDepartmentName(product.departmentId),
          trailing: isInList 
              ? Icon(Icons.check_circle, color: Colors.green[600])
              : const Icon(Icons.add_circle_outline),
          onTap: isInList 
              ? null 
              : () {
                  widget.onProductSelected(product.id!);
                  Navigator.pop(context);
                },
          enabled: !isInList,
        );
      },
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
          orElse: () => Department(id: -1, name: 'Reparto sconosciuto', orderIndex: 0),
        );
        return Text(
          dept.name,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      },
      loading: () => const Text('...'),
      error: (error, stack) => const Text('Errore'),
    );
  }
}