import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barber_gold/network/dio_client.dart';
import 'package:barber_gold/config/api_config.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRepository(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data != null && data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        
        // Guardar el primer role de la lista de roles que venga
        String role = 'ROLE_CUSTOMER';
        if (data['roles'] != null && (data['roles'] as List).isNotEmpty) {
          role = data['roles'][0];
        }
        await _storage.write(key: 'user_role', value: role);
        await _storage.write(key: 'user_email', value: data['email'] ?? email);
        await _storage.write(key: 'first_login', value: (data['firstLogin'] ?? true).toString());
        
        return {
          'success': true,
          'token': data['token'],
          'role': role,
          'firstLogin': data['firstLogin'] ?? true,
        };
      }
      throw Exception('Datos de autenticación inválidos');
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión con el servidor';
      if (e.response != null) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
          errorMessage = 'Correo o contraseña incorrectos';
        } else {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'El servidor tardó mucho en responder (Timeout)';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll(); // Limpieza total garantizada
  }

  Future<Map<String, dynamic>> checkPersistedSession() async {
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');
    final firstLoginStr = await _storage.read(key: 'first_login');
    return {
      'token': token,
      'role': role,
      'firstLogin': firstLoginStr == 'true',
    };
  }

  Future<void> setFirstLoginCompleted() async {
    await _storage.write(key: 'first_login', value: 'false');
  }
}
