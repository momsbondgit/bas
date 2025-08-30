import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../services/local_storage_service.dart';

class PostInputViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  // State
  bool _isSubmitting = false;
  String? _errorMessage;
  
  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> submitPost(String text, int selectedFloor, String selectedGender, VoidCallback onSuccess) async {
    if (text.trim().isEmpty) {
      _errorMessage = 'Please enter your confession';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Save user data locally
      await _localStorageService.setFloor(selectedFloor);
      await _localStorageService.setGender(selectedGender);
      
      // Submit post
      await _postService.addPost(text.trim(), selectedFloor, selectedGender);
      
      // Mark as posted
      await _localStorageService.setHasPosted(true);
      
      _isSubmitting = false;
      notifyListeners();
      
      // Call success callback
      onSuccess();
      return true;
      
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Failed to submit post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}