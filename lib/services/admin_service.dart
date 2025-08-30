import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String _isLoggedInKey = 'admin.isLoggedIn';
  static const String _sessionExpiryKey = 'admin.sessionExpiry';
  
  // Admin credentials
  static const String _adminUsername = 'hap';
  static const String _adminPassword = 'happyman';
  
  // Session duration (24 hours)
  static const int _sessionDurationHours = 24;
  
  /// Authenticate admin with username and password
  Future<bool> login(String username, String password) async {
    print('[ADMIN DEBUG] Login attempt - Username: $username');
    
    if (username == _adminUsername && password == _adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      final sessionExpiry = DateTime.now().add(Duration(hours: _sessionDurationHours));
      
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_sessionExpiryKey, sessionExpiry.toIso8601String());
      
      print('[ADMIN DEBUG] Login successful - Admin marked as logged in, session expires: ${sessionExpiry.toIso8601String()}');
      return true;
    }
    
    print('[ADMIN DEBUG] Login failed - Invalid credentials');
    return false;
  }
  
  /// Log out admin user
  Future<void> logout() async {
    print('[ADMIN DEBUG] Logging out admin user');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_sessionExpiryKey);
    print('[ADMIN DEBUG] Admin logout completed - session data cleared');
  }
  
  /// Check if admin is currently logged in and session is valid
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    print('[ADMIN DEBUG] Checking admin login status - Stored login flag: $isLoggedIn');
    
    if (!isLoggedIn) {
      print('[ADMIN DEBUG] Admin not logged in - no login flag found');
      return false;
    }
    
    // Check session expiry
    final sessionExpiryString = prefs.getString(_sessionExpiryKey);
    if (sessionExpiryString == null) {
      print('[ADMIN DEBUG] Admin login invalid - no session expiry found');
      return false;
    }
    
    final sessionExpiry = DateTime.parse(sessionExpiryString);
    final isSessionValid = DateTime.now().isBefore(sessionExpiry);
    
    print('[ADMIN DEBUG] Session check - Expires: ${sessionExpiry.toIso8601String()}, Valid: $isSessionValid');
    
    if (!isSessionValid) {
      // Session expired, clear stored data
      print('[ADMIN DEBUG] Session expired - clearing admin data');
      await logout();
      return false;
    }
    
    print('[ADMIN DEBUG] Admin is logged in with valid session');
    return true;
  }
  
  /// Extend current session
  Future<void> extendSession() async {
    final isCurrentlyLoggedIn = await isLoggedIn();
    if (isCurrentlyLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      final sessionExpiry = DateTime.now().add(Duration(hours: _sessionDurationHours));
      await prefs.setString(_sessionExpiryKey, sessionExpiry.toIso8601String());
    }
  }
  
  /// Get remaining session time in minutes
  Future<int> getRemainingSessionMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionExpiryString = prefs.getString(_sessionExpiryKey);
    
    if (sessionExpiryString == null) return 0;
    
    final sessionExpiry = DateTime.parse(sessionExpiryString);
    final now = DateTime.now();
    
    if (now.isAfter(sessionExpiry)) return 0;
    
    return sessionExpiry.difference(now).inMinutes;
  }
}