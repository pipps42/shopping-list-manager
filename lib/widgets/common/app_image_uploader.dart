import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';
import '../../utils/icon_types.dart';
import '../../providers/image_provider.dart';
import 'emoji_picker_dialog.dart';
import 'universal_icon.dart';

/// 📸 **AppImageUploader** - Widget completo per upload e gestione immagini

enum ButtonsLayout { below, beside }

enum UploaderMode { cameraGallery, emojiGallery }

class AppImageUploader extends ConsumerStatefulWidget {
  // Campo unificato per entrambe le modalità
  final String? value;
  final ValueChanged<String>? onValueChanged;
  final VoidCallback? onValueRemoved;

  // Solo per modalità emojiGallery
  final IconType? iconType;
  final ValueChanged<IconType>? onIconTypeChanged;

  // Parametri comuni
  final ValueChanged<String>? onError;
  final String? title;
  final IconData fallbackIcon;
  final double previewHeight;
  final double? previewWidth;
  final bool enabled;
  final ButtonsLayout buttonsLayout;
  final UploaderMode mode;
  final int imageQuality;
  final int maxWidth;
  final int maxHeight;
  final String? cameraButtonText;
  final String? galleryButtonText;
  final String? emojiButtonText;
  final String? removeButtonText;
  final String? emptyStateText;
  final bool preserveAspectRatio;

  const AppImageUploader({
    super.key,
    // Campo unificato
    this.value,
    this.onValueChanged,
    this.onValueRemoved,
    // Solo per icone
    this.iconType,
    this.onIconTypeChanged,
    // Parametri comuni
    this.onError,
    this.title,
    this.fallbackIcon = Icons.add_photo_alternate_outlined,
    this.previewHeight = 120.0,
    this.previewWidth,
    this.enabled = true,
    this.buttonsLayout = ButtonsLayout.beside,
    this.mode = UploaderMode.cameraGallery,
    this.imageQuality = AppConstants.imageQuality,
    this.maxWidth = AppConstants.maxImageWidth,
    this.maxHeight = AppConstants.maxImageHeight,
    this.cameraButtonText,
    this.galleryButtonText,
    this.emojiButtonText,
    this.removeButtonText,
    this.emptyStateText,
    this.preserveAspectRatio = false,
  });

  @override
  ConsumerState<AppImageUploader> createState() => _AppImageUploaderState();
}

