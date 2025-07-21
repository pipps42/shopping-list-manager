import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_search_bar.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class ProductFiltersWidget extends StatefulWidget {
  final List<Department> departments;
  final Function(String) onSearchChanged;
  final Function(int?) onDepartmentFilterChanged;
  final String initialSearchQuery;
  final int? initialSelectedDepartmentId;

  const ProductFiltersWidget({
    super.key,
    required this.departments,
    required this.onSearchChanged,
    required this.onDepartmentFilterChanged,
    this.initialSearchQuery = '',
    this.initialSelectedDepartmentId,
  });

  @override
  State<ProductFiltersWidget> createState() => _ProductFiltersWidgetState();
}

class _ProductFiltersWidgetState extends State<ProductFiltersWidget> {
  int? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.initialSelectedDepartmentId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        children: [
          // Barra di ricerca
          AppSearchBar(
            placeholder: AppStrings.searchPlaceholder,
            initialValue: widget.initialSearchQuery,
            onChanged: (value) => widget.onSearchChanged(value.toLowerCase()),
          ),
          const SizedBox(height: AppConstants.spacingL),
          // Filtro reparti
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Opzione "Tutti"
                Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacingS),
                  child: FilterChip(
                    label: const Text('Tutti'),
                    selected: _selectedDepartmentId == null,
                    selectedColor: AppColors.accent,
                    checkmarkColor: AppColors.textOnTertiary(context),
                    onSelected: (selected) {
                      setState(() {
                        _selectedDepartmentId = null;
                      });
                      widget.onDepartmentFilterChanged(null);
                    },
                  ),
                ),
                // Reparti
                ...widget.departments.map(
                  (dept) => Padding(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacingS,
                    ),
                    child: FilterChip(
                      label: Text(dept.name),
                      selected: _selectedDepartmentId == dept.id,
                      selectedColor: AppColors.accent,
                      checkmarkColor: AppColors.textOnTertiary(context),
                      onSelected: (selected) {
                        setState(() {
                          _selectedDepartmentId = selected ? dept.id : null;
                        });
                        widget.onDepartmentFilterChanged(_selectedDepartmentId);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
