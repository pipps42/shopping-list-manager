import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import '../models/tutorial_page.dart';

class TutorialContent extends StatelessWidget {
  final TutorialPage page;

  const TutorialContent({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (page.hasMedia) ...[
          _buildMediaContent(),
          const SizedBox(height: AppConstants.spacingL),
        ],
        
        Text(
          page.title,
          style: const TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingM),
        
        Text(
          page.description,
          style: const TextStyle(
            fontSize: AppConstants.fontL,
            height: 1.5,
          ),
        ),
      ],
    );
  }


  Widget _buildMediaContent() {
    if (!page.hasMedia) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        color: Colors.grey.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: _buildMediaWidget(),
      ),
    );
  }

  Widget _buildMediaWidget() {
    if (page.mediaAsset == null || page.mediaType == null) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: Colors.grey,
        ),
      );
    }

    switch (page.mediaType!) {
      case MediaType.image:
      case MediaType.gif:
        return _buildImageWidget();
      case MediaType.video:
        return _buildVideoPlaceholder();
    }
  }

  Widget _buildImageWidget() {
    return Image.asset(
      page.mediaAsset!,
      fit: BoxFit.cover,
      cacheWidth: 400,
      cacheHeight: 200,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Immagine non disponibile',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              'Video tutorial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}