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
  int _viewerCount = 6;
  List<QueryDocumentSnapshot> _posts = [];
  List<Map<String, dynamic>> _localBotPosts = [];
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
    final world = await _localStorageService.getWorldOrMigrateFromGender();
    
    await _postService.addPost(text.trim(), floor, world);
    // Wait a moment for Firestore to update the stream
    await Future.delayed(const Duration(milliseconds: 1000));
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
    // Navigate to session end when last user in queue is active
    final queue = _queueState.queue;
    final activeUser = _queueState.activeUser;
    
    if (queue.isEmpty || activeUser == null) return false;
    
    // Check if current active user is the last user in the queue
    final lastUserIndex = queue.length - 1;
    final currentIndex = _queueState.currentIndex;
    
    return currentIndex == lastUserIndex && activeUser.hasPosted;
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
    required int floor,
    required String world,
  }) {
    final botPost = {
      'id': 'local_bot_${DateTime.now().millisecondsSinceEpoch}',
      'confession': confession,
      'floor': floor,
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
    _postsSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    _queueSubscription?.cancel();
    _queueService.dispose();
    super.dispose();
  }
}