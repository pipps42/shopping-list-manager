import '../utils/icon_types.dart';

// Sentinel value per distinguere "non specificato" da "null esplicito"
const Object _undefined = Object();

class Department {
  final int? id;
  final String name;
  final int orderIndex;
  final IconType iconType;
  final String? iconValue;

  Department({
    this.id,
    required this.name,
    required this.orderIndex,
    this.iconType = IconType.asset,
    this.iconValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order_index': orderIndex,
      'icon_type': iconType.value,
      'icon_value': iconValue,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      orderIndex: map['order_index']?.toInt() ?? 0,
      iconType: IconType.fromString(map['icon_type'] ?? 'asset'),
      iconValue: map['icon_value'],
    );
  }

  Department copyWith({
    int? id,
    String? name,
    int? orderIndex,
    IconType? iconType,
    Object? iconValue = _undefined,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      iconType: iconType ?? this.iconType,
      iconValue: iconValue == _undefined ? this.iconValue : iconValue as String?,
    );
  }
}
