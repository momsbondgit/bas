import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _floorKey = 'user.floor';
  static const String _genderKey = 'user.gender';
  static const String _hasPostedKey = 'user.hasPosted';
  
  // Auth keys
  static const String _anonIdKey = 'auth.anonId';
  static const String _accessCodeKey = 'auth.accessCode';
  static const String _nicknameKey = 'auth.nickname';
  static const String _hasAccountKey = 'auth.hasAccount';
  
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
  
  // Auth methods
  Future<void> setAnonId(String anonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anonIdKey, anonId);
  }
  
  Future<String?> getAnonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonIdKey);
  }
  
  Future<void> setAccessCode(String accessCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessCodeKey, accessCode);
  }
  
  Future<String?> getAccessCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessCodeKey);
  }
  
  Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
  }
  
  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nicknameKey);
  }
  
  Future<void> setHasAccount(bool hasAccount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasAccountKey, hasAccount);
  }
  
  Future<bool> getHasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasAccountKey) ?? false;
  }
}