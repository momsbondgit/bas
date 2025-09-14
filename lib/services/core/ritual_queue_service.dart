import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/queue/ritual_queue_state.dart';
import '../../models/user/queue_user.dart';
import '../../models/data/message.dart';
import '../../config/ritual_config.dart';
import '../data/local_storage_service.dart';

class RitualQueueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final StreamController<RitualQueueState> _queueStateController = StreamController<RitualQueueState>.broadcast();

  Timer? _turnTimer;
  RitualQueueState? _currentState;
  bool _isSessionExpired = false;

  Stream<RitualQueueState> get queueStateStream => _queueStateController.stream;
  RitualQueueState? get currentState => _currentState;

  CollectionReference get _queueCollection => _firestore.collection('ritual_queue');
  CollectionReference get _messagesCollection => _firestore.collection('ritual_messages');

  Future<void> initialize() async {
    await _getOrCreateUserId();
    await _loadInitialState();
    _startListening();
  }

  Future<String> _getOrCreateUserId() async {
    String? userId = await _localStorage.getRitualUserId();
    
    if (userId == null) {
      userId = _generateUniqueId();
      await _localStorage.setRitualUserId(userId);
    }
    
    return userId;
  }

  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'ritual_${timestamp}_$randomNum';
  }

  Future<void> _loadInitialState() async {
    try {
      final queueDoc = await _queueCollection.doc('current').get();
      
      if (queueDoc.exists) {
        final data = queueDoc.data() as Map<String, dynamic>;
        _currentState = RitualQueueState.fromMap(data);
      } else {
        _currentState = _createInitialState();
        await _saveState(_currentState!);
      }
      
      _queueStateController.add(_currentState!);
    } catch (e) {
      throw Exception('Failed to initialize ritual queue: $e');
    }
  }

  RitualQueueState _createInitialState() {
    return const RitualQueueState(
      activeUserId: '',
      activeDisplayName: '',
      phase: QueuePhase.waiting,
      remainingTime: RitualConfig.defaultTurnDuration,
      userQueue: [],
    );
  }

  void _startListening() {
    _queueCollection.doc('current').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final newState = RitualQueueState.fromMap(data);
        
        if (_currentState != newState) {
          _currentState = newState;
          _queueStateController.add(newState);
          _handleStateChange(newState);
        }
      }
    });
  }

  void _handleStateChange(RitualQueueState newState) {
    if (newState.phase == QueuePhase.submitted && _turnTimer == null) {
      _startTurnTimer();
    } else if (newState.phase == QueuePhase.rotating) {
      _cancelTurnTimer();
    }
  }

  void _startTurnTimer() {
    _cancelTurnTimer();

    // Don't start timer if session is expired
    if (_isSessionExpired) return;

    _turnTimer = Timer(RitualConfig.defaultTurnDuration, () async {
      await rotateQueue();
    });
  }

  void _cancelTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  Future<void> startTyping(String userId) async {
    if (_currentState?.activeUserId != userId) return;

    final newState = _currentState!.startTyping();
    await _saveState(newState);
  }

  Future<void> stopTyping(String userId) async {
    if (_currentState?.activeUserId != userId) return;
    if (_currentState?.phase != QueuePhase.typing) return;

    final newState = _currentState!.copyWith(phase: QueuePhase.waiting);
    await _saveState(newState);
  }

  Future<void> submitMessage(String userId, String content) async {
    if (_currentState?.activeUserId != userId) {
      return;
    }
    if (content.trim().isEmpty) {
      return;
    }

    final message = Message(
      id: _generateMessageId(),
      userId: userId,
      displayName: _currentState!.activeDisplayName,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    await _messagesCollection.doc(message.id).set(message.toMap());

    final newState = _currentState!.submitMessage(message);
    await _saveState(newState);
  }


  Future<void> rotateQueue() async {
    // Stop rotation if session is expired
    if (_isSessionExpired) return;
    if (_currentState == null || _currentState!.userQueue.isEmpty) return;

    final currentQueue = List<QueueUser>.from(_currentState!.userQueue);
    final currentActiveIndex = currentQueue.indexWhere((user) => user.isActive);
    
    if (currentActiveIndex == -1) return;

    final nextIndex = (currentActiveIndex + 1) % currentQueue.length;
    final nextUser = currentQueue[nextIndex];

    final rotatingState = _currentState!.startRotation(nextUser.displayName);
    await _saveState(rotatingState);

    await Future.delayed(const Duration(milliseconds: 500));

    final updatedQueue = currentQueue.asMap().entries.map((entry) {
      return entry.value.copyWith(isActive: entry.key == nextIndex);
    }).toList();

    final completedState = rotatingState.completeRotation(
      nextUser.userId,
      nextUser.displayName,
      updatedQueue,
    );

    await _saveState(completedState);

    Timer(RitualConfig.bannerDisplayDuration, () async {
      if (_currentState?.showRotationBanner == true) {
        final dismissedState = _currentState!.dismissRotationBanner();
        await _saveState(dismissedState);
      }
    });
  }

  Future<void> addUserToQueue(String userId, String displayName) async {
    if (_currentState == null) return;

    final currentQueue = List<QueueUser>.from(_currentState!.userQueue);
    
    if (currentQueue.any((user) => user.userId == userId)) return;

    final newUser = QueueUser(
      userId: userId,
      displayName: displayName,
      isActive: currentQueue.isEmpty,
      position: currentQueue.length,
    );

    currentQueue.add(newUser);

    final newState = _currentState!.copyWith(
      userQueue: currentQueue,
      activeUserId: currentQueue.isEmpty ? userId : _currentState!.activeUserId,
      activeDisplayName: currentQueue.isEmpty ? displayName : _currentState!.activeDisplayName,
    );

    await _saveState(newState);
  }

  Future<void> removeUserFromQueue(String userId) async {
    if (_currentState == null) return;

    final currentQueue = List<QueueUser>.from(_currentState!.userQueue);
    final userIndex = currentQueue.indexWhere((user) => user.userId == userId);
    
    if (userIndex == -1) return;

    final wasActive = currentQueue[userIndex].isActive;
    currentQueue.removeAt(userIndex);

    for (int i = 0; i < currentQueue.length; i++) {
      currentQueue[i] = currentQueue[i].copyWith(position: i);
    }

    String newActiveUserId = _currentState!.activeUserId;
    String newActiveDisplayName = _currentState!.activeDisplayName;

    if (wasActive && currentQueue.isNotEmpty) {
      final nextActiveIndex = userIndex < currentQueue.length ? userIndex : 0;
      currentQueue[nextActiveIndex] = currentQueue[nextActiveIndex].copyWith(isActive: true);
      newActiveUserId = currentQueue[nextActiveIndex].userId;
      newActiveDisplayName = currentQueue[nextActiveIndex].displayName;
    } else if (currentQueue.isEmpty) {
      newActiveUserId = '';
      newActiveDisplayName = '';
    }

    final newState = _currentState!.copyWith(
      userQueue: currentQueue,
      activeUserId: newActiveUserId,
      activeDisplayName: newActiveDisplayName,
    );

    await _saveState(newState);
  }

  Future<void> _saveState(RitualQueueState state) async {
    try {
      await _queueCollection.doc('current').set(state.toMap());
      _currentState = state;
    } catch (e) {
      throw Exception('Failed to save ritual queue state: $e');
    }
  }

  String _generateMessageId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Method to stop the queue when session expires
  void stopSessionQueue() {
    _isSessionExpired = true;
    _cancelTurnTimer();
  }

  void dispose() {
    _cancelTurnTimer();
    _queueStateController.close();
  }
}