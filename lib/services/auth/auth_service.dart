import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _accountsCollection = 'accounts';
  
  // World-specific access codes
  static const Map<String, String> _worldAccessCodes = {
    'girl-meets-college': '789',
    'guy-meets-college': '456',
  };

  /// Get existing anon ID or create a new one
  Future<String> getOrCreateAnonId() async {
    String? existingId = await _localStorage.getAnonId();
    
    if (existingId != null) {
      return existingId;
    }
    
    // Generate new anon ID
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    final anonId = 'anon_${timestamp}_$randomSuffix';
    
    await _localStorage.setAnonId(anonId);
    return anonId;
  }

  /// Check if user has a persisted account locally
  Future<bool> isLoggedIn() async {
    final hasAccount = await _localStorage.getHasAccount();
    return hasAccount;
  }

  /// Check if user is authenticated for a specific world
  Future<bool> isLoggedInForWorld(String worldId) async {
    final hasAccount = await _localStorage.getHasAccount();
    if (!hasAccount) return false;
    
    final authenticatedWorldId = await _localStorage.getAuthenticatedWorldId();
    return authenticatedWorldId == worldId;
  }

  /// Get stored account data from localStorage
  Future<Map<String, String>?> getStoredAccount() async {
    final hasAccount = await _localStorage.getHasAccount();
    if (!hasAccount) return null;
    
    final accessCode = await _localStorage.getAccessCode();
    final nickname = await _localStorage.getNickname();
    final anonId = await _localStorage.getAnonId();
    
    if (accessCode != null && nickname != null && anonId != null) {
      return {
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
      };
    }
    
    return null;
  }

  /// Create account with access code and nickname
  Future<bool> createAccount(String accessCode, String nickname) async {
    return _createAccountInternal(accessCode, nickname, null);
  }

  /// Create account with world-specific access code and nickname
  Future<bool> createAccountForWorld(String accessCode, String nickname, String worldId) async {
    // Validate access code for the specific world
    final correctCode = _worldAccessCodes[worldId];
    if (correctCode == null || accessCode != correctCode) {
      return false;
    }

    return _createAccountInternal(accessCode, nickname, worldId);
  }

  /// Internal method to create account with optional world ID
  Future<bool> _createAccountInternal(String accessCode, String nickname, String? worldId) async {
    try {
      final anonId = await getOrCreateAnonId();

      // Build Firebase data
      final firebaseData = {
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
        'worldVisitCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (worldId != null) {
        firebaseData['worldId'] = worldId;
      }

      // Store in Firebase
      await _firestore.collection(_accountsCollection).doc(anonId).set(firebaseData);

      // Store locally
      await _localStorage.setAccessCode(accessCode);
      await _localStorage.setNickname(nickname);
      await _localStorage.setHasAccount(true);

      if (worldId != null) {
        await _localStorage.setAuthenticatedWorldId(worldId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear local account data (logout)
  Future<void> clearAccount() async {
    await _localStorage.setAccessCode('');
    await _localStorage.setNickname('');
    await _localStorage.setHasAccount(false);
    await _localStorage.setAuthenticatedWorldId('');
  }
  
  /// Track when a user visits a world and increment their return count
  Future<void> trackWorldVisit(String anonId, String worldId) async {
    try {
      final docRef = _firestore.collection(_accountsCollection).doc(anonId);
      
      // Simply increment the worldVisitCount field
      await docRef.update({
        'worldVisitCount': FieldValue.increment(1),
      });
    } catch (e) {
      // If document doesn't exist or field doesn't exist, create/set it
      try {
        await _firestore.collection(_accountsCollection).doc(anonId).set({
          'worldVisitCount': 1,
        }, SetOptions(merge: true));
      } catch (e2) {
        // Silently fail if unable to track
      }
    }
  }
  
  /// Get user's world visit count
  Future<int> getUserWorldVisitCount(String anonId) async {
    try {
      final doc = await _firestore.collection(_accountsCollection).doc(anonId).get();
      if (doc.exists) {
        final data = doc.data();
        return (data?['worldVisitCount'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}