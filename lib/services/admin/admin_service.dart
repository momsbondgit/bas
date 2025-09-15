import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String _isLoggedInKey = 'admin.isLoggedIn';

  // Admin credentials
  static const String _adminUsername = 'hap';
  static const String _adminPassword = 'happyman';

  /// Authenticate admin with username and password
  Future<bool> login(String username, String password) async {
    if (username == _adminUsername && password == _adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  /// Log out admin user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
  }

  /// Check if admin is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}