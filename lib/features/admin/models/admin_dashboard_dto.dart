import 'package:barber_gold/features/shared/models/transaction_dto.dart';

class AdminDashboardDto {
  final double grossIncomeWeek;
  final List<Map<String, dynamic>> topServices;
  final List<Map<String, dynamic>> barberLeaderboard;
  final List<TransactionDto> recentTransactions;
  final int totalPassivePoints;

  AdminDashboardDto({
    required this.grossIncomeWeek,
    required this.topServices,
    required this.barberLeaderboard,
    required this.recentTransactions,
    required this.totalPassivePoints,
  });

  factory AdminDashboardDto.fromJson(Map<String, dynamic> json) {
    var rawTxs = json['recentTransactions'] as List? ?? [];
    return AdminDashboardDto(
      grossIncomeWeek: json['grossIncomeWeek']?.toDouble() ?? 0.0,
      topServices: List<Map<String, dynamic>>.from(json['topServices'] ?? []),
      barberLeaderboard: List<Map<String, dynamic>>.from(json['barberLeaderboard'] ?? []),
      recentTransactions: rawTxs.map((e) => TransactionDto.fromJson(e)).toList(),
      totalPassivePoints: json['totalPassivePoints'] ?? 0,
    );
  }
}
