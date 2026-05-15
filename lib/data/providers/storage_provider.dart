import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class StorageProvider {
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  Future<void> saveSession(String token, String userId, String role) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_userRoleKey, role);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userRoleKey);
  }

  bool get hasSession => _prefs.containsKey(_tokenKey);
  String? get currentUserId => _prefs.getString(_userIdKey);
  String? get currentUserRole => _prefs.getString(_userRoleKey);

  Future<Map<String, String?>?> getSession() async {
    if (!hasSession) return null;
    return {
      'token': _prefs.getString(_tokenKey),
      'userId': _prefs.getString(_userIdKey),
      'role': _prefs.getString(_userRoleKey),
    };
  }
}
