import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class TypingIndicatorService {
  TypingIndicatorService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Map<String, Timer> _typingTimers = {};
  
  static const Duration _typingTimeout = Duration(seconds: 3);

  CollectionReference get _typingCollection => _firestore.collection('typing_indicators');

  Stream<Map<String, bool>> get typingUsersStream {
    return _typingCollection.snapshots().map((snapshot) {
      final typingUsers = <String, bool>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isTyping = data['isTyping'] as bool? ?? false;
        final lastUpdate = (data['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        final isRecentlyActive = DateTime.now().difference(lastUpdate) < _typingTimeout;
        typingUsers[doc.id] = isTyping && isRecentlyActive;
      }
      
      return typingUsers;
    });
  }

  Future<void> setUserTyping(String userId, bool isTyping) async {
    try {
      _cancelTypingTimer(userId);

      await _typingCollection.doc(userId).set({
        'isTyping': isTyping,
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      if (isTyping) {
        _scheduleTypingTimeout(userId);
      }
    } catch (e) {
      throw Exception('Failed to update typing indicator: $e');
    }
  }

  Future<void> broadcastTypingState(String userId, bool isTyping) async {
    await setUserTyping(userId, isTyping);
  }

  void _scheduleTypingTimeout(String userId) {
    _typingTimers[userId] = Timer(_typingTimeout, () async {
      await setUserTyping(userId, false);
      _typingTimers.remove(userId);
    });
  }

  void _cancelTypingTimer(String userId) {
    _typingTimers[userId]?.cancel();
    _typingTimers.remove(userId);
  }

  Future<void> clearAllTypingIndicators() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _typingCollection.get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      for (final timer in _typingTimers.values) {
        timer.cancel();
      }
      _typingTimers.clear();
    } catch (e) {
      throw Exception('Failed to clear typing indicators: $e');
    }
  }

  Future<void> cleanupExpiredIndicators() async {
    try {
      final cutoffTime = Timestamp.fromDate(
        DateTime.now().subtract(_typingTimeout * 2),
      );
      
      final expiredQuery = await _typingCollection
          .where('lastUpdate', isLessThan: cutoffTime)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in expiredQuery.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup expired typing indicators: $e');
    }
  }

  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
  }
}