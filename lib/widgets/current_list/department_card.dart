/* import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department_with_products.dart';
import 'product_list_tile.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentWithProducts department;

  const DepartmentCard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          ...department.items.map((item) => ProductListTile(item: item)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      child: Row(
        children: [
          _buildDepartmentImage(context),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              department.department.name,
              style: const TextStyle(
                fontSize: AppConstants.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildStats(context),
        ],
      ),
    );
  }

  Widget _buildDepartmentImage(BuildContext context) {
    if (department.department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(department.department.imagePath!),
          width: AppConstants.imageXL,
          height: AppConstants.imageXL,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultIcon(context),
        ),
      );
    }
    return _buildDefaultIcon(context);
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: AppConstants.imageXL,
      height: AppConstants.imageXL,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2), // ✅ Verde con opacità
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Icon(
        Icons.store,
        color: AppColors.secondary, // ✅ Verde pieno
        size: AppConstants.iconL,
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final total = department.items.length;
    final completed = department.items.where((item) => item.isChecked).length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        backgroundBlendMode: AppColors.isLight(context)
            ? BlendMode.darken
            : BlendMode.lighten,
        color: AppColors.textPrimary(context).withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Text(
        '$completed/$total',
        style: TextStyle(
          fontSize: AppConstants.fontL,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnSecondary(context),
        ),
      ),
    );
  }
}
 */

import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department_with_products.dart';
import 'product_list_tile.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class DepartmentCard extends StatefulWidget {
  final DepartmentWithProducts department;

  const DepartmentCard({super.key, required this.department});

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // ← Aggiunto AutomaticKeepAliveClientMixin

  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _sizeAnimation; // ← Aggiunta animazione per il size

  @override
  bool get wantKeepAlive => true; // ← Preserva lo stato quando esce dalla viewport

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // ← Animazione corretta: 0° quando espanso, -90° quando collassato
    _iconAnimation =
        Tween<double>(
          begin: 0.0, // Espanso: freccia verso il basso (0°)
          end: -0.25, // Collassato: freccia orizzontale (-90°)
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // ← Animazione per il size (0.0 = collassato, 1.0 = espanso)
    _sizeAnimation =
        Tween<double>(
          begin: 1.0, // Espanso
          end: 0.0, // Collassato
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Inizia espanso (controller a 0, size animation a 1.0)
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.reverse(); // ← Verso il basso quando espande
      } else {
        _animationController.forward(); // ← Orizzontale quando collassa
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ← Necessario per AutomaticKeepAliveClientMixin

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          // ← Sostituito AnimatedSize con SizeTransition per controllo migliore
          ClipRect(
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.vertical,
              axisAlignment:
                  -1.0, // ← Allineamento al top per collasso dall'alto verso il basso
              child: Column(
                children: widget.department.items
                    .map((item) => ProductListTile(item: item))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusL),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.4),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(AppConstants.radiusL),
            bottom: _isExpanded
                ? Radius.zero
                : const Radius.circular(AppConstants.radiusL),
          ),
        ),
        child: Row(
          children: [
            _buildDepartmentImage(context),
            const SizedBox(width: AppConstants.spacingL),
            Expanded(
              child: Text(
                widget.department.department.name,
                style: TextStyle(
                  fontSize: AppConstants.fontXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStats(context),
            const SizedBox(width: AppConstants.spacingS),
            // ← Icona con animazione corretta
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle:
                      _iconAnimation.value *
                      3.14159 *
                      2, // ← Conversione corretta a radianti
                  child: Icon(
                    Icons.expand_more,
                    color: AppColors.textPrimary(context),
                    size: AppConstants.iconM,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentImage(BuildContext context) {
    if (widget.department.department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(widget.department.department.imagePath!),
          width: AppConstants.imageXL,
          height: AppConstants.imageXL,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultIcon(context),
        ),
      );
    }
    return _buildDefaultIcon(context);
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: AppConstants.imageXL,
      height: AppConstants.imageXL,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Icon(
        Icons.store,
        color: AppColors.secondary,
        size: AppConstants.iconL,
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final total = widget.department.items.length;
    final completed = widget.department.items
        .where((item) => item.isChecked)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        backgroundBlendMode: AppColors.isLight(context)
            ? BlendMode.darken
            : BlendMode.lighten,
        color: AppColors.textPrimary(context).withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Text(
        '$completed/$total',
        style: TextStyle(
          fontSize: AppConstants.fontL,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnSecondary(context),
        ),
      ),
    );
  }
}
