import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/user/queue_user.dart';
import '../data/local_storage_service.dart';
import '../auth/auth_service.dart';

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
  final AuthService _authService = AuthService();

  List<String>? _lobbyUserIds;
  Map<String, String>? _lobbyUserNicknames;
  bool _isQueueStopped = false;

  Timer? _turnTimer;
  final StreamController<QueueState> _stateController = StreamController<QueueState>.broadcast();

  QueueState _currentState = const QueueState(
    queue: [],
    currentIndex: 0,
    isInitialized: false,
  );

  QueueState get currentState => _currentState;
  Stream<QueueState> get stateStream => _stateController.stream;

  /// Initialize queue with lobby user data
  Future<void> initialize({List<String>? lobbyUserIds, Map<String, String>? lobbyUserNicknames}) async {
    if (_currentState.isInitialized) return;

    _lobbyUserIds = lobbyUserIds;
    _lobbyUserNicknames = lobbyUserNicknames;
    await _createInitialQueue();
    _startTurnManagement();

    _currentState = _currentState.copyWith(isInitialized: true);
    _broadcastState();
  }

  /// Create queue from lobby users
  Future<void> _createInitialQueue() async {
    final realUserFloor = await _localStorageService.getFloor() ?? 1;
    final realUserWorld = await _localStorageService.getCurrentWorld();

    if (_lobbyUserIds == null || _lobbyUserIds!.isEmpty) {
      _currentState = QueueState(
        queue: [],
        activeUser: null,
        currentIndex: 0,
        isInitialized: false,
      );
      return;
    }

    final currentUserId = await _authService.getOrCreateAnonId();
    final queue = <QueueUser>[];

    for (int i = 0; i < _lobbyUserIds!.length; i++) {
      final userId = _lobbyUserIds![i];
      final isCurrentUser = userId == currentUserId;
      final nickname = _lobbyUserNicknames?[userId] ?? 'User${i + 1}';

      queue.add(QueueUser(
        id: userId,
        displayName: isCurrentUser ? 'You' : nickname,
        type: isCurrentUser ? QueueUserType.real : QueueUserType.dummy,
        state: i == 0 ? QueueUserState.active : QueueUserState.waiting,
        floor: realUserFloor,
        world: realUserWorld ?? 'Girl Meets College',
      ));
    }

    _currentState = QueueState(
      queue: queue,
      activeUser: queue.isNotEmpty ? queue.first : null,
      currentIndex: 0,
      isInitialized: false,
    );
  }

  void _startTurnManagement() {
    _turnTimer?.cancel();
    // Note: Users control queue advancement by posting, not auto-timers
    // Queue advances when user posts -> reaction timer -> next user
  }

  /// Check if real user can post
  bool canRealUserPost() {
    final activeUser = _currentState.activeUser;
    return activeUser != null && activeUser.isReal && activeUser.isActive;
  }

  /// Check if active user has posted
  bool get activeUserHasPosted {
    final activeUser = _currentState.activeUser;
    return activeUser != null && activeUser.hasPosted;
  }

  /// Handle real user post submission
  Future<void> handleRealUserPost() async {
    final activeUser = _currentState.activeUser;
    if (activeUser == null || !activeUser.isReal) return;

    final updatedQueue = List<QueueUser>.from(_currentState.queue);
    updatedQueue[_currentState.currentIndex] = activeUser.copyWith(
      state: QueueUserState.posted,
    );

    _currentState = _currentState.copyWith(queue: updatedQueue);
    _broadcastState();
    notifyListeners();

    // Move to next user after delay
    await Future.delayed(const Duration(seconds: 2));
    _advanceToNextUser();
  }

  /// Move to next user in queue
  void moveToNextUser() {
    _advanceToNextUser();
  }

  /// Start typing for real user
  void startRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (activeUser != null && activeUser.isReal) {
      final updatedQueue = List<QueueUser>.from(_currentState.queue);
      updatedQueue[_currentState.currentIndex] = activeUser.copyWith(
        typingState: TypingState.typing,
      );
      _currentState = _currentState.copyWith(queue: updatedQueue);
      _broadcastState();
      notifyListeners();
    }
  }

  /// Stop typing for real user
  void stopRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (activeUser != null && activeUser.isReal) {
      final updatedQueue = List<QueueUser>.from(_currentState.queue);
      updatedQueue[_currentState.currentIndex] = activeUser.copyWith(
        typingState: TypingState.idle,
      );
      _currentState = _currentState.copyWith(queue: updatedQueue);
      _broadcastState();
      notifyListeners();
    }
  }

  /// Stop queue rotation
  void stopQueueRotation() {
    _isQueueStopped = true;
    _turnTimer?.cancel();
  }

  void _advanceToNextUser() {
    if (_isQueueStopped || _currentState.queue.isEmpty) return;

    final nextIndex = (_currentState.currentIndex + 1) % _currentState.queue.length;
    final updatedQueue = List<QueueUser>.from(_currentState.queue);

    // Set previous user as completed
    updatedQueue[_currentState.currentIndex] = updatedQueue[_currentState.currentIndex].copyWith(
      state: QueueUserState.completed,
    );

    // Set next user as active
    updatedQueue[nextIndex] = updatedQueue[nextIndex].copyWith(
      state: QueueUserState.active,
      turnStartTime: DateTime.now(),
    );

    _currentState = _currentState.copyWith(
      queue: updatedQueue,
      currentIndex: nextIndex,
      activeUser: updatedQueue[nextIndex],
    );

    _broadcastState();
    notifyListeners();
  }

  void _broadcastState() {
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _stateController.close();
    super.dispose();
  }
}