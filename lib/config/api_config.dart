class ApiConfig {
  static const String baseUrl = 'https://barber-backend-awzb.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';

  // Cards
  static const String generateBatch = '/cards/batch';
  static const String activateCustomer = '/customers/activate';

  // Gamification
  static const String addPoints = '/points/add';
  static const String spinRoulette = '/gamification/spin';
  static const String finalizeSetup = '/users/me/finalize-setup';
  static const String profile = '/users/me';
}
