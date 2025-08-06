import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
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
    return BaseDialog(
      title: _isEditing ? 'Modifica Carta' : 'Nuova Carta',
      titleIcon: _isEditing ? Icons.edit : Icons.credit_card,
      hasColoredHeader: true,
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
              AppImageUploader(
                imagePath: _selectedImagePath,
                onImageSelected: (path) =>
                    setState(() => _selectedImagePath = path),
                onImageRemoved: () => setState(() => _selectedImagePath = null),
                title: 'Immagine della carta',
                fallbackIcon: Icons.credit_card,
                previewHeight: 150,
                buttonsLayout: ButtonsLayout.below,
                maxWidth: 1200,
                maxHeight: 1200,
                imageQuality: 90,
                preserveAspectRatio: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        DialogAction.cancel(onPressed: () => Navigator.pop(context)),
        DialogAction.save(
          text: _isEditing ? AppStrings.save : AppStrings.add,
          onPressed: _saveCard,
          isLoading: _isLoading,
        ),
      ],
    );
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
