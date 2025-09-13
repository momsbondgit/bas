import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _floorKey = 'user.floor';
  static const String _worldKey = 'user.world';
  static const String _tableIdKey = 'user.tableId';
  static const String _vibeAnswersKey = 'user.vibeAnswers';
  static const String _assignedBotsKey = 'user.assignedBots';
  static const String _hasPostedKey = 'user.hasPosted';
  
  // Auth keys
  static const String _anonIdKey = 'auth.anonId';
  static const String _accessCodeKey = 'auth.accessCode';
  static const String _nicknameKey = 'auth.nickname';
  static const String _hasAccountKey = 'auth.hasAccount';
  static const String _authenticatedWorldKey = 'auth.worldId';
  
  // Ritual Queue keys
  static const String _ritualUserIdKey = 'ritual.userId';
  static const String _ritualDisplayNameKey = 'ritual.displayName';
  
  // Session tracking keys
  static const String _lastSessionKey = 'session.lastVisit';
  static const String _sessionCountKey = 'session.count';

  Future<void> setFloor(int floor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_floorKey, floor);
  }

  Future<int?> getFloor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_floorKey);
  }

  Future<void> setTableId(String tableId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tableIdKey, tableId);
  }

  Future<String?> getTableId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tableIdKey);
  }

  Future<void> setVibeAnswers(Map<int, String> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = answers.entries.map((e) => '${e.key}:${e.value}').join(',');
    await prefs.setString(_vibeAnswersKey, jsonString);
  }

  Future<Map<int, String>?> getVibeAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_vibeAnswersKey);
    if (jsonString == null) return null;

    final Map<int, String> answers = {};
    for (final pair in jsonString.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        answers[int.parse(parts[0])] = parts[1];
      }
    }
    return answers;
  }

  Future<void> setAssignedBots(List<String> bots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_assignedBotsKey, bots);
  }

  Future<List<String>?> getAssignedBots() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_assignedBotsKey);
  }

  Future<void> setWorld(String world) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_worldKey, world);
  }

  Future<String?> getWorld() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_worldKey);
  }

  /// Get current world or default
  Future<String> getCurrentWorld() async {
    final prefs = await SharedPreferences.getInstance();
    final world = prefs.getString(_worldKey);
    return world ?? 'Girl Meets College';
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

  Future<void> setAuthenticatedWorldId(String worldId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authenticatedWorldKey, worldId);
  }
  
  Future<String?> getAuthenticatedWorldId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authenticatedWorldKey);
  }

  // Session tracking methods
  
  /// Records current session and detects if user is returning
  Future<bool> recordSessionAndCheckIfReturning() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Get last session time (null for first-time users)
    final lastSession = prefs.getInt(_lastSessionKey);
    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    
    // Save current session
    await prefs.setInt(_lastSessionKey, now);
    await prefs.setInt(_sessionCountKey, sessionCount + 1);
    
    // Return true if this is a returning user (has previous session)
    return lastSession != null;
  }
  
  /// Gets the number of sessions for this user
  Future<int> getSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionCountKey) ?? 0;
  }
  
  /// Gets time since last session in hours (null for first-time users)
  Future<double?> getHoursSinceLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSession = prefs.getInt(_lastSessionKey);
    
    if (lastSession == null) return null;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMs = now - lastSession;
    return diffMs / (1000 * 60 * 60); // Convert to hours
  }
}