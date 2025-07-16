import 'package:flutter/material.dart';

/// ===== DIALOG CHE SI AGGIORNANO AUTOMATICAMENTE =====

class DialogHelper {
  /// Mostra AlertDialog che si aggiorna automaticamente
  static Future<T?> showResponsiveDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => _ResponsiveDialog(builder: builder),
    );
  }
}

/// Widget che rebuilda il dialog al cambio tema
class _ResponsiveDialog extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const _ResponsiveDialog({required this.builder});

  @override
  State<_ResponsiveDialog> createState() => _ResponsiveDialogState();
}

class _ResponsiveDialogState extends State<_ResponsiveDialog>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      setState(() {}); // Rebuilda al cambio tema
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
