import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresenceService extends WidgetsBindingObserver {
  static const String _collectionName = 'presence_home';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Timer? _updateTimer;
  String? _userId;
  
  Future<void> start() async {
    _userId = await _getOrCreateUserId();
    if (_userId == null) return;
    
    WidgetsBinding.instance.addObserver(this);
    
    await _cleanupOldDocuments();
    await _updatePresence();
    
    _updateTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _updatePresence();
    });
  }
  
  Future<void> stop() async {
    if (_userId == null) return;
    
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    _updateTimer = null;
    
    await _firestore.collection(_collectionName).doc(_userId).set({
      'userId': _userId,
      'isHome': false,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  Future<void> _updatePresence() async {
    if (_userId == null) return;
    
    await _firestore.collection(_collectionName).doc(_userId).set({
      'userId': _userId,
      'isHome': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  Future<void> _cleanupOldDocuments() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 2));
      final oldDocs = await _firestore
          .collection(_collectionName)
          .where('lastSeen', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();
      
      for (final doc in oldDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
  
  Future<String> _getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('presence_user_id');
    
    if (userId == null) {
      userId = _generateUniqueId();
      await prefs.setString('presence_user_id', userId);
    }
    
    return userId;
  }
  
  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return '${timestamp}_$randomNum';
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      stop();
    } else if (state == AppLifecycleState.resumed) {
      start();
    }
  }
}