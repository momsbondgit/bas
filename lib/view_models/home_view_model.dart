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
  final List<String>? lobbyUserIds;
  final Map<String, String>? lobbyUserNicknames;
  
  // State
  bool _hasPosted = false;
  int _viewerCount = 6;
  List<Map<String, dynamic>> _userPosts = []; // User's own posts only
  List<Map<String, dynamic>> _localBotPosts = [];
  List<Map<String, dynamic>> _firebasePosts = []; // Posts from Firebase (other users)
  QueueState _queueState = const QueueState(queue: [], currentIndex: 0, isInitialized: false);

  // Universal reaction timer state
  int _reactionTimeRemaining = 0; // in seconds
  bool _isReactionTimerActive = false;

  // Private
  Timer? _timer;
  Timer? _viewerTimer;
  StreamSubscription<QueueState>? _queueSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  StreamSubscription<QuerySnapshot>? _firebasePostsSubscription;
  final Random _random = Random();

  // Constructor
  HomeViewModel({this.lobbyUserIds, this.lobbyUserNicknames});

  // Getters
  bool get hasPosted => _hasPosted;
  int get viewerCount => _viewerCount;
  List<Map<String, dynamic>> get posts => [..._userPosts, ..._localBotPosts, ..._firebasePosts];
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
    _initializeFirebasePostsStream();
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
    print('[POST DEBUG] submitPost called with text: ${text.trim()}');

    final world = await _localStorageService.getCurrentWorld();
    final userId = await _localStorageService.getAnonId() ?? 'unknown';

    print('[POST DEBUG] User: $userId, World: $world');

    // Get the user's nickname from lobby data
    final userNickname = lobbyUserNicknames?[userId];
    print('[POST DEBUG] User nickname from lobby: $userNickname');

    // Add to local user posts immediately
    final userPost = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'confession': text.trim(),
      'world': world,
      'userId': userId,
      'customAuthor': userNickname, // Use the lobby nickname as author
      'createdAt': DateTime.now(),
      'isUserPost': true,
    };

    _userPosts.add(userPost);
    print('[POST DEBUG] Added to local user posts. Total user posts: ${_userPosts.length}');
    print('[POST DEBUG] User post data: $userPost');

    // Save to Firebase in background with nickname
    try {
      await _postService.addPost(text.trim(), world, userId, customAuthor: userNickname);
      print('[POST DEBUG] Successfully saved to Firebase');
    } catch (e) {
      print('[POST DEBUG] Error saving to Firebase: $e');
    }

    onPostSubmitted();
    print('[POST DEBUG] onPostSubmitted called, hasPosted: $_hasPosted');
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

  void stopQueueRotation() {
    _queueService.stopQueueRotation();
  }

  bool get isTimerExpired {
    // Navigate to session end when all users have posted AND reaction time is complete
    final queue = _queueState.queue;

    if (queue.isEmpty) {
      return false;
    }

    // Check if all users have posted
    final allUsersPosted = queue.every((user) =>
      user.hasPosted || user.state == QueueUserState.completed
    );

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
    // Initialize queue with lobby users only
    await _queueService.initialize(lobbyUserIds: lobbyUserIds, lobbyUserNicknames: lobbyUserNicknames);
    
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

  void _initializeFirebasePostsStream() async {
    final world = await _localStorageService.getCurrentWorld();
    print('[FIREBASE DEBUG] Initializing Firebase posts stream for world: $world');

    // Use the general posts stream to avoid index issues, then filter by world in memory
    _firebasePostsSubscription = _postService.getPostsStream().listen((snapshot) {
      print('[FIREBASE DEBUG] Firebase posts stream update received. Docs count: ${snapshot.docs.length}');

      final firebasePosts = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Filter by world in memory to avoid index requirements
        final postWorld = data['world'] as String?;
        if (postWorld == world) {
          // Add document ID for unique identification
          data['id'] = doc.id;
          firebasePosts.add(data);
          print('[FIREBASE DEBUG] Firebase post: ${data['confession']?.substring(0, 20) ?? 'no content'}... by ${data['customAuthor'] ?? 'no author'}');
        }
      }

      _firebasePosts = firebasePosts;
      print('[FIREBASE DEBUG] Total Firebase posts for world $world: ${_firebasePosts.length}');
      print('[FIREBASE DEBUG] Total all posts (user + local bot + firebase): ${posts.length}');
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
    _firebasePostsSubscription?.cancel();
    _queueService.dispose();
    super.dispose();
  }
}