import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_storage_service.dart';

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _accountsCollection = 'accounts';

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
    return await _localStorage.getHasAccount();
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
    try {
      final anonId = await getOrCreateAnonId();
      
      // Store in Firebase
      await _firestore.collection(_accountsCollection).doc(anonId).set({
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Store locally
      await _localStorage.setAccessCode(accessCode);
      await _localStorage.setNickname(nickname);
      await _localStorage.setHasAccount(true);
      
      return true;
    } catch (e) {
      // Handle error - return false on failure
      return false;
    }
  }

  /// Clear local account data (logout)
  Future<void> clearAccount() async {
    await _localStorage.setAccessCode('');
    await _localStorage.setNickname('');
    await _localStorage.setHasAccount(false);
  }
}