import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
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
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  int? _selectedDepartmentId;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _searchFocusNode = FocusNode();
    _selectedDepartmentId = widget.initialSelectedDepartmentId;
    _hasSearchText = widget.initialSearchQuery.isNotEmpty;
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearFocus() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Barra di ricerca
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: AppStrings.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _hasSearchText // Mostra X solo quando c'è testo
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                        _clearFocus();
                      },
                      tooltip: 'Cancella ricerca',
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              widget.onSearchChanged(value.toLowerCase());
            },
            onTapOutside: (event) => _clearFocus(),
            onEditingComplete: () => _clearFocus(),
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
                    checkmarkColor: AppColors.textOnPrimary,
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
                      checkmarkColor: AppColors.textOnPrimary,
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
