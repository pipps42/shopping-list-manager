import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import 'package:shopping_list_manager/widgets/common/validated_text_field.dart';
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
  String? _selectedImagePath;
  bool _isLoading = false;
  bool _imageError = false;
  final GlobalKey<ValidatedTextFieldState> _nameFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.card?.imagePath;
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
                child: ValidatedTextField(
                  key: _nameFieldKey,
                  labelText: 'Nome della carta',
                  hintText: 'es. Carta Fidaty, Carta Insieme...',
                  initialValue: widget.card?.name ?? '',
                  isRequired: true,
                  requiredMessage: 'Il nome della carta è obbligatorio',
                  requireMinThreeLetters: true,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Sezione immagine
              AppImageUploader(
                value: _selectedImagePath,
                onValueChanged: (path) => setState(() {
                  _selectedImagePath = path;
                  if (_imageError && path.isNotEmpty) {
                    _imageError = false;
                  }
                }),
                onValueRemoved: () => setState(() => _selectedImagePath = null),
                title: 'Immagine della carta',
                fallbackIcon: Icons.credit_card,
                previewHeight: 150,
                buttonsLayout: ButtonsLayout.below,
                maxWidth: 1200,
                maxHeight: 1200,
                imageQuality: 90,
                preserveAspectRatio: true,
                isRequired: true,
                requiredMessage: 'Seleziona un\'immagine per la carta',
                hasError: _imageError,
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

  Future<void> _saveCard() async {
    final nameFieldState = _nameFieldKey.currentState;

    // Valida il campo nome
    if (nameFieldState == null || !nameFieldState.validate()) {
      return;
    }

    if (_selectedImagePath == null) {
      setState(() {
        _imageError = true;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(nameFieldState.text.trim(), _selectedImagePath!);

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
