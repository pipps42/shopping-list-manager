import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_search_bar.dart';
import '../providers/products_provider.dart';
import '../providers/departments_provider.dart';
import '../providers/current_list_provider.dart';
import '../providers/recipes_provider.dart';
import '../models/product.dart';
import '../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'common/loading_widget.dart';
import 'common/empty_state_widget.dart';
import 'common/error_state_widget.dart';

/* class AddProductDialog extends ConsumerStatefulWidget {
  final Function(int productId) onProductSelected;

  const AddProductDialog({super.key, required this.onProductSelected});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
} */
class AddProductDialog extends ConsumerStatefulWidget {
  final Function(int) onProductSelected;
  final Function(int)? onProductRemoved; // Callback per rimuovere prodotti
  final String? title;
  final String? subtitle;
  final Set<int>? excludeProductIds; // Prodotti da nascondere/disabilitare
  final Set<int>?
  preselectedProductIds; // Prodotti già selezionati (per ricette)
  final int? recipeId; // ID ricetta per reattività ingredienti

  const AddProductDialog({
    super.key,
    required this.onProductSelected,
    this.onProductRemoved,
    this.title,
    this.subtitle,
    this.excludeProductIds,
    this.preselectedProductIds,
    this.recipeId,
  });

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();

  // ===== FACTORY METHODS PER CASI D'USO SPECIFICI =====
  /// Factory per aggiungere prodotti alla lista corrente
  static Widget forCurrentList({
    required Function(int) onProductSelected,
    Function(int)? onProductRemoved,
  }) {
    return AddProductDialog(
      onProductSelected: onProductSelected,
      onProductRemoved: onProductRemoved,
      title: AppStrings.addProduct,
      subtitle: 'Seleziona i prodotti da aggiungere alla lista',
    );
  }

  /// Factory per aggiungere ingredienti a una ricetta
  static Widget forRecipeIngredients({
    required Function(int) onProductSelected,
    Function(int)? onProductRemoved,
    required String recipeName,
    Set<int>? existingIngredients,
  }) {
    return AddProductDialog(
      onProductSelected: onProductSelected,
      onProductRemoved: onProductRemoved,
      title: 'Aggiungi Ingredienti',
      subtitle: 'Seleziona gli ingredienti per "$recipeName"',
      preselectedProductIds: existingIngredients,
    );
  }

  /// Factory per gestire ingredienti di una ricetta
  static Widget forRecipeIngredientManagement({
    required Function(int) onProductSelected,
    Function(int)? onProductRemoved,
    required String recipeName,
    required int recipeId,
    Set<int>? currentIngredients,
  }) {
    return AddProductDialog(
      onProductSelected: onProductSelected,
      onProductRemoved: onProductRemoved,
      title: 'Gestisci Ingredienti',
      subtitle: 'Seleziona gli ingredienti per "$recipeName"',
      preselectedProductIds: currentIngredients,
      recipeId: recipeId,
    );
  }

  /// Factory per filtrare prodotti specifici
  static Widget withFilters({
    required Function(int) onProductSelected,
    Function(int)? onProductRemoved,
    String? title,
    String? subtitle,
    Set<int>? excludeProducts,
    Set<int>? preselectedProducts,
  }) {
    return AddProductDialog(
      onProductSelected: onProductSelected,
      onProductRemoved: onProductRemoved,
      title: title,
      subtitle: subtitle,
      excludeProductIds: excludeProducts,
      preselectedProductIds: preselectedProducts,
    );
  }
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  Department? selectedDepartment;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final departmentsState = ref.watch(departmentsProvider);
    final productsState = ref.watch(productsProvider);

