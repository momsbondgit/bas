import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_storage_service.dart';
import 'bot_assignment_service.dart';

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BotAssignmentService _botAssignmentService = BotAssignmentService();
  
  static const String _accountsCollection = 'accounts';

  /// Get existing anon ID or create a new one
  Future<String> getOrCreateAnonId() async {
    print('DEBUG AuthService.getOrCreateAnonId: Checking for existing anon ID');
    String? existingId = await _localStorage.getAnonId();
    
    if (existingId != null) {
      print('DEBUG AuthService.getOrCreateAnonId: Found existing anon ID: $existingId');
      return existingId;
    }
    
    print('DEBUG AuthService.getOrCreateAnonId: Creating new anon ID');
    // Generate new anon ID
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    final anonId = 'anon_${timestamp}_$randomSuffix';
    
    print('DEBUG AuthService.getOrCreateAnonId: Generated new anon ID: $anonId');
    await _localStorage.setAnonId(anonId);
    print('DEBUG AuthService.getOrCreateAnonId: Saved anon ID to localStorage');
    return anonId;
  }

  /// Check if user has a persisted account locally
  Future<bool> isLoggedIn() async {
    final hasAccount = await _localStorage.getHasAccount();
    print('DEBUG AuthService.isLoggedIn: User has account: $hasAccount');
    return hasAccount;
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
    print('DEBUG AuthService.createAccount: Creating account with code: $accessCode, nickname: $nickname');
    try {
      final anonId = await getOrCreateAnonId();
      print('DEBUG AuthService.createAccount: Using anon ID: $anonId');
      
      // Store in Firebase
      print('DEBUG AuthService.createAccount: Writing to Firebase accounts collection');
      await _firestore.collection(_accountsCollection).doc(anonId).set({
        'anonId': anonId,
        'accessCode': accessCode,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('DEBUG AuthService.createAccount: Successfully wrote account to Firebase');
      
      // Store locally
      print('DEBUG AuthService.createAccount: Saving account data to localStorage');
      await _localStorage.setAccessCode(accessCode);
      await _localStorage.setNickname(nickname);
      await _localStorage.setHasAccount(true);
      print('DEBUG AuthService.createAccount: Successfully saved account to localStorage');
      
      // Silently assign bots to user during account creation
      print('DEBUG AuthService.createAccount: Starting bot assignment');
      await _botAssignmentService.assignBotsToUser(anonId);
      print('DEBUG AuthService.createAccount: Successfully assigned bots to user');
      
      return true;
    } catch (e) {
      print('DEBUG AuthService.createAccount: ERROR - Failed to create account: $e');
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