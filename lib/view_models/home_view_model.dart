import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../services/post_service.dart';
import '../services/local_storage_service.dart';
import '../services/maintenance_service.dart';

class HomeViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  // State
  bool _hasPosted = false;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;
  int _viewerCount = 15;
  bool _timerExpiredAndCleared = false;
  List<QueryDocumentSnapshot> _posts = [];
  
  // Private
  Timer? _timer;
  Timer? _viewerTimer;
  StreamSubscription<QuerySnapshot>? _postsSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  final Random _random = Random();
  
  // Getters
  bool get hasPosted => _hasPosted;
  int get remainingMinutes => _remainingMinutes;
  int get remainingSeconds => _remainingSeconds;
  int get viewerCount => _viewerCount;
  List<QueryDocumentSnapshot> get posts => _posts;
  bool get shouldShowTimer => _remainingMinutes > 0 || _remainingSeconds > 0;

  void initialize() {
    _loadHasPostedStatus();
    _initializeFreshTimer();
    _startViewerUpdates();
    _listenToPosts();
  }

  void _loadHasPostedStatus() async {
    final hasPosted = await _localStorageService.getHasPosted();
    _hasPosted = hasPosted;
    notifyListeners();
  }

  void _initializeFreshTimer() async {
    try {
      await _maintenanceService.startFreshSession(minutes: 1);
      _timerExpiredAndCleared = false;
      _listenToMaintenance();
    } catch (e) {
      _listenToMaintenance();
    }
  }

  void _listenToMaintenance() {
    _maintenanceSubscription = _maintenanceService.getMaintenanceStatusStream().listen((status) {
      final remainingTime = status.remainingTime;
      _remainingMinutes = remainingTime['minutes']!;
      _remainingSeconds = remainingTime['seconds']!;
      notifyListeners();
      
      if (status.remainingSeconds <= 0 && status.sessionEndTime != null && !_timerExpiredAndCleared) {
        _timerExpiredAndCleared = true;
        _maintenanceService.clearExpiredTimer();
        // Notify listeners that timer expired - UI should handle navigation
        notifyListeners();
      }
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerDisplay();
    });
  }

  void _updateTimerDisplay() async {
    try {
      final status = await _maintenanceService.getMaintenanceStatus();
      final remainingTime = status.remainingTime;
      _remainingMinutes = remainingTime['minutes']!;
      _remainingSeconds = remainingTime['seconds']!;
      notifyListeners();
      
      if (status.remainingSeconds <= 0 && status.sessionEndTime != null && !_timerExpiredAndCleared) {
        _timerExpiredAndCleared = true;
        _maintenanceService.clearExpiredTimer();
        _timer?.cancel();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }

  void _startViewerUpdates() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _viewerCount = 15 + _random.nextInt(6);
      notifyListeners();
    });
  }

  void _listenToPosts() {
    _postsSubscription = _postService.getPostsStream().listen((snapshot) {
      _posts = snapshot.docs;
      notifyListeners();
    });
  }

  void onPostSubmitted() {
    _hasPosted = true;
    notifyListeners();
  }

  Future<void> addReaction(String postId, String emoji) async {
    try {
      await _postService.addReaction(postId, emoji);
    } catch (e) {
      // Handle error - could notify listeners with error state if needed
    }
  }

  bool get isTimerExpired => _timerExpiredAndCleared;

  @override
  void dispose() {
    _timer?.cancel();
    _viewerTimer?.cancel();
    _postsSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    super.dispose();
  }
}