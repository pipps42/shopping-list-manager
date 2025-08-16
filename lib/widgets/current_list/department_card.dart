import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import '../../models/list_item_with_product.dart';
import 'product_list_tile.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/universal_icon.dart';

class DepartmentCard extends StatefulWidget {
  final Department department;
  final List<ListItemWithProduct> items;
  final bool readOnly;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.items,
    this.readOnly = false,
  });

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _sizeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: -0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.vertical,
              axisAlignment: -1.0,
              child: Column(
                children: widget.items
                    .map(
                      (item) => ProductListTile(
                        item: item,
                        readOnly: widget.readOnly,
                      ),
                    )
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
          color: AppColors.secondary.withValues(alpha: 0.4),
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
                widget.department.name,
                style: const TextStyle(
                  fontSize: AppConstants.fontXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStats(context),
            const SizedBox(width: AppConstants.spacingS),
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _iconAnimation.value * 3.14159 * 2,
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
    return UniversalIcon(
      iconType: widget.department.iconType,
      iconValue: widget.department.iconValue,
      size: AppConstants.imageXL,
      fallbackIcon: Icons.store,
      fallbackColor: AppColors.secondary,
    );
  }

  Widget _buildStats(BuildContext context) {
    final total = widget.items.length;
    final completed = widget.items
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
        color: AppColors.textPrimary(context).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Text(
        widget.readOnly ? '$total' : '$completed/$total',
        style: TextStyle(
          fontSize: AppConstants.fontL,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnSecondary(context),
        ),
      ),
    );
  }
}
