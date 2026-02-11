import 'package:get_storage/get_storage.dart';

class StorageService {
  static final storage = GetStorage();

  /// Save Token
  static void saveToken(String token) {
    storage.write('token', token);
  }

  /// Get Token
  static String? getToken() {
    return storage.read('token');
  }

  /// Remove Token (Logout)
  static void clearToken() {
    storage.remove('token');
  }
}
