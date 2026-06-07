import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> saveUserJson(String json) =>
      _storage.write(key: StorageKeys.userJson, value: json);

  Future<String?> getUserJson() => _storage.read(key: StorageKeys.userJson);

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.userJson);
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
