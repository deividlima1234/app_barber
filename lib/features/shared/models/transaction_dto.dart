class TransactionDto {
  final String customerName;
  final String? barberName;
  final String serviceName;
  final double amountCharged;
  final int pointsAwarded;
  final DateTime date;

  TransactionDto({
    required this.customerName,
    this.barberName,
    required this.serviceName,
    required this.amountCharged,
    required this.pointsAwarded,
    required this.date,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      customerName: json['customerName'] ?? 'Desconocido',
      barberName: json['barberName'],
      serviceName: json['serviceName'] ?? 'Servicio',
      amountCharged: json['amountCharged'] != null ? (json['amountCharged'] as num).toDouble() : 0.0,
      pointsAwarded: json['pointsAwarded'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }
}
