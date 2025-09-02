import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../services/post_service.dart';
import '../services/local_storage_service.dart';
import '../services/maintenance_service.dart';
import '../services/queue_service.dart';
import '../models/queue_user.dart';

class HomeViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final QueueService _queueService = QueueService();
  
  // State
  bool _hasPosted = false;
  int _viewerCount = 15;
  List<QueryDocumentSnapshot> _posts = [];
  QueueState _queueState = const QueueState(queue: [], currentIndex: 0, isInitialized: false);
  
  // Universal reaction timer state
  int _reactionTimeRemaining = 0; // in seconds
  bool _isReactionTimerActive = false;
  
  // Private
  Timer? _timer;
  Timer? _viewerTimer;
  StreamSubscription<QuerySnapshot>? _postsSubscription;
  StreamSubscription<QueueState>? _queueSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  final Random _random = Random();
  
  // Getters
  bool get hasPosted => _hasPosted;
  int get viewerCount => _viewerCount;
  List<QueryDocumentSnapshot> get posts => _posts;
  bool get shouldShowTimer {
    // Show timer only when the universal reaction timer is active
    return _isReactionTimerActive && _reactionTimeRemaining > 0;
  }

  String get timerDisplay {
    if (_isReactionTimerActive && _reactionTimeRemaining > 0) {
      final minutes = _reactionTimeRemaining ~/ 60;
      final seconds = _reactionTimeRemaining % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '00:00';
  }
  QueueState get queueState => _queueState;
  bool get canPost => _queueService.canRealUserPost();
  QueueUser? get activeUser => _queueState.activeUser;
  List<QueueUser> get upcomingUsers => _queueState.upcomingUsers;
  bool get activeUserHasPosted => _queueService.activeUserHasPosted;

  void initialize() {
    _loadHasPostedStatus();
    _startViewerUpdates();
    _listenToPosts();
    _initializeQueue();
    _startUniversalTimerUpdates();
  }

  void _loadHasPostedStatus() async {
    final hasPosted = await _localStorageService.getHasPosted();
    _hasPosted = hasPosted;
    notifyListeners();
  }

  void _startUniversalTimerUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isReactionTimerActive && _reactionTimeRemaining > 0) {
        _reactionTimeRemaining--;
        
        if (_reactionTimeRemaining <= 0) {
          _stopReactionTimer();
          // Move to next user in queue
          _queueService.moveToNextUser();
        }
        
        notifyListeners();
      }
    });
  }

  void _startReactionTimer() {
    _reactionTimeRemaining = 30; // 30 seconds for reactions
    _isReactionTimerActive = true;
    notifyListeners();
  }

  void _stopReactionTimer() {
    _isReactionTimerActive = false;
    _reactionTimeRemaining = 0;
    notifyListeners();
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
    _queueService.handleRealUserPost();
    notifyListeners();
  }

  Future<void> submitPost(String text) async {
    final floor = await _localStorageService.getFloor() ?? 1;
    final gender = await _localStorageService.getGender() ?? 'girl';
    
    await _postService.addPost(text.trim(), floor, gender);
    // Wait a moment for Firestore to update the stream
    await Future.delayed(const Duration(milliseconds: 1000));
    onPostSubmitted();
  }

  Future<void> addReaction(String postId, String emoji) async {
    try {
      await _postService.addReaction(postId, emoji);
    } catch (e) {
      // Handle error - could notify listeners with error state if needed
    }
  }

  void startRealUserTyping() {
    _queueService.startRealUserTyping();
  }

  void stopRealUserTyping() {
    _queueService.stopRealUserTyping();
  }

  bool get isTimerExpired => false; // Don't auto-navigate on timer expiry

  void _initializeQueue() async {
    await _queueService.initialize();
    _queueSubscription = _queueService.stateStream.listen((queueState) {
      final previousActiveUser = _queueState.activeUser;
      _queueState = queueState;
      
      // Check if active user has posted and start reaction timer
      final currentActiveUser = _queueState.activeUser;
      if (currentActiveUser != null && 
          currentActiveUser.hasPosted && 
          !_isReactionTimerActive &&
          (previousActiveUser?.id != currentActiveUser.id || !previousActiveUser!.hasPosted)) {
        _startReactionTimer();
      }
      
      notifyListeners();
    });
  }

@override
  void dispose() {
    _timer?.cancel();
    _viewerTimer?.cancel();
    _postsSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    _queueSubscription?.cancel();
    _queueService.dispose();
    super.dispose();
  }
}