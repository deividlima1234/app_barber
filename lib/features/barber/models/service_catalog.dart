class ServiceCatalog {
  final int id;
  final String name;
  final double price;
  final int pointsReward;
  final bool isActive;

  ServiceCatalog({
    required this.id,
    required this.name,
    required this.price,
    required this.pointsReward,
    required this.isActive,
  });

  factory ServiceCatalog.fromJson(Map<String, dynamic> json) {
    return ServiceCatalog(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      pointsReward: json['pointsReward'],
      isActive: json['isActive'],
    );
  }
}
