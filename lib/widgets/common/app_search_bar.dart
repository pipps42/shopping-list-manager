import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

/// 🔍 **AppSearchBar** - Widget di ricerca riutilizzabile e flessibile
class AppSearchBar extends StatefulWidget {
  final String? placeholder;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSubmit;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final bool autofocus;
  final bool? showClearButton;
  final bool enabled;
  final TextStyle? textStyle;

  const AppSearchBar({
    super.key,
    this.placeholder,
    this.initialValue = '',
    this.onChanged,
    this.onClear,
    this.onSubmit,
    this.controller,
    this.focusNode,
    this.decoration,
    this.autofocus = false,
    this.showClearButton,
    this.enabled = true,
    this.textStyle,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  // Flag per sapere se stiamo usando controller/focusNode esterni
  bool _isExternalController = false;
  bool _isExternalFocusNode = false;

  @override
  void initState() {
    super.initState();

    // Inizializza controller (interno o esterno)
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isExternalController = true;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isExternalController = false;
    }

    // Inizializza focus node (interno o esterno)
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isExternalFocusNode = true;
    } else {
      _focusNode = FocusNode();
      _isExternalFocusNode = false;
    }

    // Stato iniziale del testo
    _hasText = _controller.text.isNotEmpty;

    // Listener per aggiornare lo stato del clear button
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Rimuovi listener
    _controller.removeListener(_onTextChanged);

    // Disponi solo se sono controller/focusNode interni
    if (!_isExternalController) {
      _controller.dispose();
    }
    if (!_isExternalFocusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    // Chiama callback esterno
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _clearText() {
    _controller.clear();
    _clearFocus();

    // Chiama callback esterno
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  void _clearFocus() {
    _focusNode.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _onSubmit() {
    _clearFocus();
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showClear = widget.showClearButton ?? _hasText;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      style: widget.textStyle,
      decoration: widget.decoration ?? _buildDefaultDecoration(showClear),
      onTapOutside: (_) => _clearFocus(),
      onEditingComplete: _onSubmit,
      onSubmitted: (_) => _onSubmit(),
    );
  }

  InputDecoration _buildDefaultDecoration(bool showClear) {
    return InputDecoration(
      hintText: widget.placeholder ?? AppStrings.searchPlaceholder,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: showClear
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: widget.enabled ? _clearText : null,
              tooltip: 'Cancella ricerca',
            )
          : null,

      // Border di default (unfocused)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.border(context), width: 1.0),
      ),

      // Border quando abilitato ma non in focus
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.border(context), width: 1.0),
      ),

      // Border colorato quando in focus (terziario/accent)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(
          color: AppColors.accent,
          width: 2.0, // Più spesso per evidenziare il focus
        ),
      ),

      // Border quando disabilitato
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(
          color: AppColors.border(context).withOpacity(0.5),
          width: 1.0,
        ),
      ),

      // Border in caso di errore (per futuro uso)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),

      // Border in focus durante errore
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),

      // Styling aggiuntivo
      isDense: true,
      enabled: widget.enabled,
      filled: true,
      fillColor: widget.enabled
          ? AppColors.surface(context)
          : AppColors.surface(context).withOpacity(0.5),

      // Colori delle icone
      prefixIconColor: AppColors.iconSecondary(context),
      suffixIconColor: AppColors.iconSecondary(context),

      // Stile del testo hint
      hintStyle: TextStyle(
        color: AppColors.textSecondary(context),
        fontSize: AppConstants.fontL,
      ),

      // Content padding per allineamento perfetto
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
    );
  }
}

/// 🎯 **AppSearchBarController** - Helper per controllo avanzato
///
/// Classe di utility per controllare AppSearchBar dall'esterno
/// quando serve più controllo (es. per reset programmatici)
class AppSearchBarController {
  final TextEditingController textController;
  final FocusNode focusNode;

  AppSearchBarController({String initialText = ''})
    : textController = TextEditingController(text: initialText),
      focusNode = FocusNode();

  String get text => textController.text;
  set text(String value) => textController.text = value;

  bool get hasFocus => focusNode.hasFocus;

  void clear() => textController.clear();
  void focus() => focusNode.requestFocus();
  void unfocus() => focusNode.unfocus();

  void dispose() {
    textController.dispose();
    focusNode.dispose();
  }
}
