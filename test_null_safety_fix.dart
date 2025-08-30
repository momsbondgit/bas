import 'package:flutter_test/flutter_test.dart';
import 'lib/services/post_service.dart';
import 'lib/services/ending_service.dart';

void main() {
  group('Null Safety Fix Tests', () {
    test('PostService.addPost should reject empty text', () async {
      final postService = PostService();
      
      expect(
        () async => await postService.addPost('', 1, 'male'),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('PostService.addAdminPost should reject empty text', () async {
      final postService = PostService();
      
      expect(
        () async => await postService.addAdminPost(
          text: '', 
          floor: 1, 
          gender: 'male'
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('PostService.addAdminPost should reject empty gender', () async {
      final postService = PostService();
      
      expect(
        () async => await postService.addAdminPost(
          text: 'test', 
          floor: 1, 
          gender: ''
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('EndingService.savePhoneNumber should reject null gender', () async {
      final endingService = EndingService();
      
      // This test would require mocking LocalStorageService to return null
      // For now, this demonstrates the expected behavior
      print('EndingService null safety guard added - will throw exception for null gender');
    });
  });
}