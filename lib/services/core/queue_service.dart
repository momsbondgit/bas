import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user/queue_user.dart';
import '../../models/user/bot_user.dart';
import '../data/local_storage_service.dart';
import '../auth/auth_service.dart';
import '../simulation/bot_assignment_service.dart';

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
  final BotAssignmentService _botAssignmentService = BotAssignmentService();
  final Random _random = Random();

  List<BotUser> _assignedBots = [];
  bool _isQueueStopped = false;

  // Callback for when a bot posts locally
  Function({required String botNickname, required String confession, required String world})? onBotPost;
  
  
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
  static const int baseBotTypingDelaySeconds = 20;  // Increased from 15
  static const int maxBotTypingDelaySeconds = 30;  // Increased from 25
  static const int maxTurnTimeForBots = 10;
  static const int reactionTimerSeconds = 35;  // Increased from 30
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

  /// Load user's assigned bots from local storage (based on vibe check)
  Future<void> _loadAssignedBots() async {
    try {
      // Principle: Bot assignment initialization - System loads user's vibe-matched bot table to create personalized interaction experiences

      // Get assigned bots from BotAssignmentService
      _assignedBots = await _botAssignmentService.getAssignedBots();
      // Principle: Successful bot table matching - User's vibe check results successfully mapped to appropriate bot personality table

      // If no bots assigned, this means user hasn't done vibe check yet
      if (_assignedBots.isEmpty) {
        // Principle: Prerequisite validation - Vibe check completion required before bot assignment and queue participation
      }
    } catch (e) {
      // Principle: Error resilience - Bot assignment failures are handled gracefully to maintain queue functionality
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
    final realUserWorld = await _localStorageService.getCurrentWorld();
    
    final realUser = QueueUser(
      id: 'real_user',
      displayName: 'You',
      type: QueueUserType.real,
      state: QueueUserState.waiting,
      floor: realUserFloor,
      world: realUserWorld,
    );
    
    final botUsers = List.generate(
      _assignedBots.length.clamp(0, 5), 
      (index) => _createDummyUser(index)
    );
    
    // Always place user at position 3 (index 2)
    final userPosition = 2;
    
    // Build queue with user at random position
    List<QueueUser> queue = <QueueUser>[];
    
    // Add first bot as active
    if (botUsers.isNotEmpty) {
      queue.add(botUsers[0].copyWith(state: QueueUserState.active, turnStartTime: DateTime.now()));
    }
    
    // Add remaining bots and user at specified position
    bool userAdded = false;
    for (int i = 1; i < botUsers.length + 1; i++) {
      if (i == userPosition && !userAdded) {
        queue.add(realUser);
        userAdded = true;
      } else {
        final botIndex = i > userPosition ? i - 1 : i;
        if (botIndex < botUsers.length && botIndex > 0) {
          queue.add(botUsers[botIndex]);
        }
      }
    }
    
    // Ensure user is added if position is at end (only if not already added)
    if (userPosition >= botUsers.length && !userAdded) {
      queue.add(realUser);
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
    final bot = _assignedBots[index];
    
    // Determine world based on bot's origin (all bots in same world as real user)
    final world = _getCurrentUserWorld();
    
    return QueueUser(
      id: bot.botId,
      displayName: bot.nickname,
      type: QueueUserType.dummy,
      state: QueueUserState.waiting,
      floor: floors[_random.nextInt(floors.length)],
      world: world,
    );
  }

  String _getCurrentUserWorld() {
    // Get world from current queue real user, or default to Girl Meets College
    final realUser = _currentState.queue.firstWhere(
      (user) => user.type == QueueUserType.real,
      orElse: () => const QueueUser(
        id: 'default',
        displayName: 'Default',
        type: QueueUserType.real,
        state: QueueUserState.waiting,
        floor: 1,
        world: 'Girl Meets College',
      ),
    );
    return realUser.world;
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
    // Don't advance if queue is stopped
    if (_isQueueStopped) return;

    final queue = _currentState.queue;
    if (queue.isEmpty) return;

    final nextIndex = _calculateNextIndex();
    
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
        world: dummyUser.world,
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

  /// Stops the queue rotation (called when goodbye popup appears)
  void stopQueueRotation() {
    _isQueueStopped = true;
    _turnTimer?.cancel();
    _dummyActionTimer?.cancel();
    _typingTimer?.cancel();
    _botTypingDelayTimer?.cancel();
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