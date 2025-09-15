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

    // Set Instagram field
    final instagramValue = (instagram != null && instagram.isNotEmpty)
        ? '@$instagram'
        : 'N/A';

    // Update or create user account in accounts collection
    final docRef = _firestore.collection('accounts').doc(userId);
    await docRef.set({
      'instagram': instagramValue,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}