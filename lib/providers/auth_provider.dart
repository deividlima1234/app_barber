import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
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
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    // Marcamos estado inicial cargando/limpiando error
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    try {
      final response = await _authRepository.login(username, password);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        token: response['token'],
        userRole: response['role'],
        firstLogin: response['firstLogin'] ?? false,
        errorMessage: null,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> markFirstLoginCompleted() async {
    await _authRepository.setFirstLoginCompleted();
    state = state.copyWith(firstLogin: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
