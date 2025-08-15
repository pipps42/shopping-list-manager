import 'package:flutter/material.dart';

class ValidatedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final bool isRequired;
  final String? requiredMessage;
  final bool requireMinThreeLetters;
  final String? minThreeLettersMessage;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const ValidatedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.isRequired = false,
    this.requiredMessage,
    this.requireMinThreeLetters = false,
    this.minThreeLettersMessage,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<ValidatedTextField> createState() => ValidatedTextFieldState();
}

class ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_hasBeenTouched) {
      setState(() {
        _hasBeenTouched = true;
      });
      _validateField(_controller.text);
    }
  }

  void _validateField(String value) {
    String? error;

    // Validazione campo obbligatorio
    if (widget.isRequired && value.trim().isEmpty) {
      error = widget.requiredMessage ?? 'Campo obbligatorio';
    }
    // Validazione minimo 3 lettere per parola
    else if (widget.requireMinThreeLetters && !_hasMinThreeLettersWord(value)) {
      error = widget.minThreeLettersMessage ?? 'Almeno una parola di 3 lettere';
    }
    // Validazione personalizzata
    else if (widget.validator != null) {
      error = widget.validator!(value);
    }

    if (_errorText != error) {
      setState(() {
        _errorText = error;
      });
    }
  }

  void _onTextChanged(String value) {
    // Se c'è un errore e l'utente sta digitando, rivalidare in tempo reale
    if (_errorText != null || _hasBeenTouched) {
      _validateField(value);
    }

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onChanged: _onTextChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: _errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: const OutlineInputBorder(),
        errorBorder: hasError
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : null,
        focusedErrorBorder: hasError
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : null,
      ),
    );
  }

  // Metodi pubblici per controllo esterno
  String get text => _controller.text;

  void setText(String text) {
    _controller.text = text;
  }

  void clearError() {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
  }

  bool validate() {
    setState(() {
      _hasBeenTouched = true;
    });
    _validateField(_controller.text);
    return _errorText == null;
  }

  void focus() {
    _focusNode.requestFocus();
  }

  bool _hasMinThreeLettersWord(String value) {
    if (value.trim().isEmpty) return false;

    // Dividi il testo in parole (solo lettere)
    final words = value.trim().split(RegExp(r'\s+'));

    for (final word in words) {
      // Conta solo le lettere nella parola
      final letters = word.replaceAll(
        RegExp(
          r'[^a-zA-ZàáâäãåæćčçĉèéêëđìíîïłñòóôöõøšùúûüýÿžÀÁÂÄÃÅÆĆČÇĈÈÉÊËĐÌÍÎÏŁÑÒÓÔÖÕØŠÙÚÛÜÝŸŽ]',
        ),
        '',
      );
      if (letters.length >= 3) {
        return true;
      }
    }

    return false;
  }
}
