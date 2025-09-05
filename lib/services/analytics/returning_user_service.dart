import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ReturningUserService {
  static const String _returnerCountKey = 'returner_count';
  static const String _userIdKey = 'user_tracking_id';
  static const String _collectionName = 'user_analytics';
  static const String _documentId = 'returning_users_stats';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize user tracking on app start
  Future<void> initializeUserTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get or create unique user tracking ID
      String? userId = prefs.getString(_userIdKey);
      if (userId == null) {
        // First-time user - create new tracking ID
        userId = _generateUniqueUserId();
        await prefs.setString(_userIdKey, userId);
        await prefs.setInt(_returnerCountKey, 0);
      }
      
      // Increment visit count
      final currentCount = prefs.getInt(_returnerCountKey) ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt(_returnerCountKey, newCount);
      
      // Update Firebase analytics only if this is a returning user (count > 1)
      if (newCount > 1) {
        await _updateReturningUserStats(userId, newCount);
      }
    } catch (e) {
      // Fail silently to not break app flow
    }
  }
  
  /// Get current user's visit count from local storage
  Future<int> getCurrentUserVisitCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_returnerCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get total returning users count from Firebase (admin only)
  Future<int> getTotalReturningUsersCount() async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();
          
      if (!doc.exists) {
        await _initializeStatsDocument();
        return 0;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return data['uniqueReturningUsers'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get returning users stats stream (admin only)
  Stream<int> getReturningUsersCountStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>;
      return data['uniqueReturningUsers'] ?? 0;
    });
  }
  
  /// Update returning user stats in Firebase
  Future<void> _updateReturningUserStats(String userId, int visitCount) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(_documentId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) {
          // Initialize document
          transaction.set(docRef, {
            'uniqueReturningUsers': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'userSessions': {
              userId: {
                'visitCount': visitCount,
                'lastVisit': FieldValue.serverTimestamp(),
              }
            }
          });
        } else {
          final data = doc.data() as Map<String, dynamic>;
          final userSessions = Map<String, dynamic>.from(data['userSessions'] ?? {});
          
          // Check if this is a new returning user
          final isNewReturningUser = !userSessions.containsKey(userId);
          
          // Update user session data
          userSessions[userId] = {
            'visitCount': visitCount,
            'lastVisit': FieldValue.serverTimestamp(),
          };
          
          // Update document
          transaction.update(docRef, {
            'uniqueReturningUsers': isNewReturningUser 
                ? (data['uniqueReturningUsers'] ?? 0) + 1
                : data['uniqueReturningUsers'] ?? 0,
            'lastUpdated': FieldValue.serverTimestamp(),
            'userSessions': userSessions,
          });
        }
      });
    } catch (e) {
      // Fail silently to not break app flow
    }
  }
  
  /// Generate unique user tracking ID
  String _generateUniqueUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    final input = '$timestamp$random';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  /// Initialize stats document if it doesn't exist
  Future<void> _initializeStatsDocument() async {
    try {
      await _firestore.collection(_collectionName).doc(_documentId).set({
        'uniqueReturningUsers': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userSessions': {},
      });
    } catch (e) {
      // Fail silently
    }
  }
  
  /// Reset all returning user data (admin only - for testing)
  Future<void> resetReturningUserData() async {
    try {
      await _firestore.collection(_collectionName).doc(_documentId).delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_returnerCountKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      throw Exception('Failed to reset returning user data: $e');
    }
  }
}