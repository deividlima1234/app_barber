class AdminPrizeRedemptionDto {
  final int id;
  final String customerEmail;
  final String customerFullName;
  final String prizeName;
  final String prizeDescription;
  final String status;
  final DateTime createdAt;

  AdminPrizeRedemptionDto({
    required this.id,
    required this.customerEmail,
    required this.customerFullName,
    required this.prizeName,
    required this.prizeDescription,
    required this.status,
    required this.createdAt,
  });

  factory AdminPrizeRedemptionDto.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Parsing JSON: $json");
    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AdminPrizeRedemptionDto(
      id: json['id'] ?? 0,
      customerEmail: json['customerEmail'] ?? 'N/A',
      customerFullName: json['customerFullName'] ?? 'Cliente',
      prizeName: json['prizeName'] ?? 'Premio',
      prizeDescription: json['prizeDescription'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: parsedDate,
    );
  }
}
