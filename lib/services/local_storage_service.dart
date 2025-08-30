import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _floorKey = 'user.floor';
  static const String _genderKey = 'user.gender';
  static const String _hasPostedKey = 'user.hasPosted';

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
}