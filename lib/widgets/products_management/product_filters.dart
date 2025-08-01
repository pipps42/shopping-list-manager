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
  late ScrollController _scrollController;
  final Map<int?, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.initialSelectedDepartmentId;
    _scrollController = ScrollController();
    // Crea la chiave per il chip "Tutti"
    _chipKeys[null] = GlobalKey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTag(
    int? selectedDepartmentId,
    List<Department> departments,
  ) {
    // Non fare nulla se il controller non è ancora collegato
    if (!_scrollController.hasClients) return;

    // Se selectedDepartmentId è null (opzione "Tutti"), scorri all'inizio
    if (selectedDepartmentId == null) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Ottieni la chiave del chip selezionato
    final chipKey = _chipKeys[selectedDepartmentId];
    if (chipKey?.currentContext == null) return;

    // Ottieni la posizione del chip rispetto al widget principale
    final RenderBox chipRenderBox =
        chipKey!.currentContext!.findRenderObject() as RenderBox;
    final chipPosition = chipRenderBox.localToGlobal(Offset.zero);

    // Ottieni la posizione del ScrollView
    final scrollViewContext = context;
    final RenderBox scrollViewRenderBox =
        scrollViewContext.findRenderObject() as RenderBox;
    final scrollViewPosition = scrollViewRenderBox.localToGlobal(Offset.zero);

    // Calcola la posizione relativa del chip nel ScrollView
    final relativePosition = chipPosition.dx - scrollViewPosition.dx;

    // Ottieni anche la larghezza del chip per capire se è completamente visibile
    final chipWidth = chipRenderBox.size.width;
    final scrollViewWidth = scrollViewRenderBox.size.width;

    // Calcola se il chip è completamente visibile
    final chipEndPosition = relativePosition + chipWidth;
    final isFullyVisible =
        relativePosition >= 20 && chipEndPosition <= scrollViewWidth - 20;

    // Se il chip è già completamente visibile nella posizione ideale, non fare nulla
    if (isFullyVisible && relativePosition >= 20 && relativePosition <= 50)
      return;

    // Se siamo già al massimo scroll e il chip è completamente visibile, non fare nulla
    final currentScrollPosition = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (currentScrollPosition >= maxScrollExtent - 15 && isFullyVisible) return;

    // Calcola quanto scrollare per portare il chip all'inizio
    final targetScrollPosition =
        currentScrollPosition +
        relativePosition -
        40; // -40px di margine (aumentato)

    // Assicurati di non superare i limiti
    final finalTargetPosition = targetScrollPosition > maxScrollExtent
        ? maxScrollExtent
        : (targetScrollPosition < 0 ? 0.0 : targetScrollPosition);

    _scrollController.animateTo(
      finalTargetPosition.toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Crea le chiavi per i reparti se non esistono già
    for (final dept in widget.departments) {
      _chipKeys.putIfAbsent(dept.id, () => GlobalKey());
    }

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
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Opzione "Tutti"
                Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacingS),
                  child: FilterChip(
                    key: _chipKeys[null],
                    label: const Text('Tutti'),
                    selected: _selectedDepartmentId == null,
                    selectedColor: AppColors.accent,
                    checkmarkColor: AppColors.textOnTertiary(context),
                    onSelected: (selected) {
                      setState(() {
                        _selectedDepartmentId = null;
                      });
                      widget.onDepartmentFilterChanged(null);
                      // Trigger scroll animation after the state update
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedTag(null, widget.departments);
                      });
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
                      key: _chipKeys[dept.id],
                      label: Text(dept.name),
                      selected: _selectedDepartmentId == dept.id,
                      selectedColor: AppColors.accent,
                      checkmarkColor: AppColors.textOnTertiary(context),
                      onSelected: (selected) {
                        final newSelectedId = selected ? dept.id : null;
                        setState(() {
                          _selectedDepartmentId = newSelectedId;
                        });
                        widget.onDepartmentFilterChanged(_selectedDepartmentId);
                        // Trigger scroll animation after the state update
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToSelectedTag(
                            newSelectedId,
                            widget.departments,
                          );
                        });
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
