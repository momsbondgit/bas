import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/queue_user.dart';
import '../models/bot_user.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../services/bot_assignment_service.dart';

class QueueState {
  final List<QueueUser> queue;
  final QueueUser? activeUser;
  final int currentIndex;
  final bool isInitialized;

  const QueueState({
    required this.queue,
    this.activeUser,
    required this.currentIndex,
    required this.isInitialized,
  });

  QueueState copyWith({
    List<QueueUser>? queue,
    QueueUser? activeUser,
    int? currentIndex,
    bool? isInitialized,
  }) {
    return QueueState(
      queue: queue ?? this.queue,
      activeUser: activeUser ?? this.activeUser,
      currentIndex: currentIndex ?? this.currentIndex,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  List<QueueUser> get upcomingUsers {
    if (queue.isEmpty) return [];
    final upcoming = <QueueUser>[];
    for (int i = 1; i < queue.length; i++) {
      final index = (currentIndex + i) % queue.length;
      upcoming.add(queue[index]);
    }
    return upcoming;
  }
}

class QueueService extends ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final BotAssignmentService _botAssignmentService = BotAssignmentService();
  final Random _random = Random();
  
  List<BotUser> _assignedBots = [];
  
  // Callback for when a bot posts locally
  Function({required String botNickname, required String confession, required int floor, required String gender})? onBotPost;
  
  
  Timer? _turnTimer;
  Timer? _dummyActionTimer;
  Timer? _typingTimer;
  Timer? _botTypingDelayTimer;
  final StreamController<QueueState> _stateController = StreamController<QueueState>.broadcast();
  
  QueueState _currentState = const QueueState(
    queue: [],
    currentIndex: 0,
    isInitialized: false,
  );

  QueueState get currentState => _currentState;
  Stream<QueueState> get stateStream => _stateController.stream;

  // Configuration constants
  static const int turnDurationSeconds = 60;
  static const int baseBotTypingDelaySeconds = 15;
  static const int maxBotTypingDelaySeconds = 25;
  static const int maxTurnTimeForBots = 10;
  static const int reactionTimerSeconds = 20;
  static const int unlimitedTimeForRealUsers = 999999;


  /// Initializes the queue service with users and starts all timers
  Future<void> initialize() async {
    if (_currentState.isInitialized) {
      return;
    }

    await _loadAssignedBots();
    await _createInitialQueue();
    _startAllTimers();
    
    _currentState = _currentState.copyWith(isInitialized: true);
    _broadcastState();
  }

  /// Load user's assigned bots from Firebase (handles returning users with fresh bots)
  Future<void> _loadAssignedBots() async {
    try {
      final anonId = await _authService.getOrCreateAnonId();
      
      // Check if this is a returning user
      final isReturningUser = await _localStorageService.recordSessionAndCheckIfReturning();
      
      if (isReturningUser) {
        // Returning users get fresh bot assignments for new experience
        final sessionCount = await _localStorageService.getSessionCount();
        await _botAssignmentService.reassignBotsForReturningUser(anonId, sessionCount);
      } else {
        // First-time users get initial bot assignments
        await _botAssignmentService.ensureUserHasBots(anonId);
      }
      
      _assignedBots = await _botAssignmentService.getAssignedBots(anonId);
    } catch (e) {
      _assignedBots = [];
    }
  }

  /// Starts all timer-based services
  void _startAllTimers() {
    _startTurnManagement();
    _startDummySimulation();
    _startTypingSimulation();
  }

  Future<void> _createInitialQueue() async {
    final realUserFloor = await _localStorageService.getFloor() ?? 1;
    final realUserGender = await _localStorageService.getGender() ?? 'girl';
    
    final realUser = QueueUser(
      id: 'real_user',
      displayName: 'You',
      type: QueueUserType.real,
      state: QueueUserState.waiting,
      floor: realUserFloor,
      gender: realUserGender,
    );
    
    final botUsers = List.generate(
      _assignedBots.length.clamp(0, 5), 
      (index) => _createDummyUser(index)
    );
    
    // Determine user's queue position (random for returning users, third for new users)
    final sessionCount = await _localStorageService.getSessionCount();
    final isReturningUser = sessionCount > 1;
    
    List<QueueUser> queue;
    
    if (isReturningUser) {
      // Returning users get random position (2-6, never first)
      final availablePositions = List.generate(botUsers.length, (i) => i + 1)
          .where((pos) => pos > 0) // Never position 0 (first)
          .toList();
      
      if (availablePositions.isEmpty) availablePositions.add(1); // Fallback
      
      final userPosition = availablePositions[_random.nextInt(availablePositions.length)];
      
      // Build queue with user at random position
      queue = <QueueUser>[];
      
      // Add first bot as active
      if (botUsers.isNotEmpty) {
        queue.add(botUsers[0].copyWith(state: QueueUserState.active, turnStartTime: DateTime.now()));
      }
      
      // Add remaining bots and user at specified position
      for (int i = 1; i < botUsers.length + 1; i++) {
        if (i == userPosition) {
          queue.add(realUser);
        } else {
          final botIndex = i > userPosition ? i - 1 : i;
          if (botIndex < botUsers.length && botIndex > 0) {
            queue.add(botUsers[botIndex]);
          }
        }
      }
      
      // Ensure user is added if position is at end
      if (userPosition >= botUsers.length) {
        queue.add(realUser);
      }
    } else {
      // New users get third position (existing behavior)
      queue = <QueueUser>[
        if (botUsers.isNotEmpty) botUsers[0].copyWith(state: QueueUserState.active, turnStartTime: DateTime.now()),
        if (botUsers.length > 1) botUsers[1],
        realUser,
        ...botUsers.skip(2),
      ];
    }

    _currentState = QueueState(
      queue: queue,
      activeUser: queue.first,
      currentIndex: 0,
      isInitialized: false,
    );
  }

  QueueUser _createDummyUser(int index) {
    if (_assignedBots.isEmpty || index >= _assignedBots.length) {
      throw Exception('No assigned bots available or invalid index: $index');
    }
    
    final floors = [1, 2, 3, 4, 5];
    final genders = ['girl', 'boy'];
    final bot = _assignedBots[index];
    
    return QueueUser(
      id: bot.botId,
      displayName: bot.nickname,
      type: QueueUserType.dummy,
      state: QueueUserState.waiting,
      floor: floors[_random.nextInt(floors.length)],
      gender: genders[_random.nextInt(genders.length)],
    );
  }

  void _startTurnManagement() {
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkTurnTimeout();
    });
  }

  void _checkTurnTimeout() {
    final activeUser = _currentState.activeUser;
    if (activeUser == null) return;

    // Skip timeout check for real users - they have unlimited time
    if (activeUser.isReal) return;

    // Only apply timeout to bot users
    if (activeUser.remainingTurnSeconds <= 0) {
      _advanceToNextUser();
    }
  }

  /// Advances queue to the next user in line
  void _advanceToNextUser() {
    final queue = _currentState.queue;
    if (queue.isEmpty) return;

    final currentUser = _currentState.activeUser;
    final nextIndex = _calculateNextIndex();
    final nextUser = queue[nextIndex];
    
    final updatedQueue = List<QueueUser>.from(queue);
    
    if (_isStartingNewRound(nextIndex)) {
      _resetCompletedUsers(updatedQueue);
    }
    
    _updateCurrentUserAsCompleted(updatedQueue);
    _activateNextUser(updatedQueue, nextIndex);
    _updateQueueState(updatedQueue, nextIndex);
  }

  /// Calculates the next user index in the queue
  int _calculateNextIndex() {
    return (_currentState.currentIndex + 1) % _currentState.queue.length;
  }

  /// Checks if we're starting a new round (back to index 0)
  bool _isStartingNewRound(int nextIndex) {
    return nextIndex == 0;
  }

  /// Resets all completed users back to waiting state for new round
  void _resetCompletedUsers(List<QueueUser> queue) {
    for (int i = 0; i < queue.length; i++) {
      if (queue[i].state == QueueUserState.completed) {
        queue[i] = queue[i].copyWith(
          state: QueueUserState.waiting,
          turnStartTime: null,
          reactionStartTime: null,
        );
      }
    }
  }

  /// Marks current active user as completed
  void _updateCurrentUserAsCompleted(List<QueueUser> queue) {
    final currentUser = _currentState.activeUser?.copyWith(
      state: QueueUserState.completed,
      turnStartTime: null,
    );
    if (currentUser != null) {
      queue[_currentState.currentIndex] = currentUser;
    }
  }

  /// Activates the next user in the queue
  void _activateNextUser(List<QueueUser> queue, int nextIndex) {
    final nextUser = queue[nextIndex].copyWith(
      state: QueueUserState.active,
      turnStartTime: DateTime.now(),
    );
    queue[nextIndex] = nextUser;
  }

  /// Updates the queue state with new queue and active user
  void _updateQueueState(List<QueueUser> updatedQueue, int nextIndex) {
    _currentState = _currentState.copyWith(
      queue: updatedQueue,
      activeUser: updatedQueue[nextIndex],
      currentIndex: nextIndex,
    );

    _broadcastState();
    notifyListeners();
  }

  void _startDummySimulation() {
    _dummyActionTimer?.cancel();
    _dummyActionTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _handleDummyUserAction();
    });
  }

  /// Handles bot user actions - ensures consistent flow for all bots
  void _handleDummyUserAction() {
    final activeUser = _currentState.activeUser;
    
    if (!_isBotUserActive(activeUser)) return;
    
    // Every bot must go through the complete flow: typing → delay → post → reaction timer
    if (!activeUser!.isTyping && !activeUser.hasPosted) {
      _startBotTurnSequence(activeUser);
    }
  }

  /// Checks if the active user is a bot
  bool _isBotUserActive(QueueUser? user) {
    return user != null && !user.isReal;
  }

  /// Starts the complete bot turn sequence
  void _startBotTurnSequence(QueueUser botUser) {
    final confession = _getBotResponse(botUser.id);
    final typingDelay = _calculateBotTypingDelay(confession);
    
    // Start typing immediately
    _startTyping(botUser);
    
    // Schedule post after calculated delay
    _botTypingDelayTimer?.cancel();
    _botTypingDelayTimer = Timer(
      Duration(seconds: typingDelay),
      () => _simulateDummyPost(botUser)
    );
  }

  /// Calculates typing delay based on word count (10-15 seconds)
  int _calculateBotTypingDelay(String confession) {
    final wordCount = confession.split(' ').length;
    final baseDelay = baseBotTypingDelaySeconds;
    final extraTime = (wordCount / 10).ceil(); // 1 extra second per 10 words
    return (baseDelay + extraTime).clamp(baseBotTypingDelaySeconds, maxBotTypingDelaySeconds);
  }


  /// Simulates a bot user posting a confession (local-only, no Firebase write)
  Future<void> _simulateDummyPost(QueueUser dummyUser) async {
    try {
      final confession = _getBotResponse(dummyUser.id);
      
      // Add bot post locally via callback
      onBotPost?.call(
        botNickname: dummyUser.displayName,
        confession: confession,
        floor: dummyUser.floor,
        gender: dummyUser.gender,
      );
      
      
      _transitionToPostedState(dummyUser);
    } catch (e) {
      // Silent fail for dummy posts to prevent disruption
    }
  }

  /// Gets the specific response for a bot user
  String _getBotResponse(String botId) {
    final bot = _assignedBots.firstWhere(
      (bot) => bot.botId == botId,
      orElse: () => throw Exception('Bot with ID $botId not found in assigned bots'),
    );
    return bot.quineResponse;
  }

  /// Checks if the real user can post (is active and real)
  bool canRealUserPost() {
    final activeUser = _currentState.activeUser;
    final result = activeUser != null && activeUser.isReal && activeUser.isActive;
    return result;
  }

  /// Checks if the currently active user has posted
  bool get activeUserHasPosted {
    final activeUser = _currentState.activeUser;
    return activeUser != null && activeUser.hasPosted;
  }

  /// Handles when the real user submits a post
  Future<void> handleRealUserPost() async {
    final activeUser = _currentState.activeUser;
    if (!_isRealUserActive(activeUser)) return;

    if (activeUser!.isTyping) {
      _stopTyping(activeUser);
    }

    await _delayBeforeStateTransition();
    _transitionToPostedState(activeUser);
  }

  /// Checks if active user is the real user
  bool _isRealUserActive(QueueUser? user) {
    return user != null && user.isReal;
  }

  /// Small delay before transitioning state for better UX
  Future<void> _delayBeforeStateTransition() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _broadcastState() {
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }

  void _startTypingSimulation() {
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _handleTypingSimulation();
    });
  }

  void _handleTypingSimulation() {
    // Remove random typing simulation for bots
    // Bots will only show typing when they're about to post (via _startBotTypingDelay)
    return;
  }

  void _startTyping(QueueUser user) {
    final updatedUser = user.copyWith(
      typingState: TypingState.typing,
      typingStartTime: DateTime.now(),
    );

    final queue = List<QueueUser>.from(_currentState.queue);
    final userIndex = queue.indexWhere((u) => u.id == user.id);
    if (userIndex != -1) {
      queue[userIndex] = updatedUser;
      
      _currentState = _currentState.copyWith(
        queue: queue,
        activeUser: updatedUser,
      );
      
      _broadcastState();
      notifyListeners();
    }
  }

  void _stopTyping(QueueUser user) {
    final updatedUser = user.copyWith(
      typingState: TypingState.idle,
      typingStartTime: null,
    );

    final queue = List<QueueUser>.from(_currentState.queue);
    final userIndex = queue.indexWhere((u) => u.id == user.id);
    if (userIndex != -1) {
      queue[userIndex] = updatedUser;
      
      _currentState = _currentState.copyWith(
        queue: queue,
        activeUser: updatedUser,
      );
      
      _broadcastState();
      notifyListeners();
    }
  }

  /// Starts typing indicator for real user
  void startRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (!_isRealUserActive(activeUser)) return;
    
    _startTyping(activeUser!);
  }

  /// Stops typing indicator for real user
  void stopRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (!_isRealUserActive(activeUser)) return;
    
    _stopTyping(activeUser!);
  }

  /// Transitions user to posted state after submitting
  void _transitionToPostedState(QueueUser user) {
    final updatedUser = _createPostedUser(user);
    final queue = _updateUserInQueue(user.id, updatedUser);
    
    if (queue != null) {
      _updateStateWithPostedUser(queue, updatedUser);
    }
  }

  /// Creates a user in posted state
  QueueUser _createPostedUser(QueueUser user) {
    return user.copyWith(
      state: QueueUserState.posted,
      typingState: TypingState.idle,
      typingStartTime: null,
      reactionStartTime: DateTime.now(),
    );
  }

  /// Updates a specific user in the queue and returns new queue
  List<QueueUser>? _updateUserInQueue(String userId, QueueUser updatedUser) {
    final queue = List<QueueUser>.from(_currentState.queue);
    final userIndex = queue.indexWhere((u) => u.id == userId);
    
    if (userIndex != -1) {
      queue[userIndex] = updatedUser;
      return queue;
    }
    return null;
  }

  /// Updates state with posted user and broadcasts changes
  void _updateStateWithPostedUser(List<QueueUser> queue, QueueUser updatedUser) {
    _currentState = _currentState.copyWith(
      queue: queue,
      activeUser: updatedUser,
    );
    
    _broadcastState();
    notifyListeners();
  }

  /// Public method for HomeViewModel to advance queue when timer expires
  void moveToNextUser() {
    _advanceToNextUser();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _dummyActionTimer?.cancel();
    _typingTimer?.cancel();
    _botTypingDelayTimer?.cancel();
    _stateController.close();
    super.dispose();
  }
}