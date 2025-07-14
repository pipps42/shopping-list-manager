import 'department.dart';
import 'list_item.dart';

class DepartmentWithProducts {
  final Department department;
  final List<ListItem> items;

  DepartmentWithProducts({
    required this.department,
    required this.items,
  });

  bool get hasItems => items.isNotEmpty;
  bool get hasCompletedItems => items.any((item) => item.isChecked);
  bool get hasActiveItems => items.any((item) => !item.isChecked);
}