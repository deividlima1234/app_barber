import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barber_gold/network/dio_client.dart';
import 'package:barber_gold/config/api_config.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRepository(this._dioClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.login,
        data: {
          'username': username,
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
        await _storage.write(key: 'username', value: data['username'] ?? username);
        
        return {
          'success': true,
          'token': data['token'],
          'role': role,
        };
      }
      throw Exception('Datos de autenticación inválidos');
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión con el servidor';
      if (e.response != null) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
          errorMessage = 'Usuario o contraseña incorrectos';
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
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'username');
  }

  Future<Map<String, String?>> checkPersistedSession() async {
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');
    return {
      'token': token,
      'role': role,
    };
  }
}
