import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

/// 📸 **AppImageUploader** - Widget completo per upload e gestione immagini

enum ButtonsLayout { below, beside }

class AppImageUploader extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String>? onImageSelected;
  final VoidCallback? onImageRemoved;
  final ValueChanged<String>? onError;
  final String? title;
  final IconData fallbackIcon;
  final double previewHeight;
  final double? previewWidth;
  final bool enabled;
  final ButtonsLayout buttonsLayout;
  final int imageQuality;
  final int maxWidth;
  final int maxHeight;
  final String? cameraButtonText;
  final String? galleryButtonText;
  final String? removeButtonText;
  final String? emptyStateText;

  const AppImageUploader({
    super.key,
    this.imagePath,
    this.onImageSelected,
    this.onImageRemoved,
    this.onError,
    this.title,
    this.fallbackIcon = Icons.add_photo_alternate_outlined,
    this.previewHeight = 120.0,
    this.previewWidth,
    this.enabled = true,
    this.buttonsLayout = ButtonsLayout.below,
    this.imageQuality = AppConstants.imageQuality,
    this.maxWidth = AppConstants.maxImageWidth,
    this.maxHeight = AppConstants.maxImageHeight,
    this.cameraButtonText,
    this.galleryButtonText,
    this.removeButtonText,
    this.emptyStateText,
  });

  @override
  State<AppImageUploader> createState() => _AppImageUploaderState();
}

class _AppImageUploaderState extends State<AppImageUploader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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

        // Pulsante rimuovi (se c'è un'immagine)
        if (widget.imagePath != null && widget.enabled && !_isLoading)
          _buildRemoveButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    final width = widget.previewWidth ?? 280.0;
    final height = widget.previewHeight;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context), width: 1.0),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        color: widget.imagePath == null
            ? AppColors.surface(context).withOpacity(0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: widget.imagePath == null
            ? _buildEmptyState()
            : _buildImageContent(),
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

  Widget _buildImageContent() {
    return Stack(
      children: [
        // Immagine
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: File(widget.imagePath!).existsSync()
              ? Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: AppConstants.imageCacheWidth,
                  cacheHeight: AppConstants.imageCacheHeight,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorState(),
                )
              : _buildErrorState(),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.overlay.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
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
          Flexible(child: _buildCameraButton()),
          const SizedBox(height: AppConstants.spacingS),
          Flexible(child: _buildGalleryButton()),
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

  Widget _buildActionButtons() {
    if (!widget.enabled || widget.imagePath != null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(child: _buildCameraButton()),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(child: _buildGalleryButton()),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingM),
      child: TextButton.icon(
        onPressed: _handleRemoveImage,
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
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: widget.maxWidth.toDouble(),
        maxHeight: widget.maxHeight.toDouble(),
        imageQuality: widget.imageQuality,
      );

      if (image != null && widget.onImageSelected != null) {
        widget.onImageSelected!(image.path);
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

  void _handleRemoveImage() {
    if (widget.onImageRemoved != null) {
      widget.onImageRemoved!();
    }
  }
}

/// 🎛️ **AppImageUploaderController** - Controller per controllo avanzato
///
/// Classe helper per gestire lo stato dell'uploader dall'esterno
class AppImageUploaderController {
  String? _imagePath;
  final List<VoidCallback> _listeners = [];

  String? get imagePath => _imagePath;
  bool get hasImage => _imagePath != null;

  set imagePath(String? path) {
    if (_imagePath != path) {
      _imagePath = path;
      _notifyListeners();
    }
  }

  void setImage(String path) => imagePath = path;
  void removeImage() => imagePath = null;

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
