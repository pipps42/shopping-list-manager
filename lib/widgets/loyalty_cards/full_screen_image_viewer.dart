// lib/widgets/loyalty_cards/full_screen_image_viewer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String cardName;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.cardName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        title: Text(cardName, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1,
            maxScale: 4.0,
            child: Center(
              child: File(imagePath).existsSync()
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorWidget(context),
                    )
                  : _buildErrorWidget(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: AppConstants.iconXXL * 2,
            color: Colors.white70,
          ),
          const SizedBox(height: AppConstants.spacingL),
          const Text(
            'Impossibile caricare l\'immagine',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Il file dell\'immagine potrebbe essere stato spostato o eliminato',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppConstants.fontL,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Torna indietro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
