import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../models/tutorial_config.dart';
import 'tutorial_content.dart';

enum TutorialDialogResult { completed, skipped, cancelled, neverShowAgain }

class TutorialDialog extends StatefulWidget {
  final TutorialConfig config;

  const TutorialDialog({super.key, required this.config});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPageIndex == widget.config.pages.length - 1;
  bool get _isFirstPage => _currentPageIndex == 0;
  bool get _hasSinglePage => widget.config.pages.length == 1;

  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (!_isFirstPage) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _completeTutorial() {
    Navigator.of(context).pop(TutorialDialogResult.completed);
  }

  void _cancelTutorial() {
    Navigator.of(context).pop(TutorialDialogResult.cancelled);
  }

  void _neverShowAgain() {
    Navigator.of(context).pop(TutorialDialogResult.neverShowAgain);
  }

  Widget _buildPageIndicators() {
    if (widget.config.pages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.config.pages.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPageIndex
                  ? AppColors.secondary
                  : AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.isEmpty) {
      return BaseDialog(
        title: 'Tutorial non disponibile',
        content: const Text(
          'Non ci sono contenuti tutorial per questa sezione.',
        ),
        actions: [DialogAction.cancel(onPressed: _cancelTutorial)],
      );
    }

    return BaseDialog(
      title: widget.config.title,
      subtitle: widget.config.subtitle,
      titleIcon: Icons.school,
      hasColoredHeader: true,
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.85,
      content: Column(
        children: [
          // Indicatori di pagina fissi in alto
          _buildPageIndicators(),
          
          // Contenuto scrollabile
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.config.pages.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: TutorialContent(
                    page: widget.config.pages[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      customActions: Row(
        children: _buildCustomActions(),
      ),
    );
  }


  List<Widget> _buildCustomActions() {
    // Pulsante "Non mostrare più" sempre presente - layout migliorato
    final neverShowButton = SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: _neverShowAgain,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary(context),
          side: BorderSide(color: AppColors.textSecondary(context)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text(
          'Non mostrare più',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );

    if (_hasSinglePage) {
      // Layout per pagina singola
      return [
        neverShowButton,
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _completeTutorial,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ho capito!'),
            ),
          ),
        ),
      ];
    } else if (_isFirstPage) {
      // Layout per prima pagina
      return [
        neverShowButton,
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Avanti'),
            ),
          ),
        ),
      ];
    } else if (_isLastPage) {
      // Layout per ultima pagina
      return [
        neverShowButton,
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextButton(
              onPressed: _previousPage,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
              ),
              child: const Text('Indietro'),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _completeTutorial,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Completato!'),
            ),
          ),
        ),
      ];
    } else {
      // Layout per pagine intermedie
      return [
        neverShowButton,
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextButton(
              onPressed: _previousPage,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
              ),
              child: const Text('Indietro'),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Avanti'),
            ),
          ),
        ),
      ];
    }
  }
}
