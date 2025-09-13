import 'package:flutter/material.dart';
import '../services/data/post_service.dart';
import '../services/data/local_storage_service.dart';

class PostInputViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  // State
  bool _isSubmitting = false;
  String? _errorMessage;
  
  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> submitPost(String text, int selectedFloor, VoidCallback onSuccess) async {
    if (text.trim().isEmpty) {
      _errorMessage = 'Please enter your confession';
      notifyListeners();
      return false;
    }

    if (text.trim().length > 200) {
      _errorMessage = 'Post is too long. Please keep it under 200 characters.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Save user data locally
      await _localStorageService.setFloor(selectedFloor);
      
      // Get user ID for tracking
      final userId = await _localStorageService.getAnonId() ?? 'unknown';
      
      // Submit post
      await _postService.addPost(text.trim(), selectedFloor, userId);
      
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

  Future<Map<String, dynamic>> loadUserPreferences() async {
    final floor = await _localStorageService.getFloor();
    final world = await _localStorageService.getCurrentWorld();
    
    return {
      'floor': floor ?? 1, // Default to floor 1
      'world': world, // Will be Girl Meets College by default
    };
  }
}