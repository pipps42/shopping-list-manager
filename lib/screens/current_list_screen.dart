import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/current_list_provider.dart';
import '../providers/products_provider.dart';
import '../models/department_with_products.dart';
import '../models/list_item.dart';
import '../models/product.dart';
import '../widgets/add_product_dialog.dart';

class CurrentListScreen extends ConsumerWidget {
  const CurrentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentListState = ref.watch(currentListProvider);

    return Scaffold(
      body: currentListState.when(
        data: (departmentsWithProducts) => _buildListView(context, ref, departmentsWithProducts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Errore: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentListProvider),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, List<DepartmentWithProducts> departments) {
    if (departments.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(currentListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return _buildDepartmentSection(context, ref, dept);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Lista vuota',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aggiungi prodotti con il pulsante +',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSection(BuildContext context, WidgetRef ref, DepartmentWithProducts dept) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del reparto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (dept.department.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(dept.department.imagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.store, size: 20),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 20),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dept.department.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDepartmentStats(dept),
              ],
            ),
          ),
          // Lista prodotti
          ...dept.items.map((item) => _buildProductItem(context, ref, item)),
        ],
      ),
    );
  }

  Widget _buildDepartmentStats(DepartmentWithProducts dept) {
    final total = dept.items.length;
    final completed = dept.items.where((item) => item.isChecked).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$completed/$total',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, WidgetRef ref, ListItem item) {
    return Dismissible(
      key: Key('item_${item.id}'),
      background: _buildSwipeBackground(context, false),
      secondaryBackground: _buildSwipeBackground(context, true),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - marca come completato
          ref.read(currentListProvider.notifier).toggleItemChecked(item.id!, true);
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left - marca come non completato  
          ref.read(currentListProvider.notifier).toggleItemChecked(item.id!, false);
        }
        return false; // Non rimuovere l'item, solo aggiorna lo stato
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: item.isChecked ? Colors.grey[200] : Colors.white,
        ),
        child: ListTile(
          leading: _buildProductImage(item),
          title: Text(
            item.productName ?? 'Prodotto sconosciuto',
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey[600] : null,
            ),
          ),
          trailing: item.isChecked
              ? Icon(Icons.check_circle, color: Colors.green[600])
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
          onTap: () {
            ref.read(currentListProvider.notifier).toggleItemChecked(item.id!, !item.isChecked);
          },
          onLongPress: () => _showRemoveItemDialog(context, ref, item),
        ),
      ),
    );
  }

  Widget _buildProductImage(ListItem item) {
    if (item.productImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(item.productImagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultProductIcon(),
        ),
      );
    }
    return _buildDefaultProductIcon();
  }

  Widget _buildDefaultProductIcon() {
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

  Widget _buildSwipeBackground(BuildContext context, bool isSecondary) {
    return Container(
      color: isSecondary ? Colors.orange : Colors.green,
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isSecondary ? Icons.undo : Icons.check,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductSelected: (productId) {
          ref.read(currentListProvider.notifier).addProductToList(productId);
        },
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, WidgetRef ref, ListItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi prodotto'),
        content: Text('Vuoi rimuovere "${item.productName}" dalla lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(currentListProvider.notifier).removeItemFromList(item.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
  }
}