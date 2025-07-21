import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/loyalty_card.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class AddLoyaltyCardDialog extends StatefulWidget {
  final LoyaltyCard? card; // Se presente, è in modalità modifica
  final Function(String name, String imagePath) onSave;

  const AddLoyaltyCardDialog({super.key, this.card, required this.onSave});

  @override
  State<AddLoyaltyCardDialog> createState() => _AddLoyaltyCardDialogState();
}

class _AddLoyaltyCardDialogState extends State<AddLoyaltyCardDialog> {
  late final TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.name ?? '');
    _selectedImagePath = widget.card?.imagePath;

    // Aggiungi listener per aggiornare UI quando cambia il testo
    _nameController.addListener(() {
      setState(() {
        // Il rebuild farà sì che _canSave venga ricalcolato
        // e il bottone si abiliti/disabiliti di conseguenza
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.card != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifica Carta' : 'Nuova Carta Fedeltà'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo nome
              SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome della carta',
                    hintText: 'es. Carta Fidaty, Carta Insieme...',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Sezione immagine
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Immagine della carta:',
                  style: TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Anteprima immagine con dimensioni fisse
              _buildImagePreview(),
              const SizedBox(height: AppConstants.spacingM),

              // Pulsanti per scegliere immagine
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        AppStrings.camera,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galleria'),
                    ),
                  ),
                ],
              ),

              // Pulsante rimuovi se c'è un'immagine
              if (_selectedImagePath != null && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.spacingM),
                  child: TextButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Rimuovi immagine'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _canSave && !_isLoading ? _saveCard : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary(context),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Modifica' : 'Aggiungi'),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath == null) {
      return _buildEmptyPreview();
    }

    return Container(
      width: double.maxFinite,
      height: 150, // Altezza fissa
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: File(_selectedImagePath!).existsSync()
            ? Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150, // Altezza fissa
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorPreview(),
              )
            : _buildErrorPreview(),
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      width: double.maxFinite,
      height: 150, // Altezza fissa
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        color: Colors.grey[50],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: AppConstants.iconXL,
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.spacingS),
          Text('Seleziona un\'immagine', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorPreview() {
    return Container(
      width: double.maxFinite,
      height: 150, // Altezza fissa
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppConstants.iconXL,
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.spacingS),
          Text('Errore nel caricamento', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella selezione dell\'immagine: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() => _selectedImagePath = null);
  }

  bool get _canSave {
    return _nameController.text.trim().isNotEmpty && _selectedImagePath != null;
  }

  Future<void> _saveCard() async {
    if (!_canSave) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSave(_nameController.text.trim(), _selectedImagePath!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Carta modificata con successo!'
                  : 'Carta aggiunta con successo!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
