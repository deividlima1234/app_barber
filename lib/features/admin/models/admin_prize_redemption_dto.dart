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
    return AdminPrizeRedemptionDto(
      id: json['id'],
      customerEmail: json['user']['email'] ?? 'N/A',
      customerFullName: json['user']['fullName'] ?? 'Cliente',
      prizeName: json['prize']['name'],
      prizeDescription: json['prize']['description'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
