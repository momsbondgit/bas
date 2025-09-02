import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/queue_user.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';

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
  final Random _random = Random();
  
  Timer? _turnTimer;
  Timer? _dummyActionTimer;
  Timer? _typingTimer;
  final StreamController<QueueState> _stateController = StreamController<QueueState>.broadcast();
  
  QueueState _currentState = const QueueState(
    queue: [],
    currentIndex: 0,
    isInitialized: false,
  );

  QueueState get currentState => _currentState;
  Stream<QueueState> get stateStream => _stateController.stream;

  static const int turnDurationSeconds = 60;
  static const List<String> dummyNames = [
    'THATGIRL123',
    'Who IS ShE', 
    'Girlly',
    '316 girlly'
  ];

  static const List<String> dummyConfessions = [
    'Okay so I literally pretended to drop my pencil in calc just to pick it up near his desk and he didn\'t even notice 😭',
    'I joined the debate team just because he was in it and now I have to actually debate... what have I done',
    'Asked him for his number saying it was for a group project that didn\'t exist. Got his number but now I have to make up a fake project 💀',
    'Wore his favorite color every day for two weeks straight hoping he\'d notice... he complimented my friend instead',
    'I learned to skateboard because he mentioned he liked skater girls. Fell flat on my face in front of him the first day',
    'Signed up for the same electives as him three semesters in a row. My transcript looks so random now lol',
    'Pretended to be into his favorite band and bought concert tickets just to \'accidentally\' run into him there',
    'I started going to the library at the exact times he does his homework. Been there for 3 weeks, still no courage to say hi'
  ];

  Future<void> initialize() async {
    if (_currentState.isInitialized) return;

    await _createInitialQueue();
    _startTurnManagement();
    _startDummySimulation();
    _startTypingSimulation();
    
    _currentState = _currentState.copyWith(isInitialized: true);
    _broadcastState();
  }

  Future<void> _createInitialQueue() async {
    final realUserFloor = await _localStorageService.getFloor() ?? 1;
    final realUserGender = await _localStorageService.getGender() ?? 'girl';
    
    final queue = <QueueUser>[
      QueueUser(
        id: 'real_user',
        displayName: 'You',
        type: QueueUserType.real,
        state: QueueUserState.active,
        turnStartTime: DateTime.now(),
        floor: realUserFloor,
        gender: realUserGender,
      ),
      ...List.generate(3, (index) => _createDummyUser(index)),
    ];

    _currentState = QueueState(
      queue: queue,
      activeUser: queue.first,
      currentIndex: 0,
      isInitialized: false,
    );
  }

  QueueUser _createDummyUser(int index) {
    final floors = [1, 2, 3, 4, 5];
    final genders = ['girl', 'boy'];
    
    return QueueUser(
      id: 'dummy_${index + 1}',
      displayName: dummyNames[index % dummyNames.length],
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

    if (activeUser.remainingTurnSeconds <= 0) {
      _advanceToNextUser();
    }
  }

  void _advanceToNextUser() {
    final queue = _currentState.queue;
    if (queue.isEmpty) return;

    final nextIndex = (_currentState.currentIndex + 1) % queue.length;
    final nextUser = queue[nextIndex].copyWith(
      state: QueueUserState.active,
      turnStartTime: DateTime.now(),
    );

    final currentUser = _currentState.activeUser?.copyWith(
      state: QueueUserState.completed,
      turnStartTime: null,
    );

    final updatedQueue = List<QueueUser>.from(queue);
    if (currentUser != null) {
      updatedQueue[_currentState.currentIndex] = currentUser;
    }
    updatedQueue[nextIndex] = nextUser;

    _currentState = _currentState.copyWith(
      queue: updatedQueue,
      activeUser: nextUser,
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

  void _handleDummyUserAction() {
    final activeUser = _currentState.activeUser;
    if (activeUser == null || activeUser.isReal) return;

    final shouldPost = _random.nextDouble() < 0.3;
    if (shouldPost) {
      _simulateDummyPost(activeUser);
    }

    final shouldAdvance = _random.nextDouble() < 0.1 || activeUser.remainingTurnSeconds < 10;
    if (shouldAdvance) {
      _advanceToNextUser();
    }
  }

  Future<void> _simulateDummyPost(QueueUser dummyUser) async {
    try {
      final confession = dummyConfessions[_random.nextInt(dummyConfessions.length)];
      await _postService.addPost(confession, dummyUser.floor, dummyUser.gender);
      
      // Transition to posted state and start reaction timer
      _transitionToPostedState(dummyUser);
    } catch (e) {
      // Silent fail for dummy posts
    }
  }

  bool canRealUserPost() {
    final activeUser = _currentState.activeUser;
    return activeUser != null && activeUser.isReal && activeUser.isActive;
  }

  bool get activeUserHasPosted {
    final activeUser = _currentState.activeUser;
    return activeUser != null && activeUser.hasPosted;
  }

  Future<void> handleRealUserPost() async {
    final activeUser = _currentState.activeUser;
    if (activeUser == null || !activeUser.isReal) return;

    if (activeUser.isTyping) {
      _stopTyping(activeUser);
    }

    // Transition to posted state and start reaction timer
    await Future.delayed(const Duration(milliseconds: 500));
    _transitionToPostedState(activeUser);
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
    final activeUser = _currentState.activeUser;
    if (activeUser == null || activeUser.isReal) return;

    if (activeUser.isTyping) {
      final typingDuration = activeUser.typingStartTime != null
          ? DateTime.now().difference(activeUser.typingStartTime!).inSeconds
          : 0;
      
      if (typingDuration >= 3 + _random.nextInt(4)) {
        _stopTyping(activeUser);
      }
    } else {
      final shouldStartTyping = _random.nextDouble() < 0.4;
      if (shouldStartTyping) {
        _startTyping(activeUser);
      }
    }
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

  void startRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (activeUser == null || !activeUser.isReal) return;
    
    _startTyping(activeUser);
  }

  void stopRealUserTyping() {
    final activeUser = _currentState.activeUser;
    if (activeUser == null || !activeUser.isReal) return;
    
    _stopTyping(activeUser);
  }

  void _transitionToPostedState(QueueUser user) {
    final updatedUser = user.copyWith(
      state: QueueUserState.posted,
      typingState: TypingState.idle,
      typingStartTime: null,
      reactionStartTime: DateTime.now(),
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
      
      // No longer start individual reaction timer - let HomeViewModel handle universal timer
    }
  }

  // Public method for HomeViewModel to call when universal timer expires
  void moveToNextUser() {
    _advanceToNextUser();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _dummyActionTimer?.cancel();
    _typingTimer?.cancel();
    _stateController.close();
    super.dispose();
  }
}