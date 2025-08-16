import 'department.dart';

/// Enum per i tipi di operazioni sui dipartimenti
enum DepartmentEventType { created, updated, deleted }

/// Evento che rappresenta un'operazione atomica su un dipartimento
class DepartmentEvent {
  final DepartmentEventType type;
  final Department? department; // null per le operazioni di delete
  final int? departmentId; // per le operazioni di delete
  final String? oldName; // per le operazioni di update, se il nome è cambiato

  const DepartmentEvent({
    required this.type,
    this.department,
    this.departmentId,
    this.oldName,
  });

  /// Factory per evento di creazione dipartimento
  DepartmentEvent.created(Department this.department)
      : type = DepartmentEventType.created,
        departmentId = null,
        oldName = null;

  /// Factory per evento di aggiornamento dipartimento
  DepartmentEvent.updated(Department this.department, {this.oldName})
      : type = DepartmentEventType.updated,
        departmentId = null;

  /// Factory per evento di eliminazione dipartimento
  DepartmentEvent.deleted(int this.departmentId)
      : type = DepartmentEventType.deleted,
        department = null,
        oldName = null;

  @override
  String toString() {
    switch (type) {
      case DepartmentEventType.created:
        return 'DepartmentEvent.created(${department?.name})';
      case DepartmentEventType.updated:
        return 'DepartmentEvent.updated(${department?.name}${oldName != null ? ', oldName: $oldName' : ''})';
      case DepartmentEventType.deleted:
        return 'DepartmentEvent.deleted($departmentId)';
    }
  }
}