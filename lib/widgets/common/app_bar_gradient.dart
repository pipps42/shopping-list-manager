import 'package:flutter/material.dart';
import '../../utils/color_palettes.dart';

/// AppBar standardizzata con gradient e drawer logic
class AppBarGradient extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final Widget? subtitle;
  final List<Widget>? actions;
  final bool showDrawer;
  final VoidCallback? onDrawerPressed;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Color>? gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  const AppBarGradient({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showDrawer = false,
    this.onDrawerPressed,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      actions: actions,
      leading: _buildLeading(context),
      automaticallyImplyLeading:
          automaticallyImplyLeading && leading == null && !showDrawer,
      flexibleSpace: _buildGradientBackground(context),
      foregroundColor: AppColors.textOnPrimary(context),
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  /// Costruisce il titolo, gestendo subtitle se presente
  Widget _buildTitle(BuildContext context) {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [_buildTitleWidget(context), subtitle!],
      );
    }

    return _buildTitleWidget(context);
  }

  /// Converte title in Widget se è String
  Widget _buildTitleWidget(BuildContext context) {
    if (title is String) {
      return Text(
        title as String,
        style: TextStyle(
          color: AppColors.textOnPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return title as Widget;
  }

  /// Costruisce il leading widget (drawer button, back button, o custom)
  Widget? _buildLeading(BuildContext context) {
    // Se c'è un leading personalizzato, usalo
    if (leading != null) {
      return leading;
    }

    // Se showDrawer è true, crea il drawer button
    if (showDrawer) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onDrawerPressed ?? () => _openDrawer(context),
        tooltip: 'Apri menu',
      );
    }

    // Altrimenti lascia che AppBar gestisca automaticamente
    return null;
  }

  /// Logica standard per aprire il drawer con fallback
  void _openDrawer(BuildContext context) {
    try {
      Scaffold.of(context).openDrawer();
    } catch (e) {
      // Fallback: trova manualmente il Scaffold parent
      final scaffoldState = context.findAncestorStateOfType<ScaffoldState>();
      scaffoldState?.openDrawer();
    }
  }

  /// Costruisce il background con gradient
  Widget _buildGradientBackground(BuildContext context) {
    final colors =
        gradientColors ??
        [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
      ),
    );
  }
}

/// Convenienza per AppBar con menu
class AppBarGradientWithPopupMenu<T> extends StatelessWidget
    implements PreferredSizeWidget {
  final dynamic title;
  final Widget? subtitle;
  final bool showDrawer;
  final VoidCallback? onDrawerPressed;
  final List<PopupMenuEntry<T>> menuItems;
  final void Function(T)? onMenuSelected;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppBarGradientWithPopupMenu({
    super.key,
    required this.title,
    this.subtitle,
    this.showDrawer = false,
    this.onDrawerPressed,
    required this.menuItems,
    this.onMenuSelected,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBarGradient(
      title: title,
      subtitle: subtitle,
      showDrawer: showDrawer,
      onDrawerPressed: onDrawerPressed,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        PopupMenuButton<T>(
          onSelected: onMenuSelected,
          itemBuilder: (context) => menuItems,
          tooltip: 'Menu opzioni',
        ),
      ],
    );
  }
}
