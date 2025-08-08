import '../utils/icon_types.dart';

// Sentinel value per distinguere "non specificato" da "null esplicito"
const Object _undefined = Object();

class Product {
  final int? id;
  final String name;
  final int departmentId;
  final IconType iconType;
  final String? iconValue;

  Product({
    this.id,
    required this.name,
    required this.departmentId,
    this.iconType = IconType.asset,
    this.iconValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department_id': departmentId,
      'icon_type': iconType.value,
      'icon_value': iconValue,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      departmentId: map['department_id']?.toInt() ?? 0,
      iconType: IconType.fromString(map['icon_type'] ?? 'asset'),
      iconValue: map['icon_value'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    int? departmentId,
    IconType? iconType,
    Object? iconValue = _undefined,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      iconType: iconType ?? this.iconType,
      iconValue: iconValue == _undefined ? this.iconValue : iconValue as String?,
    );
  }
}
