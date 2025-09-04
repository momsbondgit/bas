import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class EndingService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> savePhoneNumber(String phone) async {
    final gender = await _localStorageService.getGender();
    final floor = await _localStorageService.getFloor();
    
    if (gender == null) {
      throw Exception('Gender data is required but not available');
    }
    
    await _firestore.collection('endings').add({
      'phone': phone,
      'gender': gender,
      'floor': floor,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}