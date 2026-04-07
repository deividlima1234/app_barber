class ServiceCatalogDto {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int pointsReward;
  final bool isActive;

  ServiceCatalogDto({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.pointsReward,
    required this.isActive,
  });

  factory ServiceCatalogDto.fromJson(Map<String, dynamic> json) {
    return ServiceCatalogDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      pointsReward: json['pointsReward'] as int,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'price': price,
      'pointsReward': pointsReward,
      'isActive': isActive,
    };
  }

  ServiceCatalogDto copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? pointsReward,
    bool? isActive,
  }) {
    return ServiceCatalogDto(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      pointsReward: pointsReward ?? this.pointsReward,
      isActive: isActive ?? this.isActive,
    );
  }
}
