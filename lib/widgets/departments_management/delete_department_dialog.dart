import 'package:flutter/material.dart';
import '../../models/department.dart';

class DeleteDepartmentDialog extends StatelessWidget {
  final Department department;
  final VoidCallback onConfirmDelete;

  const DeleteDepartmentDialog({
    super.key,
    required this.department,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Elimina Reparto'),
      content: Text(
        'Sei sicuro di voler eliminare "${department.name}"?\n\nTutti i prodotti associati verranno eliminati.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmDelete();
            Navigator.pop(context);

            // Mostra snackbar di conferma nel context parent
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reparto "${department.name}" eliminato'),
                  backgroundColor: Colors.green,
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Elimina'),
        ),
      ],
    );
  }
}
