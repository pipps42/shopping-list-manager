class Product {
  final int? id;
  final String name;
  final int departmentId;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.departmentId,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department_id': departmentId,
      'image_path': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      departmentId: map['department_id']?.toInt() ?? 0,
      imagePath: map['image_path'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    int? departmentId,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}