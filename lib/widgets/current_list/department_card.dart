import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department_with_products.dart';
import 'product_list_tile.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentWithProducts department;

  const DepartmentCard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildDepartmentImage(context),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              department.department.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildDepartmentImage(BuildContext context) {
    if (department.department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(department.department.imagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheWidth: 100,
          cacheHeight: 100,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultIcon(context),
        ),
      );
    }
    return _buildDefaultIcon(context);
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store, color: Colors.white, size: 20),
    );
  }

  Widget _buildStats() {
    final total = department.items.length;
    final completed = department.items.where((item) => item.isChecked).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$completed/$total',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
