import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import '../../utils/constants.dart';

class DepartmentTileWidget extends StatelessWidget {
  final Department department;
  final int index;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const DepartmentTileWidget({
    super.key,
    required this.department,
    required this.index,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('dept_${department.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle per drag
            Icon(Icons.drag_handle, color: Colors.grey[600]),
            const SizedBox(width: 8),
            // Immagine reparto
            _buildDepartmentImage(),
          ],
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Posizione: ${index + 1}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Visualizza prodotti'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifica'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Elimina', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap ?? onView,
      ),
    );
  }

  Widget _buildDepartmentImage() {
    if (department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(department.imagePath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultDepartmentIcon(),
        ),
      );
    }
    return _buildDefaultDepartmentIcon();
  }

  Widget _buildDefaultDepartmentIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store, size: 24, color: Colors.blue),
    );
  }
}
