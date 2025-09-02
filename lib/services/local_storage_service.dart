import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _floorKey = 'user.floor';
  static const String _genderKey = 'user.gender';
  static const String _hasPostedKey = 'user.hasPosted';
  
  // Ritual Queue keys
  static const String _ritualUserIdKey = 'ritual.userId';
  static const String _ritualDisplayNameKey = 'ritual.displayName';

  Future<void> setFloor(int floor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_floorKey, floor);
  }

  Future<int?> getFloor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_floorKey);
  }

  Future<void> setGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_genderKey, gender);
  }

  Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_genderKey);
  }

  Future<void> setHasPosted(bool hasPosted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasPostedKey, hasPosted);
  }

  Future<bool> getHasPosted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPostedKey) ?? false;
  }
  
  // Ritual Queue methods
  Future<void> setRitualUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ritualUserIdKey, userId);
  }
  
  Future<String?> getRitualUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ritualUserIdKey);
  }
  
  Future<void> setRitualDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ritualDisplayNameKey, displayName);
  }
  
  Future<String?> getRitualDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ritualDisplayNameKey);
  }
}