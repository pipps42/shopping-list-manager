import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/current_list_provider.dart';
import '../models/department_with_products.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/current_list/department_card.dart';

class CurrentListScreen extends ConsumerWidget {
  const CurrentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentListState = ref.watch(currentListProvider);

    return Scaffold(
      body: currentListState.when(
        data: (departmentsWithProducts) =>
            _buildListView(context, ref, departmentsWithProducts),
        loading: () => const LoadingWidget(message: AppStrings.loadingList),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento della lista: $error',
          onRetry: () => ref.invalidate(currentListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "current_list_fab",
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary(context),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    List<DepartmentWithProducts> departments,
  ) {
    if (departments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: AppStrings.emptyList,
        subtitle: AppStrings.emptyListSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingM,
          left: AppConstants.paddingM,
          right: AppConstants.paddingM,
          bottom: AppConstants.listBottomSpacing, // Spazio per il FAB
        ),
        itemCount: departments.length,
        itemBuilder: (context, index) =>
            DepartmentCard(department: departments[index]),
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
}
