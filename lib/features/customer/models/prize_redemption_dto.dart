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
    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return PrizeRedemptionDto(
      id: json['id'] as int?,
      prizeName: json['prizeName'] ?? json['prize']?['name'] ?? 'Premio',
      prizeDescription: json['prizeDescription'] ?? json['prize']?['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: parsedDate,
    );
  }
}

typedef Long = int;
