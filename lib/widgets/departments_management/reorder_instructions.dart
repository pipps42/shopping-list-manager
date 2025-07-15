import 'package:flutter/material.dart';

class ReorderInstructionsWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const ReorderInstructionsWidget({
    super.key,
    this.text =
        'Trascina per riordinare i reparti secondo il layout del supermercato',
    this.icon = Icons.drag_handle,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.blue[50];
    final txtColor = textColor ?? Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, color: txtColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: txtColor, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
