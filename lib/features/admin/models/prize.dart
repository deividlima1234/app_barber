class Prize {
  final int? id;
  final String name;
  final String? description;
  final int weight;
  final int pointCost;
  final int? stock;
  final bool isActive;
  final bool isRespin;

  Prize({
    this.id,
    required this.name,
    this.description,
    this.weight = 10,
    this.pointCost = 0,
    this.stock,
    this.isActive = true,
    this.isRespin = false,
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      weight: json['weight'] ?? 10,
      pointCost: json['pointCost'] ?? 0,
      stock: json['stock'],
      isActive: json['isActive'] ?? true,
      isRespin: json['isRespin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weight': weight,
      'pointCost': pointCost,
      'stock': stock,
      'isActive': isActive,
      'isRespin': isRespin,
    };
  }

  Prize copyWith({
    int? id,
    String? name,
    String? description,
    int? weight,
    int? pointCost,
    int? stock,
    bool? isActive,
    bool? isRespin,
  }) {
    return Prize(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      pointCost: pointCost ?? this.pointCost,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isRespin: isRespin ?? this.isRespin,
    );
  }
}
