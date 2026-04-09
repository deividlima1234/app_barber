class PrizeRedemptionDto {
  final Long? id;
  final String prizeName;
  final String prizeDescription;
  final String status; // PENDING, DELIVERED
  final DateTime createdAt;

  PrizeRedemptionDto({
    this.id,
    required this.prizeName,
    required this.prizeDescription,
    required this.status,
    required this.createdAt,
  });

  factory PrizeRedemptionDto.fromJson(Map<String, dynamic> json) {
    return PrizeRedemptionDto(
      id: json['id'],
      prizeName: json['prize']['name'],
      prizeDescription: json['prize']['description'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

typedef Long = int;
