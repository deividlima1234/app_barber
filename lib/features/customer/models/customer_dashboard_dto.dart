import 'package:barber_gold/features/shared/models/transaction_dto.dart';

class CustomerDashboardDto {
  final int totalPoints;
  final int pointsToNextSpin;
  final String? qrToken;
  final String customerName;
  final List<TransactionDto> recentTransactions;

  CustomerDashboardDto({
    required this.totalPoints,
    required this.pointsToNextSpin,
    this.qrToken,
    required this.customerName,
    required this.recentTransactions,
  });

  factory CustomerDashboardDto.fromJson(Map<String, dynamic> json) {
    var rawTxs = json['recentTransactions'] as List? ?? [];
    return CustomerDashboardDto(
      totalPoints: json['totalPoints'] ?? 0,
      pointsToNextSpin: json['pointsToNextSpin'] ?? 0,
      qrToken: json['qrToken'],
      customerName: json['customerName'] ?? 'Miembro',
      recentTransactions: rawTxs.map((e) => TransactionDto.fromJson(e)).toList(),
    );
  }
}
