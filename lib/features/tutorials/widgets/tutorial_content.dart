import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import '../models/tutorial_page.dart';

class TutorialContent extends StatelessWidget {
  final TutorialPage page;

  const TutorialContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          style: const TextStyle(fontSize: AppConstants.fontL, height: 1.5),
        ),

        if (page.hasMedia) ...[
          const SizedBox(height: AppConstants.spacingL),
          _buildMediaContent(),
        ],
      ],
    );
  }

  Widget _buildMediaContent() {
    if (!page.hasMedia) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
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
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
      );
    }

    switch (page.mediaType!) {
      case MediaType.image:
      case MediaType.gif:
        return _buildImageWidget();
      case MediaType.video:
        return _buildVideoPlaceholder();
      case MediaType.webm:
        return _buildWebmVideoWidget();
    }
  }

  Widget _buildImageWidget() {
    return Image.asset(
      page.mediaAsset!,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Immagine non disponibile',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
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
            Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'Video tutorial',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebmVideoWidget() {
    return WebmVideoPlayer(videoAsset: page.mediaAsset!);
  }
}

class WebmVideoPlayer extends StatefulWidget {
  final String videoAsset;

  const WebmVideoPlayer({super.key, required this.videoAsset});

  @override
  State<WebmVideoPlayer> createState() => _WebmVideoPlayerState();
}

class _WebmVideoPlayerState extends State<WebmVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        widget.videoAsset,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Configura loop e volume, ma non avviare automaticamente
        _controller.setLooping(true);
        _controller.setVolume(0.0); // Muted come le GIF
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _startVideo() {
    if (!mounted || _isDisposed) return;
    if (_controller.value.isInitialized && !_controller.value.isPlaying) {
      _controller.play();
    }
  }

  void _pauseVideo() {
    if (!mounted || _isDisposed) return;
    if (_controller.value.isInitialized && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Video non disponibile',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return VisibilityDetector(
      key: Key('webm_video_${widget.videoAsset}'),
      onVisibilityChanged: (info) {
        // Video diventa visibile quando almeno il 70% è sullo schermo
        if (info.visibleFraction > 0.7) {
          _startVideo();
        } else {
          _pauseVideo();
        }
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
