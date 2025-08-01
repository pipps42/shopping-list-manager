import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'move_product_dialog.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  final List<Department> departments;
  final int? defaultDepartmentId;
  final Function(String name, int departmentId, String? imagePath) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.departments,
    this.defaultDepartmentId,
    required this.onSave,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  late TextEditingController _nameController;
  int? _selectedDepartmentId;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');

    _selectedDepartmentId =
        widget.product?.departmentId ?? // 1. Prodotto esistente
        widget.defaultDepartmentId ?? // 2. Reparto di default passato
        (widget.departments.isNotEmpty
            ? widget.departments.first.id
            : null); // 3. Fallback primo reparto

    _selectedImagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return BaseDialog(
      title: isEditing ? AppStrings.editProduct : AppStrings.newProduct,
      titleIcon: isEditing ? Icons.edit : Icons.shopping_basket,
      hasColoredHeader: true,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome prodotto
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.productNamePlaceholder,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Selezione reparto
            _buildDepartmentSelector(),
            const SizedBox(height: AppConstants.spacingM),

            // Sezione immagine
            AppImageUploader(
              imagePath: _selectedImagePath,
              onImageSelected: (path) =>
                  setState(() => _selectedImagePath = path),
              onImageRemoved: () => setState(() => _selectedImagePath = null),
              title: 'Immagine del prodotto',
              fallbackIcon: Icons.shopping_basket,
              previewHeight: 100,
              previewWidth: 100,
              buttonsLayout: ButtonsLayout.beside,
            ),
          ],
        ),
      ),
      actions: [
        DialogAction.cancel(
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction.save(
          text: isEditing ? AppStrings.save : AppStrings.add,
          onPressed: _handleSave,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildDepartmentSelector() {
    final selectedDepartment = widget.departments
        .firstWhere((dept) => dept.id == _selectedDepartmentId,
            orElse: () => widget.departments.first);

    return InkWell(
      onTap: _showDepartmentSelection,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Reparto',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDepartment.name,
                style: const TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepartmentSelection() async {
    // Nascondi la tastiera e aspetta che l'animazione si completi
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Verifica che il widget sia ancora montato prima di aprire la dialog
    if (!mounted) return;
    
    // Creo un prodotto temporaneo per la modale
    final tempProduct = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Prodotto',
      departmentId: _selectedDepartmentId ?? widget.departments.first.id!,
      imagePath: _selectedImagePath,
    );

    showDialog(
      context: context,
      builder: (context) => MoveProductDialog(
        product: tempProduct,
        departments: widget.departments,
        onMoveProduct: (department) {
          setState(() {
            _selectedDepartmentId = department.id;
          });
        },
        isSelection: true,
      ),
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.productNameRequired)),
      );
      return;
    }

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectDepartment)),
      );
      return;
    }

    widget.onSave(name, _selectedDepartmentId!, _selectedImagePath);
    Navigator.pop(context);
  }
}
