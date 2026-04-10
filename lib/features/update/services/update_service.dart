import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdateService {
  final Dio _dio = Dio();
  
  // URL del archivo JSON de configuración (Debes reemplazarla por tu URL de Gist o servidor)
  // Ejemplo: https://gist.githubusercontent.com/usuario/gist_id/raw/version.json
  final String _updateUrl = 'https://raw.githubusercontent.com/deividlima1234/app_barber/main/version.json';
  
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_updateUrl == 'ESTA_ES_TU_URL_DEL_ARCHIVO_JSON') {
        print('ALERTA: Debes configurar la URL del archivo JSON en UpdateService');
        return null;
      }

      final response = await _dio.get(_updateUrl);
      
      if (response.statusCode == 200) {
        dynamic data = response.data;
        // Si Dio no lo parseó automáticamente (por ser text/plain), lo parseamos nosotros
        if (data is String) {
          data = jsonDecode(data);
        }
        
        final String latestVersion = data['version'].toString().replaceFirst('v', '');
        
        print('OTA: Versión actual: $currentVersion - Latest: $latestVersion');

        if (_isVersionNewer(currentVersion, latestVersion)) {
          return {
            'latestVersion': latestVersion,
            'downloadUrl': data['url'],
            'releaseNotes': data['changelog'] ?? '',
          };
        }
      }
    } catch (e) {
      print('Error checking for update: $e');
    }
    return null;
  }

  bool _isVersionNewer(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestParts[i] > currentPart) return true;
      if (latestParts[i] < currentPart) return false;
    }
    return false;
  }

  Stream<OtaEvent> downloadAndInstall(String url) {
    try {
      return OtaUpdate().execute(
        url,
        destinationFilename: 'barber_gold.apk',
      );
    } catch (e) {
      throw 'Error durante la ejecución OTA: $e';
    }
  }

  Future<int> getSkipCount(String version) async {
    final countStr = await _storage.read(key: 'update_skip_count_$version');
    return countStr != null ? int.parse(countStr) : 0;
  }

  Future<void> incrementSkipCount(String version) async {
    final count = await getSkipCount(version);
    await _storage.write(key: 'update_skip_count_$version', value: (count + 1).toString());
  }
}
