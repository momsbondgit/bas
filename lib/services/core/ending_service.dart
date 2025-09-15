import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class EndingService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> saveContactInfo(String? instagram) async {
    // Get user ID using existing logic
    String? userId = await _localStorageService.getAnonId();
    userId ??= await _localStorageService.getRitualUserId();

    if (userId == null) {
      // Generate a new user ID if none exists
      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await _localStorageService.setAnonId(userId);
    }

    // Update or create user account in accounts collection
    final docRef = _firestore.collection('accounts').doc(userId);
    await docRef.set({
      'instagram': _formatInstagram(instagram),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveRejectedUserInstagram(String instagram) async {
    await _firestore.collection('rejected_users').add({
      'instagram': _formatInstagram(instagram),
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatInstagram(String? instagram) {
    return (instagram != null && instagram.isNotEmpty) ? '@$instagram' : 'N/A';
  }
}