    return Dialog(
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Barra di ricerca
            AppSearchBar(
              placeholder: AppStrings.searchProductPlaceholder,
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Filtro per reparto
            departmentsState.when(
              data: (departments) =>
                  _buildDepartmentFilter(context, departments),
              loading: () => const LoadingWidget(
                message: AppStrings.loadingDepartments,
                size: AppConstants.iconS,
              ),
              error: (error, stack) => Padding(
                padding: EdgeInsets.all(AppConstants.paddingS),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: AppConstants.iconS,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        'Errore reparti: $error',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: AppConstants.fontM,
                        ),
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
    );
  }

  Widget _buildDepartmentFilter(
    BuildContext context,
    List<Department> departments,
  ) {
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
              selectedColor: AppColors.accent,
              checkmarkColor: AppColors.textOnTertiary(context),
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
                selectedColor: AppColors.accent,
                checkmarkColor: AppColors.textOnTertiary(context),
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
            Icon(Icons.error, color: AppColors.error),
            Text('Errore nel caricamento: $error'),
          ],
        ),
      ),
    );
  }

  /*   Widget _buildProductTile(Product product) {
    final productIdsInList = ref.watch(currentListProductIdsProvider);

    return productIdsInList.when(
      data: (productIds) {
        final isInList = productIds.contains(product.id!);

        return ListTile(
          leading: _buildProductImage(product),
          title: Text(product.name),
          subtitle: _buildDepartmentName(context, product.departmentId),
          trailing: isInList
              ? Icon(Icons.check_circle, color: AppColors.success)
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
        leading: Icon(Icons.error, color: AppColors.error, size: 20),
        title: Text(
          'Errore',
          style: TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ),
    );
  } */
  Widget _buildProductTile(Product product) {
    final productIdsInList = ref.watch(currentListProductIdsProvider);

    // Controlla se il prodotto deve essere escluso
    final isExcluded = widget.excludeProductIds?.contains(product.id!) ?? false;
    if (isExcluded) return const SizedBox.shrink();

    // Se abbiamo un recipeId, usa il provider dedicato per gli ingredienti
    if (widget.recipeId != null) {
      final recipeIngredientsState = ref.watch(recipeIngredientProductIdsProvider(widget.recipeId!));
      
      return recipeIngredientsState.when(
        data: (recipeIngredientIds) {
          final isInRecipe = recipeIngredientIds.contains(product.id!);
          
          if (isInRecipe) {
            return _buildCheckedProductTile(product);
          } else {
            return _buildUncheckedProductTile(product);
          }
        },
        loading: () => ListTile(
          leading: _buildProductImage(product),
          title: Text(product.name),
          subtitle: _buildDepartmentName(context, product.departmentId),
          trailing: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stack) => ListTile(
          leading: _buildProductImage(product),
          title: Text(product.name),
          subtitle: Text('Errore: $error'),
          trailing: const Icon(Icons.error, color: AppColors.error),
        ),
      );
    }

    // Logica per current list (usa productIdsInList)
    return productIdsInList.when(
      data: (productIds) {
        final isInList = productIds.contains(product.id!);
        final isPreselected =
            widget.preselectedProductIds?.contains(product.id!) ?? false;

        // Il prodotto è "checkato" se è nella lista corrente o preselezionato
        final isChecked = isInList || isPreselected;

        if (isChecked) {
          return _buildCheckedProductTile(product);
        } else {
          return _buildUncheckedProductTile(product);
        }
      },
      loading: () => ListTile(
        leading: _buildProductImage(product),
        title: Text(product.name),
        subtitle: _buildDepartmentName(context, product.departmentId),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => ListTile(
        leading: _buildProductImage(product),
        title: Text(product.name),
        subtitle: Text('Errore: $error'),
        trailing: const Icon(Icons.error, color: AppColors.error),
      ),
    );
  }

  Widget _buildUncheckedProductTile(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: ListTile(
        leading: _buildProductImage(product),
        title: Text(product.name),
        subtitle: _buildDepartmentName(context, product.departmentId),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: () => widget.onProductSelected(product.id!),
      ),
    );
  }

  Widget _buildCheckedProductTile(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        leading: _buildProductImage(product),
        title: Text(
          product.name,
          style: TextStyle(
            color: AppColors.textSecondary(context),
          ),
        ),
        subtitle: _buildDepartmentName(context, product.departmentId),
        trailing: widget.onProductRemoved != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  onTap: () => widget.onProductRemoved!(product.id!),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Image.file(
          File(product.imagePath!),
          width: AppConstants.imageM,
          height: AppConstants.imageM,
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
      width: AppConstants.imageM,
      height: AppConstants.imageM,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        Icons.shopping_basket,
        size: AppConstants.iconM,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDepartmentName(BuildContext context, int departmentId) {
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
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textDisabled(context),
          ),
        );
      },
      loading: () => const LoadingWidget(message: '...'),
      error: (error, stack) => const Text('Errore'),
    );
  }
}
