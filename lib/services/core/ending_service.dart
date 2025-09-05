import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local_storage_service.dart';

class EndingService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> savePhoneNumber(String phone) async {
    final gender = await _localStorageService.getGender();
    final floor = await _localStorageService.getFloor();
    
    final data = <String, dynamic>{
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    // Add gender only if available (optional)
    if (gender != null) {
      data['gender'] = gender;
    }
    
    // Add floor only if available (optional)
    if (floor != null) {
      data['floor'] = floor;
    }
    
    await _firestore.collection('endings').add(data);
  }

  Future<void> saveContactInfo(String? phone, String? instagram) async {
    final gender = await _localStorageService.getGender();
    final floor = await _localStorageService.getFloor();
    
    if (phone == null && instagram == null) {
      throw Exception('At least one contact method is required');
    }
    
    final data = <String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    // Add gender only if available (optional)
    if (gender != null) {
      data['gender'] = gender;
    }
    
    // Add floor only if available (optional)
    if (floor != null) {
      data['floor'] = floor;
    }
    
    if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }
    
    if (instagram != null && instagram.isNotEmpty) {
      data['instagram'] = instagram;
    }
    
    await _firestore.collection('endings').add(data);
  }
}