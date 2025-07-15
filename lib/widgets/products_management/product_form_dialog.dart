import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import '../../providers/image_provider.dart';
import '../../utils/constants.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  final List<Department> departments;
  final Function(String name, int departmentId, String? imagePath) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.departments,
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
        widget.product?.departmentId ??
        (widget.departments.isNotEmpty ? widget.departments.first.id : null);
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

    return AlertDialog(
      title: Text(isEditing ? 'Modifica Prodotto' : 'Nuovo Prodotto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome prodotto
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome prodotto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Selezione reparto
            DropdownButtonFormField<int>(
              value: _selectedDepartmentId,
              decoration: const InputDecoration(
                labelText: 'Reparto',
                border: OutlineInputBorder(),
              ),
              items: widget.departments
                  .map(
                    (dept) => DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sezione immagine
            _buildImageSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: Text(isEditing ? 'Salva' : 'Aggiungi'),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Row(
      children: [
        // Preview immagine
        if (_selectedImagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_selectedImagePath!),
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

        // Bottoni gestione immagine
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handlePickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scegli immagine'),
              ),
              if (_selectedImagePath != null)
                TextButton.icon(
                  onPressed: _handleRemoveImage,
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
    );
  }

  Future<void> _handlePickImage() async {
    setState(() => _isLoading = true);

    try {
      final imagePath = await ref.read(imageServiceProvider).pickAndSaveImage();

      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella selezione immagine: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleRemoveImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  void _handleSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Il nome del prodotto è obbligatorio')),
      );
      return;
    }

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleziona un reparto')));
      return;
    }

    widget.onSave(name, _selectedDepartmentId!, _selectedImagePath);
    Navigator.pop(context);
  }
}
