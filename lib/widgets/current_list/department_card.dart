import 'package:shopping_list_manager/utils/constants.dart';
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
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusL)),
      ),
      child: Row(
        children: [
          _buildDepartmentImage(context),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              department.department.name,
              style: const TextStyle(fontSize: AppConstants.fontXXL, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(department.department.imagePath!),
          width: AppConstants.imageM,
          height: AppConstants.imageM,
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
      width: AppConstants.imageM,
      height: AppConstants.imageM,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: const Icon(Icons.store, color: Colors.white, size: AppConstants.iconS),
    );
  }

  Widget _buildStats() {
    final total = department.items.length;
    final completed = department.items.where((item) => item.isChecked).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS, vertical: AppConstants.paddingXS),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Text(
        '$completed/$total',
        style: const TextStyle(fontSize: AppConstants.fontM, fontWeight: FontWeight.bold),
      ),
    );
  }
}
