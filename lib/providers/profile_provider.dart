import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:barber_gold/config/api_config.dart';
import 'package:barber_gold/models/user_profile.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final dio = _ref.read(dioClientProvider).dio;
      final response = await dio.get(ApiConfig.profile);
      final profile = UserProfile.fromJson(response.data);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final currentProfile = state.asData?.value;
    if (currentProfile == null) return;

    try {
      final dio = _ref.read(dioClientProvider).dio;
      await dio.put(ApiConfig.profile, data: {
        'fullName': fullName ?? currentProfile.fullName,
        'phone': phone ?? currentProfile.phone,
      });
      
      // Update local state
      state = AsyncValue.data(currentProfile.copyWith(
        fullName: fullName,
        phone: phone,
      ));
    } catch (e) {
      // Re-fetch on error to ensure sync
      fetchProfile();
      rethrow;
    }
  }
}
