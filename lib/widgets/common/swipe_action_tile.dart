import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class SwipeActionTile extends StatefulWidget {
  final Widget child;
  final bool isChecked; // stato che influisce sulla decorazione
  final double actionThreshold; // es. 0.4 = 40%
  final double removeThreshold; // es. 0.75 = 75%
  final VoidCallback? onCheck;
  final VoidCallback? onUncheck;
  final VoidCallback? onRemove;

  const SwipeActionTile({
    super.key,
    required this.child,
    required this.isChecked,
    this.actionThreshold = 0.4,
    this.removeThreshold = 0.65,
    this.onCheck,
    this.onUncheck,
    this.onRemove,
  });

  @override
  State<SwipeActionTile> createState() => _SwipeActionTileState();
}

class _SwipeActionTileState extends State<SwipeActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _anim;
  double _dx = 0.0; // posizione corrente (positiva = right, negativa = left)
  double _width = 1.0; // impostata da LayoutBuilder

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target, {VoidCallback? onCompleted}) {
    _anim?.removeListener(_animListener);
    _anim = Tween<double>(
      begin: _dx,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _anim!.addListener(_animListener);
    _controller.forward(from: 0.0).then((_) {
      _anim?.removeListener(_animListener);
      onCompleted?.call();
    });
  }

  void _animListener() {
    setState(() {
      _dx = _anim!.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = max(1.0, constraints.maxWidth);

        // calcoli percentuali (solo per uso interno)
        final double leftFraction = (-_dx / _width).clamp(0.0, 1.0);
        final double rightFraction = (_dx / _width).clamp(0.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) {
            _controller.stop();
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dx += details.delta.dx;
              _dx = _dx.clamp(-_width, _width);
            });
          },
          onHorizontalDragEnd: (details) {
            // setState(() => _isDragging = false);

            final double actThresh = widget.actionThreshold;

            // destra -> check
            if (rightFraction >= actThresh) {
              _animateTo(
                _width * 1.05,
                onCompleted: () {
                  widget.onCheck?.call();
                  _animateTo(0.0);
                },
              );
              return;
            }

            // sinistra oltre soglia -> remove (slide out)
            if (leftFraction >= widget.removeThreshold) {
              _animateTo(
                -_width * 1.05,
                onCompleted: () {
                  widget.onRemove?.call();
                },
              );
              return;
            }

            // piccolo swipe left -> uncheck
            if (leftFraction > actThresh) {
              _animateTo(
                0.0,
                onCompleted: () {
                  widget.onUncheck?.call();
                },
              );
              return;
            }

            // snap-back neutro
            _animateTo(0.0);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // background LIMITATO alla porzione liberata:
              if (_dx > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dx.clamp(0.0, _width),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL,
                    ),
                    color: AppColors.success,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.check,
                      color: AppColors.textOnPrimary(context),
                      size: AppConstants.iconL,
                    ),
                  ),
                ),
              if (_dx < 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: (-_dx).clamp(0.0, _width),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL,
                    ),
                    color: (leftFraction >= widget.removeThreshold)
                        ? AppColors.error
                        : AppColors.swipeDelete,
                    alignment: Alignment.centerRight,
                    child: Icon(
                      (leftFraction >= widget.removeThreshold)
                          ? Icons.close
                          : Icons.undo,
                      color: AppColors.textOnPrimary(context),
                      size: AppConstants.iconL,
                    ),
                  ),
                ),

              Transform.translate(
                offset: Offset(_dx, 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: widget.isChecked
                        ? AppColors.completedOverlay
                        : AppColors.cardBackground(context),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
