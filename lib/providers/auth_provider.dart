import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/main.dart';
import 'package:barber_gold/network/dio_client.dart';
import 'package:barber_gold/repositories/auth_repository.dart';

// Provides standard DioClient
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// Provides AuthRepository explicitly
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient);
});

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userRole;
  final String? token;
  final bool firstLogin;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.checking,
    this.userRole,
    this.token,
    this.firstLogin = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userRole,
    String? token,
    bool? firstLogin,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userRole: userRole ?? this.userRole,
      token: token ?? this.token,
      firstLogin: firstLogin ?? this.firstLogin,
      errorMessage: errorMessage, // if null, it can be passed explicit to erase
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final sessionData = await _authRepository.checkPersistedSession();
      if (sessionData['token'] != null && sessionData['role'] != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: sessionData['token'],
          userRole: sessionData['role'],
          firstLogin: sessionData['firstLogin'] ?? false,
        );
        // Suscribir al tópico de su rol
        _ref.read(notificationServiceProvider).subscribeToRole(sessionData['role']);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    try {
      final response = await _authRepository.login(email, password);
      final role = response['role'] as String;
      
      state = AuthState(
        status: AuthStatus.authenticated,
        token: response['token'],
        userRole: role,
        firstLogin: response['firstLogin'] ?? false,
        errorMessage: null,
      );

      // Suscribir al tópico de su rol
      _ref.read(notificationServiceProvider).subscribeToRole(role);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    final currentRole = state.userRole;
    if (currentRole != null) {
      await _ref.read(notificationServiceProvider).unsubscribeFromRole(currentRole);
    }
    
    await _authRepository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> markFirstLoginCompleted() async {
    await _authRepository.setFirstLoginCompleted();
    state = state.copyWith(firstLogin: false);
  }
}
