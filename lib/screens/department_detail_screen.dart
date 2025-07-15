import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/departments_provider.dart';
import '../models/department.dart';
import '../models/product.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/products_management/product_form_dialog.dart';
import '../widgets/products_management/move_product_dialog.dart';
import '../widgets/products_management/delete_product_dialog.dart';
import '../widgets/department_detail/department_product_tile.dart';

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
        title: AppStrings.emptyProducts,
        subtitle: AppStrings.emptyProductsSubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppConstants.paddingS,
        left: AppConstants.paddingS,
        right: AppConstants.paddingS,
        bottom: AppConstants.listBottomSpacing, // Spazio per il FAB
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return DepartmentProductTile(
          product: product,
          department: department,
          onEdit: () => _showEditProductDialog(context, ref, product),
          onMove: () => _showMoveProductDialog(context, ref, product),
          onDelete: () => _showDeleteProductDialog(context, ref, product),
        );
      },
    );
  }

  // Dialog Methods
  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final departmentsState = ref.watch(departmentsProvider);

    if (!departmentsState.hasValue) return;

    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        departments: departmentsState.value!,
        defaultDepartmentId: department.id,
        onSave: (name, departmentId, imagePath) async {
          await ref
              .read(productsProvider.notifier)
              .addProduct(name, departmentId, imagePath);

          // Refresh della lista prodotti per questo reparto
          ref.invalidate(productsByDepartmentProvider(department.id!));
        },
      ),
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    final departmentsState = ref.watch(departmentsProvider);

    if (!departmentsState.hasValue) return;

    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        departments: departmentsState.value!,
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

          // Refresh della lista prodotti per questo reparto
          ref.invalidate(productsByDepartmentProvider(department.id!));
        },
      ),
    );
  }

  void _showMoveProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    final departmentsState = ref.watch(departmentsProvider);

    if (!departmentsState.hasValue) return;

    showDialog(
      context: context,
      builder: (context) => MoveProductDialog(
        product: product,
        departments: departmentsState.value!,
        onMoveProduct: (newDepartment) async {
          await ref
              .read(productsProvider.notifier)
              .updateProduct(product.copyWith(departmentId: newDepartment.id));

          // Refresh della lista prodotti per questo reparto
          ref.invalidate(productsByDepartmentProvider(department.id!));
        },
      ),
    );
  }

  void _showDeleteProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteProductDialog(
        product: product,
        onConfirmDelete: () async {
          await ref.read(productsProvider.notifier).deleteProduct(product.id!);

          // Refresh della lista prodotti per questo reparto
          ref.invalidate(productsByDepartmentProvider(department.id!));
        },
      ),
    );
  }
}
