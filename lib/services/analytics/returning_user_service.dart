import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReturningUserService {
  static const String _collectionName = 'returning_users';
  static const String _localStorageKey = 'user_first_visit';
  static const String _userIdKey = 'unique_user_id';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Check if user is a returning user and track visit
  Future<bool> checkAndTrackReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has visited before
    final firstVisitString = prefs.getString(_localStorageKey);
    final userId = prefs.getString(_userIdKey);
    
    if (firstVisitString == null || userId == null) {
      // First time user
      final newUserId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_userIdKey, newUserId);
      await prefs.setString(_localStorageKey, DateTime.now().toIso8601String());
      return false;
    }
    
    // Returning user - track in Firestore
    final firstVisit = DateTime.parse(firstVisitString);
    final daysSinceFirstVisit = DateTime.now().difference(firstVisit).inDays;
    
    // Only track if it's been at least 1 day since first visit
    if (daysSinceFirstVisit >= 1) {
      await _trackReturningUser(userId, firstVisit);
      return true;
    }
    
    return false;
  }
  
  /// Track returning user in Firestore
  Future<void> _trackReturningUser(String userId, DateTime firstVisit) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      final doc = await docRef.get();
      
      if (doc.exists) {
        // Update existing returning user
        await docRef.update({
          'lastVisit': FieldValue.serverTimestamp(),
          'visitCount': FieldValue.increment(1),
        });
      } else {
        // Create new returning user record
        await docRef.set({
          'userId': userId,
          'firstVisit': Timestamp.fromDate(firstVisit),
          'lastVisit': FieldValue.serverTimestamp(),
          'visitCount': 2, // 2 because this is their second visit
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error tracking returning user: $e');
    }
  }
  
  /// Get total count of returning users
  Future<int> getTotalReturningUsersCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.size;
    } catch (e) {
      print('Error getting returning users count: $e');
      return 0;
    }
  }
  
  /// Get stream of returning users count
  Stream<int> getReturningUsersCountStream() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
  
  /// Get detailed returning users data
  Future<List<Map<String, dynamic>>> getReturningUsersData() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('lastVisit', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'],
          'firstVisit': (data['firstVisit'] as Timestamp?)?.toDate(),
          'lastVisit': (data['lastVisit'] as Timestamp?)?.toDate(),
          'visitCount': data['visitCount'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting returning users data: $e');
      return [];
    }
  }
  
  /// Reset all returning user data (Admin only)
  Future<void> resetReturningUserData() async {
    try {
      // Get all documents
      final snapshot = await _firestore.collection(_collectionName).get();
      
      // Delete in batches (Firestore limit is 500 operations per batch)
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error resetting returning user data: $e');
      throw e;
    }
  }
  
  /// Get returning users statistics
  Future<Map<String, dynamic>> getReturningUsersStats() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      
      if (snapshot.docs.isEmpty) {
        return {
          'totalReturningUsers': 0,
          'averageVisits': 0,
          'mostRecentVisit': null,
        };
      }
      
      int totalVisits = 0;
      DateTime? mostRecentVisit;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalVisits += (data['visitCount'] as int?) ?? 0;
        
        final lastVisit = (data['lastVisit'] as Timestamp?)?.toDate();
        if (lastVisit != null) {
          if (mostRecentVisit == null || lastVisit.isAfter(mostRecentVisit)) {
            mostRecentVisit = lastVisit;
          }
        }
      }
      
      return {
        'totalReturningUsers': snapshot.size,
        'averageVisits': snapshot.size > 0 ? (totalVisits / snapshot.size).toStringAsFixed(1) : '0',
        'mostRecentVisit': mostRecentVisit,
      };
    } catch (e) {
      print('Error getting returning users stats: $e');
      return {
        'totalReturningUsers': 0,
        'averageVisits': 0,
        'mostRecentVisit': null,
      };
    }
  }
}