import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/recipe.dart';

class RecipeFormDialog extends StatefulWidget {
  final Recipe? recipe;
  final Function(Recipe) onSave;

  const RecipeFormDialog({super.key, this.recipe, required this.onSave});

  @override
  State<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends State<RecipeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _descriptionController.text = widget.recipe!.description ?? '';
      _imagePath = widget.recipe!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifica Ricetta' : 'Nuova Ricetta'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome ricetta',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Il nome è obbligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingM),

            // Campo descrizione
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrizione (opzionale)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: AppConstants.spacingM),

            // Immagine
            _buildImageSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(onPressed: _saveRecipe, child: const Text('Salva')),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Immagine (opzionale)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppConstants.spacingS),

        if (_imagePath != null)
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                    cacheWidth: 100,
                    cacheHeight: 100,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _imagePath = null),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Aggiungi immagine'),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel selezionare l\'immagine: $e')),
        );
      }
    }
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;

    final recipe = Recipe(
      id: widget.recipe?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imagePath: _imagePath,
      createdAt:
          widget.recipe?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    widget.onSave(recipe);
    Navigator.of(context).pop();
  }
}
