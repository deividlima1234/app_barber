import 'package:barber_gold/features/shared/models/transaction_dto.dart';

class BarberDashboardDto {
  final double incomeToday;
  final int servicesToday;
  final List<TransactionDto> recentTransactions;

  BarberDashboardDto({
    required this.incomeToday,
    required this.servicesToday,
    required this.recentTransactions,
  });

  factory BarberDashboardDto.fromJson(Map<String, dynamic> json) {
    var rawList = json['recentTransactions'] as List? ?? [];
    return BarberDashboardDto(
      incomeToday: json['incomeToday'] != null ? (json['incomeToday'] as num).toDouble() : 0.0,
      servicesToday: json['servicesToday'] ?? 0,
      recentTransactions: rawList.map((e) => TransactionDto.fromJson(e)).toList(),
    );
  }
}
