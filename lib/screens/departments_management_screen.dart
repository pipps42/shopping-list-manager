import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/departments_provider.dart';
import '../models/department.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/departments_management/department_tile.dart';
import '../widgets/departments_management/department_form_dialog.dart';
import '../widgets/departments_management/delete_department_dialog.dart';
import '../widgets/departments_management/reorder_instructions.dart';
import 'department_detail_screen.dart';

class DepartmentsManagementScreen extends ConsumerWidget {
  const DepartmentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsState = ref.watch(departmentsProvider);

    return Scaffold(
      body: departmentsState.when(
        data: (departments) => _buildDepartmentsList(context, ref, departments),
        loading: () =>
            const LoadingWidget(message: AppStrings.loadingDepartments),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento dei reparti: $error',
          onRetry: () => ref.invalidate(departmentsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "departments_management_fab",
        onPressed: () => _showAddDepartmentDialog(context, ref),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary(context),
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
        title: AppStrings.emptyDepartments,
        subtitle: AppStrings.emptyDepartmentsSubtitle,
      );
    }

    return CustomScrollView(
      slivers: [
        // Header a tutta larghezza che scrolla via
        SliverToBoxAdapter(child: const ReorderInstructionsWidget()),

        // Lista con padding solo sui tiles
        SliverReorderableList(
          itemBuilder: (context, index) {
            final department = departments[index];
            return ReorderableDelayedDragStartListener(
              key: Key('dept_${department.id}'),
              index: index,
              child: DepartmentTileWidget(
                department: department,
                index: index,
                onView: () => _navigateToDepartmentDetail(context, department),
                onEdit: () =>
                    _showEditDepartmentDialog(context, ref, department),
                onDelete: () =>
                    _showDeleteDepartmentDialog(context, ref, department),
              ),
            );
          },
          itemCount: departments.length,
          onReorder: (oldIndex, newIndex) =>
              _onReorder(ref, departments, oldIndex, newIndex),
        ),

        // Spazio per FAB
        SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.listBottomSpacing),
        ),
      ],
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

  // Dialog Methods
  void _showAddDepartmentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => DepartmentFormDialog(
        onSave: (name, iconType, iconValue) async {
          await ref.read(departmentsProvider.notifier).addDepartment(name);

          // Se c'è un'icona, aggiorna il reparto appena creato
          if (iconValue != null) {
            final departments = ref.read(departmentsProvider).value ?? [];
            final newDept = departments.lastWhere((d) => d.name == name);
            await ref
                .read(departmentsProvider.notifier)
                .updateDepartment(
                  newDept.copyWith(iconType: iconType, iconValue: iconValue),
                );
          }
        },
      ),
    );
  }

  void _showEditDepartmentDialog(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    showDialog(
      context: context,
      builder: (context) => DepartmentFormDialog(
        department: department,
        onSave: (name, iconType, iconValue) async {
          await ref
              .read(departmentsProvider.notifier)
              .updateDepartment(
                department.copyWith(
                  name: name,
                  iconType: iconType,
                  iconValue: iconValue,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteDepartmentDialog(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteDepartmentDialog(
        department: department,
        onConfirmDelete: () async {
          await ref
              .read(departmentsProvider.notifier)
              .deleteDepartment(department.id!);
        },
      ),
    );
  }
}
