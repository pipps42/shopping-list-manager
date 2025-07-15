import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/departments_provider.dart';
import '../providers/image_provider.dart';
import '../models/department.dart';
import '../utils/constants.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import 'department_detail_screen.dart';

class DepartmentsManagementScreen extends ConsumerWidget {
  const DepartmentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsState = ref.watch(departmentsProvider);

    return Scaffold(
      body: departmentsState.when(
        data: (departments) => _buildDepartmentsList(context, ref, departments),
        loading: () => const LoadingWidget(message: 'Caricamento reparti...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento dei reparti: $error',
          onRetry: () => ref.invalidate(departmentsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "departments_management_fab",
        onPressed: () => _showAddDepartmentDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDepartmentsList(
    BuildContext context,
    WidgetRef ref,
    List<Department> departments,
  ) {
    if (departments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.store_outlined,
        title: 'Nessun reparto',
        subtitle: 'Aggiungi il primo reparto con il pulsante +',
      );
    }

    return Column(
      children: [
        // Header con istruzioni
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: const Row(
            children: [
              Icon(Icons.drag_handle, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trascina per riordinare i reparti secondo il layout del supermercato',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        // Lista riordinabile
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: departments.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(ref, departments, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final department = departments[index];
              return _buildDepartmentTile(context, ref, department, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentTile(
    BuildContext context,
    WidgetRef ref,
    Department department,
    int index,
  ) {
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
            _buildDepartmentImage(department),
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
              case 'edit':
                _showEditDepartmentDialog(context, ref, department);
                break;
              case 'view':
                _navigateToDepartmentDetail(context, department);
                break;
              case 'delete':
                _showDeleteConfirmation(context, ref, department);
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
        onTap: () => _navigateToDepartmentDetail(context, department),
      ),
    );
  }

  Widget _buildDepartmentImage(Department department) {
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

  void _onReorder(
    WidgetRef ref,
    List<Department> departments,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final List<Department> reorderedDepartments = List.from(departments);
    final Department item = reorderedDepartments.removeAt(oldIndex);
    reorderedDepartments.insert(newIndex, item);

    // Aggiorna l'orderIndex per tutti i reparti
    for (int i = 0; i < reorderedDepartments.length; i++) {
      reorderedDepartments[i] = reorderedDepartments[i].copyWith(
        orderIndex: i + 1,
      );
    }

    ref
        .read(departmentsProvider.notifier)
        .reorderDepartments(reorderedDepartments);
  }

  void _navigateToDepartmentDetail(
    BuildContext context,
    Department department,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartmentDetailScreen(department: department),
      ),
    );
  }

  void _showAddDepartmentDialog(BuildContext context, WidgetRef ref) {
    _showDepartmentDialog(context, ref, null);
  }

  void _showEditDepartmentDialog(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    _showDepartmentDialog(context, ref, department);
  }

  void _showDepartmentDialog(
    BuildContext context,
    WidgetRef ref,
    Department? department,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: department?.name ?? '',
    );
    String? selectedImagePath = department?.imagePath;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            department == null ? 'Nuovo Reparto' : 'Modifica Reparto',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome reparto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Sezione immagine
              Row(
                children: [
                  if (selectedImagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(selectedImagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cacheWidth: AppConstants.imageCacheWidth,
                        cacheHeight: AppConstants.imageCacheHeight,
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store, size: 30),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  final imagePath = await ref
                                      .read(imageServiceProvider)
                                      .pickAndSaveImage();
                                  if (imagePath != null) {
                                    selectedImagePath = imagePath;
                                  }
                                  setState(() => isLoading = false);
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scegli immagine'),
                        ),
                        if (selectedImagePath != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => selectedImagePath = null);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Rimuovi',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      if (department == null) {
                        // Nuovo reparto
                        await ref
                            .read(departmentsProvider.notifier)
                            .addDepartment(name);
                        if (selectedImagePath != null) {
                          // Trova il reparto appena creato e aggiorna l'immagine
                          final departments =
                              ref.read(departmentsProvider).value ?? [];
                          final newDept = departments.lastWhere(
                            (d) => d.name == name,
                          );
                          await ref
                              .read(departmentsProvider.notifier)
                              .updateDepartment(
                                newDept.copyWith(imagePath: selectedImagePath),
                              );
                        }
                      } else {
                        // Modifica reparto esistente
                        await ref
                            .read(departmentsProvider.notifier)
                            .updateDepartment(
                              department.copyWith(
                                name: name,
                                imagePath: selectedImagePath,
                              ),
                            );
                      }

                      Navigator.pop(context);
                    },
              child: Text(department == null ? 'Aggiungi' : 'Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () async {
              await ref
                  .read(departmentsProvider.notifier)
                  .deleteDepartment(department.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reparto "${department.name}" eliminato'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
