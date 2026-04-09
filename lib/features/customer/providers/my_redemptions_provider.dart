import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/customer/repositories/customer_repository.dart';
import 'package:barber_gold/features/customer/models/prize_redemption_dto.dart';

final myRedemptionsProvider = FutureProvider<List<PrizeRedemptionDto>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getMyRedemptions();
});