class _AppImageUploaderState extends ConsumerState<AppImageUploader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool _hasContent() {
    return widget.value != null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo opzionale
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
        ],

        // Layout principale basato su buttonsLayout
        if (widget.buttonsLayout == ButtonsLayout.beside)
          _buildBesideLayout()
        else
          _buildBelowLayout(),

        // Pulsante rimuovi (se c'è contenuto)
        if (_hasContent() && widget.enabled && !_isLoading)
          _buildRemoveButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    final width = widget.previewWidth ?? 280.0;
    final height = widget.previewHeight;

    final hasContent = _hasContent();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context), width: 1.0),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        color: !hasContent ? AppColors.surface(context).withOpacity(0.5) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: !hasContent
            ? _buildEmptyState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surface(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.fallbackIcon,
            size: AppConstants.iconL,
            color: AppColors.iconSecondary(context),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingS,
            ),
            child: Text(
              widget.emptyStateText ?? AppStrings.chooseImage,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: AppConstants.fontM,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Contenuto: immagine per cameraGallery, icona per emojiGallery
        if (widget.mode == UploaderMode.cameraGallery)
          // Modalità immagini
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: File(widget.value!).existsSync()
                ? Image.file(
                    File(widget.value!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: AppConstants.imageCacheWidth,
                    cacheHeight: AppConstants.imageCacheHeight,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorState(),
                  )
                : _buildErrorState(),
          )
        else
          // Modalità icone
          Center(
            child: UniversalIcon(
              iconType: widget.iconType ?? IconType.asset,
              iconValue: widget.value,
              size: widget.previewHeight * 0.6,
              fallbackIcon: widget.fallbackIcon,
            ),
          ),

        // Loading overlay
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.overlay.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surface(context).withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppConstants.iconL,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingS,
            ),
            child: Text(
              'Errore nel caricamento',
              style: TextStyle(
                color: AppColors.error,
                fontSize: AppConstants.fontM,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Layout con bottoni sotto la preview (default)
  Widget _buildBelowLayout() {
    return Column(
      children: [
        _buildImagePreview(),
        const SizedBox(height: AppConstants.spacingM),
        _buildActionButtons(),
      ],
    );
  }

  /// Layout con bottoni a fianco della preview (a destra)
  Widget _buildBesideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagePreview(),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(child: _buildButtonsWithPureMath()),
      ],
    );
  }

  /// Layout bottoni a fianco - gestione automatica dimensioni
  Widget _buildButtonsWithPureMath() {
    return SizedBox(
      height: widget.previewHeight,
      child: Column(
        children: [
          if (widget.mode == UploaderMode.cameraGallery) ...[
            Flexible(child: _buildCameraButton()),
            const SizedBox(height: AppConstants.spacingS),
            Flexible(child: _buildGalleryButton()),
          ] else ...[
            Flexible(child: _buildEmojiButton()),
            const SizedBox(height: AppConstants.spacingS),
            Flexible(child: _buildGalleryButton()),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt),
      label: Text(
        widget.cameraButtonText ?? AppStrings.camera,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
      icon: const Icon(Icons.photo_library),
      label: Text(
        widget.galleryButtonText ?? AppStrings.gallery,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary),
      ),
    );
  }

  Widget _buildEmojiButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showEmojiPicker,
      icon: const Icon(Icons.emoji_emotions),
      label: Text(
        widget.emojiButtonText ?? 'Emoji',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    // Nascondi i bottoni se c'è già contenuto
    if (_hasContent()) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.mode == UploaderMode.cameraGallery) ...[
          Expanded(child: _buildCameraButton()),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(child: _buildGalleryButton()),
        ] else ...[
          Expanded(child: _buildEmojiButton()),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(child: _buildGalleryButton()),
        ],
      ],
    );
  }

  Widget _buildRemoveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingM),
      child: TextButton.icon(
        onPressed: _handleRemove,
        icon: const Icon(Icons.delete_outline),
        label: Text(widget.removeButtonText ?? AppStrings.removeImage),
        style: TextButton.styleFrom(foregroundColor: AppColors.error),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!widget.enabled || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      String? imagePath;

      if (widget.preserveAspectRatio) {
        // Comportamento originale per carte fedeltà (preserva proporzioni)
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: widget.maxWidth.toDouble(),
          maxHeight: widget.maxHeight.toDouble(),
          imageQuality: widget.imageQuality,
        );
        imagePath = image?.path;
      } else {
        // Default: usa il servizio di immagini con crop 1:1
        final imageService = ref.read(imageServiceProvider);
        imagePath = await imageService.pickAndSaveImage(cropSquare: true);
      }

      if (imagePath != null) {
        // Modalità emojiGallery - imposta come immagine personalizzata
        if (widget.mode == UploaderMode.emojiGallery) {
          if (widget.onIconTypeChanged != null) {
            widget.onIconTypeChanged!(IconType.custom);
          }
        }
        // Per entrambe le modalità: aggiorna il valore
        if (widget.onValueChanged != null) {
          widget.onValueChanged!(imagePath);
        }
      }
    } catch (e) {
      final errorMessage = 'Errore nella selezione dell\'immagine: $e';

      if (widget.onError != null) {
        widget.onError!(errorMessage);
      } else {
        // Fallback: mostra SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEmojiPicker() async {
    if (!widget.enabled || _isLoading) return;

    try {
      await EmojiPickerDialog.show(
        context,
        onEmojiSelected: (emoji) {
          if (widget.onIconTypeChanged != null) {
            widget.onIconTypeChanged!(IconType.emoji);
          }
          if (widget.onValueChanged != null) {
            widget.onValueChanged!(emoji);
          }
        },
      );
    } catch (e) {
      final errorMessage = 'Errore nella selezione dell\'emoji: $e';
      if (widget.onError != null) {
        widget.onError!(errorMessage);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleRemove() {
    if (widget.onValueRemoved != null) {
      widget.onValueRemoved!();
    }
  }
}

/// 🎛️ **AppImageUploaderController** - Controller per controllo avanzato
///
/// Classe helper per gestire lo stato dell'uploader dall'esterno
class AppImageUploaderController {
  String? _value;
  final List<VoidCallback> _listeners = [];

  String? get value => _value;
  bool get hasValue => _value != null;

  set value(String? newValue) {
    if (_value != newValue) {
      _value = newValue;
      _notifyListeners();
    }
  }

  void setValue(String newValue) => value = newValue;
  void removeValue() => value = null;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
