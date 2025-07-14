class Department {
  final int? id;
  final String name;
  final int orderIndex;
  final String? imagePath;

  Department({
    this.id,
    required this.name,
    required this.orderIndex,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order_index': orderIndex,
      'image_path': imagePath,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      orderIndex: map['order_index']?.toInt() ?? 0,
      imagePath: map['image_path'],
    );
  }

  Department copyWith({
    int? id,
    String? name,
    int? orderIndex,
    String? imagePath,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}