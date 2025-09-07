import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../services/data/post_service.dart';
import '../services/data/local_storage_service.dart';
import '../services/admin/maintenance_service.dart';
import '../services/core/queue_service.dart';
import '../models/user/queue_user.dart';

class HomeViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final QueueService _queueService = QueueService();
  
  // State
  bool _hasPosted = false;
  int _viewerCount = 6;
  List<Map<String, dynamic>> _userPosts = []; // User's own posts only
  List<Map<String, dynamic>> _localBotPosts = [];
  QueueState _queueState = const QueueState(queue: [], currentIndex: 0, isInitialized: false);
  
  // Universal reaction timer state
  int _reactionTimeRemaining = 0; // in seconds
  bool _isReactionTimerActive = false;
  
  // Private
  Timer? _timer;
  Timer? _viewerTimer;
  StreamSubscription<QueueState>? _queueSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  final Random _random = Random();
  
  // Getters
  bool get hasPosted => _hasPosted;
  int get viewerCount => _viewerCount;
  List<Map<String, dynamic>> get posts => [..._userPosts, ..._localBotPosts];
  List<Map<String, dynamic>> get localBotPosts => _localBotPosts;
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
  bool get canPost {
    final result = _queueService.canRealUserPost();
    return result;
  }
  QueueUser? get activeUser => _queueState.activeUser;
  List<QueueUser> get upcomingUsers => _queueState.upcomingUsers;
  bool get activeUserHasPosted => _queueService.activeUserHasPosted;

  void initialize() {
    _loadHasPostedStatus();
    _startViewerUpdates();
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
    _reactionTimeRemaining = 20; // 20 seconds for reactions
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
      _viewerCount = 6;
      notifyListeners();
    });
  }


  void onPostSubmitted() {
    _hasPosted = true;
    _queueService.handleRealUserPost();
    notifyListeners();
  }

  Future<void> submitPost(String text) async {
    final world = await _localStorageService.getWorldOrMigrateFromGender();
    final userId = await _localStorageService.getAnonId() ?? 'unknown';
    
    // Add to local user posts immediately
    final userPost = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'confession': text.trim(),
      'world': world,
      'userId': userId,
      'createdAt': DateTime.now(),
      'isUserPost': true,
    };
    
    _userPosts.add(userPost);
    
    // Save to Firebase in background
    await _postService.addPost(text.trim(), world, userId);
    
    onPostSubmitted();
  }

  void addLocalReaction(String postId, String emoji) {
    // This method exists for API compatibility but doesn't write to Firebase
    // All reaction handling is now done locally in the UI components
  }


  void startRealUserTyping() {
    _queueService.startRealUserTyping();
  }

  void stopRealUserTyping() {
    _queueService.stopRealUserTyping();
  }

  bool get isTimerExpired {
    // Navigate to session end when all users have posted AND reaction time is complete
    final queue = _queueState.queue;
    
    if (queue.isEmpty) {
      return false;
    }
    
    // Check if all users have completed their posts (state == posted OR completed)
    final allUsersPosted = queue.every((user) => user.hasPosted || user.state == QueueUserState.completed);
    final postedCount = queue.where((user) => user.hasPosted || user.state == QueueUserState.completed).length;
    
    if (!allUsersPosted) {
      return false;
    }
    
    // Check if 6th user (queue.last) has posted and universal reaction timer expired
    if (queue.length == 6) {
      final lastUser = queue[5]; // 6th user (0-indexed)
      final lastUserHasPosted = lastUser.hasPosted || lastUser.state == QueueUserState.completed;
      final reactionTimerExpired = !_isReactionTimerActive && _reactionTimeRemaining <= 0;
      
      
      return lastUserHasPosted && reactionTimerExpired;
    }
    
    return false;
  }

  void _initializeQueue() async {
    // Set up callback for bot posts
    _queueService.onBotPost = addLocalBotPost;
    
    await _queueService.initialize();
    
    // Get the initial state immediately after initialization
    _queueState = _queueService.currentState;
    notifyListeners();
    
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

  /// Add a local bot post (not saved to Firebase)
  void addLocalBotPost({
    required String botNickname,
    required String confession,
    required String world,
  }) {
    final botPost = {
      'id': 'local_bot_${DateTime.now().millisecondsSinceEpoch}',
      'confession': confession,
      'world': world,
      'customAuthor': botNickname, // Use bot's actual nickname
      'createdAt': DateTime.now(),
      'isLocalBotPost': true,
    };

    _localBotPosts.add(botPost);
    notifyListeners();
  }

@override
  void dispose() {
    _timer?.cancel();
    _viewerTimer?.cancel();
    _maintenanceSubscription?.cancel();
    _queueSubscription?.cancel();
    _queueService.dispose();
    super.dispose();
  }
}